function convertTRC2brainvision(cfg,ieeg_dir, fieeg_name)

filename = cfg.filename;

% file ieeg of the recording to .vhdr extension
% fileTRC = cell(1);
% fileVHDR = cell(1);
% fileVHDRcopy = cell(1);


fileTRC  = fullfile(ieeg_dir,fieeg_name);
fileVHDR = replace(fileTRC,'.TRC','.vhdr');

%% create Brainvision format from TRC

temp = [];
temp.dataset                     = filename;
temp.continuous = 'yes';
data2write = ft_preprocessing(temp);

temp = [];
temp.outputfile                  = fileVHDR;

temp.method = 'convert';
temp.writejson = 'no';
temp.writetsv = 'no';
temp.ieeg.writesidecar = 'no';

% write .vhdr, .eeg, .vmrk
data2bids(temp, data2write)

% fix group permissions
newFiles=replace(temp.outputfile,'vhdr','*');
try
    fileattrib(newFiles,'+w','g')
    %disp('vhdr,eeg,vmrk file permissions in output directory set for group')
catch
    warning('Could not automatically set group permissions. /n Check permissions for files %s', newFiles)
end

end