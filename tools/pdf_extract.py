#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
pdf_extract.py — разбор исходного PDF с фактурой об обновлениях Кайтена.

Используется навыком `monthly-updates-source` (этап 01 конвейера
`workflows/monthly_updates_pipeline.md`). Скрипт ничего не придумывает и не
интерпретирует: он только вытаскивает из PDF текст и картинки и складывает
рядом технический отчёт. Смысловая работа — какое изображение к какому
обновлению относится, семантическое имя файла, подпись — за навыком.

Что делает:
  1. текст по страницам → `01_source_text.md`;
  2. встроенные растровые картинки → `assets/images/raw/pNN_imgMM.png|jpg`;
  3. рендер страниц целиком (по флагу `--render-pages`) → `assets/images/pages/`;
  4. технический отчёт → `assets/images/extract_report.json` и `.md`.

Три вещи, которые скрипт отдельно помечает:
  * **служебные картинки** (логотипы, иконки, разделители, повторы на страницах)
    — `service: true`, в статью не идут;
  * **битые картинки** — в исходном документе изображение не загрузилось, и в
    PDF попала иконка-заглушка. Для каждой такой заглушки в отчёт пишется
    заголовок, под которым она стоит: значит, у этого обновления скриншота нет
    и его нужно запрашивать отдельно;
  * **мусорные токены** — «съехавший» alt-текст непрогрузившихся картинок
    (`тваеымфВдйлпнвораесте` и подобное). В фактуру их брать нельзя.

Запуск:
    python tools/pdf_extract.py --pdf "путь/к/updates.pdf" \
        --out "articles/2026-08-obnovleniya-avgust" [--render-pages] [--dpi 200]

Требуется PyMuPDF:
    python -m pip install pymupdf
"""

from __future__ import annotations

import argparse
import difflib
import hashlib
import json
import re
import sys
from pathlib import Path

try:
    import pymupdf  # PyMuPDF >= 1.24
except ImportError:  # pragma: no cover — старое имя пакета
    try:
        import fitz as pymupdf  # type: ignore
    except ImportError:
        sys.exit("Нужен PyMuPDF. Установите: python -m pip install pymupdf")

# Картинка меньше этих порогов почти наверняка иконка/буллет/разделитель.
MIN_WIDTH = 220
MIN_HEIGHT = 120
MIN_AREA = 60_000
# Узкая полоска (линия, разделитель) — тоже не иллюстрация.
MAX_ASPECT = 12.0
# Иконка-заглушка вместо непрогрузившейся картинки.
PLACEHOLDER_MAX_SIDE = 48

# Кириллическое «слово» с заглавной буквой в середине — почти наверняка
# перемешанный alt-текст непрогрузившейся картинки.
NOISE_RE = re.compile(r"\b[а-яё]{6,}[А-ЯЁ][а-яё:]{4,}\b")


def _norm(text: str) -> str:
    return " ".join(text.split())


def page_blocks(page) -> list[dict]:
    """Текстовые блоки страницы с координатами, сверху вниз."""
    blocks = []
    for b in page.get_text("blocks"):
        text = _norm(b[4])
        if text:
            blocks.append({"y0": b[1], "y1": b[3], "x0": b[0], "x1": b[2], "text": text})
    blocks.sort(key=lambda b: (b["y0"], b["x0"]))
    return blocks


def context_above(blocks: list[dict], top: float, limit: int = 2) -> list[str]:
    """Ближайшие текстовые блоки над картинкой — кандидаты в заголовок раздела."""
    above = [b for b in blocks if b["y1"] <= top + 4]
    return [b["text"][:200] for b in above[-limit:]]


def context_below(blocks: list[dict], bottom: float, limit: int = 1) -> list[str]:
    below = [b for b in blocks if b["y0"] >= bottom - 4]
    return [b["text"][:200] for b in below[:limit]]


def echo_blocks(blocks: list[dict]) -> list[str]:
    """Блоки-эхо: alt-текст непрогрузившейся картинки дублирует заголовок над ней.

    Такие строки — не фактура, а подпись к пропавшему скриншоту. В статью не идут.
    """
    def key(text: str) -> str:
        return re.sub(r"[^а-яёa-z0-9]", "", text.lower())

    def close(a: str, b: str) -> bool:
        return difflib.SequenceMatcher(None, a, b).ratio() >= 0.85

    echoes = []
    # Заголовок и его эхо часто склеиваются в один блок — ищем удвоение внутри блока.
    for block in blocks:
        s = key(block["text"])
        half = len(s) // 2
        if half >= 12 and close(s[:half], s[half:]):
            echoes.append(block["text"][:160])
    # Чаще эхо приклеивается к началу следующего блока: «Заголовок Заголовок Текст…».
    for prev, cur in zip(blocks, blocks[1:]):
        a, b = key(prev["text"]), key(cur["text"])
        if len(a) < 12 or len(b) < 12:
            continue
        if close(a, b) or close(a, b[: len(a)]):
            echoes.append(prev["text"][:160])
    return echoes


def extract(pdf_path: Path, out_dir: Path, render_pages: bool, dpi: int) -> dict:
    doc = pymupdf.open(pdf_path)

    images_dir = out_dir / "assets" / "images"
    raw_dir = images_dir / "raw"
    raw_dir.mkdir(parents=True, exist_ok=True)

    text_parts: list[str] = [
        f"# Исходный текст PDF: {pdf_path.name}",
        "",
        "> Машинная выгрузка `tools/pdf_extract.py`. Источник истины по фактуре.",
        "> Руками не правим — разбор и нормализация идут в `02_source_facts.md`.",
        "",
    ]
    records: list[dict] = []
    hash_pages: dict[str, set[int]] = {}
    noise_tokens: list[str] = []
    echoes: list[dict] = []

    for page_index in range(doc.page_count):
        page = doc[page_index]
        page_no = page_index + 1
        blocks = page_blocks(page)
        page_text = page.get_text("text").strip()

        for token in NOISE_RE.findall(page_text):
            if token not in noise_tokens:
                noise_tokens.append(token)
        for line in echo_blocks(blocks):
            echoes.append({"page": page_no, "text": line})

        text_parts += [f"## Страница {page_no}", "", page_text, ""]

        seen: set[int] = set()
        img_no = 0
        for info in page.get_images(full=True):
            xref = info[0]
            if xref in seen:
                continue
            seen.add(xref)

            try:
                raw = doc.extract_image(xref)
            except Exception as exc:  # повреждённый объект — в отчёт, но не в статью
                records.append(
                    {"page": page_no, "xref": xref, "service": True,
                     "error": f"не удалось извлечь: {exc}"}
                )
                continue

            width, height = raw.get("width", 0), raw.get("height", 0)
            digest = hashlib.sha1(raw["image"]).hexdigest()[:12]
            hash_pages.setdefault(digest, set()).add(page_no)

            aspect = max(width, height) / max(1, min(width, height))
            reasons = []
            if width < MIN_WIDTH or height < MIN_HEIGHT:
                reasons.append("маленький размер")
            if width * height < MIN_AREA:
                reasons.append("маленькая площадь")
            if aspect > MAX_ASPECT:
                reasons.append("полоска/разделитель")

            is_placeholder = max(width, height) <= PLACEHOLDER_MAX_SIDE

            img_no += 1
            name = f"p{page_no:02d}_img{img_no:02d}.{raw.get('ext', 'png')}"
            (raw_dir / name).write_bytes(raw["image"])

            placements = []
            for rect in page.get_image_rects(xref):
                placements.append(
                    {
                        "bbox": [round(v, 1) for v in (rect.x0, rect.y0, rect.x1, rect.y1)],
                        "context_above": context_above(blocks, rect.y0),
                        "context_below": context_below(blocks, rect.y1),
                    }
                )

            records.append(
                {
                    "page": page_no,
                    "index": img_no,
                    "xref": xref,
                    "file": f"assets/images/raw/{name}",
                    "width": width,
                    "height": height,
                    "hash": digest,
                    "placements_count": len(placements),
                    "placements": placements,
                    "placeholder": is_placeholder,
                    "service": bool(reasons),
                    "service_reasons": reasons,
                    "page_size": [round(page.rect.width, 1), round(page.rect.height, 1)],
                }
            )

        if render_pages:
            pages_dir = images_dir / "pages"
            pages_dir.mkdir(parents=True, exist_ok=True)
            page.get_pixmap(dpi=dpi).save(pages_dir / f"p{page_no:02d}_page.png")

    # Картинка, встречающаяся на половине страниц и больше, — шапка/логотип/футер.
    repeated = {h for h, pages in hash_pages.items() if len(pages) >= max(2, doc.page_count // 2)}
    for rec in records:
        if rec.get("hash") in repeated and not rec.get("service"):
            rec["service"] = True
            rec.setdefault("service_reasons", []).append("повторяется на страницах")

    # Заглушки непрогрузившихся картинок: где именно в документе не хватает скриншота.
    missing: list[dict] = []
    for rec in records:
        if not rec.get("placeholder"):
            continue
        for pl in rec.get("placements", []):
            missing.append(
                {
                    "page": rec["page"],
                    "heading_candidate": (pl["context_above"] or ["—"])[-1],
                    "context_below": (pl["context_below"] or [""])[0][:160],
                }
            )

    text_parts += [
        "---",
        "",
        "## Шум PDF (не брать в фактуру)",
        "",
        "> Alt-текст непрогрузившихся картинок и артефакты извлечения.",
        "> Это не факты об обновлениях, а подписи к пропавшим скриншотам.",
        "",
        "**Строки-эхо (дублируют заголовок над картинкой):**",
        "",
    ]
    text_parts += [f"- стр. {e['page']}: {e['text']}" for e in echoes] or ["- не найдено"]
    text_parts += ["", "**Мусорные токены и склейки:**", ""]
    text_parts += [f"- `{t}`" for t in noise_tokens] or ["- не найдено"]
    text_parts.append("")

    (out_dir / "01_source_text.md").write_text("\n".join(text_parts), encoding="utf-8")

    useful = [r for r in records if not r.get("service")]
    report = {
        "source_pdf": pdf_path.name,
        "pages": doc.page_count,
        "images_found": len(records),
        "images_useful": len(useful),
        "images_service": len(records) - len(useful),
        "broken_image_placeholders": len(missing),
        "noise_tokens": noise_tokens,
        "echo_lines": echoes,
        "missing_images": missing,
        "records": records,
    }
    (images_dir / "extract_report.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8"
    )

    md = [
        f"# Отчёт извлечения изображений — {pdf_path.name}",
        "",
        f"- Страниц: **{doc.page_count}**",
        f"- Картинок найдено: **{len(records)}**",
        f"- Похожи на иллюстрации: **{len(useful)}**",
        f"- Отсеяно как служебные: **{len(records) - len(useful)}**",
        f"- Заглушек непрогрузившихся картинок: **{len(missing)}**",
        "",
        "> Служебные картинки в статью не идут. Семантические имена и подписи",
        "> назначает навык при сборке `06_image_manifest.md`.",
        "",
        "## Извлечённые картинки",
        "",
        "| Файл | Стр. | Размер | Служебная | Текст над картинкой |",
        "| --- | --- | --- | --- | --- |",
    ]
    for r in records:
        if "error" in r:
            md.append(f"| — | {r['page']} | — | ошибка | {r['error']} |")
            continue
        above = " / ".join(r["placements"][0]["context_above"]) if r["placements"] else ""
        above = above[:120].replace("|", "\\|")
        flag = "да (" + ", ".join(r["service_reasons"]) + ")" if r["service"] else "нет"
        md.append(
            f"| `{Path(r['file']).name}` | {r['page']} | {r['width']}×{r['height']} | {flag} | {above} |"
        )

    md += ["", "## Где в исходнике картинка не загрузилась", ""]
    if missing:
        md += [
            "> У этих обновлений в PDF стоит иконка-заглушка вместо скриншота.",
            "> Скриншот нужно запросить у продуктовой команды — рисовать интерфейс нельзя.",
            "",
            "| Стр. | Заголовок над заглушкой |",
            "| --- | --- |",
        ]
        for m in missing:
            md.append(f"| {m['page']} | {m['heading_candidate'][:140].replace('|', chr(92) + '|')} |")
    else:
        md.append("Заглушек не найдено — все картинки в исходнике на месте.")

    md += ["", "## Шум PDF (в фактуру не берём)", ""]
    md += ["**Строки-эхо** — alt-текст пропавшей картинки, дублирует заголовок:", ""]
    md += [f"- стр. {e['page']}: {e['text']}" for e in echoes] or ["- не найдено"]
    md += ["", "**Мусорные токены и склейки:**", ""]
    md += [f"- `{t}`" for t in noise_tokens] or ["- не найдено"]

    (images_dir / "extract_report.md").write_text("\n".join(md) + "\n", encoding="utf-8")

    doc.close()
    return report


def main() -> None:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    parser = argparse.ArgumentParser(description="Разбор PDF с обновлениями Кайтена")
    parser.add_argument("--pdf", required=True, help="путь к исходному PDF")
    parser.add_argument("--out", required=True, help="папка статьи, например articles/2026-08-…")
    parser.add_argument("--render-pages", action="store_true", help="отрендерить страницы целиком")
    parser.add_argument("--dpi", type=int, default=200, help="DPI рендера страниц (по умолчанию 200)")
    args = parser.parse_args()

    pdf_path = Path(args.pdf)
    if not pdf_path.exists():
        sys.exit(f"Не найден PDF: {pdf_path}")
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    r = extract(pdf_path, out_dir, args.render_pages, args.dpi)
    print(f"Страниц: {r['pages']}")
    print(
        f"Картинок: {r['images_found']} "
        f"(иллюстраций {r['images_useful']}, служебных {r['images_service']}, "
        f"заглушек {r['broken_image_placeholders']})"
    )
    print(f"Текст:  {out_dir / '01_source_text.md'}")
    print(f"Отчёт:  {out_dir / 'assets' / 'images' / 'extract_report.md'}")


if __name__ == "__main__":
    main()
