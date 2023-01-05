CURRENT_PROJECT = 0
MAIN_TRACK = "Vocal Lead"
VST_NAME = "REPLACE BY YOUR VST"

function get_vst_index(track, vst_name)
  return reaper.TrackFX_AddByName(track, vst_name, false, 0)
end

function get_vst_num_param(track, fx_index)
  return reaper.TrackFX_GetNumParams(track, fx_index)
end

function copy_vst_param_to_dest_track(src_track, dest_track, vst_name)
  src_track_vst_index = get_vst_index(src_track, vst_name)
  dest_track_vst_index = get_vst_index(dest_track, vst_name)
  
  vst_param = get_vst_num_param(src_track, src_track_vst_index)
  for param=0, vst_param-1 do
    retval, minval, maxval = reaper.TrackFX_GetParam(src_track, src_track_vst_index, param)
    reaper.TrackFX_SetParam(dest_track, dest_track_vst_index, param, retval)
  end
end

function get_vocal_lead_from_selected_track(selected_tracks)
  for track=0,selected_tracks-1 do
    current_name = reaper.GetTrackName(track)
    if current_name == MAIN_TRACK
    then
      return track
    end
  end
end

function copy_vst_param_to_all_dest_tracks(track, selected_tracks)
  for track=0,selected_tracks-1 do
    current_track = reaper.GetSelectedTrack(0, track)
    vst_index = get_vst_index(vocal_lead, VST_NAME)
    vst_param_num = get_vst_num_param(vocal_lead, vst_index)
    copy_vst_param_to_dest_track(vocal_lead, current_track, VST_NAME)
  end
end

selected_tracks = reaper.CountSelectedTracks(0)
vocal_lead_index = get_vocal_lead_from_selected_track(selected_tracks)
vocal_lead = reaper.GetSelectedTrack(0, vocal_lead_index)
copy_vst_param_to_all_dest_tracks(vocal_lead, selected_tracks)