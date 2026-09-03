# Pipeline status — обзор обновлений за <месяц> <год>

> Живой статус прохождения по `workflows/monthly_updates_pipeline.md`.
> Статус: `не начато` / `в работе` / `на проверке` / `готово` / `возврат`.
> Решение (на stop-points): `approved` / `needs_revision` / `blocked` / `—`.

| Этап | Файл | Статус | Кто проверяет | Решение | Комментарий |
| --- | --- | --- | --- | --- | --- |
| Intake | `00_intake.md` | не начато | редактор | — | PDF, месяц, год |
| Разбор PDF | `01_source_text.md` | не начато | — | — | машинная выгрузка, руками не править |
| Реестр обновлений | `02_source_facts.md` | не начато | — | — | полный список + major/minor |
| 🛑 Структура (STOP 1) | `03_outline.md` | не начато | редактор | — | H1, deck, деление обновлений |
| 🛑 Черновик (STOP 2) | `04_draft.md` | не начато | редактор | — | не release notes, без отсебятины |
| Вычитка | `05_editorial_review.md` | не начато | ai-pre-review | — | редполитика + Vale |
| Манифест изображений | `06_image_manifest.md` | не начато | редактор | — | смысловые имена, кропы |
| 🛑 QA (STOP 3) | `07_qa_report.md` | не начато | monthly-updates-qa + редактор | — | unsupported claims = 0 |
| Публикационный пакет | `08_publication_pack.md` | не начато | package-for-cms | — | только после PASS |
