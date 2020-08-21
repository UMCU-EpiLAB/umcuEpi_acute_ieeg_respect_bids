%% extract all metadata needed for bids structure

% annots - annotations of the trc file
% ch     - channel labels of all channels in the trc file

function [status,msg,metadata] = extract_metadata_from_annotations(annots,ch,trigger,patName,sfreq)
try
    status   = 0;
    metadata = [];
    
    %Codes for start and stop of good segments
    BEG_GS = 222;
    END_GS = 223;
    
    ART_Start = 'xxx';
    ART_STOP  = 'yyy';
    
    ODD_Start = 'vvv';
    ODD_STOP  = 'www';
    
    trig_pos  = trigger(1,:);
    trig_v    = trigger(2,:);
    
    %% Check the compulsory fields
    % Included; markers; situation name;Bad;(Bad field can appear more than once)
    % Resected;Edges;Format
    
    
    %situation
    sit_idx = cellfun(@(x) contains(x,{'Situation'}),annots(:,2));
    if(sum(sit_idx)~=1)
        status = 1;
        error('Missing situation annotation (example "Situation 1A") or too many situation annotation')
    end
    metadata.sit_name = annots{sit_idx,2};
    
    % useful channels
    
    metadata.ch2use_included = single_annotation(annots,'Included',ch);
    
    
    % markers start and stop good segments
    begins = find(trig_v == BEG_GS);
    ends   = find(trig_v == END_GS);
    if(isempty(begins) || isempty(ends) )
        status = 1;
        error('Missing markers for good segments %i %i',BEG_GS,END_GS);
    end
    if(length(begins)~=length(ends))
        status = 1;
        error('Missing start or stop Trigger');
    end
    
    for i=1:numel(begins)
        if(~issorted([trig_pos(begins(i)) trig_pos(ends(i))],'ascend'))
            status = 1;
            error('Trigger are not consecutive')
        end
    end
    
    
    %% Look for bad channels
    metadata.ch2use_bad = single_annotation(annots,'Bad',ch);
    
    % cavity and silicon are not onmi present
    %% Look for cavity
    cavity_idx             = cellfun(@(x) contains(x,{'Cavity'}),annots(:,2));
    metadata.ch2use_cavity = false(size(ch));
    if(sum(cavity_idx))
        metadata.ch2use_cavity = single_annotation(annots,'Cavity',ch);
    end
    %% Look for silicon
    silicon_idx             = cellfun(@(x) contains(x,{'Silicon'}),annots(:,2));
    metadata.ch2use_silicon = false(size(ch));
    if(sum(silicon_idx))
        metadata.ch2use_silicon = single_annotation(annots,'Silicon',ch);
    end
    
   
    
    %% Look for artefacts
    
    metadata.artefacts = look_for_annotation_start_stop(annots,'xxx','yyy',ch,sfreq);
    
    
    %% look for odd behaviour in the recordings additional notes
    
    metadata.add_notes = look_for_annotation_start_stop(annots,'vvv','www',ch,sfreq);
    
    
    %% look for burst suppression
    
    metadata.bsuppression = look_for_burst_suppression(annots,sfreq);
    
    
    
    %%look for Format
    %TODO double check for the syntax
    
    format_idx=cellfun(@(x) contains(x,{'Format'}),annots(:,2));
    if(sum(format_idx)<1)
        status = 1;
        error('Missing Format annotation (example "Format;Gr[5x4];")')
    end
    metadata.format_info = annots{format_idx,2};
    
    
    resected_required = regexpi(metadata.sit_name,'situation 1.');
    if(resected_required)
        %% look for resected channels
        metadata.ch2use_resected = single_annotation(annots,'Resected',ch);
        %% look for edges channels
        metadata.ch2use_edges    = single_annotation(annots,'Edge',ch);
    else
        metadata.ch2use_resected = [];
        metadata.ch2use_edges    = [];
    end
    
    %% add triggers
    
    metadata.trigger.pos  = trigger(1,:) / sfreq  ;
    metadata.trigger.val  = trigger(end,:);
    
    metadata.sfreq = sfreq; 
    %% add channel labels
    
    metadata.ch_label = ch;
    
    status = 0 ;
    msg    = '';
    %
catch ME
    status = 1;
    msg = sprintf('%s err:%s --func:%s',deblank(patName'),ME.message,ME.stack(1).name);
    
end
