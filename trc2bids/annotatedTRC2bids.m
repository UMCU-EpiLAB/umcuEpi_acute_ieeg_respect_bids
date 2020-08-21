%  Convert annotated (see annotation scheme in docs) micromed file (.TRC) to Brain Imaging Data Structure (BIDS)
%  it generate all the required directory structure and files
%
%  cfg.proj_dir - directory name where to store the files
%  cfg.filename - name of the micromed file to convert
%
%  output structure with some information about the subject
%  output.subjName - name of the subject
% 
% 


% The following functions rely and take inspiration on fieltrip data2bids.m  function
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
%  
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



 
function [status,msg,output] = annotatedTRC2bids(cfg)

try
  
    output.subjName = '';
    output.sitName  = '';
    msg = '';
    
    check_input(cfg,'proj_dir');
    check_input(cfg,'filename');

    proj_dir  = cfg.proj_dir;
    filename  = cfg.filename;

    [indir,fname,exte] = fileparts(filename);
    %create the subject level dir if not exist
  
    [header,data,data_time,trigger,annots] = read_TRC_HDR_DATA_TRIGS_ANNOTS(filename);
    
    if(isempty(header) || isempty(data) || isempty(data_time) || isempty(trigger) || isempty(annots))
        error('TRC reading failed')  ;
    end 
    ch_label = deblank({header.elec.Name}');
    sub_label = strcat('sub-',upper(deblank(header.name)));
    
    output.subjName = sub_label;
    
    sfreq = header.Rate_Min;
    
    [status,msg,metadata] = extract_metadata_from_annotations(annots,ch_label,trigger,sub_label,sfreq);
    
    output.sitName = upper(replace(deblank(metadata.sit_name),' ',''));
    
    if(status==0)
        %% move trc with the proper naming and start to create the folder structure
        % for now for simplicity using the .trc even though is not one of the
        % allowed format (later it should be moved to source)

        %proj-dir/
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

        task_label    = 'acute';
        ses_label     = strcat('ses-',upper(replace(deblank(metadata.sit_name),' ','')));

        %subject dir
        sub_dir       = fullfile(proj_dir,sub_label);
        ses_dir       = fullfile(proj_dir,sub_label,ses_label);
        ieeg_dir      = fullfile(proj_dir,sub_label,ses_label,'ieeg');
        source_dir    = fullfile(proj_dir,'sourcedata',sub_label,ses_label,'ieeg');
     
        mydirMaker(sub_dir);
        mydirMaker(ses_dir);
        mydirMaker(ieeg_dir);
        mydirMaker(source_dir);
        
        
        %check if it is empty
        %otherwise remove tsv,json,eeg,vhdr,trc,vmrk
        ieeg_files = dir(ieeg_dir);
        
        if(numel(ieeg_files)>2)
        
            delete(fullfile(ieeg_dir,'*.tsv'))  ;
            delete(fullfile(ieeg_dir,'*.json')) ;
            delete(fullfile(ieeg_dir,'*.eeg'))  ;
            delete(fullfile(ieeg_dir,'*.vhdr')) ;
            delete(fullfile(ieeg_dir,'*.vmrk')) ;
            delete(fullfile(ieeg_dir,'*.TRC'))  ;            
        
        end

        fieeg_name = strcat(sub_label,'_',ses_label,'_','task-',task_label,'_','ieeg',exte);
        fieeg_json_name = strcat(sub_label,'_',ses_label,'_','task-',task_label,'_','ieeg','.json');
        fchs_name = strcat(sub_label,'_',ses_label,'_','task-',task_label,'_','channels','.tsv');
        fevents_name = strcat(sub_label,'_',ses_label,'_','task-',task_label,'_','events','.tsv');
        felec_name = strcat(sub_label,'_',ses_label,'_','electrodes','.tsv');
        fcoords_name = strcat(sub_label,'_',ses_label,'_','coordsystem','.json');
        fpic_name = strcat(sub_label,'_',ses_label,'_','photo','.jpg');
        
        
            
         
        % file ieeg of the recording
        copyfile(filename,fullfile(source_dir,fieeg_name));

        fileTRC  = fullfile(source_dir,fieeg_name);
        fileVHDR = fullfile(ieeg_dir,fieeg_name);
        fileVHDR = replace(fileVHDR,'.TRC','.vhdr');

        %% create Brainvision format from TRC

        cfg = [];
        cfg.dataset    = fileTRC;
        cfg.continuous = 'yes';
        data2write     = ft_preprocessing(cfg);

        cfg = [];
        cfg.outputfile                  = fileVHDR;


        
       
        cfg.writejson = 'no';
        cfg.ieeg.writesidecar     = 'no';
        cfg.writetsv  = 'no'; 
        cfg.datatype  = 'ieeg';
              
        data2bids(cfg, data2write)
        
        % delete the json created by fieldtrip in order to create the
        % custom one
        delete(replace(cfg.outputfile,'vhdr','json'))
       
        %% create json sidecar for ieeg file
        cfg                             = [];
        cfg.ieeg                        = struct;
        cfg.channels                    = struct;
        cfg.electrodes                  = struct;
        cfg.coordsystem                 = struct;

        cfg.outputfile                  = fileVHDR;

        cfg.TaskName                    = task_label;
        cfg.InstitutionName             = 'University Medical Center Utrecht';
        cfg.InstitutionAddress          = 'Heidelberglaan 100, 3584 CX Utrecht';
        cfg.Manufacturer                = 'Micromed';
        cfg.ManufacturersModelName      = sprintf('Acqui.eq:%i  File_type:%i',header.acquisition_eq,header.file_type);
        cfg.DeviceSerialNumber          = '';
        cfg.SoftwareVersions            = header.Header_Type;





        % create _channels.tsv

      
        % create _electrodes.tsv
        % we don't have a position of the electrodes, anyway we are keeping this
        % file for BIDS compatibility


        json_sidecar_and_ch_and_ele_tsv(header,metadata,cfg)


        %% create coordsystem.json
        cfg.coordsystem.iEEGCoordinateSystem                = 'pixel'   ;
        cfg.coordsystem.iEEGCoordinateUnits                 = 'pixel'      ;
        cfg.coordsystem.iEEGCoordinateProcessingDescription = 'none'    ;
        cfg.coordsystem.IntendedFor                         =  fpic_name;                

        json_coordsystem(cfg)

        %% move photo with the proper naming into the /ieeg folder

        %% create _events.tsv
        write_events_tsv(metadata,cfg);


        %% write dataset descriptor
        create_datasetDesc(proj_dir)

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


%% create dataset descriptor
function create_datasetDesc(proj_dir)

ddesc_json.Name               = 'RESPECT' ;
ddesc_json.BIDSVersion        = 'BEP010';
ddesc_json.License            = 'Not licenced yet';
ddesc_json.Authors            = {'Demuru M.,', 'Zweiphenning W.J.E.,', 'van Blooijs D.,', 'Leijten F.S.S.,', 'Zijlmans G.J.M.'};
ddesc_json.Acknowledgements   = 'D''angremont E.,  Wassenaar M.';
ddesc_json.HowToAcknowledge   = 'possible paper to quote' ;
ddesc_json.Funding            = {'Epi-Sign Project'} ;  
ddesc_json.ReferencesAndLinks = {'articles and/or links'};
ddesc_json.DatasetDOI         = 'DOI of the dataset if online'; 


if ~isempty(ddesc_json)
    
    filename = fullfile(proj_dir,'dataset_description.json');
    if isfile(filename)
        existing = read_json(filename);
    else
        existing = [];
    end
    write_json(filename, mergeconfig(existing, ddesc_json))
end




