# reaper-trim-items-to-regions

Stock REAPER ReaScript that keeps only the parts of selected media items that
fall inside project regions and removes everything outside those regions.

## Features

- Works on all selected media items in the active project.
- Uses project regions only and ignores plain markers.
- Merges overlapping and touching regions into continuous keep intervals.
- Splits items at the required boundaries from right to left.
- Deletes only the fragments outside every keep interval.
- Preserves item timing, gaps, and track placement.
- Leaves only surviving fragments selected after processing.
- Uses stock REAPER API only. No SWS, ReaPack dependency, or third-party
  extension is required to run the script.

## Requirements

- REAPER with Lua ReaScript support enabled.
- Project regions already set up in the project timeline.

## Installation

### Option 1: Action List

1. Download
   [`Trim selected items to project regions (keep inside regions).lua`](./Trim%20selected%20items%20to%20project%20regions%20%28keep%20inside%20regions%29.lua).
2. Copy it into your REAPER scripts folder.
3. Open REAPER's Action List.
4. Choose `ReaScript: Load...` and select the Lua file.
5. Run `Trim selected items to project regions (keep inside regions)`.

### Option 2: ReaPack

1. Install [ReaPack](https://reapack.com/).
2. In REAPER, open `Extensions -> ReaPack -> Import repositories...`.
3. Add this repository index URL:
   `https://raw.githubusercontent.com/dennech/reaper-trim-items-to-regions/main/index.xml`
4. Synchronize packages and install the script from the repository.

## Usage

1. Select the media items you want to trim.
2. Make sure the project contains one or more regions.
3. Run the script from the Action List.
4. Review the surviving fragments. Only the parts inside regions are kept.

## Known Limits

- The script is intentionally non-destructive in behavior but still edits the
  project. Use REAPER Undo if you want to revert the result.
- If no items are selected, the script exits with an info message.
- If the project has no regions, the script exits with an info message.
- The script does not use plain markers, time selection, edit cursor, ripple
  editing, glue, or render operations.

## Reporting Bugs

Please open a GitHub issue and include:

- REAPER version
- Operating system
- Exact steps to reproduce
- Expected result
- Actual result
- If possible, a small test project or screenshot of the timeline

See [CONTRIBUTING.md](./CONTRIBUTING.md) for the recommended bug report format.

## Manual Smoke Tests

- Item `0-10`, region `2-8` keeps only `2-8`.
- Item `0-10`, regions `1-2`, `4-5`, `7-9` keeps three fragments in place.
- Item fully inside a region stays unchanged.
- Item fully outside all regions is deleted.
- Regions `2-6` and `5-9` behave as one keep interval `2-9`.
- Regions `2-6` and `6-9` behave as one keep interval `2-9`.
- Plain markers without regions cause a safe no-op with an info message.
- Multiple selected items on different tracks are processed independently.
- One Undo command restores the project to the pre-script state.
