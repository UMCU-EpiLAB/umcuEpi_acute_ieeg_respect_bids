function cfg = personalDataPath_anonymization_example(varargin)

% function that contains local data path, is ignored in .gitignore
% This function is an example!! You should make your own
% personalDataPath_anonymization.m where you fill in the correct
% repositories.
% This personalDataPath_anonymization.m is ignored in .gitignore and will
% never be visible online!

if ~isempty(varargin{1})
    if isstruct(varargin{1})
        if strcmp(varargin{1}.mode,'anonymization')
            
            cfg.proj_dirinput = '/folder/to/copies/trc-files/temp_ecog/';
            tempName = varargin{1}.sub_labels{:};
            
            % check whether RESP-number is entered correctly
            if strcmp(tempName,'') && ~isempty(respName)
                
            elseif contains(tempName,'RESP')
                cfg.respName = tempName;
            else
                error('RESPect name is not correct')
            end
            
        else
            if sum(contains(fieldnames(varargin{1}),'sub_labels'))
                % for conversion trc-file to BIDS
                if strcmp(varargin{1}.mode,'bidsconversion')                    
                    % FILL IN THE SYSTEMPLUS FOLDERS YOU USE FOR
                    % YOURSELF!
                    foldername = input('Choose SystemPlus-folder: testomgeving, RESPect_acute_ECoG_trc: ','s');
                    if strcmp(foldername,'testomgeving')
                        cfg.proj_dirinput = '/folder/to/trc-files/testomgeving/patients/';
                    elseif strcmp(foldername,'RESPect_acute_ECoG_trc')
                        cfg.proj_dirinput = '/folder/to/trc-files/patients/';
                    else
                        error('Foldername is not recognized')
                    end
                end
                
                cfg.proj_diroutput = '/folder/with/bidsfiles/acute_ECoG/';

            end
        end
    end
    
    if contains(fieldnames(cfg),'no_fieldtrip')
        cfg.fieldtrip_folder  = '/folder/with/fieldtrip/';
        % copy the private folder in fieldtrip to somewhere else
        cfg.fieldtrip_private = '/folder/with/fieldtrip_private/';
        %%add those later to path to avoid errors with function 'dist'
        rmpath(cfg.fieldtrip_folder)
        rmpath(cfg.fieldtrip_private)
    else
        fieldtrip_folder  = '/folder/with/fieldtrip/';
        % copy the private folder in fieldtrip to somewhere else
        fieldtrip_private = '/folder/with/fieldtrip_private/';
    end
    
    jsonlab_folder    = '/folder/with/jsonlab/';
    addpath(fieldtrip_folder)
    addpath(fieldtrip_private)
    addpath(jsonlab_folder)
    ft_defaults
    
    
end
end