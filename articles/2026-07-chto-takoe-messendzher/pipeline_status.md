# Pipeline status — Что такое мессенджер простыми словами

> Копия `templates/pipeline_status_template.md`. Обновляй на каждом этапе.
> Статус: `не начато` / `в работе` / `на проверке` / `готово` / `возврат`.
> Решение: `approved` / `needs_revision` / `blocked` / `—`.

| Этап | Файл | Статус | Кто проверяет | Решение | Комментарий |
| --- | --- | --- | --- | --- | --- |
| Intake | `00_intake.md` | готово | редактор | — | SEO-вводные полные; вопросов-блокеров нет |
| Brief | `01_brief.md` | готово | — | approved | v2 после доработки (структура + честный продуктовый блок) |
| 🛑 Brief review (STOP 1) | `01_brief_review.md` | готово | редактор | approved (93/100) | STOP 1 пройден — редактор дал «да» на research |
| Research | `02_research.md` | готово | редактор | — | цифры/годы подтверждены источниками; факты Кайтена по офсайту; URL живые; конкуренты разобраны; ⚠️ русский регуляторный контекст — рекомендуем вне политики |
| 🛑 Outline (STOP 2) | `03_outline.md` | готово | редактор | approved | STOP 2 пройден; русский контекст — вне политики |
| 🛑 Draft (STOP 3) | `04_draft.md` | готово | редактор | approved | STOP 3 пройден; +2 новых H2 (SMS, мифы) согласованы |
| Editorial review | `05_editorial_review.md` | готово | редактор | — | Vale HARD: 0; SOFT: плотность «мессендж» 59× (Тургенев/text.ru перед публикацией) |
| 🛑 Article score (STOP 4) | `06_article_score.md` | готово | ai-pre-review + редактор | approved (94/100) | **STOP 4 пройден → publication pack**; ждём «да» редактора |
| Revision task | `07_revision_task.md` | пропущен | — | — | не нужен: score 94 ≥ 90 (только SOFT-правки в 04) |
| Revised draft | `08_revised_draft.md` | пропущен | — | — | не нужен (SOFT-правки внесены в 04_draft) |
| Rescore | `09_rescore.md` | пропущен | — | — | не нужен (не было revision-цикла) |
| Publication pack | `10_publication_pack.md` | не начато | package-for-cms | — | создаём после «да» редактора (STOP 4 пройден) |
| Visual brief | `11_visual_brief.md` | не начато | visual-producer | — | только после publication pack |
| 🛑 Visual assets (STOP 5) | `12_visual_assets.md` | не начато | редактор | — | не генерировать всё подряд |
| Image queue | `13_image_generation_queue.md` | не начато | редактор | — | генерация только по команде |
