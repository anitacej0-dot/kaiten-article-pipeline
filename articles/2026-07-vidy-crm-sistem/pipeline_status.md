# Pipeline status — Виды и типы CRM-систем

> Живой статус прохождения статьи по `workflows/seo_article_pipeline.md`.
> Статус: `не начато` / `в работе` / `на проверке` / `готово` / `возврат`.
> Решение (на stop-points): `approved` / `needs_revision` / `blocked` / `—`.

| Этап | Файл | Статус | Кто проверяет | Решение | Комментарий |
| --- | --- | --- | --- | --- | --- |
| Intake | `00_intake.md` | готово | редактор | — | SEO-вводные полные |
| Brief | `01_brief.md` | готово | — | — | brief-architect |
| 🛑 Brief review (STOP 1) | `01_brief_review.md` | готово | редактор | **approved** | 93/100, угол сильный |
| Research | `02_research.md` | готово | — | — | канон + примеры + история + границы Kaiten |
| 🛑 Outline (STOP 2) | `03_outline.md` | готово | редактор | **approved** | 10 H2, ключи распределены, 4 живые ссылки |
| 🛑 Draft (STOP 3) | `04_draft.md` | готово | редактор | — | черновик по outline |
| Editorial review | `05_editorial_review.md` | готово | редактор | — | 1 HARD (нейрослоп) |
| 🛑 Article score (STOP 4) | `06_article_score.md` | готово | ai-pre-review + редактор | **needs_revision** | 84/100 → revision |
| Revision task | `07_revision_task.md` | готово | редактор | — | точечное ТЗ |
| Revised draft | `08_revised_draft.md` | готово | автор | — | HARD+SOFT закрыты — **финальный текст** |
| Rescore | `09_rescore.md` | готово | ai-pre-review | **approved** | 93/100 → publication |
| Publication pack | `10_publication_pack.md` | готово | package-for-cms | — | Title/Desc/slug/ссылки/чек-лист |
| Visual brief | `11_visual_brief.md` | готово | visual-producer | — | что визуализируем и что нет |
| 🛑 Visual assets (STOP 5) | `12_visual_assets.md` | готово | редактор | — | 1 схема готова (`crm-types.svg`), остальное в очередь |
| Image queue | `13_image_generation_queue.md` | готово | редактор | **ждет команды** | генерация обложки/мема — только по команде |

## Открытые пункты до публикации (не блокеры пайплайна)
- Фактчекинг: 1С:CRM (домен/вендор), отрасль RetailCRM — по офсайтам.
- Финальные SEO-гейты при вычитке: Тургенев (Баден-Баден), text.ru (уникальность ≥90%, заспамленность в зеленой зоне), Орфограммка.
- Визуалы: отрисовать 2 схемы (D1, D2), обложку и мем/скриншот — по команде редактора (STOP 5).
- Объем чистого текста ~15 900 знаков («около 15 000»); при желании поджать — по решению редактора.
