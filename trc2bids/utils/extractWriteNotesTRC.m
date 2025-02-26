function extractWriteNotesTRC(cfg)

[annotationsTRC, note_offset] = extractNotesTRC(cfg.filename);
idx_sit = contains(annotationsTRC(:,2),'Situation');
annotationsTRC{idx_sit,2} = replace(annotationsTRC{idx_sit,2},annotationsTRC{idx_sit,2},['Run;',annotationsTRC{idx_sit,2}]);
samp_ses = ceil((annotationsTRC{idx_sit,1} + annotationsTRC{find(idx_sit,1,'first')+1,1})/2);
sizeAnnot = size(annotationsTRC,1);
annotationsTRC{sizeAnnot+1,1} = samp_ses;
annotationsTRC{sizeAnnot+1,2} = 'Ses;1';

[~,I] = sort([annotationsTRC{:,1}]);
annotationsSorted = annotationsTRC(I,:);

%% delete duplicated annotations

[~,~,ic1] = unique([annotationsSorted{:,1}],'stable'); % find duplicate samples
[~,~,ic2] = unique(annotationsSorted(:,2),'stable'); % find duplicate texts

% make sure that the annotation note is an exact duplicate, so both in
% sample and in text! Otherwise, keep both and check manually
ib = NaN(1);
nCount = 1;
for nIC1 = 1:max(ic1)
    val = find(ic1 == nIC1);
    if size(val,1) == 2 % if samples are duplicate, check whether text is duplicate
        if ic2(val(1)) == ic2(val(2)) % if texts are duplicate
            ib(nCount) = val(1);
            nCount = nCount+1;
        end
    elseif size(val,1) == 1
        ib(nCount) = val(1);
        nCount = nCount+1;
    end

end

annotationsUnique = horzcat(annotationsSorted(ib,1), annotationsSorted(ib,2));

writeNotesTRC(cfg.filename, annotationsUnique, note_offset)

end


