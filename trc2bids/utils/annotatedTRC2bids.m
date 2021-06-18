%  Convert annotated (see annotation scheme in docs) micromed file (.TRC) to Brain Imaging Data Structure (BIDS)
%  it generate all the required directory structure and files
%
%  cfg.proj_diroutput - directory name where to store the files
%  cfg.filename - name of the micromed file to convert
%
%  output structure with some information about the subject
%  output.subjName - name of the subject
% 
% The following functions rely and take inspiration on fieldtrip data2bids.m  function
% (https://github.com/fieldtrip/fieldtrip.git)
% 
% fieldtrip toolbox should be on the path (plus the fieldtrip_private folder)
% (see http://www.fieldtriptoolbox.org/faq/matlab_does_not_see_the_functions_in_the_private_directory/) 
%
% jsonlab toolbox
% https://github.com/fangq/jsonlab.git

% some external function to read micromed TRC files is used
% https://github.com/fieldtrip/fieldtrip/blob/master/fileio/private/read_micromed_trc.m
% copied in the external folder
%  
%     Copyright (C) 2019 Matteo Demuru
%     Copyright (C) 2020 Willemiek Zweiphenning
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
 
function [status,msg,output] = annotatedTRC2bids(cfg,filenum)

try
    
    check_input(cfg,'proj_dirinput');
    check_input(cfg,'proj_diroutput');
    check_input(cfg,'filename');
    
    msg = '';

%     proj_dir  = cfg.proj_dirinput;
    filename  = cfg.filename;
    runall = cfg.runall;

    [indir,fname,exte] = fileparts(filename); % TODO; exte is altijd .TRC?
    
    % obtain information from the header of the trc-file
    [header,data,data_time,trigger,annots] = read_TRC_HDR_DATA_TRIGS_ANNOTS(filename);
    
    if(isempty(header) || isempty(data) || isempty(data_time) || isempty(trigger) && isempty(annots))
        output = [];
        msg = 'TRC reading failed';
        error('TRC reading failed')  ;
    end 
    
    ch_label = strtrim({header.elec.Name}'); 
    sub_label = strcat('sub-',strtrim(header.name));
    
    output.subjName = sub_label;
    
    sfreq = header.Rate_Min;
    
    [status,msg,metadata] = extract_metadata_from_annotations(annots,ch_label,trigger,sub_label,header.Rate_Min,cfg.proj_dirinput);
    
    output.sitName = upper(replace(deblank(metadata.sit_name),' ',''));
    
    if(status==0)
        % folder structure
        % proj-dir/
        %   sub-<label>/
        %       ses-<label>/
        %           ieeg/
        %               sub-<label>_ses-<label>_task-<task_label>_ieeg.<allowed_extension>
        %               sub-<label>_ses-<label>_task-<task_label>_ieeg.json
        %               sub-<label>_ses-<label>_task-<task_label>_channels.tsv
        %               sub-<label>_ses-<label>_task-<task_label>_events.tsv
        %               sub-<label>_ses-<label>_electrodes.tsv
        %               sub-<label>_ses-<label>_coordsystem.json
        %               
        %               sub-<label>_ses-<label>_photo.jpg

        ses_label     = strcat('ses-',upper(replace(deblank(metadata.sit_name),' ','')));
        task_label    = strcat('task-',strtrim(metadata.task_name),' ','');
        metadata.hour = header.hour; metadata.min = header.min; metadata.sec = header.sec; % this is needed for acq_time in scans.tsv

        %subject directions
        sub_dir       = fullfile(cfg.proj_diroutput,sub_label);
        ses_dir       = fullfile(cfg.proj_diroutput,sub_label,ses_label);
        ieeg_dir      = fullfile(cfg.proj_diroutput,sub_label,ses_label,'ieeg');
        ieeg_file     = strcat(sub_label,'_',ses_label,'_',task_label);
        source_dir    = fullfile(cfg.proj_diroutput,'sourcedata',sub_label,ses_label,'ieeg');
        cfg.sub_dir   = sub_dir;
        cfg.ses_dir   = ses_dir;
        cfg.ieeg_dir  = ieeg_dir;
        
        mydirMaker(sub_dir);
        mydirMaker(ses_dir);
        mydirMaker(ieeg_dir);
        mydirMaker(source_dir);
        
        
        %check if it is empty
        %otherwise remove tsv,json,eeg,vhdr,trc,vmrk
        ieeg_files = dir(ieeg_dir);
        
        if contains([ieeg_files(:).name],ieeg_file)%(numel(ieeg_files)>2)
        
            delete(fullfile(ieeg_dir,'*.tsv'))  ;
            delete(fullfile(ieeg_dir,'*.json')) ;
            delete(fullfile(ieeg_dir,'*.eeg'))  ;
            delete(fullfile(ieeg_dir,'*.vhdr')) ;
            delete(fullfile(ieeg_dir,'*.vmrk')) ;
            delete(fullfile(ieeg_dir,'*.TRC'))  ;            
        
        end
        
        % delete scans.tsv if all files in a patient folder are run, 
        % with the first file, scans.tsv can be deleted to run it again correctly
        if cfg.runall == 1  && filenum == 1 
                scans_files = dir(sub_dir);
                
                if contains([scans_files(:).name],'_scans.tsv')
                    
                    delete(fullfile(sub_dir,[extractBefore(ieeg_file,'_ses') '_scans.tsv']))  ;
                    
                end
        end
        
        % make names of files to be constructed
        subses_label = strcat(sub_label,'_',ses_label,'_');
        fieeg_name = strcat(subses_label,task_label,'_','ieeg.TRC');
        fieeg_json_name = strcat(subses_label,task_label,'_','ieeg','.json');
        fchs_name = strcat(subses_label,task_label,'_','channels','.tsv');
        fevents_name = strcat(subses_label,task_label,'_','events','.tsv');
        felec_name = strcat(subses_label,'electrodes','.tsv');
        fcoords_name = strcat(subses_label,'coordsystem','.json');
        fpic_name = strcat(subses_label,'photo','.jpg');
        fscans_name = strcat(sub_label,'_scans','.tsv');
        
        %% create Brainvision format from TRC
        
        convertTRC2brainvision(cfg,ieeg_dir, fieeg_name);      
        
        %% create json sidecar for ieeg file
        
        cfg = create_jsonsidecar(cfg,metadata,header,fieeg_json_name);
        
        %% create _channels.tsv
        
        create_channels_tsv(cfg,metadata,header,fchs_name)
        
        %% create _electrodes.tsv
        
        create_electrodes_tsv(cfg,metadata,header,felec_name)
        
        %% create coordsystem.json
        cfg.coordsystem.iEEGCoordinateSystem                = 'Other'   ;
        cfg.coordsystem.iEEGCoordinateUnits                 = 'mm'   ;
        cfg.coordsystem.iEEGCoordinateSystemDescription     = 'The origin of the coordinate system is between the ears and the axis are in the RAS direction. The scaling is with respect to the individuals anatomical scan and no scaling or deformation have been applied to the individuals anatomical scan';
        cfg.coordsystem.iEEGCoordinateProcessingDescription = 'none'    ;
        cfg.coordsystem.IntendedFor                         =  fpic_name;                

        json_coordsystem(cfg, fcoords_name)
        
        %% move photo with the proper naming into the /ieeg folder
        
        %% create _events.tsv
        
        events_tsv = write_events_tsv(metadata,cfg, fevents_name);
        
        %% write scans-file
        
        write_scans_tsv(cfg,metadata,events_tsv,fscans_name,fieeg_json_name)
        
        %% write participants-file
        
        write_participants_tsv(cfg,header,metadata)
               
        %% write dataset descriptor
        
        create_datasetDesc(cfg.proj_diroutput,sub_label)

        %% write event descriptor
        
        create_eventDesc(fullfile(ieeg_dir,subses_label))
        
        %% write scans descriptor
        create_scansDesc([fullfile(sub_dir,sub_label),'_'])
        
        %% write electrodes descriptor 
        create_elecDesc(fullfile(ieeg_dir,subses_label))
        
        %% write channels descriptor
        create_chanDesc(fullfile(ieeg_dir,subses_label))

        %% write participants descriptor
        create_participantsDesc(cfg.proj_diroutput)

    else 
        %% errors in parsing the data
        error(msg)
    end

catch ME
   
   status = 1;
   if (isempty(msg))
       msg = sprintf('%s err:%s --func:%s',filename,ME.message,ME.stack(1).name);
   else
       msg = sprintf('%s err:%s %s --func:%s',filename,msg,ME.message,ME.stack(1).name); 
   end
    
end





