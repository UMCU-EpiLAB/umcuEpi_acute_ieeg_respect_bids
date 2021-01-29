
function create_chanDesc(proj_dir)

chandesc_json.name                  = 'Name of the channel';
chandesc_json.type                  = 'Type of signal measured with the channel';
chandesc_json.units                 = 'Unit of the channel';
chandesc_json.low_cutoff            = 'Cut-off value of the low-pass filter';
chandesc_json.high_cutoff           = 'Cut-off value of the high-pass filter';
chandesc_json.reference             = 'The reference of the channel';
chandesc_json.group                 = 'Group to which the channel belongs, this can be grid, strip, depth or other';
chandesc_json.sampling_frequency    = 'Sampling frequency of the channel';
chandesc_json.notch                 = 'If a notch filter is applied';
chandesc_json.status                = 'The status of the channel';
chandesc_json.status_description    = 'The description that belongs to the status of the channel';
chandesc_json.chan_recording        = 'Number that corresponds to the channel in SystemPlus and BrainQuick';

if ~isempty(chandesc_json)
    
    filename = [proj_dir,'channels.json'];
    if isfile(filename)
        existing = read_json(filename);
    else
        existing = [];
    end
    write_json(filename, mergeconfig(existing, chandesc_json))
end
end
