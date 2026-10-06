# Шаблон папки новости для Executive.ru

Заготовка для новой новости Кайтена в разделе «Новости компаний» на Executive.ru. Путь тот
же, что у статьи блога: те же этапы, те же имена файлов, те же стоп-точки. Полный цикл —
[`workflows/executive_news_pipeline.md`](../../../workflows/executive_news_pipeline.md),
навык — [`executive-news`](../../../skills/executive-news/SKILL.md), правила площадки —
[`platform_rules.md`](../platform_rules.md), примеры — [`examples.md`](../examples.md).

## Как создать новость

1. **Скопируй эту папку** в `external_platforms/e-xecutive/news/YYYY-MM-тема/`
   (например, `news/2026-10-issledovanie-pereryvy/`).
2. **Заполни `00_intake.md`:** повод, источник, дата события, тип новости, спикер.
3. **Запусти `executive-news`** → `01_brief.md` (с проверкой повода по правилам площадки) и
   `01_brief_review.md`.
4. **🛑 STOP 1:** остановись после `01_brief_review.md` и жди решения редактора. Новость
   пишется только при `APPROVED`.
5. **Дальше по** `workflows/executive_news_pipeline.md`: research → outline (🛑 STOP 2) →
   draft (🛑 STOP 3) → editorial review → score (🛑 STOP 4).
6. **Оценка ниже 90** → `07_revision_task` → `08_revised_draft` → `09_rescore`.
7. **Publication pack** (`10_`) — **только после оценки 90+**. Отправляет человек.
8. **После публикации** опубликованный текст — в `examples/`, строка — в `examples.md`.
   Так копим примеры.

Визуальных этапов (`11_`–`13_`) нет: новости компаний на площадке выходят без картинок.

## Что в папке

- `00_intake.md` — входная карточка (заполнить).
- `pipeline_status.md` — живой статус по этапам (обновлять).

Остальные артефакты создаются по ходу по шаблонам `templates/executive_news_*.md`.

## Проверка черновика

```bash
perl tools/news_check.pl external_platforms/e-xecutive/news/<папка>/04_draft.md
perl tools/vale_lite.pl external_platforms/e-xecutive/news/<папка>/04_draft.md --start '^## Заголовок' --end '^## Ссылка'
```

Первая команда проверяет правила площадки: длину заголовка и анонса, объем, ссылки, третье
лицо, открытые вопросы. Вторая — словарь редполитики.

> Папка `_NEWS_FOLDER_TEMPLATE` — только образец. Не веди в ней реальную новость, копируй под
> новую.
