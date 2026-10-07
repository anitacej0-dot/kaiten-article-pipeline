# Pipeline status — новость для Executive.ru: <тема>

> Живой статус по `workflows/executive_news_pipeline.md`. Этапы и имена файлов — те же, что
> у статей блога; визуальных этапов нет (новости на площадке выходят без картинок).
> Статус: `не начато` / `в работе` / `на проверке` / `готово` / `возврат` / `пропущен`.
> Решение (на stop-points): `approved` / `needs_revision` / `blocked` / `—`.

| Этап | Файл | Статус | Кто проверяет | Решение | Комментарий |
| --- | --- | --- | --- | --- | --- |
| Intake | `00_intake.md` | не начато | редактор | — | повод, источник, дата события |
| Brief | `01_brief.md` | не начато | executive-news | — | проверка повода, угол, структура |
| 🛑 Brief review (STOP 1) | `01_brief_review.md` | не начато | редактор | — | не писать новость без APPROVED |
| Research | `02_source_text.md`, `02_research.md` | не начато | executive-news | — | каждый факт с опорой |
| 🛑 Outline (STOP 2) | `03_outline.md` | не начато | редактор | — | заголовок, анонс, план абзацев |
| 🛑 Draft (STOP 3) | `04_draft.md` | не начато | редактор | — | не реклама, третье лицо, связность |
| Editorial review | `05_editorial_review.md` | не начато | ai-pre-review | — | механика + факты + замечания |
| 🛑 Article score (STOP 4) | `06_article_score.md` | не начато | ai-pre-review + редактор | — | <90 → revision; 90+ → пакет |
| Revision task | `07_revision_task.md` | не начато | редактор | — | |
| Revised draft | `08_revised_draft.md` | не начато | executive-news | — | точечные правки |
| Rescore | `09_rescore.md` | не начато | ai-pre-review | — | <90 → снова revision |
| Publication pack | `10_publication_pack.md` | не начато | executive-news | — | только после 90+; отправляет человек |
| Публикация и примеры | `10_publication_pack.md` | не начато | редактор | — | ссылка, журнал, текст в examples/ |

## Заметки по ходу

<Что решили, что уточняли, что вернули на доработку.>
