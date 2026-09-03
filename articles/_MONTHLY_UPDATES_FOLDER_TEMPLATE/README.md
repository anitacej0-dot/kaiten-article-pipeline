# Шаблон папки: обзор обновлений за месяц

Заготовка для статьи типа `monthly_product_updates`. Полный цикл —
[`workflows/monthly_updates_pipeline.md`](../../workflows/monthly_updates_pipeline.md).
Редакционные правила формата — [`knowledge/monthly_updates_style_guide.md`](../../knowledge/monthly_updates_style_guide.md).

Это **не SEO-статья**: брифа, ресерча и скоринга здесь нет. Источник фактуры один —
внутренний PDF с релизами за месяц.

## Как создать новую статью

1. **Скопируй эту папку** в `articles/YYYY-MM-obnovleniya-<месяц>/`
   (например, `articles/2026-08-obnovleniya-avgusta/`).
2. **Заполни `00_intake.md`:** путь к PDF, месяц, год, комментарии редактора.
3. **Прогони PDF:**
   ```bash
   python tools/pdf_extract.py --pdf "<путь к PDF>" --out "articles/<папка>" --render-pages
   ```
4. **Запусти `monthly-updates-source`** → `02_source_facts.md` (реестр обновлений).
5. **Запусти `monthly-updates-writer`** → `03_outline.md`.
   **🛑 STOP 1:** редактор утверждает H1, deck и деление на крупные/мелкие обновления.
6. **Черновик** → `04_draft.md`. **🛑 STOP 2:** редактор смотрит текст.
7. **Вычитка** (`ai-pre-review`) → `05_editorial_review.md`, правки вносятся в черновик.
8. **Манифест изображений** → `06_image_manifest.md`.
9. **Запусти `monthly-updates-qa`** → `07_qa_report.md`.
   **🛑 STOP 3:** `Unsupported claims` больше нуля или потерянные обновления → возврат.
10. **Упаковка** (`package-for-cms`) → `08_publication_pack.md`.

## Что в папке
- `00_intake.md` — вводные редактора (заполнить).
- `pipeline_status.md` — живой статус по этапам (обновлять).

Остальное создается по ходу: `01_source_text.md`, `02_source_facts.md`, `03_outline.md`,
`04_draft.md`, `05_editorial_review.md`, `06_image_manifest.md`, `07_qa_report.md`,
`08_publication_pack.md`, `assets/images/`.

## Чего здесь нельзя

- Придумывать функции, ограничения, тарифы, цифры, даты, ссылки и сценарии — источник
  истины только PDF. Не хватает данных — `[НУЖНО УТОЧНИТЬ: вопрос]`.
- Пересказывать PDF абзац за абзацем: материал пересобирается редакционно.
- Дорисовывать интерфейс продукта. Нет скриншота — раздел выходит без картинки, а в
  манифесте появляется запрос скриншота.

> Папка `_MONTHLY_UPDATES_FOLDER_TEMPLATE` — только образец. Не веди в ней реальную
> статью, копируй под новый месяц.
