# reaper-trim-items-to-regions

REAPER Lua script that trims selected media items to project regions, keeping
only the parts that fall inside those regions.

Lua-скрипт для REAPER, который обрезает выбранные media items по project
regions и оставляет только те части, которые попадают внутрь этих regions.

- [English](#english)
- [Русский](#русский)

---

## English

REAPER Lua script that trims selected media items to project regions, keeping
only the parts that fall inside those regions.

This repository is built for one specific task: cut selected items at project
region boundaries and remove everything outside those regions in a single run.

### What problem it solves

If your timeline is already structured with regions, this script treats those
regions as **keep zones**.

Instead of splitting and cleaning up each item by hand, you can select the
items you want to process, run the script once, and keep only the parts that
belong inside the project regions.

### Quick examples

- `item 0-10 + region 2-8 -> keep 2-8`
- `item 0-10 + regions 1-2, 4-5, 7-9 -> keep 3 fragments`

### Who this is for

This script is useful for REAPER users working with:

- podcasts
- dialogue and voice-over
- music stems
- ambience and room tone
- long backing or support items

It is especially useful when regions are already part of your workflow and you
want a fast cleanup pass without trimming every item manually.

### When to use it

Use this script when:

- you already know which timeline areas should stay
- one long item or several selected items cross multiple regions
- you want to clean up several items at once
- you want to preserve timing, spacing, and item positions

### When not to use it

This script is probably not the right tool when:

- you need to move items around
- you want to glue or render the result
- you want to build a new edit from scratch
- you work with plain markers instead of project regions

### What the script does

The script:

- scans all selected media items in the current REAPER project
- reads all project regions
- merges overlapping or touching regions into continuous keep ranges
- splits selected items only where needed
- deletes the fragments that fall outside the merged region ranges
- keeps the remaining fragments exactly where they were

The surviving fragments stay in place. Their timing and gaps are preserved.

### Region behavior

Overlapping regions are treated as one continuous keep zone.

Example:

- `2-6` and `5-9` become `2-9`

Touching regions are treated the same way.

Example:

- `2-6` and `6-9` become `2-9`

### How it works in practice

1. Select the media items you want to process.
2. Make sure your project already contains one or more regions.
3. Run the script from the Action List.
4. The script splits the selected items where needed and removes only the parts
   outside the region keep zones.
5. Review the result. One Undo step restores everything if needed.

### What it does not do

The script does **not**:

- move items
- glue anything
- render anything
- use plain markers
- depend on the edit cursor
- depend on time selection

It uses the stock REAPER API only.

It does not require SWS or any other third-party extension to run. ReaPack is
optional and only needed if you want to install the script as a package.

If no items are selected, the script exits safely with a message.

If the project contains no regions, the script exits safely with a message.

### Installation

#### Option 1: Action List

1. Download
   [`Trim selected items to project regions (keep inside regions).lua`](./Trim%20selected%20items%20to%20project%20regions%20%28keep%20inside%20regions%29.lua).
2. Copy it to your REAPER scripts folder.
3. Open REAPER's **Action List**.
4. Choose **ReaScript: Load...** and select the Lua file.
5. Run **Trim selected items to project regions (keep inside regions)**.

#### Option 2: ReaPack

1. Install **ReaPack**.
2. In REAPER, open **Extensions -> ReaPack -> Import repositories...**
3. Add this repository index URL:

   `https://raw.githubusercontent.com/dennech/reaper-trim-items-to-regions/main/index.xml`

4. Synchronize packages.
5. Install the script from the repository.

### Usage

1. Select one or more media items.
2. Make sure the project timeline contains regions.
3. Run the script.
4. Check the result: only the parts inside the region keep zones remain.
5. If needed, use a single Undo step to revert the whole operation.

### Bug reports

If something behaves unexpectedly, please open a GitHub issue and include:

- REAPER version
- operating system
- exact steps to reproduce the problem
- expected result
- actual result
- screenshot or small test project, if possible

See [CONTRIBUTING.md](./CONTRIBUTING.md) for the recommended report format.

### Technical notes

- The script uses the stock REAPER API only.
- The repository is intentionally small: one main Lua script, release metadata,
  and ReaPack packaging.
- Manual smoke tests cover single-region, multi-region, overlapping, touching,
  inside-only, outside-only, marker-only, and multi-track scenarios.

---

## Русский

Lua-скрипт для REAPER, который обрезает выбранные media items по project
regions и оставляет только те части, которые попадают внутрь этих regions.

Этот репозиторий решает одну конкретную задачу: за один запуск разрезать
выбранные items по границам project regions и удалить всё, что находится вне
них.

### Какую задачу решает

Если проект уже размечен через regions, скрипт воспринимает их как **зоны
сохранения**.

Вместо того чтобы вручную разрезать и чистить каждый item, можно просто
выделить нужные items, запустить скрипт один раз и оставить только те части,
которые попадают внутрь project regions.

### Быстрые примеры

- `item 0-10 + region 2-8 -> оставить 2-8`
- `item 0-10 + regions 1-2, 4-5, 7-9 -> оставить 3 фрагмента`

### Для кого это

Скрипт особенно полезен тем, кто работает в REAPER с:

- подкастами
- диалогом и VO
- музыкальными stems
- ambience и room tone
- длинными подложками и фоновыми items

Он особенно удобен, если regions уже используются как часть твоего рабочего
процесса и нужна быстрая очистка без ручной подрезки каждого item.

### Когда использовать

Скрипт подходит, когда:

- уже понятно, какие зоны таймлайна нужно оставить
- один длинный item или несколько выбранных items проходят через несколько
  regions
- нужно быстро почистить сразу несколько items
- важно сохранить тайминг, паузы и исходные позиции items

### Когда не использовать

Скрипт вряд ли подойдёт, если:

- items нужно сдвигать
- результат нужно glue или render
- монтаж нужно собирать заново с нуля
- в проекте используются обычные markers, а не project regions

### Что делает скрипт

Скрипт:

- берёт все выбранные media items в текущем проекте REAPER
- читает все project regions
- объединяет пересекающиеся и соприкасающиеся regions в непрерывные зоны
  сохранения
- делает надрезы только там, где это действительно нужно
- удаляет фрагменты, которые находятся вне объединённых region-интервалов
- оставляет остальные фрагменты на своих местах

Оставшиеся куски не сдвигаются. Их тайминг и паузы сохраняются.

### Как скрипт трактует regions

Если regions пересекаются, скрипт считает их одной непрерывной зоной
сохранения.

Пример:

- `2-6` и `5-9` превращаются в `2-9`

Если regions соприкасаются, это тоже считается одной непрерывной зоной.

Пример:

- `2-6` и `6-9` превращаются в `2-9`

### Как это работает на практике

1. Выдели media items, которые хочешь обработать.
2. Убедись, что в проекте уже есть один или несколько regions.
3. Запусти скрипт из **Action List**.
4. Скрипт сделает надрезы только в нужных местах и удалит только части вне зон
   сохранения.
5. Проверь результат. Если нужно, всё можно откатить одним Undo.

### Чего скрипт не делает

Скрипт **не**:

- двигает items
- делает glue
- делает render
- использует обычные markers
- зависит от edit cursor
- зависит от time selection

Скрипт использует только стандартный REAPER API.

Для работы ему не нужны SWS или другие сторонние расширения. ReaPack нужен
только в том случае, если ты хочешь установить скрипт через пакетный менеджер.

Если ничего не выделено, скрипт безопасно показывает сообщение и выходит без
изменений.

Если в проекте нет regions, скрипт безопасно показывает сообщение и выходит без
изменений.

### Установка

#### Вариант 1: через Action List

1. Скачай
   [`Trim selected items to project regions (keep inside regions).lua`](./Trim%20selected%20items%20to%20project%20regions%20%28keep%20inside%20regions%29.lua).
2. Скопируй файл в папку со скриптами REAPER.
3. Открой **Action List** в REAPER.
4. Выбери **ReaScript: Load...** и укажи Lua-файл.
5. Запусти **Trim selected items to project regions (keep inside regions)**.

#### Вариант 2: через ReaPack

1. Установи **ReaPack**.
2. В REAPER открой **Extensions -> ReaPack -> Import repositories...**
3. Добавь URL индекса этого репозитория:

   `https://raw.githubusercontent.com/dennech/reaper-trim-items-to-regions/main/index.xml`

4. Синхронизируй пакеты.
5. Установи скрипт из репозитория.

### Использование

1. Выдели один или несколько media items.
2. Убедись, что на таймлайне есть regions.
3. Запусти скрипт.
4. Проверь результат: останутся только части внутри зон сохранения.
5. Если результат не нужен, всё откатывается одним Undo.

### Сообщения об ошибках

Если скрипт работает не так, как ожидается, создай issue на GitHub и приложи:

- версию REAPER
- операционную систему
- точные шаги воспроизведения
- ожидаемый результат
- фактический результат
- по возможности скриншот или небольшой тестовый проект

Рекомендуемый формат описан в [CONTRIBUTING.md](./CONTRIBUTING.md).

### Технические заметки

- Скрипт использует только стандартный REAPER API.
- Репозиторий намеренно сделан компактным: один основной Lua-скрипт,
  метаданные релиза и упаковка для ReaPack.
- Ручные smoke tests покрывают сценарии с одним region, несколькими regions,
  пересекающимися и соприкасающимися regions, cases только внутри, только вне,
  marker-only и multi-track.
