CURRENT_PROJECT = 0

function getCurrentScale(track)
  wave_tune_index = reaper.TrackFX_AddByName(track, "Waves Tune Real-Time Stereo (x86) (Waves)", false, 0)
  current_speed, minval, maxval = reaper.TrackFX_GetParam(track, wave_tune_index, 0)
  current_note_transition, minval, maxval = reaper.TrackFX_GetParam(track, wave_tune_index, 1)
  current_note, minval, maxval = reaper.TrackFX_GetParam(track, wave_tune_index, 11)
  current_scale, minval, maxval = reaper.TrackFX_GetParam(track, wave_tune_index, 10)
  return current_note, current_scale, current_speed, current_note_transition
end

function setScaleAndNote(note, scale, track)
  wave_tune_index = reaper.TrackFX_AddByName(track, "Waves Tune Real-Time Stereo (x86) (Waves)", false, 0)
  -- Set note
  reaper.TrackFX_SetParam(track, wave_tune_index, 11, note)
  -- Set Scale
  reaper.TrackFX_SetParam(track, wave_tune_index, 10, scale)
end

function setSpeedAndTranstion(speed, transition, track)
  wave_tune_index = reaper.TrackFX_AddByName(track, "Waves Tune Real-Time Stereo (x86) (Waves)", false, 0)
  -- Set speed
  reaper.TrackFX_SetParam(track, wave_tune_index, 0, speed)
  -- Set transition
  reaper.TrackFX_SetParam(track, wave_tune_index, 1, transition)
end

function getLeadVocalTrackIndex()
  count_selected_track = reaper.CountSelectedTracks(CURRENT_PROJECT)
  for track_index=0, count_selected_track-1 do
    vocal_track = reaper.GetSelectedTrack(CURRENT_PROJECT, track_index)
    retVal, vocal_lead = reaper.GetTrackName(vocal_track)
    if vocal_lead == "Vocal Lead"
    then
      return track_index
    end
  end
end

function ApplyWaveTuneToAllOtherVocal(note, scale, speed, transition)
  count_selected_track = reaper.CountSelectedTracks(CURRENT_PROJECT)
  for track_index=0, count_selected_track-1 do
    vocal_track = reaper.GetSelectedTrack(CURRENT_PROJECT, track_index)
    retVal, vocal_lead = reaper.GetTrackName(vocal_track)
    if vocal_lead ~= "Vocal Lead"
    then
      setScaleAndNote(note, scale, vocal_track)
      setSpeedAndTranstion(speed, transition, vocal_track)
    end
  end
end

vocal_lead_index = getLeadVocalTrackIndex()
sel_track = reaper.GetSelectedTrack(CURRENT_PROJECT, vocal_lead_index)
current_note, current_scale, current_speed, current_transition = getCurrentScale(sel_track)
ApplyWaveTuneToAllOtherVocal(current_note, current_scale, current_speed, current_transition)
