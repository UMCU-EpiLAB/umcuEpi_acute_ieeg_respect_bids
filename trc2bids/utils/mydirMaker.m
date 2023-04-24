
function mydirMaker(dirname)
if exist(dirname, 'dir')
    warning('%s exist already',dirname)
else
    mkdir(dirname)
    
    try
    fileattrib(dirname,'-w -x','o') % make not-writable and not-executable for other users
    fileattrib(dirname,'+w +x','g') % make writable and executable for group
    %disp('directory permissions in output directory set for group')
    catch
    warning('Could not automatically set group permissions. /n Check permissions for directory %s', dirname)
    end
    
end
