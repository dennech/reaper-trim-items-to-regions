--[[
  @description Trim selected items to project regions (keep inside regions)
  @version 1.0.0
  @author OpenAI Codex
  @about
    Keeps only the parts of the selected media items that fall inside any
    project region. Plain markers are ignored.
]]

local ACTION_NAME = "Trim selected items to project regions (keep inside regions)"
local PROJECT = 0
local EPSILON = 1e-9

local function show_message(message)
  reaper.ShowMessageBox(message, ACTION_NAME, 0)
end

local function show_summary(stats)
  local message = table.concat({
    ("[%s]"):format(ACTION_NAME),
    ("Items processed: %d"):format(stats.items_processed),
    ("Fragments kept: %d"):format(stats.fragments_kept),
    ("Fragments deleted: %d"):format(stats.fragments_deleted),
    ("Items deleted wholly: %d"):format(stats.items_deleted_wholly),
  }, "\n")

  reaper.ShowConsoleMsg("!SHOW:" .. message .. "\n")
end

local function append_items(destination, source)
  for index = 1, #source do
    destination[#destination + 1] = source[index]
  end
end

local function collect_selected_items(project)
  local items = {}
  local item_count = reaper.CountMediaItems(project)

  for item_index = 0, item_count - 1 do
    local item = reaper.GetMediaItem(project, item_index)
    if item and reaper.IsMediaItemSelected(item) then
      items[#items + 1] = item
    end
  end

  return items
end

local function collect_regions(project)
  local intervals = {}
  local region_or_marker_count = reaper.GetNumRegionsOrMarkers(project)

  for index = 0, region_or_marker_count - 1 do
    local region_or_marker = reaper.GetRegionOrMarker(project, index, "")
    if region_or_marker then
      local is_region = reaper.GetRegionOrMarkerInfo_Value(project, region_or_marker, "B_ISREGION")
      if is_region > 0.5 then
        intervals[#intervals + 1] = {
          start_pos = reaper.GetRegionOrMarkerInfo_Value(project, region_or_marker, "D_STARTPOS"),
          end_pos = reaper.GetRegionOrMarkerInfo_Value(project, region_or_marker, "D_ENDPOS"),
        }
      end
    end
  end

  return intervals
end

local function merge_intervals(intervals, epsilon)
  table.sort(intervals, function(left, right)
    if math.abs(left.start_pos - right.start_pos) <= epsilon then
      return left.end_pos < right.end_pos
    end

    return left.start_pos < right.start_pos
  end)

  local merged = {}

  for index = 1, #intervals do
    local interval = intervals[index]
    if interval.end_pos - interval.start_pos > epsilon then
      local last_interval = merged[#merged]

      if not last_interval or interval.start_pos > last_interval.end_pos + epsilon then
        merged[#merged + 1] = {
          start_pos = interval.start_pos,
          end_pos = interval.end_pos,
        }
      elseif interval.end_pos > last_interval.end_pos then
        last_interval.end_pos = interval.end_pos
      end
    end
  end

  return merged
end

local function get_item_bounds(item)
  local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
  local item_length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
  local item_end = item_start + item_length

  return item_start, item_length, item_end
end

local function intersect_item_with_regions(item_start, item_end, merged_regions, epsilon)
  local intersections = {}

  for index = 1, #merged_regions do
    local interval = merged_regions[index]

    if interval.end_pos <= item_start + epsilon then
      goto continue
    end

    if interval.start_pos >= item_end - epsilon then
      break
    end

    local overlap_start = math.max(item_start, interval.start_pos)
    local overlap_end = math.min(item_end, interval.end_pos)

    if overlap_end - overlap_start > epsilon then
      intersections[#intersections + 1] = {
        start_pos = overlap_start,
        end_pos = overlap_end,
      }
    end

    ::continue::
  end

  return intersections
end

local function collect_split_points(intersections, item_start, item_end, epsilon)
  local split_points = {}

  local function add_split_point(point)
    if point <= item_start + epsilon or point >= item_end - epsilon then
      return
    end

    for index = 1, #split_points do
      if math.abs(split_points[index] - point) <= epsilon then
        return
      end
    end

    split_points[#split_points + 1] = point
  end

  for index = 1, #intersections do
    local intersection = intersections[index]
    add_split_point(intersection.start_pos)
    add_split_point(intersection.end_pos)
  end

  table.sort(split_points, function(left, right)
    return left > right
  end)

  return split_points
end

local function split_item_by_points(item, split_points_desc)
  local fragments = {}
  local current_left = item

  for index = 1, #split_points_desc do
    local split_point = split_points_desc[index]
    local current_start, _, current_end = get_item_bounds(current_left)

    if split_point > current_start + EPSILON and split_point < current_end - EPSILON then
      local right_fragment = reaper.SplitMediaItem(current_left, split_point)
      if not right_fragment then
        error(("Failed to split media item at %.12f seconds."):format(split_point))
      end

      fragments[#fragments + 1] = right_fragment
    end
  end

  fragments[#fragments + 1] = current_left

  return fragments
end

local function classify_or_delete_fragments(fragments, keep_intersections, track, epsilon)
  local kept_fragments = {}
  local deleted_fragments = 0

  for index = 1, #fragments do
    local fragment = fragments[index]
    local fragment_start, _, fragment_end = get_item_bounds(fragment)
    local should_keep = false

    for keep_index = 1, #keep_intersections do
      local keep_interval = keep_intersections[keep_index]
      if fragment_start >= keep_interval.start_pos - epsilon
        and fragment_end <= keep_interval.end_pos + epsilon then
        should_keep = true
        break
      end
    end

    if should_keep then
      kept_fragments[#kept_fragments + 1] = fragment
    else
      if not reaper.DeleteTrackMediaItem(track, fragment) then
        error("Failed to delete an out-of-region fragment.")
      end

      deleted_fragments = deleted_fragments + 1
    end
  end

  return kept_fragments, deleted_fragments
end

local function process_item(item, merged_regions, epsilon)
  local track = reaper.GetMediaItem_Track(item)
  local item_start, _, item_end = get_item_bounds(item)
  local keep_intersections = intersect_item_with_regions(item_start, item_end, merged_regions, epsilon)

  if #keep_intersections == 0 then
    if not reaper.DeleteTrackMediaItem(track, item) then
      error("Failed to delete an item that does not intersect any region.")
    end

    return {}, {
      items_processed = 1,
      fragments_kept = 0,
      fragments_deleted = 1,
      items_deleted_wholly = 1,
    }
  end

  local split_points_desc = collect_split_points(keep_intersections, item_start, item_end, epsilon)
  local fragments = split_item_by_points(item, split_points_desc)
  local kept_fragments, deleted_fragments = classify_or_delete_fragments(
    fragments,
    keep_intersections,
    track,
    epsilon
  )

  return kept_fragments, {
    items_processed = 1,
    fragments_kept = #kept_fragments,
    fragments_deleted = deleted_fragments,
    items_deleted_wholly = 0,
  }
end

local function select_only_items(project, selected_items)
  local item_count = reaper.CountMediaItems(project)

  for item_index = 0, item_count - 1 do
    local item = reaper.GetMediaItem(project, item_index)
    if item then
      reaper.SetMediaItemSelected(item, false)
    end
  end

  for index = 1, #selected_items do
    reaper.SetMediaItemSelected(selected_items[index], true)
  end
end

local function merge_stats(destination, source)
  destination.items_processed = destination.items_processed + source.items_processed
  destination.fragments_kept = destination.fragments_kept + source.fragments_kept
  destination.fragments_deleted = destination.fragments_deleted + source.fragments_deleted
  destination.items_deleted_wholly = destination.items_deleted_wholly + source.items_deleted_wholly
end

local function format_error(error_value)
  if debug and debug.traceback then
    return debug.traceback(tostring(error_value), 2)
  end

  return tostring(error_value)
end

local function run(selected_items, merged_regions)
  local stats = {
    items_processed = 0,
    fragments_kept = 0,
    fragments_deleted = 0,
    items_deleted_wholly = 0,
  }
  local surviving_fragments = {}

  for index = 1, #selected_items do
    local item_fragments, item_stats = process_item(selected_items[index], merged_regions, EPSILON)
    append_items(surviving_fragments, item_fragments)
    merge_stats(stats, item_stats)
  end

  select_only_items(PROJECT, surviving_fragments)
  show_summary(stats)
end

local function main()
  local selected_items = collect_selected_items(PROJECT)
  if #selected_items == 0 then
    show_message("No media items are selected. Nothing was changed.")
    return
  end

  local merged_regions = merge_intervals(collect_regions(PROJECT), EPSILON)
  if #merged_regions == 0 then
    show_message("No project regions were found. Nothing was changed.")
    return
  end

  reaper.Undo_BeginBlock2(PROJECT)
  reaper.PreventUIRefresh(1)

  local ok, result = xpcall(function()
    run(selected_items, merged_regions)
  end, format_error)

  reaper.PreventUIRefresh(-1)
  reaper.UpdateArrange()

  if ok then
    reaper.Undo_EndBlock2(PROJECT, ACTION_NAME, -1)
  else
    reaper.Undo_EndBlock2(PROJECT, ACTION_NAME .. " (failed)", -1)
    show_message(result)
  end
end

local M = {
  ACTION_NAME = ACTION_NAME,
  PROJECT = PROJECT,
  EPSILON = EPSILON,
  collect_selected_items = collect_selected_items,
  collect_regions = collect_regions,
  merge_intervals = merge_intervals,
  get_item_bounds = get_item_bounds,
  intersect_item_with_regions = intersect_item_with_regions,
  collect_split_points = collect_split_points,
  split_item_by_points = split_item_by_points,
  classify_or_delete_fragments = classify_or_delete_fragments,
  process_item = process_item,
  main = main,
}

if _G.__TRIM_SELECTED_ITEMS_TO_REGIONS_TEST then
  return M
end

main()
