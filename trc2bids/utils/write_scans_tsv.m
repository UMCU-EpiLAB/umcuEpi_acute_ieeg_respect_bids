function write_scans_tsv(cfg,metadata,events_tsv,fscans_name,fieeg_json_name)

    f = replace(fieeg_json_name,'.json','.eeg');
    
    file_name = fullfile(cfg.sub_dir,fscans_name);
    
    files = dir(cfg.sub_dir);
    if contains([files(:).name],'scans.tsv')
        
        % read existing scans-file
        scans_tsv = read_tsv(file_name);
        
        if any(contains(scans_tsv.filename,f))
            scansnum = find(contains(scans_tsv.filename,f) ==1);
        else
            scansnum = size(scans_tsv,1)+1;
        end
        
        filename                    = scans_tsv.filename;
        acq_time                    = scans_tsv.acq_time;
        good_segments_duration      = scans_tsv.good_segments_duration;
        good_segments_number        = scans_tsv.good_segments_number;
        artefact_number             = scans_tsv.artefact_number;
        artefact_number_electrodes  = scans_tsv.artefact_number_electrodes;
        burstsuppression_duration   = scans_tsv.burstsuppression_duration;
        oddbehavior_duration        = scans_tsv.oddbehavior_duration;
        
    else
        scansnum = 1;
    end
    
    filename{scansnum,1}              = [cfg.ieeg_dir(length(cfg.sub_dir)+2:end),'/' f]; 
    
    % acquisition time
    time_original                     = datetime(metadata.recyear,metadata.recmonth,metadata.recday,...
        str2double(metadata.hour),str2double(metadata.min),str2double(metadata.sec),'Format','yyyy-MM-dd''T''HH:mm:ss.SSSSSSS'); 
    if isempty(metadata.reductions)
        acq_time(scansnum,1)              = time_original;
    else
        acq_time(scansnum,1)              = time_original + seconds(metadata.reductions(1,1)/metadata.Rate_Min);
    end
    
    % good data segments
    id_good = strcmp(events_tsv.trial_type,'good data segment');
    if sum(id_good)>0
    annotgood = find(id_good==1);
    for i = 1:sum(id_good)
        duration_good(i,1) = str2double(events_tsv.duration{annotgood(i)});
    end
    good_segments_duration(scansnum,1)           = sum(duration_good);
    good_segments_number(scansnum,1)             = sum(id_good);
    else
        good_segments_duration(scansnum,1) = 0;
        good_segments_number(scansnum,1) = 0;
    end
    
    % artefacts
    id_artefact = strcmp(events_tsv.trial_type,'artefact');
    if sum(id_artefact)>0
    annotartefact = find(id_artefact==1);
    
    for i = 1:sum(id_artefact)
        onset_artefact(i,1) = str2double(events_tsv.onset{annotartefact(i)});
        ch_artefact{i,1} = events_tsv.electrodes_involved{annotartefact(i)};
    end
    artefact_number(scansnum,1)           = size(unique(onset_artefact),1);
    artefact_number_electrodes(scansnum,1)  = size(unique(ch_artefact),1);
    else
        artefact_number(scansnum,1) = 0;
        artefact_number_electrodes(scansnum,1) = 0;
    end
    
    % burst suppression
    id_bs = strcmp(events_tsv.trial_type,'burst-suppression');
    if sum(id_bs)>0
    annotbs = find(id_bs==1);
    for i = 1:sum(id_bs)
        duration_bs(i,1) = str2double(events_tsv.duration{annotbs(i)});
    end
    burstsuppression_duration(scansnum,1) = sum(duration_bs);
    else
        burstsuppression_duration(scansnum,1)=0;
    end
    
    % oddbehavior
    id_ob = strcmp(events_tsv.trial_type,'odd behavior');
    if sum(id_ob)>0
    annotob = find(id_ob==1);
    for i = 1:sum(id_ob)
        duration_ob(i,1) = str2double(events_tsv.duration{annotob(i)});
    end
    oddbehavior_duration(scansnum,1) = sum(duration_ob);
    else
        oddbehavior_duration(scansnum,1)=0;
    end
    
    % sorts table based on situation number 
        [~,I] = sortrows([filename]);
        
        filename = filename(I);
        acq_time = acq_time(I);
        good_segments_duration = good_segments_duration(I);
        good_segments_number = good_segments_number(I);
        artefact_number = artefact_number(I);
        artefact_number_electrodes = artefact_number_electrodes(I);
        burstsuppression_duration = burstsuppression_duration(I);
        oddbehavior_duration = oddbehavior_duration(I);
        
    scans_tsv  = table(filename, acq_time, good_segments_duration, good_segments_number, artefact_number, artefact_number_electrodes, burstsuppression_duration, oddbehavior_duration,...
        'VariableNames',{'filename', 'acq_time', 'good_segments_duration','good_segments_number','artefact_number', 'artefact_number_electrodes',...
        'burstsuppression_duration','oddbehavior_duration'});
    
    if ~isempty(scans_tsv)
        
        write_tsv(file_name, scans_tsv);
    end
end