function [artefacts] = look_for_annotation_start_stop(annots,str_start,str_stop,ch,sfreq)

start_art = find(contains(annots(:,2),str_start));
end_art   = find(contains(annots(:,2),str_stop));

if(length(start_art) ~= length(end_art))
    error('starts and ends did no match')
end

artefacts = cell(size(start_art));

for i = 1:numel(start_art)
    art         = struct;
    matched_end = find(contains(annots(:,2),replace(annots{start_art(i),2},str_start,str_stop)));
    
    if(isempty(matched_end))
        error('start and stop %s does not match',annots{start_art(i),2});
    end
    if(length(matched_end)>1)
        matched_end       = matched_end((matched_end-start_art(i))>0);
        [val,idx_closest] = min(matched_end);
        matched_end       = matched_end(idx_closest);%take the closest in time
    end
    ch_art_idx = parse_annotation(annots{start_art(i),2},ch);
    
    
    art.ch_names = {ch{logical(ch_art_idx)}};
    
    art.pos = [(annots{start_art(i),1})/sfreq annots{matched_end,1}/sfreq];
    artefacts{i} = art;
end
