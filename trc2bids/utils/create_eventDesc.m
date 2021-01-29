%% create dataset descriptor
function create_eventDesc(proj_dir)

edesc_json.onset.type                           = 'object';
edesc_json.onset.description                    = 'onset of event in seconds';
edesc_json.duration.type                        = 'object';
edesc_json.duration.description                 = 'duration of event in seconds' ;
edesc_json.trial_type.type                      = 'object';
edesc_json.trial_type.description               = 'type of event (good data segment/ artefect at channel level/ period of burstsuppresion/ period of odd behavior)' ;
edesc_json.electrodes_involved.type             = 'object';
edesc_json.electrodes_involved.description      = 'electrodes involved in event.' ;
edesc_json.sample_start.type                    = 'object';
edesc_json.sample_start.description             = 'onset of event in samples' ;
edesc_json.sample_stop.type                     = 'object';
edesc_json.sample_stop.description              = 'offset of event in samples' ;

if ~isempty(edesc_json)
    
    filename = [proj_dir,'events.json'];
    write_json(filename, edesc_json)
end
