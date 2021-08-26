%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_json(filename, json)
json = remove_empty(json);
ft_info('writing %s\n', filename);
if ft_hastoolbox('jsonlab', 3)
    opt.FileName     = filename;
    opt.SingletCell  = 1;
    savejson('', json, opt);
else
    str = jsonencode(json);
    fid = fopen(filename, 'w');
    fwrite(fid, str);
    fclose(fid);
end
try
    fileattrib(filename,'+w','g')
    %disp('json write permissions in output directory set for group')
catch
    warning('Could not automatically set group permissions. /n Check permissions for file %s', filename)
end
