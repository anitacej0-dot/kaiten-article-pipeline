# Vale-правила Kaiten (styles/Kaiten/)

Редполитика как код. Каждый `.yml` — одно правило, проверяет текст автоматически до
редактора. Источник правил — `knowledge/forbidden_phrases.md` и `knowledge/editorial_policy.md`.

## Уровни (level) = наша модель HARD/SOFT
- `error` → **HARD**: блокирует сдачу редактору (грубое нарушение редполитики/позиционирования).
- `warning` / `suggestion` → **SOFT**: предупреждение, решает автор/редактор.

## Правила
| Файл | Тип | Уровень | Что ловит |
| --- | --- | --- | --- |
| Lexicon.yml | substitution | error (HARD) | функционал→функциональность, «для того чтобы»→чтобы |
| Positioning.yml | existence | error (HARD) | «Kaiten — трекер задач», «бесплатный таск-трекер» |
| AgileTerms.yml | substitution | error (HARD) | Эджайл→Agile, Scrum-метод→Scrum-фреймворк |
| Anglicisms.yml | substitution | warning | таск, фича, колл, аттач |
| Bureaucratese.yml | substitution | warning | канцелярит: в целях, осуществлять, являться |
| Cliches.yml | existence | warning | журналистские штампы |
| Intensifiers.yml | existence | suggestion | самый/наиболее/лучший без факта |
| SentenceLength.yml | metric | warning | среднее предложение > 15 слов |
| NoYo.yml | existence | error (HARD) | буква «ё» — не используем нигде |

## Важно про русский
Регулярочные проверки (existence, substitution, occurrence, metric) **языконезависимы** —
для русского работают сразу. Орфографию оставляем Орфограммке (см. research/04).
Vale использует Go-regexp (RE2): **нет lookahead/lookbehind** — поэтому формы слов
перечислены явно.

## Запуск
1. Установить Vale (https://vale.sh/docs/install).
2. Из корня репозитория: `vale articles/<папка>/04_draft.md`.
