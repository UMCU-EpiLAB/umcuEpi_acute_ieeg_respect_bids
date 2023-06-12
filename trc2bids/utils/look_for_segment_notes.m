
function triggersub = look_for_segment_notes(annots,sfreq,segstarts,segstops)

if ~iscell(segstarts),segstarts={segstarts};end
if ~iscell(segstops),segstops={segstops};end

start_seg =[];
end_seg = [];
for i=numel(segstarts)
    Seg_Start = segstarts{i};
    Seg_Stop = segstops{i};
    
    start_seg = [start_seg;find(startsWith(annots(:,2),Seg_Start))];
    end_seg   = [end_seg;find(startsWith(annots(:,2),Seg_Stop))];


    if(length(start_seg) ~= length(end_seg))
        error([start_seg, ' notes: starts and ends did no match'])
    end
end

triggersub = cell(size(start_seg));

for i = 1:numel(start_seg)
    
    segment          = struct;
    matched_end = find(contains(annots(:,2),Seg_Stop));
    
    if(isempty(matched_end))
        error('start and stop %s does not match',annots{start_seg(i),2});
    end
    if(length(matched_end)>1)
        
        matched_end       = matched_end((matched_end-start_seg(i))>0);
        [val,idx_closest] = min(matched_end);
        matched_end       = matched_end(idx_closest);%take the closest in time
    end
    
    segment.pos          = [(annots{start_seg(i),1})/sfreq annots{matched_end,1}/sfreq];
    triggersub{i} = segment;
end
