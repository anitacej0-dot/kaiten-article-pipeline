# kaiten-article-pipeline

Редакционный конвейер статей Kaiten для Claude Code. AI делает черновую часть, редактор
отвечает за качество. Как работать в репозитории — [CLAUDE.md](CLAUDE.md),
чертёж пилота — [MVP_SPEC.md](MVP_SPEC.md).

## Три конвейера

| Тип статьи | Когда | Документ |
| --- | --- | --- |
| SEO-статья (MVP) | тема из контент-плана, есть интент и ключи | [`workflows/seo_article_pipeline.md`](workflows/seo_article_pipeline.md) |
| `monthly_product_updates` | ежемесячный обзор обновлений Кайтена по внутреннему PDF | [`workflows/monthly_updates_pipeline.md`](workflows/monthly_updates_pipeline.md) |
| `case_rewrite` | кейс клиента вышел на сторонней площадке, дублируем рерайтом в блог | [`workflows/case_rewrite_pipeline.md`](workflows/case_rewrite_pipeline.md) |

## Быстрый старт

**SEO-статья:** скопировать `articles/_ARTICLE_FOLDER_TEMPLATE/` в `articles/YYYY-MM-slug/`,
заполнить `00_intake.md`, запустить `brief-architect` и остановиться на ревью брифа.

**Обзор обновлений:** скопировать `articles/_MONTHLY_UPDATES_FOLDER_TEMPLATE/` в
`articles/YYYY-MM-obnovleniya-<месяц>/`, заполнить `00_intake.md`, разобрать PDF:

```bash
python tools/pdf_extract.py --pdf "Обновления август _ Kaiten.pdf" --out "articles/2026-08-obnovleniya-avgusta" --render-pages
```

Дальше — навыки `monthly-updates-source` → `monthly-updates-writer` → `monthly-updates-qa`
со стоп-точками для редактора. Пример полного прохода —
[`articles/2026-08-obnovleniya-avgusta/`](articles/2026-08-obnovleniya-avgusta/).

Скрипту нужен PyMuPDF: `python -m pip install pymupdf`.

**Кейс-рерайт:** скопировать `articles/_CASE_FOLDER_TEMPLATE/` в
`articles/YYYY-MM-case-<компания>/`, заполнить `00_intake.md`, выгрузить исходную
публикацию дословно в `01_source_text.md`. Дальше — навыки `case-source` →
`case-rewriter` → `case-qa` → `case-package` со стоп-точками для редактора.

Самопроверка уникальности до прогона в text.ru:

```bash
perl tools/shingle_check.pl articles/<папка>/03_draft.md articles/<папка>/01_source_text.md
```

## Структура

- `knowledge/` — база знаний: редполитика, продукт, ICP, SEO, чёрный список, паттерны статей.
- `templates/` — шаблоны артефактов каждого этапа.
- `skills/` — навыки по этапам обоих конвейеров.
- `.claude/skills/` — навыки визуального этапа (дизайн-система, visual producer).
- `workflows/` — сквозные конвейеры по типам статей.
- `tools/` — вспомогательные скрипты.
- `styles/Kaiten/` — Vale-правила (редполитика как код).
- `articles/` — рабочие папки статей.
- `research/` — исследования, на которых собран конвейер.
