%% anonymize the TRC file and fill in the RESPect number
% author Dorien van Blooijs
% date: 2019
% Edited Paul Smits 2020

% respect-folder on bulkstorage
% or other scratch folder


%% RESPECT name ---------------------------------------------------------
tempName = input('Respect name (e.g. [RESP0733]): ','s');
cfg.sub_labels = {['sub-' tempName]};
cfg.mode = 'anonymization';

%% set paths
addpath(['..' filesep '..'])
cfg = setLocalDataPath(cfg);

%% prepare for local copy
if cfg.copymethod
    cfg.tempdir='~/matlab_temp/'; 
    fprintf('NB: samba share detected, editing in local copy (%s)\n',cfg.tempdir);
    if ~exist(cfg.tempdir,'dir')
        warning('creating temp matlab_temp directory at %s', cfg.tempdir); mkdir(cfg.tempdir);
    end
end

%% ask for respnumbers
if strcmp(tempName,'') && ~isempty(respName)
    
elseif contains(tempName,'RESP')
    respName = tempName;
else
    error('Respect name is not correct')
end

%% choose the eeg-file ----------------------------------------------------
files=cfg.files;
for i=1:size(files,1)
    if contains(files(i).name,'EEG_')
        filename = files(i).name;
        pathname = cfg.proj_dirinput;
        fileName = [pathname, filename];
        % create local copy if necessary
        if cfg.copymethod
            assert(copyfile(fileName,cfg.tempdir),'Could not copy file to local directory %s', cfg.tempdir)
            fileName = [cfg.tempdir, filename];
        end
        
        % anonymize the TRC file    
        fprintf('Anonymising: %s\n',filename);
        [status,msg] = anonymized_asRecorded(fileName,respName)
        
        % overwrite and clear temp directory
        if cfg.copymethod && ~status
            assert(copyfile(fileName,pathname),'Could not copy file to remote directory %s',pathname);
            delete(fileName);
        end
    end
end
fprintf('Anonymised files in: %s\n\n',cfg.proj_dirinput);

