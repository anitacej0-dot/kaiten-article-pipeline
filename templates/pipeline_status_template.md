# Pipeline status — <название статьи>

> Живой статус прохождения статьи по `workflows/seo_article_pipeline.md`.
> Обновляется на каждом этапе. Статус: `не начато` / `в работе` / `на проверке` / `готово` / `возврат`.
> Решение (на stop-points): `approved` / `needs_revision` / `blocked` / `—`.

| Этап | Файл | Статус | Кто проверяет | Решение | Комментарий |
| --- | --- | --- | --- | --- | --- |
| Intake | `00_intake.md` | не начато | редактор | — | |
| Brief | `01_brief.md` | не начато | — | — | |
| 🛑 Brief review (STOP 1) | `01_brief_review.md` | не начато | редактор | — | не писать статью без APPROVED |
| Research | `02_research.md` | не начато | — | — | |
| 🛑 Outline (STOP 2) | `03_outline.md` | не начато | редактор | — | не писать черновик без одобрения |
| 🛑 Draft (STOP 3) | `04_draft.md` | не начато | редактор | — | проверить на ИИ-шность/воду/типовость |
| Editorial review | `05_editorial_review.md` | не начато | редактор | — | |
| 🛑 Article score (STOP 4) | `06_article_score.md` | не начато | ai-pre-review + редактор | — | <90 → revision; 90+ → publication |
| Revision task | `07_revision_task.md` | не начато | редактор | — | |
| Revised draft | `08_revised_draft.md` | не начато | автор | — | точечные правки, не переписывать |
| Rescore | `09_rescore.md` | не начато | ai-pre-review | — | <90 → снова revision |
| Publication pack | `10_publication_pack.md` | не начато | package-for-cms | — | только после 90+ |
| Visual brief | `11_visual_brief.md` | не начато | visual-producer | — | только после publication pack |
| 🛑 Visual assets (STOP 5) | `12_visual_assets.md` | не начато | редактор | — | не генерировать всё подряд |
| Image queue | `13_image_generation_queue.md` | не начато | редактор | — | генерация только по команде |
