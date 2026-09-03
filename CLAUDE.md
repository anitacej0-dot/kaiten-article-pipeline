# CLAUDE.md — как работать в этом репозитории

Это **редакционный конвейер статей Kaiten**. Не автогенератор: AI делает первые ~60%
(черновую и рутинную часть), человек отвечает за стратегию на входе и за качество на
выходе. **Редактор — финальный владелец качества.** Никогда не публикуй без редактора.

Полный чертёж — [MVP_SPEC.md](MVP_SPEC.md). Обоснования — в [research/](research/).

## Что где лежит

- `knowledge/` — база знаний Kaiten (источник истины): редполитика, продукт, ICP, SEO, примеры, чёрный список, паттерны статей, редакторские правила, анти-паттерны слабых статей. **Всегда сверяйся с ней.**
- `templates/` — шаблоны артефактов каждого этапа (включая `brief_template.md`, `brief_review_template.md`).
- `styles/Kaiten/` — Vale-правила (редполитика как код, HARD/SOFT).
- `skills/` — навыки по этапам (`brief-architect`, `brief-reviewer`, `research-article`, …).
- `.claude/skills/` — навыки визуального этапа: `design-system-kaiten-v01` (источник истины по стилю) и `visual-producer-kaiten`.
- `articles/ГГГГ-ММ-тема/` — рабочие файлы конкретной статьи (артефакты 00–12).
- `workflows/` — сквозные конвейеры по типам статей.
- `tools/` — вспомогательные скрипты (например, `pdf_extract.py` для разбора PDF).

## Типы статей

В репозитории два конвейера. Они не пересекаются — выбирай по типу материала.

| Тип | Когда | Конвейер |
| --- | --- | --- |
| SEO-статья (по умолчанию) | тема из контент-плана, есть интент и ключи | [`workflows/seo_article_pipeline.md`](workflows/seo_article_pipeline.md) |
| `monthly_product_updates` | ежемесячный обзор обновлений Кайтена по внутреннему PDF | [`workflows/monthly_updates_pipeline.md`](workflows/monthly_updates_pipeline.md) |

Всё, что ниже до раздела «Ежемесячный обзор обновлений», относится к **SEO-статьям**.

## Конвейер SEO-статьи: этапы и артефакты

MVP = **SEO-статья в блог**. Кейсы и экспертные статьи в пилот не входят.

| # | Этап | Навык | Артефакт |
| --- | --- | --- | --- |
| 0 | Intake | — | `00_intake.md` |
| 1 | Brief + ревью брифа (gate) | `brief-architect` → `brief-reviewer` | `01_brief.md` + `01_brief_review.md` |
| 2 | Research | `research-article` | `02_sources.md` |
| 3 | Outline | `build-outline` | `03_outline.md` |
| 4 | Draft | (автор) | `04_draft.md` |
| 5 | AI-предредактура | `ai-pre-review` | `05_ai_review.md` |
| 6 | Author fixes | (автор) | `06_author_fixed.md` |
| 7 | Редактура | (редактор) | `07_editorial_review.md` |
| 8 | CMS / публикационный пакет | `package-for-cms` | `08_cms_package.md` / `10_publication_pack.md` |
| 9 | Visual brief | `visual-producer-kaiten` | `11_visual_brief.md` |
| 10 | Visual assets | `visual-producer-kaiten` | `12_visual_assets.md` |

### Редакционный gate брифа (Пакет 1)

Первый этап после intake — редакционный gate из двух навыков, он важнее всех остальных:

1. **`brief-architect`** собирает **подробный** бриф (не короткое ТЗ на 1–2 страницы). Фиксирует: боль читателя, поисковый интент, **угол** статьи, **формат подачи**, уровень креатива, **продуктовую связку** с Kaiten, фактуру и визуалы, анти-паттерны. Опирается на `knowledge/` (`article_patterns.md`, `editorial_corrections_patterns.md`, `weak_article_antipatterns.md`, `seo_policy.md`, `icp_segments.md`, `products.md`, `good_examples.md`).
2. **`brief-reviewer`** проверяет бриф **до автора** и ставит статус **APPROVED / NEEDS_REVISION / BLOCKED**. Главный вопрос ревью — не «заполнены ли поля», а: «получится ли статья, которую редактору не придётся спасать руками?».

**Правило: статья не пишется, пока бриф не получил `APPROVED`.** Если `NEEDS_REVISION`/`BLOCKED` — бриф возвращается `brief-architect` на доработку. Бриф обязан **предотвратить типовую SEO-статью**: задать угол, аудиторию, формат подачи, продуктовую связку и критерии качества.

Артефакты: бриф → `01_brief.md`, ревью → `01_brief_review.md`. (Внутри навыки ссылаются на имена `02_brief.md` / `03_brief_review.md` — привести к нумерации проекта при внедрении.) `brief-architect` — более строгая замена облегчённого `make-brief`.

**Вспомогательные навыки (сквозные):**
- `kaiten-editorial` — редполитика и инфостиль Kaiten как навык. Применяй при написании/редактуре **любого** текста (статьи, подборки, мета-теги, лиды). Свой свод фактов — `references/kaiten-facts.md` (позиционирование, тарифы, **Kaiten Встречи**, перелинковка). Пересекается с `knowledge/editorial_policy.md` и `forbidden_phrases.md`.
- `product-roundup-v2` — навык «под ключ» для статей-подборок: research → черновик (Kaiten первым) → глубокий фактчекинг → юр-проверка, ~20k знаков, свои quality gates. Альтернатива поэтапному прохождению make-brief→…→ai-pre-review для формата подборки. Ссылается на несуществующий пока `product-roundup` (v1) — для «обычных» подборок.
- `product-fact-check` — фактчекинг описаний продуктов из подборок по официальным сайтам. Используй на этапах research (2) и AI-предредактуры (5). Проверяет факты строго по офсайтам, с датой; не выдумывает.
- `make-cover` — сборка обложки статьи по фирменному шаблону (этап иллюстраций/CMS).

> Заметка: несколько навыков носят с собой свои копии редполитики/фактов/позиционирования
> (`kaiten-editorial`, `product-roundup-v2`). Единый источник истины — `knowledge/`.
> Со временем стоит свести дубли, чтобы правки редполитики/фактов делались в одном месте.

### Визуальный этап (после публикационного пакета)

После `10_publication_pack.md` статью **нельзя считать полностью готовой, если в
публикационном пакете есть визуальные рекомендации** (обложка, схемы, скриншоты). Нужно
запустить `visual-producer-kaiten` и создать:

- `11_visual_brief.md` — что и зачем визуализируем, что визуализировать не нужно;
- `12_visual_assets.md` — обложка, схемы, иллюстрации, таблицы, скриншоты, промпты, alt, статусы.

**Правило: все визуалы для статей Kaiten должны соответствовать
[`design-system-kaiten-v01`](.claude/skills/design-system-kaiten-v01/SKILL.md)** — спокойный
B2B/SaaS-стиль, фиолетовый `#7D4CCF` как единственный акцент, Inter, скруглённые карточки,
без визуального шума. Интерфейс продукта не выдумываем — нужен реальный скриншот.

> Навыки визуального этапа лежат в `.claude/skills/` (а не в `skills/`, где остальные) —
> так `design-system-kaiten-v01` и `visual-producer-kaiten` автозагружаются как навыки Claude Code.

## Quality gates — НЕ переходи дальше, если

- **До брифа:** нет цели / ЦА / площадки / типа / SEO-вводных → задай вопросы редактору.
- **До статьи (главный gate):** бриф не прошёл `brief-reviewer` со статусом `APPROVED` → статью не писать, вернуть бриф на доработку.
- **До черновика:** нет `02_sources.md` или структура не отвечает интенту → не отдавай автору.
- **До редактора:** AI-ревью нашёл HARD-замечания → верни автору на правку.
- **До финала:** неподтверждённые факты, не готов SEO-пакет, риск Баден-Бадена → не публикуй.
- **До полной готовности:** в публикационном пакете есть визуальные рекомендации, но нет `11_visual_brief.md` / `12_visual_assets.md` → запусти `visual-producer-kaiten`; визуалы вне `design-system-kaiten-v01` не принимаются.

## Главные правила

1. **Сверяйся с `knowledge/`** на каждом этапе. Факты о продукте — из `products.md` **со сверкой по официальной базе знаний Kaiten [faq-ru.kaiten.site](https://faq-ru.kaiten.site/)** на этапе фактчекинга (она свежее `products.md`); тон — из `editorial_policy.md`, запреты — из `forbidden_phrases.md`.
2. **Не выдумывай факты и цифры.** Нет источника — пометь как требующее проверки, не пиши «из головы».
3. **Соблюдай гейты.** Высококритичное замечание блокирует движение дальше.
4. **Показывай результат** после каждого этапа и жди подтверждения, прежде чем идти дальше.
5. **Пиши по-русски**, по редполитике. Перед сдачей редактору — прогон через AI-предредактуру (`templates/ai_review.md`): Vale + рубрика + русские сервисы.

## Как запускать этап

«Собери бриф по `00_intake.md`» → `brief-architect` читает intake + нужные `knowledge/`,
заполняет `templates/brief_template.md`, сохраняет `01_brief.md`. Затем `brief-reviewer`
проверяет его (`templates/brief_review_template.md`) и ставит статус. Статья идёт дальше
только при `APPROVED`. Аналогично остальные этапы.

## Как запускать SEO article pipeline

Единый цикл для всех SEO-статей — [`workflows/seo_article_pipeline.md`](workflows/seo_article_pipeline.md).
Порядок для новой статьи:

1. Создать папку `articles/YYYY-MM-slug/` (копией `articles/_ARTICLE_FOLDER_TEMPLATE/`).
2. Заполнить `00_intake.md` по `templates/article_intake_template.md`.
3. Запустить этап `brief-architect`.
4. **🛑 Остановиться после `01_brief_review.md`** и ждать решения редактора.
5. Дальше двигаться по `workflows/seo_article_pipeline.md` (со stop-points на outline, draft, score).
6. `10_publication_pack.md` создаётся **только после rescore 90+**.
7. `11_visual_brief.md` и `13_image_generation_queue.md` создаются **только после publication pack**.
8. Картинки генерируются **только из `13_image_generation_queue.md` и только по отдельной команде редактора**.

Статус статьи ведётся в её `pipeline_status.md` (шаблон — `templates/pipeline_status_template.md`).

## Ежемесячный обзор обновлений (`monthly_product_updates`)

Второй тип статьи. **Это не SEO-статья:** нет интента, ключей, брифа и скоринга.
Материал выходит раз в месяц и пишется по внутреннему PDF с фактурой о релизах.
Полный цикл — [`workflows/monthly_updates_pipeline.md`](workflows/monthly_updates_pipeline.md),
редакционные правила формата — [`knowledge/monthly_updates_style_guide.md`](knowledge/monthly_updates_style_guide.md).

**Источник истины — приложенный PDF.** Внешний ресёрч по фактуре запрещён по умолчанию.
Нельзя придумывать функции, ограничения, тарифы, сценарии, цифры, даты, ссылки и
технические возможности. Не хватает данных — `[НУЖНО УТОЧНИТЬ: вопрос]`, а не догадка.

Навыки: `monthly-updates-source` (разбор PDF и реестр обновлений) →
`monthly-updates-writer` (структура, черновик, манифест картинок) →
`monthly-updates-qa` (сверка статьи с источником). Тон — сквозной `kaiten-editorial`,
вычитка — `ai-pre-review`, упаковка — `package-for-cms`.

Порядок для нового месяца:

1. Создать папку `articles/YYYY-MM-obnovleniya-<месяц>/` (копией `articles/_MONTHLY_UPDATES_FOLDER_TEMPLATE/`).
2. Заполнить `00_intake.md` по `templates/monthly_updates_intake_template.md`.
3. Прогнать PDF: `python tools/pdf_extract.py --pdf "<файл>" --out "articles/<папка>" --render-pages`.
4. `monthly-updates-source` → `02_source_facts.md` (полный реестр обновлений, major/minor).
5. `monthly-updates-writer` → `03_outline.md`. **🛑 STOP 1** — редактор утверждает H1, описание под заголовком и деление обновлений.
6. Черновик → `04_draft.md`. **🛑 STOP 2** — редактор смотрит текст.
7. Вычитка → `05_editorial_review.md`, манифест картинок → `06_image_manifest.md`.
8. `monthly-updates-qa` → `07_qa_report.md`. **🛑 STOP 3** — `Unsupported claims: 0` и ни одного потерянного обновления.
9. Упаковка → `08_publication_pack.md`.

Картинки берутся **из PDF**, а не рисуются: `visual-producer-kaiten` и генерация
изображений в этом конвейере не участвуют. Нет скриншота — раздел выходит без картинки,
а в манифесте появляется запрос скриншота у продуктовой команды.
