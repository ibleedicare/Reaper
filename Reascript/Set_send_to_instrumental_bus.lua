function getInstrumentalBus()
  all_track = reaper.GetNumTracks()
  for track_index=0,all_track-1 do
    current_track = reaper.GetTrack(0, track_index)
    retval, track_name = reaper.GetTrackName(current_track)
    if track_name == "Instrumental"
    then
      return current_track
    end
  end
end

function isTrackRoutedToInstrumentalBus(track)
  num_send = reaper.GetTrackNumSends(track, 0)
  for send_index=0,num_send-1 do
    retval, send_name = reaper.GetTrackSendName(track, send_index)
    if send_name == "Instrumental"
    then
      return true
    end
  end
  return false
end

num_selected_track = reaper.CountSelectedTracks(0)
for track_index=0, num_selected_track-1 do
  track = reaper.GetSelectedTrack(0, track_index)
  instrumental_bus = getInstrumentalBus()

  if (isTrackRoutedToInstrumentalBus(track) == false)
  then
    send_index = reaper.CreateTrackSend(track, instrumental_bus)
    reaper.SetTrackSendInfo_Value(track, 0, send_index, "D_VOL", 0.12589254117942)
    master_track = reaper.GetMasterTrack(0)
    reaper.SetMediaTrackInfo_Value(track, "B_MAINSEND", 0)
  end
end
