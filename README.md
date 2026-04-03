# reaper-trim-items-to-regions

Stock REAPER ReaScript that trims the selected media items to the union of all
project regions and removes everything outside those regions.

## Script

- `Trim selected items to project regions (keep inside regions).lua`

## What it does

- Reads all selected media items from the active project.
- Reads project regions only and ignores plain markers.
- Merges overlapping and touching regions into continuous keep intervals.
- Splits selected items at the needed boundaries from right to left.
- Deletes the fragments that fall outside every keep interval.
- Keeps surviving fragments in place without moving, gluing, or rendering them.
- Leaves only surviving fragments selected at the end.

## Safety

- If no media items are selected, the script shows a message and exits.
- If the project contains no regions, the script shows a message and exits.
- The script does not depend on edit cursor, time selection, ripple editing,
  SWS, ReaPack, or any third-party extension.

## Install

1. Copy `Trim selected items to project regions (keep inside regions).lua` into
   your REAPER scripts folder.
2. Open the REAPER Action List.
3. Use `ReaScript: Load...` and choose the Lua file.
4. Run `Trim selected items to project regions (keep inside regions)`.

## Manual checks

- Item `0-10`, region `2-8` keeps only `2-8`.
- Item `0-10`, regions `1-2`, `4-5`, `7-9` keeps three fragments in place.
- Item fully inside a region stays unchanged.
- Item fully outside all regions is deleted.
- Regions `2-6` and `5-9` behave as one keep interval `2-9`.
- Regions `2-6` and `6-9` behave as one keep interval `2-9`.
- Plain markers without regions cause a safe no-op with an info message.
- Multiple selected items on different tracks are processed independently.
- One Undo command restores the project to the pre-script state.
