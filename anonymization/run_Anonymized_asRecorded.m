%% anonymize the TRC file and fill in the RESPect number
% author Dorien van Blooijs
% date: 24-1-2019
% Edited Paul Smits
% 2020

% clc

% respect-folder on bulkstorage
% or other scratch folder
cfg.proj_dirinput = '~/RESPsand/RESPect_scratch/Archive Micromed/PAT_7';
patterns={};

%% check input and dir
if cfg.proj_dirinput(end) ==filesep; else cfg.proj_dirinput=[cfg.proj_dirinput filesep]; end

files = dir(cfg.proj_dirinput);
assert(~isempty(files),'Cannot locate trc files, check if remote directory (e.g. RESPsand) was properly mounted.')

cfg.copymethod = contains(files(1).folder,'smb'); % true if samba share
if cfg.copymethod
    cfg.tempdir='~/matlab_temp/'; 
    fprintf('NB: samba share detected, editing in local copy (%s)\n',cfg.tempdir);
    if ~exist(cfg.tempdir,'dir')
        warning('creating temp matlab_temp directory at %s', cfg.tempdir); mkdir(cfg.tempdir);
    end
end

%% RESPECT name ---------------------------------------------------------
tempName = input('Respect name (e.g. [RESP0733]): ','s');

if strcmp(tempName,'') && ~isempty(respName)
    
elseif contains(tempName,'RESP')
    respName = tempName;
else
    error('Respect name is not correct')
end

%% check entered resp number
% addpath /home/paul/Documents/MATLAB/aes
% load('~/Documents/MATLAB/CryptArray.mat')
% PID=uint32(decryptentry(CryptArray,respName));
% answer = questdlg(sprintf('Are you anonymising patient with number: %u\n',PID),'Patient check');
% switch answer
%     case 'Yes'
%         fprintf('Anonymising patient: %u\n\n',PID);
%         clear PID      
%     case 'No'
%         fprintf('User: incorrect patient number: %u\n',PID);
%         clear PID
%         error('Patient number must match data')
%     otherwise
%         clear PID
%         error('Anonymisation operation aborted by user')
% end

%% ask for respnumbers
% answer=inputdlg('Patterns to search for', 'Search header for patterns?',6);
% 
% for h=size(answer{1},1):-1:1
%     patterns{h}=strtrim(answer{1}(h,:));
% end



%% choose the eeg-file ----------------------------------------------------


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
        [status,msg] = anonymized_asRecorded(fileName,respName,patterns)
        
        % overwrite and clear temp directory
        if cfg.copymethod && ~status
            assert(copyfile(fileName,pathname),'Could not copy file to remote directory %s',pathname);
            delete(fileName);
        end
    end
end
fprintf('Anonymised files in: %s\n\n',cfg.proj_dirinput);
%% TRC to bids
% 
% cfg.proj_dirinput = '/home/dorien/Desktop/bulk/smb-share:server=smb-ds.bsc01.gd.umcutrecht.nl,share=ds_her_respect-leijten/Dorien/c_ecog/sz_cle/RESPect_sz_scratch/patients';
% cfg.proj_diroutput = '/Fridge/CCEP';
% 
% [filename, pathname] = uigetfile('*.TRC;*.trc','Select *.TRC file',[cfg.proj_dirinput]);
% cfg.filename = [pathname,filename];
%         
% pathsplit = strsplit(pathname,{'/'});
% patient = pathsplit{end-1};
% filesplit = strsplit(filename,{'_','.TRC'});
% file = filesplit{end-1};
% 
% fprintf('Running %s, writing EEG: %s to BIDS \n', patient,file)
% 
% [status,msg,output ] = annotatedTRC2bids_cECoG(cfg)

