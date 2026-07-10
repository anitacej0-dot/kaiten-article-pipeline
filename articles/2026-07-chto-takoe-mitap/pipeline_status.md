# Pipeline status — Что такое митапы

> Копия `templates/pipeline_status_template.md`. Обновляй на каждом этапе.
> Статус: `не начато` / `в работе` / `на проверке` / `готово` / `возврат`.
> Решение: `approved` / `needs_revision` / `blocked` / `—`.

| Этап | Файл | Статус | Кто проверяет | Решение | Комментарий |
| --- | --- | --- | --- | --- | --- |
| Intake | `00_intake.md` | готово | редактор | — | SEO-вводные полные |
| Brief | `01_brief.md` | готово | — | approved | v2 после доработки |
| 🛑 Brief review (STOP 1) | `01_brief_review.md` | готово | редактор | approved (92/100) | **STOP 1: ждём «да» редактора на переход к research** |
| Research | `02_research.md` | готово | редактор | — | факты/URL/конкуренты проверены; факт 11.09 — решено не включать; на обсуждении у редактора |
| 🛑 Outline (STOP 2) | `03_outline.md` | готово | редактор | approved | STOP 2 пройден |
| 🛑 Draft (STOP 3) | `04_draft.md` | готово | редактор | approved | STOP 3 пройден; ~9 750 знаков, SOFT-правки внесены |
| Editorial review | `05_editorial_review.md` | готово | редактор | — | Vale HARD: 0; SOFT-замечания (follow-up ×6 и др.) |
| 🛑 Article score (STOP 4) | `06_article_score.md` | готово | ai-pre-review + редактор | approved (94/100) | STOP 4 пройден → publication pack |
| Revision task | `07_revision_task.md` | пропущен | — | — | не нужен: score 94 ≥ 90 (только SOFT-правки в 04) |
| Revised draft | `08_revised_draft.md` | пропущен | — | — | не нужен (SOFT-правки внесены в 04_draft) |
| Rescore | `09_rescore.md` | пропущен | — | — | не нужен (не было revision-цикла) |
| Publication pack | `10_publication_pack.md` | готово | редактор | — | мета/анонс/перелинковка/визуал-рекомендации; ждёт Тургенев+text.ru |
| Visual brief | `11_visual_brief.md` | готово | редактор | — | обложка + схема-чеклист + скриншот Кайтен Встречи; по дизайн-системе |
| 🛑 Visual assets (STOP 5) | `12_visual_assets.md` | готово | редактор | — | обложка+схема — SVG готовы; скриншот Встреч — реальный, ждём |
| Image queue | `13_image_generation_queue.md` | готово | редактор | approved (генерация) | обложка `assets/cover.svg` + схема `assets/mitap-flow.svg` готовы; скриншот — на стороне продукта |
