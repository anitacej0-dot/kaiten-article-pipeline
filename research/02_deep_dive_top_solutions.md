# Research 02: глубокий разбор топ-решений — что берём и как переносим

> Продолжение [01_content_pipelines.md](01_content_pipelines.md). Там — обзор и сравнение.
> Здесь — три самых близких нам решения, разобранные до структуры файлов, с конкретным
> планом переноса в наш репозиторий (`knowledge/`, `templates/`, будущие `skills/`).
>
> Дата: июнь 2026. Структура репозиториев сверена через GitHub API на эту дату.

---

## 1. SEOMachine — эталон организации Claude Code workspace

**Ссылка:** https://github.com/TheCraigHewitt/seomachine · MIT · ~7k ⭐

### Реальная структура репозитория

```
seomachine/
├── CLAUDE.md                  # корневая инструкция агенту
├── .claude/
│   ├── commands/   (24 шт.)   # slash-команды = этапы конвейера
│   ├── agents/                # специализированные агенты
│   └── skills/     (25 шт.)   # навыки по категориям
├── context/        (11 файлов)# = наш knowledge/
├── research/ drafts/ output/ published/ rewrites/  # артефакты по стадиям
├── data_sources/  config/  wordpress/
└── research_*.py   seo_*.py  # питон-модули для SEO-аналитики (DataForSEO)
```

### Что напрямую переносится

**А) Команды по этапам** (`.claude/commands/`). Реальные имена, релевантные нам:
`research.md`, `research-serp.md`, `research-gaps.md`, `research-topics.md`,
`research-trending.md`, `write.md`, `article.md`, `optimize.md`, `analyze-existing.md`,
`rewrite.md`, `scrub.md`, `publish-draft.md`, `cluster.md`, `content-calendar.md`.

→ **Берём идею «одна команда = один этап».** Наш будущий набор: `/intake`, `/brief`,
`/research`, `/outline`, `/ai-review`, `/cms-package`. Команда `scrub` («очеловечить
текст») — прямой аналог нашей AI-предредактуры против нейрослопа.

**Б) `context/` ≈ наш `knowledge/`** — совпадение почти один-в-один, подтверждает нашу раскладку:

| SEOMachine `context/` | Наш `knowledge/` |
| --- | --- |
| brand-voice.md, style-guide.md | editorial_policy.md |
| seo-guidelines.md | seo_policy.md |
| features.md | products.md |
| writing-examples.md | good_examples.md |
| competitor-analysis.md | (в products.md / отдельный файл) |
| target-keywords.md, internal-links-map.md | (добавить — у нас пока нет) |
| ai-citation-targets.md | (новое: цели цитирования для GEO/нейросетей) |
| cro-best-practices.md, reddit-strategy.md | — (не наш кейс) |

→ **Что добавить себе:** `target-keywords.md` (ключи по кластерам тем) и
`internal-links-map.md` (карта внутренней перелинковки) — у нас этих файлов нет, а
SEO-политика на них опирается. `ai-citation-targets.md` — интересная идея под наш пункт
«структура под нейросети».

**В) Числовые пороги и scoring.** SEOMachine задаёт конкретные правила: ≥2000 слов, ключ
в H1 и первых 100 словах, 3–5 внутренних ссылок, иерархия H1>H2>H3, уровень чтения
«8–10 класс», предложения 15–20 слов; агент `Editor` выдаёт **humanity score 0–100**,
`Content Analyzer` — health/SEO/readability score.

→ **Берём механику scoring** в наш `ai_review.md`: автоответ «готово к редактору / вернуть
автору» по числовому порогу, а не на глаз. Пороги адаптируем под нашу редполитику
(предложения ≤15 слов — у нас строже).

### Что НЕ берём / адаптируем
- 25 skills SEOMachine — почти все про CRO/маркетинг/paid-ads/popup (growth-направление). Нам нужны 5–6 контентных, остальное мимо.
- `research_*.py` на **DataForSEO** и публикация в **WordPress** — у нас Яндекс-выдача и Ghost. Питон-аналитику заменим (вспомним: на этой машине рабочего Python нет, см. memory). Скорее MCP/веб-инструменты.
- Английские readability-формулы (Flesch) не работают для русского — нужна русская метрика (см. раздел Vale).

---

## 2. Cody Article Writer — эталон оформления одного навыка (наш формат Skill)

**Ссылка:** https://github.com/ibuildwith-ai/cody-article-writer · ⚠️ кастомная лицензия
(бесплатное использование для создания контента, **редистрибуция кода запрещена** — берём
паттерны, а не файлы).

### Реальная структура

```
cody-article-writer/
├── cody-article-writer.skill        # упакованный навык (30 КБ)
└── source/cody-article-writer/
    ├── SKILL.md                     # инструкция навыка (главное)
    ├── references/                  # справочные материалы навыка
    └── assets/                      # шаблоны/ресурсы
```

→ Это **канонический формат Anthropic Agent Skills** (`SKILL.md` + `references/` +
`assets/`) — ровно тот, на котором строится наш стек. Каждый наш этап оформляем так же:
один навык = папка с `SKILL.md`, ссылающимся на `knowledge/` и `templates/`.

### Что берём (механики, не код)

- **10 фаз с явными gate'ами:** идея → план research → стиль → заголовок/тезис → структура → черновик с цитатами → **approval** → проход редактора → метаданные → экспорт. «Ничего не идёт дальше, пока не подтверждено» = наши quality gates.
- **Approved sources + required/optional.** Автор фиксирует источники и помечает обязательные/опциональные до написания. → встраиваем в наш `research_report.md`: источник не «использован», пока не утверждён; обязательные — должны быть отражены в тексте. Закрывает «непонятно, что смотрел автор».
- **Reusable style guides.** Стиль/тон как переиспользуемый объект на входе. → у нас это `editorial_policy.md`, навык подтягивает его автоматически.
- **Инлайн-цитаты с автобиблиографией** (`[^1]`), которые переживают редакторский проход. → полезно для экспертных статей и фактуры.

---

## 3. Vale — редполитика как код (главный инструмент против ручной редактуры)

**Ссылка:** https://github.com/vale-cli/vale · https://vale.sh · MIT.

### Как устроены правила (конкретно)

Правило — это `.yml`-файл в папке стиля. 11 типов проверок; нам нужны прежде всего:

| Тип | Для чего у нас |
| --- | --- |
| **substitution** | замена: «функционал» → «функциональность», англицизмы |
| **existence** | поймать запрещённое: штампы, ошибки позиционирования |
| **occurrence** | частота: злоупотребление усилителями |
| **metric** | читаемость по своей формуле (длина предложений) |
| **consistency** | единообразие (Kaiten vs Кайтен в одном тексте) |
| spelling / sequence | орфография и части речи — **нужны русские модели** |

**Уровни серьёзности** = ровно наша модель из лендингов:
- `error` → **HARD** (блокирует сдачу редактору)
- `warning` → **SOFT** (предупреждение)
- `suggestion` → инфо

### Русский язык — что важно
Проверки на регулярках (**existence, substitution, occurrence**) **языконезависимы** —
для русского чёрного списка и редполитики работают сразу, без доработок. Языковые модели
(spelling, sequence/части речи, английские readability-формулы) — НЕ для русского из
коробки; орфографию и «части речи» пришлось бы подключать отдельно (Hunspell ru, spaCy ru).
Vale Studio уже поддерживает русский для тегирования.

→ **Вывод:** 80% нашей редполитики (весь `forbidden_phrases.md`) ложится на Vale прямо
сейчас. Орфографию оставляем «Орфограммке»/«Главреду», как в текущем процессе.

### Реальные правила под нашу редполитику

Прямой перенос из [[forbidden_phrases]] (черновик — кладём в будущий `styles/Kaiten/`):

```yaml
# styles/Kaiten/Lexicon.yml — HARD: жёсткие лексические замены
extends: substitution
message: "Редполитика: '%s' → '%s'."
level: error
ignorecase: true
action: { name: replace }
swap:
  'функционал': функциональность
  'для того[,]?\s+чтобы': чтобы
  'в целях': чтобы
```

```yaml
# styles/Kaiten/Anglicisms.yml — SOFT: заимствования и жаргон
extends: substitution
message: "Заимствование: '%s' → '%s' (оцените по контексту)."
level: warning
ignorecase: true
swap:
  '\bтаск(а|и|ов)?\b': 'задача, карточка'
  '\bфич[аиеу]?\b': 'функция, возможность'
  '\bколл\b': 'звонок, встреча'
  '\bаттач\b': 'файл, вложение'
```

```yaml
# styles/Kaiten/Cliches.yml — SOFT: журналистские штампы
extends: existence
message: "Штамп: «%s». Переформулируйте своими словами."
level: warning
ignorecase: true
tokens:
  - 'как снег на голову'
  - 'плачевные последствия'
  - 'были затронуты вопросы'
  - 'революционн(ое|ый|ая)'
```

```yaml
# styles/Kaiten/Positioning.yml — HARD: ошибки позиционирования
extends: existence
message: "Позиционирование: Kaiten — не «трекер задач» (см. products.md)."
level: error
ignorecase: true
tokens:
  - '(Кайтен|Kaiten)[^.!?]{0,25}трекер задач'
```

```yaml
# styles/Kaiten/SentenceLength.yml — SOFT: длинные предложения
extends: metric
message: "Среднее предложение длиннее 15 слов — упростите."
level: warning
formula: (words / sentences)
condition: '> 15'
```

→ Это и есть автоматизация «исправлять язык», которую сейчас руками делает редактор.
Прогон Vale ставим в AI-предредактуру ДО редактора. Закрывает **узкое место №1**.

---

## Сводный план переноса

| Берём | Откуда | Куда у нас |
| --- | --- | --- |
| Раскладка knowledge-файлов | SEOMachine `context/` | `knowledge/` (есть; добавить target-keywords, internal-links-map) |
| Команды по этапам | SEOMachine `commands/` | будущие `skills/` + slash-команды |
| Числовой scoring черновика | SEOMachine `Editor`/`Content Analyzer` | `templates/ai_review.md` |
| Формат навыка SKILL.md + references | Cody (Agent Skills spec) | каждый наш `skills/<этап>/` |
| Approved sources (required/optional) | Cody | `templates/research_report.md` |
| Quality gates между фазами | Cody / ALwrity | вся схема MVP |
| Редполитика как код (HARD/SOFT) | Vale | `styles/Kaiten/*.yml` из `forbidden_phrases.md` |

## Что проверить перед сборкой MVP
1. **Русская читаемость:** какую формулу/инструмент берём вместо Flesch (длина предложений как стартовая метрика — уже работает в Vale).
2. **Лицензия Cody:** берём только паттерны (код не копируем) — ок.
3. **Чем заменить DataForSEO/WordPress** под Яндекс + Ghost; учесть, что рабочего Python на машине нет (см. memory) — вероятно, MCP/веб-инструменты.
4. **Где запускать Vale** в процессе автора (локально / в навыке ai-review).

## Следующий шаг
На основе этого — черновик MVP-спецификации: список навыков, какие knowledge-файлы и
quality gates они используют, и стартовый набор Vale-правил из `forbidden_phrases.md`.
