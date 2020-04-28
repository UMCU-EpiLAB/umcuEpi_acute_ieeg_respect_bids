% Move intraoperative pictures with drawn resected area to the corresponding
% patient BIDS folder
%
%
% INPUT
%      cfg a struct with the following fields
%
%             bidsRootFolder - folder name of where the BIDS structure is stored
%    
%             picRootFolder  - folder name where the pictures are stores
%
%             logFolder      - folder name to store log.txt      
%
% Assumptions: 
%    1) all the available pictures are saved in a folder with the
%       RESPest name (e.g. RESPXXXX)
%    2) the name of the processed pictures file followed this format
%       RESPXXXX_SituationXXdraw_el.png    
% OUTPUT
%      status - 0 if the function did not fail 1 if an error occured
%      msg    - Error message in case of error
%
%      It copies the pictures in the proper BIDS format and folders
%      it creates a log.txt file with the reports
%
%
%
%     Copyright (C) 2020 Matteo Demuru
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


function [status , msg] = moveIntraOpPic2BIDS(cfg)

status = 0;
msg    = [];
try
    
    check_input(cfg,'bidsRootFolder');
    check_input(cfg,'picRootFolder');
    check_input(cfg,'logFolder');
    
    findStr = sprintf('find %sRESP* | grep -e "\\w*draw_el\\w*"',cfg.picRootFolder);
    [status,picNameList] = system(findStr);
    
    picNameList = strip(split(picNameList,'.png'));
    picNameList = picNameList(1:end-1);
    
    
    picOrFileName   = [];
    subjBIDS        = [];
    sitBIDS         = [];
    picBIDSFileName = [];
    
    if(status)
        error('Failed grep from the system');
    end
    
    
    
    log_F      = fullfile(cfg.logFolder,'pictures_log.tsv');
    overview_F = fullfile(cfg.logFolder,'pictures_overview.tsv');
    
    log_T = [];
    if(exist(log_F,'file'))

        log_T = readtable(log_F, 'Delimiter', 'tab', 'FileType', 'text', 'ReadVariableNames', true);

    end
    
    
    % look for pics of subjects imported in BIDS
    subjList = dir(fullfile(cfg.bidsRootFolder,'sub-*'));
    
    for s = 1 : numel(subjList)
        
        sitList = dir(fullfile(subjList(s).folder,subjList(s).name,'ses*'));
        
        c_subjName = replace(subjList(s).name,'sub-','');
        
        % remove pictures already done
        idx2remove = zeros(numel(sitList),1);
        if(~isempty(log_T)) % some pics are already copied
            
            for i = 1 : numel(sitList)
                pic_outName = sprintf('sub-%s_%s_photo.jpg',c_subjName,sitList(i).name);
                
                pic_present = strcmp(pic_outName,log_T.bidsPic);
                if(any(pic_present))
                    orPic = log_T.orPic{pic_present};
                    if(~strcmp(orPic,'none') && ~strcmp(orPic,'more than one') )
                        idx2remove(i) = 1;
                    end
                    
                end
                
            end
        end
        idx2keep = ~idx2remove;
        sitList  = sitList(idx2keep);
         
        for i = 1 : numel(sitList)  
            
            c_sitName  = replace(sitList(i).name,'ses-','');
            
             pic_check = regexpi(picNameList,sprintf('\\w*%s\\w*%s\\w*',c_subjName,c_sitName));
             idx_pic   = ~cellfun(@isempty,pic_check,'UniformOutput',1);
             w_image_F = sprintf('sub-%s_ses-%s_photo.jpg',c_subjName,c_sitName);
             if(any(idx_pic)) %found a picture
                
                if(sum(idx_pic) == 1)
                    c_image_F = strcat(picNameList{idx_pic},'.png'); 
                    c_image   = imread(c_image_F);
                    
                    w_out_F = fullfile(sitList(i).folder,sitList(i).name,'ieeg',w_image_F)
                    %imwrite(c_image,w_out_F);
                    picOrFileName   = [picOrFileName ; {c_image_F}];
                 
                else %more than one pic for situation
                    picOrFileName   = [picOrFileName ; {'more than one'}];
                end
                   
             else             % picture not present
                 picOrFileName   = [picOrFileName ; {'none'}];
                  
             end
             subjBIDS        = [subjBIDS ; {c_subjName}];
             sitBIDS         = [sitBIDS ; {c_sitName}];
             picBIDSFileName = [picBIDSFileName ; {w_image_F} ];
             
        end
        
    end
        
    subj_T     = cell2table(subjBIDS,'VariableNames',{'subjID'});
    sit_T      = cell2table(sitBIDS,'VariableNames',{'Situation'});
    or_pic_T   = cell2table(picOrFileName,'VariableNames',{'orPic'});
    bids_pic_T = cell2table(picBIDSFileName,'VariableNames',{'bidsPic'});
    
    
    aux_T = [ subj_T sit_T bids_pic_T or_pic_T];          
    
    aux_T.Properties.RowNames = aux_T.bidsPic;
    
    % update or write log table

     if(~isempty(log_T))
        log_T.Properties.RowNames = log_T.bidsPic;
        
        log_T{aux_T.Row,'orPic'} = aux_T.orPic;
     else
        log_T = aux_T;
     end
    
    writetable(log_T,log_F,'FileType','text','WriteVariableNames',1,'Delimiter','tab');
    
    % count how many picture expected (according to BIDS) and how many
    % computed
    countFUN   = @(x) [sum(length(x)) (sum(length(x)) - sum(strcmp(x,'none') | strcmp(x,'more than one')))];
    [G,ids]    = findgroups(log_T.subjID);
    Y          = splitapply(countFUN,log_T.orPic,G);
    overview_T = [table(ids,'VariableNames',{'subjID'}) array2table(Y,'VariableNames',{'expected_pictures','pictures_found'})];
   
    writetable(overview_T,overview_F,'FileType','text','WriteVariableNames',1,'Delimiter','tab');
    
catch ME
   
   status = 1;
   
   if (isempty(msg))
       msg = sprintf('%s err:%s --func:%s',ME.message,ME.stack(1).name);
   else
       msg = sprintf('%s err:%s %s --func:%s',msg,ME.message,ME.stack(1).name); 
   end
    
    end

% check if the configuration struct contains all the required fields
function check_input(cfg,key)

if (isa(cfg, 'struct')) 
  
  fn = fieldnames(cfg);
  if ~any(strcmp(key, fn))
       
    error('Provide the configuration struct with all the fields example: cfg.bidsRootFolder cfg.picRootFolder cfg.logFolder error: %s missing ', key);
  end
  
else
    error('Provide the configuration struct with all the fields example: cfg.bidsRootFolder cfg.picRootFolder cfg.logFolder');
end
  





