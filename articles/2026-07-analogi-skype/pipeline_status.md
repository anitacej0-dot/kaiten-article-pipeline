# Pipeline status — Аналоги Skype в России для компьютера

> Копия `templates/pipeline_status_template.md`. Обновляй на каждом этапе.
> Статус: `не начато` / `в работе` / `на проверке` / `готово` / `возврат`.
> Решение: `approved` / `needs_revision` / `blocked` / `—`.

| Этап | Файл | Статус | Кто проверяет | Решение | Комментарий |
| --- | --- | --- | --- | --- | --- |
| Intake | `00_intake.md` | готово | редактор | — | подборка, 11 сервисов, блог Kaiten |
| Brief | `01_brief.md` | готово | brief-reviewer | — | угол «роль, а не сервис»; Kaiten = Встречи (бета) |
| 🛑 Brief review (STOP 1) | `01_brief_review.md` | готово | редактор | approved (92/100) | редактор одобрил, идём в research |
| Research | `02_research.md` | готово | — | — | факты с офсайтов на 2026-07-21; закрытие Skype подтверждено; десктоп/бесплатно по 11 сервисам |
| 🛑 Outline (STOP 2) | `03_outline.md` | готово | редактор | approved | редактор одобрил; FAQ не добавляем |
| 🛑 Draft (STOP 3) | `04_draft.md` | ревизия 2 | редактор | — | text.ru 51.59% и заспам 63% → переписано под уникальность/заспам; ждём повторный прогон |
| Editorial review | `05_editorial_review.md` | готово | ai-pre-review | — | Vale-эквивалент 0 error; открытый вопрос — бренд; уникальность на повторной проверке |
| 🛑 Article score (STOP 4) | `06_article_score.md` | пересчёт после text.ru | ai-pre-review + редактор | 93/100* | *до провала уникальности; пересверить после повторного text.ru |
| Revision task | `07_revision_task.md` | не начато | редактор | — | |
| Revised draft | `08_revised_draft.md` | не начато | автор | — | точечные правки |
| Rescore | `09_rescore.md` | не начато | ai-pre-review | — | <90 → снова revision |
| Publication pack | `10_publication_pack.md` | готово | package-for-cms | — | мета-теги из ТЗ (68/139/108), CTA, 15 ссылок, visual-рекомендации, чек-лист |
| Visual brief | `11_visual_brief.md` | не начато | visual-producer | — | только после publication pack |
| 🛑 Visual assets (STOP 5) | `12_visual_assets.md` | не начато | редактор | — | не генерировать всё подряд |
| Image queue | `13_image_generation_queue.md` | не начато | редактор | — | генерация только по команде |
