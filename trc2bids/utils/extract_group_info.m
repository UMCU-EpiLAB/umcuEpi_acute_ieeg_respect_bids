
% extract group information
% assumption the included are only grid and strip
function ch_group = extract_group_info(metadata)

    ch_label                                    = metadata.ch_label                    ;
    
    idx_grid                                    = regexpi(ch_label,'Gr[0-9]+')         ;
    idx_grid                                    = cellfun(@isempty,idx_grid)           ; 
    idx_grid                                    = ~idx_grid                            ;
    idx_strip                                   = ~idx_grid & metadata.ch2use_included ;
    
    ch_group                                    = cell(size(metadata.ch2use_included)) ;
    if(any(idx_grid))
        [ch_group{idx_grid}]                    = deal('grid')                         ;
    end
    if(any(idx_strip))
        [ch_group{idx_strip}]                   = deal('strip')                        ;
    end
    if(any(~metadata.ch2use_included))
        [ch_group{ ~metadata.ch2use_included }] = deal('other')                        ;
    end
    
