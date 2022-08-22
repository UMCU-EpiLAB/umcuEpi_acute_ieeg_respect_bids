
function mydirMaker(dirname)
if exist(dirname, 'dir')
    warning('%s exist already',dirname)
else
    mkdir(dirname)
    
    try
    fileattrib(dirname,'+w','g')
    %disp('directory permissions in output directory set for group')
    catch
    warning('Could not automatically set group permissions. /n Check permissions for directory %s', dirname)
    end
    
end
