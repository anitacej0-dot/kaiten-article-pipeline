# Шаблон папки статьи

Заготовка для новой SEO-статьи. Полный цикл — [`workflows/seo_article_pipeline.md`](../../workflows/seo_article_pipeline.md).

## Как создать новую статью

1. **Скопируй эту папку** в `articles/YYYY-MM-slug/` (например, `articles/2026-08-chto-takoe-crm/`).
   Название — год-месяц-слаг темы латиницей.
2. **Заполни `00_intake.md`** по `templates/article_intake_template.md` (цель, ЦА, площадка, тип, SEO-вводные, ключи, конкуренты, продуктовая зона, ограничения, что нельзя).
3. **Запусти `brief-architect`** → `01_brief.md`, затем `brief-reviewer` → `01_brief_review.md`.
4. **🛑 STOP 1:** остановись после `01_brief_review.md` и жди решения редактора. Пиши статью только при `APPROVED`.
5. **Дальше двигайся по** `workflows/seo_article_pipeline.md`: research → outline (🛑 STOP 2) → draft (🛑 STOP 3) → editorial review → score (🛑 STOP 4).
6. **Publication pack** (`10_`) создаётся **только после rescore 90+**.
7. **Visual brief и image queue** (`11_`–`13_`) — **только после publication pack** (🛑 STOP 5).
8. **Картинки** генерируются только из `13_image_generation_queue.md` и **только по отдельной команде редактора**.

## Что в папке
- `00_intake.md` — входная карточка (заполнить).
- `pipeline_status.md` — живой статус по этапам (обновлять).

Остальные артефакты (`01_…`–`13_…`) создаются по ходу пайплайна соответствующими навыками.

> Папка `_ARTICLE_FOLDER_TEMPLATE` — только образец. Не веди в ней реальную статью, копируй под новую.
