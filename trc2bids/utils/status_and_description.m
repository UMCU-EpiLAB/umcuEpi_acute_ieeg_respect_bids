

function [ch_status,ch_status_desc]=status_and_description(metadata)

ch_label                                                        = metadata.ch_label                         ;

ch_status                                                       = cell(size(metadata.ch2use_included))      ;
ch_status_desc                                                  = cell(size(metadata.ch2use_included))      ;

idx_ecg                                                         = ~cellfun(@isempty,regexpi(ch_label,'ECG'));
idx_ecg                                                         = idx_ecg                                  ;
idx_mkr                                                         = ~cellfun(@isempty,regexpi(ch_label,'MKR'));
idx_mkr                                                         = idx_mkr                                  ;
% channels which are open but not recording 
ch_open                                                         = ~(metadata.ch2use_included | ...
                                                                    metadata.ch2use_bad      | ...
                                                                    metadata.ch2use_cavity   | ...
                                                                    metadata.ch2use_silicon  | ...
                                                                    idx_ecg                  | ...
                                                                    idx_mkr                    ...
                                                                    )                                       ;  

[ch_status{:}]                                                  = deal('good')                              ;        

if(any(metadata.ch2use_bad             | ... 
               metadata.ch2use_cavity  | ...
               metadata.ch2use_silicon ...
                                        )) 

    [ch_status{(metadata.ch2use_bad    | ... 
               metadata.ch2use_cavity  | ...
               metadata.ch2use_silicon   ...       
           )}] = deal('bad');
end

if (any(ch_open))
    [ch_status{ch_open}] = deal('bad');
end

%% status description
if(any(metadata.ch2use_included))
    [ch_status_desc{metadata.ch2use_included}] = deal('included');
end

if(any(metadata.ch2use_bad))
    [ch_status_desc{metadata.ch2use_bad}] = deal('noisy (visual assessment)');
end

if(any(metadata.ch2use_cavity))
    [ch_status_desc{metadata.ch2use_cavity}] = deal('cavity');
end

if(any(metadata.ch2use_silicon))
    [ch_status_desc{metadata.ch2use_silicon}] = deal('silicon');
end

if(any(ch_open))
    [ch_status_desc{ch_open}] = deal('not recording');
end
                                                        
if(sum(idx_ecg))
    [ch_status_desc{idx_ecg}] = deal('not included');
end
if(sum(idx_mkr))
    [ch_status_desc{idx_mkr}] = deal('not included');
end
