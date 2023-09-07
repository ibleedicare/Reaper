-- Centralized messages
local messages = {
  noTrackSelected = "No track selected\n",
  noParent = "Selected track has no parent\n",
  multipleTracksFound = "Multiple tracks found with name: ",
  routingFailed = "Failed to create track send\n"
}

-- Function to check if any track is selected
function tracksSelected()
  return reaper.CountSelectedTracks(0) > 0
end

-- Function to get parent track of a given track
function getParent(track)
  return reaper.GetParentTrack(track)
end

-- Function to find unique track by name
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

-- Function to find a track by name under a given parent track name
function findTrackByNameUnderParent(parentName, trackName)
  local num_tracks = reaper.CountTracks(0)
  local found_tracks = 0
  local found_track = nil

  for i = 0, num_tracks - 1 do
    local track = reaper.GetTrack(0, i)
    local parent_track = getParent(track)
    if parent_track then
      local _, parent_track_name = reaper.GetSetMediaTrackInfo_String(parent_track, "P_NAME", "", false)
      
      if parent_track_name == parentName then
        local _, current_track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
        if current_track_name == trackName then
          found_tracks = found_tracks + 1
          found_track = track
        end
      end
    end
  end

  if found_tracks == 1 then
    return found_track
  else
    reaper.ShowConsoleMsg(messages.multipleTracksFound .. trackName .. " under " .. parentName .. "\n")
    return nil
  end
end


-- Function to route the tracks
function routeTracks(sourceTrack, destinationTrack)
  reaper.SetMediaTrackInfo_Value(sourceTrack, "B_MAINSEND", 0)
  reaper.CreateTrackSend(sourceTrack, destinationTrack)
end

-- Function to create a new child track
function createChildTrack(parent, name)
  local parent_track_num = reaper.GetMediaTrackInfo_Value(parent, "IP_TRACKNUMBER")
  local parent_folder_depth = reaper.GetMediaTrackInfo_Value(parent, "I_FOLDERDEPTH")
  reaper.InsertTrackAtIndex(parent_track_num, false)
  reaper.TrackList_AdjustWindows(false)
  local new_track = reaper.GetTrack(0, parent_track_num)
  reaper.GetSetMediaTrackInfo_String(new_track, "P_NAME", name, true)
  
  if parent_folder_depth == 0 then
    reaper.SetMediaTrackInfo_Value(parent, "I_FOLDERDEPTH", 1)
    reaper.SetMediaTrackInfo_Value(new_track, "I_FOLDERDEPTH", -1)
  end
  
  return new_track
end

-- Main function
function main()

  if not tracksSelected() then
    reaper.ShowConsoleMsg(messages.noTrackSelected)
    return
  end

  local numSelectedTracks = reaper.CountSelectedTracks(0)
  
  for i = 0, numSelectedTracks - 1 do
    local selected_track = reaper.GetSelectedTrack(0, i)
    local parent_track = getParent(selected_track)
    local track_name = ""

    if parent_track ~= nil then
      _, track_name = reaper.GetSetMediaTrackInfo_String(parent_track, "P_NAME", "", false)
    else
      _, track_name = reaper.GetSetMediaTrackInfo_String(selected_track, "P_NAME", "", false)
    end

    local destinationTrack = findUniqueTrackByName("Instrumental")  -- Default destination

    -- Special case: If the track is named "Drums", find the existing "Drums" under "2 Bus"
    if track_name == "Drums" then
      destinationTrack = findTrackByNameUnderParent("2 Bus", "Drums")
    end

    if destinationTrack == nil then
      return
    end

    if track_name == "Drums" then
      routeTracks(selected_track, destinationTrack)
    else
      local newChildTrack = createChildTrack(destinationTrack, track_name)
      if parent_track ~= nil then
        routeTracks(parent_track, newChildTrack)
      else
        routeTracks(selected_track, newChildTrack)
      end
    end
  end
end


-- Execute the main function
main()
