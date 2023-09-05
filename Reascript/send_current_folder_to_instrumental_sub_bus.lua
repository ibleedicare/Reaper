-- Centralized messages
local messages = {
  noTrackSelected = "No track selected\n",
  noParent = "Selected track has no parent\n",
  multipleTracksFound = "Multiple tracks found with name: ",
  routingFailed = "Failed to create track send\n"
}

-- Function to check if a track is selected
function trackSelected()
  return reaper.CountSelectedTracks(0) > 0
end

-- Function to get parent track of a given track
function getParent(track)
  return reaper.GetParentTrack(track)
end

-- Function to select one track and unselect another
function selectAndUnselect(toSelect, toUnselect)
  reaper.SetTrackSelected(toSelect, true)
  reaper.SetTrackSelected(toUnselect, false)
end

-- Function to find tracks by name and ensure only one exists
function findUniqueTrackByName(name)
  local num_tracks = reaper.CountTracks(0)
  local found_tracks = 0
  local found_track = nil
  for i = 0, num_tracks - 1 do
    local track = reaper.GetTrack(0, i)
    local _, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    if track_name == name then
      found_tracks = found_tracks + 1
      found_track = track
    end
  end

  if found_tracks == 1 then
    return found_track
  else
    reaper.ShowConsoleMsg(messages.multipleTracksFound .. name .. "\n")
    return nil
  end
end

-- Function to route the parent folder track to the newly created child track and remove the master send from the parent
function routeTracks(sourceTrack, destinationTrack)
  -- Remove master send from the source (parent folder) track
  reaper.SetMediaTrackInfo_Value(sourceTrack, "B_MAINSEND", 0)
  
  -- Create a send from the source track to the destination track
  reaper.CreateTrackSend(sourceTrack, destinationTrack)
end


-- Function to create a new child track under a given parent track ("Instrumental" in this case)
function createChildTrack(parent, name)
  -- Get the index of the parent ("Instrumental") track
  local parent_track_num = reaper.GetMediaTrackInfo_Value(parent, "IP_TRACKNUMBER")
  
  -- Get the folder depth of the parent ("Instrumental") track
  local parent_folder_depth = reaper.GetMediaTrackInfo_Value(parent, "I_FOLDERDEPTH")
  
  -- Insert a new track below the parent ("Instrumental") track
  reaper.InsertTrackAtIndex(parent_track_num, false)
  
  -- Apply changes
  reaper.TrackList_AdjustWindows(false)
  
  -- Retrieve the newly created track
  local new_track = reaper.GetTrack(0, parent_track_num)
  
  -- Name the new track after the previously selected parent folder
  reaper.GetSetMediaTrackInfo_String(new_track, "P_NAME", name, true)
  
  -- If "Instrumental" is not already a folder, make it one
  if parent_folder_depth == 0 then
    reaper.SetMediaTrackInfo_Value(parent, "I_FOLDERDEPTH", 1)
    reaper.SetMediaTrackInfo_Value(new_track, "I_FOLDERDEPTH", -1)
  end
  
  return new_track
end

-- Main function encapsulating the script logic
function main()
  if not trackSelected() then
    reaper.ShowConsoleMsg(messages.noTrackSelected)
    return
  end

  local selected_track = reaper.GetSelectedTrack(0, 0)
  local parent_track = getParent(selected_track)
  local track_name = ""

  -- If a parent track exists, use its name; otherwise, use the name of the selected track
  if parent_track ~= nil then
    selectAndUnselect(parent_track, selected_track)
    _, track_name = reaper.GetSetMediaTrackInfo_String(parent_track, "P_NAME", "", false)
  else
    _, track_name = reaper.GetSetMediaTrackInfo_String(selected_track, "P_NAME", "", false)
  end

  local twoBusTrack = findUniqueTrackByName("2 Bus")
  local instrumentalTrack = findUniqueTrackByName("Instrumental")

  if twoBusTrack == nil or instrumentalTrack == nil then
    return
  end

  -- Create a new child track under "Instrumental" with the determined name
  local newChildTrack = createChildTrack(instrumentalTrack, track_name)

  -- Route the appropriate source track to the newly created child track and remove the master send
  if parent_track ~= nil then
    routeTracks(parent_track, newChildTrack)
  else
    routeTracks(selected_track, newChildTrack)
  end
end


-- Execute the main function
main()

