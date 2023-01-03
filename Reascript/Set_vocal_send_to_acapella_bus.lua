function getAcapellaBus()
  all_track = reaper.GetNumTracks()
  for track_index=0,all_track-1 do
    current_track = reaper.GetTrack(0, track_index)
    retval, track_name = reaper.GetTrackName(current_track)
    if track_name == "Acapella"
    then
      return current_track
    end
  end
end

function isTrackRoutedToAcapellaBus(track)
  num_send = reaper.GetTrackNumSends(vocal_track, 0)
  for send_index=0,num_send-1 do
    retval, send_name = reaper.GetTrackSendName(track, send_index)
    if send_name == "Acapella"
    then
      return true
    end
  end
  return false
end

vocal_track = reaper.GetSelectedTrack(0, 0)
acapella_bus = getAcapellaBus()

if (isTrackRoutedToAcapellaBus(vocal_track) == false)
then
  send_index = reaper.CreateTrackSend(vocal_track, acapella_bus)
  reaper.SetTrackSendInfo_Value(vocal_track, 0, send_index, "D_VOL", 0.12589254117942)
end
