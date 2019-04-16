%% import situation from a BIDS format plus custom annotation file
% cfg is a struct specifying three fields
% 
% cfg.datasetName  - filename of the header of Brainvision file (.vhdr)
% cfg.annotFile    - channel name of custom table with the trial information
% cfg.channelFile  - file name of channel table as defined in brain imaging
%                    data structure (BIDS) 
%
% data            - the function return a data structure preprocessed by fieldtrip for trial
%                   extraction



%     Copyright (C) 2019 Matteo Demuru
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <https://www.gnu.org/licenses/>.

function data = importSituation(cfg)

check_input(cfg,'datasetName')
check_input(cfg,'annotFile')
check_input(cfg,'channelFile')

datasetName = cfg.datasetName ;
annotFile   = cfg.annotFile   ;
channelFile = cfg.channelFile ;

trl = [];

if(~isempty(annotFile))
    %% read good epochs
    tsv_annots = readtable(annotFile, 'Delimiter', 'tab', 'FileType', 'text', 'ReadVariableNames', true);

    trl       = [tsv_annots.start tsv_annots.stop]; %TODO check the type or if it is implicit conversion
    idx_trial = strcmp(tsv_annots.type,'trial');
    trl       = trl(idx_trial,:);
    trl       = [trl  zeros(size(trl,1),1)];
    
    if(isempty(trl))
        error('No trial available, try with noArtefact flag at 0')
    end
end



%% read good channels
tsv_channels = readtable(channelFile, 'Delimiter', 'tab', 'FileType', 'text', 'ReadVariableNames', true);

ch_label      = tsv_channels.name                ;
ch_type       = tsv_channels.type                ;
ch_status     = tsv_channels.status              ;
ch_status_des = tsv_channels.status_description  ;

idx_ecog      = strcmp(ch_type,'ECOG')            ;
idx_good      = strcmp(ch_status,'good')          ;
idx_included  = regexp(ch_status_des,'^included') ;
idx_included  = ~cellfun(@isempty,idx_included)   ;


cfg                = []                                           ;
cfg.dataset        = datasetName                                  ;
cfg.channel        = ch_label(idx_ecog & idx_good & idx_included) ;

if(~isempty(trl))
    cfg.trl        = trl                                          ;
end    

if(isempty(cfg.channel))
    error('no channels imported');
    
end
data               = ft_preprocessing(cfg)                        ;


%% check if the configuration struct contains all the required fields
function check_input(cfg,key)

if (isa(cfg, 'struct')) 
  
  fn = fieldnames(cfg);
  if ~any(strcmp(key, fn))
    error('Provide the configuration struct with all the fields example: cfg.datasetName  cfg.annotFile  cfg.channelFile  error: %s missing ', key);
  end
  
else
    error('Provide the configuration struct with all the fields example:  cfg.datasetName  cfg.annotFile  cfg.channelFile');
end
  