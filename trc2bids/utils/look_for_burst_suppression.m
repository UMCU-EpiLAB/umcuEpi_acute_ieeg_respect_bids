
function bsuppression = look_for_burst_suppression(annots,sfreq)

BS_Start = '200';
BS_Stop  = '201';

start_bs = find(startsWith(annots(:,2),BS_Start));
end_bs   = find(startsWith(annots(:,2),BS_Stop));

if(length(start_bs) ~= length(end_bs))
    error('burst suppression: starts and ends did no match')
end

bsuppression = cell(size(start_bs));

for i = 1:numel(start_bs)
    
    bs          = struct;
    matched_end = find(contains(annots(:,2),BS_Stop));
    
    if(isempty(matched_end))
        error('start and stop %s does not match',annots{start_bs(i),2});
    end
    if(length(matched_end)>1)
        
        matched_end       = matched_end((matched_end-start_bs(i))>0);
        [val,idx_closest] = min(matched_end);
        matched_end       = matched_end(idx_closest);%take the closest in time
    end
    
    bs.pos          = [(annots{start_bs(i),1})/sfreq annots{matched_end,1}/sfreq];
    bsuppression{i} = bs;
end
