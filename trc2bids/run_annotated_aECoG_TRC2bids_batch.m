% Run annotated aECoG data to BIDS in batch/single patient/single file mode

% author Matteo Demuru, Dorien van Blooijs, Willemiek Zweiphenning
% year 2019
% adjusted by Eline Schaft, 2020

%% patient characteristics & add paths

clear cfg
cfg.sub_labels = {['sub-' input('Patient number (RESPXXXX): ','s')]};
cfg.mode = 'bidsconversion';

% set paths and add them
cfg = setLocalDataPath(cfg);

%% conversion annotated TRC2BIDS
% Different options:
% 1a) run all files in patient-folder
% 1b) run files which gave errors again
% 2)  run one single file instead of all files within the input directory
% 3a) run all patients in database
% 3b) run files which gave errors again
% 4a) run files off list of patient folders

%% 1a) run all files in patient-folder

files = dir(cfg.pathname);
runall = struct; % For save message for every TRC file
cfg.runall=1;

if size(files,1)<1
    error('Pathname is wrong, no files found')
end

% run all files within your input directory
n = 1;
for i=1:size(files,1)
    runall(i).file = files(i).name;
    if contains(files(i).name,'EEG_')
        
        cfg.filename = fullfile(cfg.pathname,files(i).name);
        
        pathsplit = strsplit(cfg.pathname,{'/'});
        patient = pathsplit{end-1};
        filesplit = strsplit(files(i).name,{'_','.TRC'});
        file = filesplit{end-1};
        
        fprintf('Running %s, writing EEG: %s to BIDS \n', patient,file)
        [runall(i).status,runall(i).msg,runall(i).output] = annotatedTRC2bids(cfg,n);
        
        n = n+1;
    end
end

if any([runall(:).status])
    disp('All runs are done, but some still have errors. Fix them manually!')
else
    disp('All runs are completed')
end

%% 1b) run files which gave errors again

cfg.runall = 0;
for i=1:size(runall,2)
    
    if runall(i).status ==1 
        % There was an error in the previous run
        cfg.filename = fullfile(cfg.pathname,runall(i).file);
        
        pathsplit = strsplit(cfg.pathname,{'/'});
        patient = pathsplit{end-1};
        filesplit = strsplit(runall(i).file,{'_','.TRC'});
        file = filesplit{end-1};
        
        fprintf('Running %s, writing EEG: %s to BIDS \n', patient,file)
        [runall(i).status,runall(i).msg,runall(i).metadata,runall(i).annots] = annotatedTRC2bids(cfg,1);
        
    end
end

if any([runall(:).status])
    disp('All runs are done, but some still have errors')
else
    disp('All runs are completed')
end

%% 2) run one single file instead of all files within the input directory

files = dir(cfg.pathname);
eegfiles = {files(contains({files(:).name},'EEG')==1).name};
string = [repmat('%s, ',1,size(eegfiles,2)-1),'%s'];
cfg.runall = 0;

if size(files,1) <1
    error('Pathname does not contain any files')
else
    fileinput = input(sprintf(['Select one of these files [',string,']: \n'],eegfiles{:}),'s');
end

cfg.filename = fullfile(cfg.pathname,fileinput);

pathsplit = strsplit(cfg.pathname,{'/'});
patient = pathsplit{end};
filesplit = strsplit(fileinput,{'_','.TRC'});
file = filesplit{end-1};

fprintf('Running %s, writing EEG: %s to BIDS \n', patient,file)
[status,msg,output] = annotatedTRC2bids(cfg,1);

if status
    disp('Run is done, but still had an error')
else
    disp('Run is completed')
end



%% 3a) run all patients in database

pats = dir(cfg.proj_dirinput);
runpat = struct;
cfg.runall=1;

for pat = 1:size(pats,1)
    
    if contains(pats(pat).name,'PAT')
        n = 1;
        cfg.pathname = [fullfile(dbdir,pats(pat).name),'/'];
        
        files = dir(cfg.pathname);
        
        if size(files,1)<1
            error('Pathname is wrong, no files found')
        end
        
        % run all files within your input directory
        for i=1:size(files,1)
            runpat(pat).runall(i).file = files(i).name;
            if contains(files(i).name,'EEG_')
                
                cfg.filename = fullfile(cfg.pathname,files(i).name);
                
                pathsplit = strsplit(cfg.pathname,{'/'});
                patient = pathsplit{end-1};
                filesplit = strsplit(files(i).name,{'_','.TRC'});
                file = filesplit{end-1};
                
                fprintf('Running %s, writing EEG: %s to BIDS \n', patient,file)
                [runpat(pat).runall(i).status,runpat(pat).runall(i).msg,runpat(pat).runall(i).output] = annotatedTRC2bids(cfg,n);
                
                n = n+1;
            end
        end
        
        if any([runpat(pat).runall(:).status])
            disp('All runs are done, but some still have errors. Fix them manually!')
        else
            disp('All runs are completed')
        end
    end
end

% check which patients do not run without errors
if contains(fieldnames(runpat),'status')
    runpat = rmfield(runpat, 'status');
end

for i=1:size(runpat,2)
    
    if ~isempty(runpat(i).runall)
        
        if any(vertcat(runpat(i).runall(:).status) == 1)
            
            runpat(i).status = 1;
            
        else
            runpat(i).status = 0;
            
            
        end
    end
end

disp(['The number of patients with at least one error is ', num2str(sum([runpat(:).status]))]);


%% 3b) run files which gave errors again

cfg.runall = 0;

for pat=1:size(runpat,2)
    
    if runpat(pat).status == 1
        
        for i=1:size(runpat(pat).runall,2)
            if runpat(pat).runall(i).status == 1
                
                cfg.filename = fullfile(cfg(1).proj_dirinput,runpat(pat).pat,runpat(pat).runall(i).file);
                
                fprintf('Running %s, writing EEG: %s to BIDS \n', runpat(pat).pat,runpat(pat).runall(i).file)
                [runpat(pat).runall(i).status,runpat(pat).runall(i).msg,runpat(pat).runall(i).metadata,runpat(pat).runall(i).annots] = annotatedTRC2bids(cfg,1);
            end
        end
    end
end

% check which patients do not run without errors
if contains(fieldnames(runpat),'status')
    runpat = rmfield(runpat, 'status');
end

for i=1:size(runpat,2)
    
    if ~isempty(runpat(i).runall)
        
        if any(vertcat(runpat(i).runall(:).status) == 1)
            
            runpat(i).status = 1;
            
        else
            runpat(i).status = 0;
            
            
        end
    end
end
    
disp(['The number of patients with at least one error is ', num2str(sum([runpat(:).status]))]);

%% 4a)
runpat = struct;
cfg.runall=1;
% 36,44,61,294,84,89,92,94,95,103,111,117,118,132,147,149,150,154,158,159,166,171,174,
% 196,199,216,217,222,233,265,267,270,275,277,279,293,292,289,288,287,286
runs = [172, 356 354 183 184 332 360 333 342 321 329 317 193 334 198 343 ...
    204 212 215 242]; %[35,36,44,61,294,84,89,92,94,95,103,111,117,118,132,147,149,150,154,158,159,166,171,174, ...
    %196,199,216,217,222,233,265,267,270,275,277,279,293,292,289,288,287,286];
for pat = 1:length(runs)
    
        n = 1;
        cfg.pathname = [fullfile(cfg.proj_dirinput,['/PAT_',num2str(runs(pat))]),'/'];
        
        files = dir(cfg.pathname);
        
        if size(files,1)<1
            error('Pathname is wrong, no files found')
        end
        
        % run all files within your input directory
        for i=1:size(files,1)
            runpat(pat).runall(i).file = files(i).name;
            if contains(files(i).name,'EEG_')
                
                cfg.filename = fullfile(cfg.pathname,files(i).name);
                
                pathsplit = strsplit(cfg.pathname,{'/'});
                patient = pathsplit{end-1};
                filesplit = strsplit(files(i).name,{'_','.TRC'});
                file = filesplit{end-1};
                
                fprintf('Running %s, writing EEG: %s to BIDS \n', patient,file)
                [runpat(pat).runall(i).status,runpat(pat).runall(i).msg,runpat(pat).runall(i).output] = annotatedTRC2bids(cfg,n);
                
                n = n+1;
            end
        end
        
        if any([runpat(pat).runall(:).status])
            disp('All runs are done, but some still have errors. Fix them manually!')
        else
            disp('All runs are completed')
        end
end

% check which patients do not run without errors
if contains(fieldnames(runpat),'status')
    runpat = rmfield(runpat, 'status');
end

for i=1:size(runpat,2)
    
    if ~isempty(runpat(i).runall)
        
        if any(vertcat(runpat(i).runall(:).status) == 1)
            
            runpat(i).status = 1;
            
        else
            runpat(i).status = 0;
            
            
        end
    end
end

disp(['The number of patients with at least one error is ', num2str(sum([runpat(:).status]))]);
