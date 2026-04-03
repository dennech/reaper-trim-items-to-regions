# reaper-trim-items-to-regions

REAPER script that cuts selected items by project regions and keeps only the
parts inside those regions.

Этот репозиторий нужен для одной конкретной задачи: быстро разрезать выбранные
items по границам project regions и удалить всё, что находится вне regions, за
один запуск.

**What problem it solves / Какую задачу решает**

When you already marked the timeline with regions, this script turns those
regions into keep zones.

Если у тебя уже размечен проект через regions, скрипт воспринимает их как зоны,
которые нужно сохранить, и автоматически вычищает всё остальное.

**Quick before / after**

- `item 0-10 + region 2-8 -> keep 2-8`
- `item 0-10 + regions 1-2, 4-5, 7-9 -> keep 3 fragments`

**Who this is for / Для кого это**

- REAPER users who prepare podcasts, dialogue, VO, music stems, ambience, or
  long backing items and already use regions as structure markers.
- Люди, которые уже размечают проект regions и хотят быстро “оставить только
  нужные зоны” без ручной резки каждого item.

**When to use / Когда использовать**

- You already know which timeline areas should stay.
- You have one long item or many selected items crossing several regions.
- You want batch cleanup without moving anything.

- Когда regions уже расставлены и нужно быстро оставить только эти зоны.
- Когда один длинный item или несколько items проходят через много regions.
- Когда нужна массовая очистка без ручной работы по каждому куску.

**When not to use / Когда не использовать**

- If you need to move items, glue them, render them, or build a new edit from
  scratch.
- If you work with plain markers instead of regions.

- Если тебе нужно сдвигать items, glue/render или собирать монтаж заново.
- Если ты используешь обычные markers, а не project regions.

---

## English

### What this script does

This script looks at all selected media items in the current REAPER project,
finds all project regions, cuts the selected items at the relevant region
borders, and keeps only the fragments that fall inside at least one region.

Think about it like this: regions are treated as **keep zones**.

### Typical use cases

- You have a long room tone, ambience, or background item that runs across many
  spoken regions, and you want to keep only the parts that belong to those
  spoken sections.
- You have one large take, stem, or backing item that spans multiple song
  sections, and you want to keep only the parts inside the named regions.
- You selected several items on different tracks and want a batch cleanup pass
  based on timeline regions you already prepared.

### Examples

- `item 0-10 + region 2-8 -> keep 2-8`
- `item 0-10 + regions 1-2, 4-5, 7-9 -> keep 3 fragments`
- Overlapping regions such as `2-6` and `5-9` are treated like one keep zone
  `2-9`.
- Touching regions such as `2-6` and `6-9` are also treated like one keep zone
  `2-9`.

### How it works in practice

1. Select the media items you want to process.
2. Make sure your project already contains one or more regions.
3. Run the script from the Action List.
4. The script splits the selected items where needed and deletes only the
   fragments outside the merged region ranges.
5. The remaining fragments stay where they were, with their original timing and
   gaps preserved.

### What it does not do

- It does not move items.
- It does not glue or render anything.
- It does not use plain markers.
- It does not depend on edit cursor or time selection.
- It does not need SWS, ReaPack, or any third-party extension to run.
- If no items are selected, it exits safely with a message.
- If the project has no regions, it exits safely with a message.

### Installation

#### Option 1: Action List

1. Download
   [`Trim selected items to project regions (keep inside regions).lua`](./Trim%20selected%20items%20to%20project%20regions%20%28keep%20inside%20regions%29.lua).
2. Copy it into your REAPER scripts folder.
3. Open REAPER's Action List.
4. Choose `ReaScript: Load...` and select the Lua file.
5. Run `Trim selected items to project regions (keep inside regions)`.

#### Option 2: ReaPack

1. Install [ReaPack](https://reapack.com/).
2. In REAPER, open `Extensions -> ReaPack -> Import repositories...`.
3. Add this repository index URL:
   `https://raw.githubusercontent.com/dennech/reaper-trim-items-to-regions/main/index.xml`
4. Synchronize packages and install the script from the repository.

### Usage

- Select one or more media items.
- Make sure the timeline has regions.
- Run the script.
- Review the result. Only the parts inside the region keep zones remain.
- If needed, use one Undo step to revert the whole operation.

### Bug reports

If something behaves unexpectedly, please open a GitHub issue and include:

- REAPER version
- operating system
- exact steps to reproduce
- expected result
- actual result
- screenshot or small test project if possible

See [CONTRIBUTING.md](./CONTRIBUTING.md) for the recommended report format.

---

## Русский

### Что делает скрипт

Скрипт берёт все выбранные media items в текущем проекте REAPER, находит все
project regions, разрезает выбранные items по нужным границам и оставляет
только те фрагменты, которые попадают внутрь хотя бы одного region.

Удобная ментальная модель простая: **regions = зоны, которые нужно сохранить**.

### Когда это полезно

- Есть длинный ambient, room tone или background item, который проходит через
  несколько речевых regions, и нужно оставить только куски внутри этих sections.
- Есть один длинный дубль, stem или подложка, которая тянется через несколько
  частей трека, и нужно быстро сохранить только фрагменты внутри song sections.
- Есть несколько выбранных items на разных дорожках, и хочется сделать batch
  cleanup по уже размеченным regions одним запуском.

### Примеры

- `item 0-10 + region 2-8 -> оставить 2-8`
- `item 0-10 + regions 1-2, 4-5, 7-9 -> оставить 3 фрагмента`
- Если regions пересекаются, например `2-6` и `5-9`, скрипт считает их одной
  непрерывной зоной `2-9`.
- Если regions соприкасаются, например `2-6` и `6-9`, это тоже одна зона
  сохранения `2-9`.

### Как это работает на практике

1. Выделяешь media items, которые хочешь обработать.
2. Проверяешь, что в проекте уже стоят один или несколько regions.
3. Запускаешь скрипт из Action List.
4. Скрипт делает надрезы только там, где это нужно, и удаляет только части вне
   объединённых region-интервалов.
5. Оставшиеся куски не сдвигаются и остаются на своих местах с теми же паузами.

### Чего скрипт не делает

- Не двигает items.
- Не делает glue и не рендерит.
- Не использует обычные markers.
- Не зависит от edit cursor и time selection.
- Не требует SWS, ReaPack или других расширений для запуска.
- Если ничего не выделено, безопасно показывает сообщение и выходит.
- Если в проекте нет regions, безопасно показывает сообщение и выходит.

### Установка

#### Вариант 1: через Action List

1. Скачай
   [`Trim selected items to project regions (keep inside regions).lua`](./Trim%20selected%20items%20to%20project%20regions%20%28keep%20inside%20regions%29.lua).
2. Скопируй файл в папку со скриптами REAPER.
3. Открой Action List в REAPER.
4. Выбери `ReaScript: Load...` и укажи Lua-файл.
5. Запусти `Trim selected items to project regions (keep inside regions)`.

#### Вариант 2: через ReaPack

1. Установи [ReaPack](https://reapack.com/).
2. В REAPER открой `Extensions -> ReaPack -> Import repositories...`.
3. Добавь URL индекса этого репозитория:
   `https://raw.githubusercontent.com/dennech/reaper-trim-items-to-regions/main/index.xml`
4. Синхронизируй пакеты и установи скрипт из репозитория.

### Использование

- Выдели один или несколько media items.
- Убедись, что на таймлайне есть regions.
- Запусти скрипт.
- Проверь результат: останутся только части внутри region keep zones.
- Если результат не нужен, всё откатывается одним Undo.

### Сообщения об ошибках

Если что-то работает не так, создай issue на GitHub и приложи:

- версию REAPER
- операционную систему
- точные шаги воспроизведения
- ожидаемый результат
- фактический результат
- по возможности скриншот или маленький тестовый проект

Формат рекомендаций есть в [CONTRIBUTING.md](./CONTRIBUTING.md).

---

## Technical Notes

- The script uses stock REAPER API only.
- It keeps the repository intentionally small: one main Lua script, release
  metadata, and ReaPack packaging.
- Manual smoke tests cover single-region, multi-region, overlapping, touching,
  inside-only, outside-only, marker-only, and multi-track scenarios.
