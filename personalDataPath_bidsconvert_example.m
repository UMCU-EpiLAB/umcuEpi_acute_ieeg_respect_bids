function cfg = personalDataPath_bidsconvert_example(varargin)

% function that contains local data path, is ignored in .gitignore
% This function is an example!! You should make your own
% personalDataPath_bidsconvert.m where you fill in the correct
% repositories.
% This personalDataPath_bidsconvert.m is ignored in .gitignore and will
% never be visible online! 

if ~isempty(varargin{1})
    if isstruct(varargin{1})
        
        if sum(contains(fieldnames(varargin{1}),'sub_labels'))
            
            foldername = input('Choose SystemPlus-folder: testomgeving, RESPect_acute_ECoG_trc: ','s');
            if strcmp(foldername,'testomgeving')
                cfg.proj_dirinput = '/folder/to/ieeg-files/testomgeving/patients/';
            elseif strcmp(foldername,'RESPect_acute_ECoG_trc')
                cfg.proj_dirinput = '/folder/to/ieeg-files/RESPect_acute_ECoG_trc/patients/';
            else
                error('Foldername is not recognized')
            end
        end
        cfg.proj_diroutput = '/folder/to/BIDS-files/chronic_ECoG/';
        
    end
    pat = [input('What is the PAT-folder in micromed database? [PAT_XXX] ','s'),'/'];
    cfg.pathname = fullfile(cfg(1).proj_dirinput,pat);
    
end

if contains(fieldnames(cfg),'no_fieldtrip')
    cfg.fieldtrip_folder  = '/folder/to/fieldtrip/';
    % copy the private folder in fieldtrip to somewhere else
    cfg.fieldtrip_private = '/folder/to/fieldtrip_private/';
    %%add those later to path to avoid errors with function 'dist'
    rmpath(cfg.fieldtrip_folder)
    rmpath(cfg.fieldtrip_private)
else
    fieldtrip_folder  = '/folder/to/fieldtrip/';
    % copy the private folder in fieldtrip to somewhere else
    fieldtrip_private = '/folder/to/fieldtrip_private/';
end

jsonlab_folder    = '/folder/to/jsonlab/';
addpath(fieldtrip_folder)
addpath(fieldtrip_private)
addpath(jsonlab_folder)
ft_defaults


end
