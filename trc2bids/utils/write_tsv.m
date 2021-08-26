%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_tsv(filename, tsv)
ft_info('writing %s\n', filename);
writetable(tsv, filename, 'Delimiter', 'tab', 'FileType', 'text');
try
    fileattrib(filename,'+w','g')
    %disp('tsv write permissions in output directory set for group')
catch
    warning('Could not automatically set group permissions. /n Check permissions for file %s', filename)
end
%%%%%