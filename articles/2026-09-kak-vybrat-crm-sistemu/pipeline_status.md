# Pipeline status — Как выбрать CRM-систему

> Копия `templates/pipeline_status_template.md`. Обновляй на каждом этапе.
> Статус: `не начато` / `в работе` / `на проверке` / `готово` / `возврат`.
> Решение: `approved` / `needs_revision` / `blocked` / `—`.

| Этап | Файл | Статус | Кто проверяет | Решение | Комментарий |
| --- | --- | --- | --- | --- | --- |
| Intake | `00_intake.md` | готово | редактор | approved | по ТЗ SEO + 4 решения редактора от 2026-09-30 |
| Brief | `01_brief.md` | готово | brief-architect | — | угол «по маршруту сделки, а не по списку функций» |
| 🛑 Brief review (STOP 1) | `01_brief_review.md` | готово | редактор | approved (91/100) | редактор утвердил 2026-09-30; пример — вентиляция (по умолчанию); скриншоты CRM — запрос продукту |
| Research | `02_research.md` | готово | редактор | approved | 2026-10-01: тарифы в knowledge/ исправлены по kaiten.ru/tariffs; 1С:CRM — одной фразой |
| 🛑 Outline (STOP 2) | `03_outline.md` | готово | редактор | approved | 2026-10-01: лид — ситуация; без срока внедрения; чек-лист для скачивания — да; скриншоты — из кейса case-kaiten-crm |
| 🛑 Draft (STOP 3) | `04_draft.md` | готово | редактор | approved | 2026-10-05: редактор пропустил к вычитке |
| Editorial review | `05_editorial_review.md` | готово | ai-pre-review + независимый проверяющий | — | механика 0/0/0; 2 HIGH: шаблон «мало что…» ×6, сроки вопреки решению редактора |
| 🛑 Article score (STOP 4) | `06_article_score.md` | на проверке | ai-pre-review + редактор | needs_revision (82/100) | <90 → revision: 07 → 08 → 09 |
| Revision task | `07_revision_task.md` | не начато | редактор | — | |
| Revised draft | `08_revised_draft.md` | не начато | автор | — | точечные правки |
| Rescore | `09_rescore.md` | не начато | ai-pre-review | — | <90 → снова revision |
| Publication pack | `10_publication_pack.md` | не начато | package-for-cms | — | только после 90+ |
| Visual brief | `11_visual_brief.md` | не начато | visual-producer | — | только после publication pack |
| 🛑 Visual assets (STOP 5) | `12_visual_assets.md` | не начато | редактор | — | не генерировать всё подряд |
| Image queue | `13_image_generation_queue.md` | не начато | редактор | — | генерация только по команде |
