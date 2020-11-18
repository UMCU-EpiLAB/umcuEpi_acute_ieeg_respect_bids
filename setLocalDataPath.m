function localDataPath = setLocalDataPath(varargin)
% function LocalDataPath = setLocalDataPath(varargin)
% For acute ECoG
% Return the path to the aECoG  directory and add paths in this repo
%
% input:
%   personalDataPath: optional, set to 1 if adding personalDataPath
%
% when adding personalDataPath, the following function should be in the
% root of this repo:
%
% function localDataPath = personalDataPath()
%     'localDataPath = [/my/path/to/data];
% 
%
% dhermes, 2020, Multimodal Neuroimaging Lab
% dvanblooijs, 2020, University Medical Center Utrecht, the Netherlands
% eschaft, 2020, University Medical Center Utrecht, the Netherlands

if isempty(varargin)
    rootPath = which('setLocalDataPath');
    RepoPath = fileparts(rootPath);
    
    % add path to functions
    addpath(genpath(RepoPath));
    
    % add localDataPath default
    localDataPath = fullfile(RepoPath,'data');
    
elseif ~isempty(varargin)
    % add path to functions
    rootPath = which('setLocalDataPath');
    RepoPath = fileparts(rootPath);
    addpath(genpath(RepoPath));

    % add path to data
    if isstruct(varargin{1})
        if any(contains(fieldnames(varargin{1}),'mode'))
            if strcmp(varargin{1}.mode,'anonymization')
                        localDataPath = personalDataPath_anonymization(varargin{1});

            elseif strcmp(varargin{1}.mode,'bidsconversion')
                        localDataPath = personalDataPath_bidsconvert(varargin{1});

            end
            
        else
           error('No mode in cfg, make sure to add mode [bidsconversion/anonymization] to cfg') 
        end
        
    else
        if varargin{1}==1 && exist('personalDataPath','file')
            
            localDataPath = personalDataPath();
            
        elseif varargin{1}==1 && ~exist('personalDataPath','file')
            
            sprintf(['add personalDataPath function to add your localDataPath:\n'...
                '\n'...
                'function localDataPath = personalDataPath()\n'...
                'localDataPath.input = [/my/path/to/data];\n'...
                'localDataPath.output = [/my/path/to/output];\n'...
                '\n'...
                'this function is ignored in .gitignore'])
            return
        end
    end
    
end

return

