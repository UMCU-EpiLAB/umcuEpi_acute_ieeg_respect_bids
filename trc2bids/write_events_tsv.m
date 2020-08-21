%% write annotations to a tsv file _events

function write_events_tsv(metadata,cfg)

%% type / sample start / sample end /  chname;
ch_label  = metadata.ch_label;

metadata;

type      = {};
s_start   = {};
s_end     = {};
ch_name   = {};
onset     = {};
duration  = {};

cc        = 1;
%% artefacts
artefact = metadata.artefacts;

if(~isempty(artefact))
    for i = 1 : numel(artefact)
        
        curr_ch = artefact{i}.ch_names;
        if(isempty(curr_ch))
                error('artefact channel name wrong')
        end
        
        for j = 1 : numel(curr_ch)
            
            type{cc}     = 'artefact'                           ;
            s_start{cc}  = num2str(artefact{i}.pos(1) * metadata.sfreq)           ;
            s_end{cc}    = num2str(artefact{i}.pos(end) * metadata.sfreq )        ;
            ch_name{cc}  = curr_ch{j}; 
            onset{cc}    = num2str(artefact{i}.pos(1));
            duration{cc} = num2str(artefact{i}.pos(end)-artefact{i}.pos(1));
            
            cc          = cc + 1                               ;
        end
    end
end
%% bsuppression
bsuppression = metadata.bsuppression;

if(~isempty(bsuppression))
    for i=1:numel(bsuppression)

        type{cc}     = 'bsuppression'                       ;
        s_start{cc}  = num2str(bsuppression{i}.pos(1) * metadata.sfreq)       ;
        s_end{cc}    = num2str(bsuppression{i}.pos(end) * metadata.sfreq )    ;
        ch_name{cc}  = 'all';
        onset{cc}    = num2str(bsuppression{i}.pos(1));
        duration{cc} = num2str(bsuppression{i}.pos(end)-bsuppression{i}.pos(1));
           
        cc          = cc + 1                               ;

    end
end

%% addnotes
addnotes = metadata.add_notes;

if(~isempty(addnotes))
    for i=1:numel(addnotes)

        curr_ch = addnotes{i}.ch_names;
        if(isempty(curr_ch))
                error('artefact channel name wrong')
        end
        
        for j = 1 : numel(curr_ch)
            type{cc}     = 'oddbehaviour'                       ;
            s_start{cc}  = num2str(addnotes{i}.pos(1) * metadata.sfreq )          ;
            s_end{cc}    = num2str(addnotes{i}.pos(end)* metadata.sfreq )        ;
            ch_name{cc}  = num2str(curr_ch{j})                  ;
            onset{cc}    = num2str(addnotes{i}.pos(1))          ;
            duration{cc} = num2str(addnotes{i}.pos(end)-addnotes{i}.pos(1));
      
            cc          = cc + 1                               ;
        end
    end
end


%% triggers for good epochs
trigger = metadata.trigger;
BEG_GS  = 222             ;
END_GS  = 223             ;

if(~isempty(trigger))
    idx_begins  = find(trigger.val==BEG_GS);
    idx_ends    = find(trigger.val==END_GS);
    
    for i=1:numel(idx_begins)

        type{cc}     = 'trial'                               ;
        s_start{cc}  = trigger.pos(idx_begins(i)) * metadata.sfreq  ;
        s_end{cc}    = trigger.pos(idx_ends(i)) * metadata.sfreq    ;
        ch_name{cc}  = 'ALL'                                 ;
        onset{cc}    = num2str(trigger.pos(idx_begins(i)))          ;
        duration{cc} = num2str(trigger.pos(idx_ends(i)) - trigger.pos(idx_begins(i)));
        
        cc          = cc + 1                                ;

    end
end



%onset	duration	trial_type	sample_start	sample_end

%events_tsv  = table( type', s_start', s_end', ch_name' , ...
%                        'VariableNames',{'type', 'start', 'stop', 'channel' });
events_tsv  = table( onset', duration' ,type', s_start', s_end', ch_name' , ...
                        'VariableNames',{'onset','duration','trial_type', 'sample_start', 'sample_stop', 'electrode_involved' });
if ~isempty(events_tsv)
    [p, f, x] = fileparts(cfg.outputfile);
    
    filename = fullfile(p, [f '_events.tsv']);
    filename = replace(filename,'_ieeg','');
    %filename = replace(filename,'_task-acute','')
    if isfile(filename)
        existing = read_tsv(filename);
    else
        existing = [];
    end % try
    if ~isempty(existing)
        ft_error('existing file is not empty');
    end
    write_tsv(filename, events_tsv);
end
