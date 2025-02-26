%% rewrite annotations in trc-files

% this script first extract annotations from a trc-file, rewrites these
% annotations and writes them back to the trc-file. 

% author: Dorien van Blooijs, SEIN Zwolle, 2025

%%% extract annotations %%%

% default: 
% - all subjects should have ses;1 (since only a singe patient has a re-OR
%   for epilepsy)
% - the current ses;situation1 should become run;situation1 etc. 

%%% write annotations %%%

%% patient characteristics & add paths

clear cfg
cfg.sub_labels = {['sub-' input('Patient number (RESPXXXX): ','s')]};
cfg.mode = 'bidsconversion';

% set paths and add them
cfg = setLocalDataPath(cfg);

%% 2) run one single file instead of all files within the input directory

files = dir(cfg.pathname);
eegfiles = {files(contains({files(:).name},'EEG')==1).name};
string = [repmat('%s, ',1,size(eegfiles,2)-1),'%s'];

if size(files,1) <1
    error('Pathname does not contain any files')
else
    fileinput = input(sprintf(['Select one of these files [',string,']: \n'],eegfiles{:}),'s');
end

cfg.filename = fullfile(cfg.pathname,fileinput);

pathsplit = strsplit(cfg.pathname,{'\'});
patient = pathsplit{end};
filesplit = strsplit(fileinput,{'_','.TRC'});
file = filesplit{end-1};

fprintf('Running %s, writing EEG: %s to BIDS \n', patient,file)
extractWriteNotesTRC(cfg);

