CURRENT_PROJECT = 0
MAIN_TRACK = "Vocal Lead"
VST_NAME = "REPLACE BY YOUR VST"

function getVstIndex(track, vst_name)
  return reaper.TrackFX_AddByName(track, vst_name, false, 0)
end

function getVstNumParam(track, fx_index)
  return reaper.TrackFX_GetNumParams(track, fx_index)
end

function copyVSTParamToDestTrack(src_track, dest_track, vst_name)
  src_track_vst_index = getVstIndex(src_track, vst_name)
  dest_track_vst_index = getVstIndex(dest_track, vst_name)
  
  vst_param = getVstNumParam(src_track, src_track_vst_index)
  for param=0, vst_param-1 do
    retval, minval, maxval = reaper.TrackFX_GetParam(src_track, src_track_vst_index, param)
    reaper.TrackFX_SetParam(dest_track, dest_track_vst_index, param, retval)
  end
end

function getVocalLeadFromSelectedTrack(selectedTracks)
  for track=0,selected_tracks-1 do
    current_name = reaper.GetTrackName(track)
    if current_name == MAIN_TRACK
    then
      return track
    end
  end
end

function copyVSTParamToAllDestTracks(track, selected_tracks)
  for track=0,selected_tracks-1 do
    current_track = reaper.GetSelectedTrack(0, track)
    vst_index = getVstIndex(vocal_lead, VST_NAME)
    vst_param_num = getVstNumParam(vocal_lead, vst_index)
    copyVSTParamToDestTrack(vocal_lead, current_track, VST_NAME)
  end
end

selected_tracks = reaper.CountSelectedTracks(0)
vocal_lead_index = getVocalLeadFromSelectedTrack(selected_tracks)
vocal_lead = reaper.GetSelectedTrack(0, vocal_lead_index)
copyVSTParamToAllDestTracks(vocal_lead, selected_tracks)