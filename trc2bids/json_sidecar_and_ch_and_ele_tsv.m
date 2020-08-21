%% function for json and tsv ieeg following fieldtrip style
function json_sidecar_and_ch_and_ele_tsv(header,metadata,cfg)



%% Generic fields for all data types
cfg.TaskName                          = ft_getopt(cfg, 'TaskName'                    ); % REQUIRED. Name of the task (for resting state use the “rest” prefix). Different Tasks SHOULD NOT have the same name. The Task label is derived from this field by removing all non alphanumeric ([a-zA-Z0-9]) characters.
cfg.TaskDescription                   = ft_getopt(cfg, 'TaskDescription'             ); % OPTIONAL. Description of the task.
cfg.Manufacturer                      = ft_getopt(cfg, 'Manufacturer'                ); % OPTIONAL. Manufacturer of the MEG system ("CTF", "​Elekta/Neuromag​", "​4D/BTi​", "​KIT/Yokogawa​", "​ITAB​", "KRISS", "Other")
cfg.ManufacturersModelName            = ft_getopt(cfg, 'ManufacturersModelName'      ); % OPTIONAL. Manufacturer’s designation of the MEG scanner model (e.g. "CTF-275"). See ​Appendix VII​ with preferred names
cfg.DeviceSerialNumber                = ft_getopt(cfg, 'DeviceSerialNumber'          ); % OPTIONAL. The serial number of the equipment that produced the composite instances. A pseudonym can also be used to prevent the equipment from being identifiable, as long as each pseudonym is unique within the dataset.
cfg.SoftwareVersions                  = ft_getopt(cfg, 'SoftwareVersions'            ); % OPTIONAL. Manufacturer’s designation of the acquisition software.
cfg.InstitutionName                   = ft_getopt(cfg, 'InstitutionName'             ); % OPTIONAL. The name of the institution in charge of the equipment that produced the composite instances.
cfg.InstitutionAddress                = ft_getopt(cfg, 'InstitutionAddress'          ); % OPTIONAL. The address of the institution in charge of the equipment that produced the composite instances.
cfg.InstitutionalDepartmentName       = ft_getopt(cfg, 'InstitutionalDepartmentName' ); % The department in the institution in charge of the equipment that produced the composite instances. Corresponds to DICOM Tag 0008, 1040 ”Institutional Department Name”.

%% IEEG inherited fields used
cfg.ieeg.ECOGChannelCount             = ft_getopt(cfg.ieeg, 'ECOGChannelCount'  ); %RECOMMENDED
cfg.ieeg.SEEGChannelCount             = ft_getopt(cfg.ieeg, 'SEEGChannelCount'  ); %RECOMMENDED
cfg.ieeg.EEGChannelCount              = ft_getopt(cfg.ieeg, 'EEGChannelCount'   ); %RECOMMENDED
cfg.ieeg.EOGChannelCount              = ft_getopt(cfg.ieeg, 'EOGChannelCount'   ); %RECOMMENDED
cfg.ieeg.ECGChannelCount              = ft_getopt(cfg.ieeg, 'ECGChannelCount'   ); %RECOMMENDED
cfg.ieeg.EMGChannelCount              = ft_getopt(cfg.ieeg, 'EMGChannelCount'   ); %RECOMMENDED
cfg.ieeg.RecordingDuration            = ft_getopt(cfg.ieeg, 'RecordingDuration' ); %RECOMMENDED
cfg.ieeg.RecordingType                = ft_getopt(cfg.ieeg, 'RecordingType'     ); %RECOMMENDED
cfg.ieeg.EpochLength                  = ft_getopt(cfg.ieeg, 'EpochLength'       ); %RECOMMENDED


%% IEEG specific fields
cfg.ieeg.SamplingFrequency            = ft_getopt(cfg.ieeg, 'SamplingFrequency'          ); % REQUIRED.
cfg.ieeg.PowerLineFrequency           = ft_getopt(cfg.ieeg, 'PowerLineFrequency'         ); % REQUIRED.
cfg.ieeg.SoftwareFilters              = ft_getopt(cfg.ieeg, 'SoftwareFilters'            ); % REQUIRED.
cfg.ieeg.iEEGReference                = ft_getopt(cfg.ieeg, 'iEEGReference'              ); % REQUIRED.
cfg.ieeg.ElectrodeManufacturer        = ft_getopt(cfg.ieeg, 'ElectrodeManufacturer'      ); %RECOMMENDED
cfg.ieeg.iEEGElectrodeGroups          = ft_getopt(cfg.ieeg, 'iEEGElectrodeGroups'        ); %RECOMMENDED


ft_warning('iEEG metadata fields need to be updated with the draft specification at http://bit.ly/bids_ieeg');


%% columns in the channels.tsv
cfg.channels.name               = ft_getopt(cfg.channels, 'name'               , nan);  % REQUIRED. Channel name (e.g., MRT012, MEG023)
cfg.channels.type               = ft_getopt(cfg.channels, 'type'               , nan);  % REQUIRED. Type of channel; MUST use the channel types listed below.
cfg.channels.units              = ft_getopt(cfg.channels, 'units'              , nan);  % REQUIRED. Physical unit of the data values recorded by this channel in SI (see Appendix V: Units for allowed symbols).
cfg.channels.description        = ft_getopt(cfg.channels, 'description'        , nan);  % OPTIONAL. Brief free-text description of the channel, or other information of interest. See examples below.
cfg.channels.sampling_frequency = ft_getopt(cfg.channels, 'sampling_frequency' , nan);  % OPTIONAL. Sampling rate of the channel in Hz.
cfg.channels.low_cutoff         = ft_getopt(cfg.channels, 'low_cutoff'         , nan);  % OPTIONAL. Frequencies used for the high-pass filter applied to the channel in Hz. If no high-pass filter applied, use n/a.
cfg.channels.high_cutoff        = ft_getopt(cfg.channels, 'high_cutoff'        , nan);  % OPTIONAL. Frequencies used for the low-pass filter applied to the channel in Hz. If no low-pass filter applied, use n/a. Note that hardware anti-aliasing in A/D conversion of all MEG/EEG electronics applies a low-pass filter; specify its frequency here if applicable.
cfg.channels.reference          = ft_getopt(cfg.channels, 'reference'          , nan);  % OPTIONAL.
cfg.channels.group              = ft_getopt(cfg.channels, 'group'              , nan);  % OPTIONAL.
cfg.channels.notch              = ft_getopt(cfg.channels, 'notch'              , nan);  % OPTIONAL. Frequencies used for the notch filter applied to the channel, in Hz. If no notch filter applied, use n/a.
cfg.channels.software_filters   = ft_getopt(cfg.channels, 'software_filters'   , nan);  % OPTIONAL. List of temporal and/or spatial software filters applied (e.g. "SSS", "SpatialCompensation"). Note that parameters should be defined in the general MEG sidecar .json file. Indicate n/a in the absence of software filters applied.
cfg.channels.status             = ft_getopt(cfg.channels, 'status'             , nan);  % OPTIONAL. Data quality observed on the channel (good/bad). A channel is considered bad if its data quality is compromised by excessive noise. Description of noise type SHOULD be provided in [status_description].
cfg.channels.status_description = ft_getopt(cfg.channels, 'status_description' , nan);  % OPTIONAL. Freeform text description of noise or artifact affecting data quality on the channel. It is meant to explain why the channel was declared bad in [status].


%% *_electrodes.tsv 
cfg.electrodes.name             = ft_getopt(cfg.electrodes, 'name'               , nan);
cfg.electrodes.x                = ft_getopt(cfg.electrodes, 'x'                  , nan);
cfg.electrodes.y                = ft_getopt(cfg.electrodes, 'y'                  , nan);
cfg.electrodes.z                = ft_getopt(cfg.electrodes, 'z'                  , nan);
cfg.electrodes.size             = ft_getopt(cfg.electrodes, 'size'               , nan);
cfg.electrodes.group            = ft_getopt(cfg.electrodes, 'group'              , nan);
cfg.electrodes.material         = ft_getopt(cfg.electrodes, 'material'           , nan);
cfg.electrodes.manufacturer     = ft_getopt(cfg.electrodes, 'manufacturer'       , nan);
cfg.electrodes.resected         = ft_getopt(cfg.electrodes, 'resected'           , nan);
cfg.electrodes.edge             = ft_getopt(cfg.electrodes, 'edge'               , nan);
cfg.electrodes.cavity           = ft_getopt(cfg.electrodes, 'cavity'             , nan);





%% start with empty  descriptions
ieeg_json    = [];
channels_tsv = [];


ieeg_json.TaskName                          = cfg.TaskName;
ieeg_json.TaskDescription                   = cfg.TaskDescription;
ieeg_json.Manufacturer                      = cfg.Manufacturer;
ieeg_json.ManufacturersModelName            = cfg.ManufacturersModelName;
ieeg_json.DeviceSerialNumber                = cfg.DeviceSerialNumber;
ieeg_json.SoftwareVersions                  = cfg.SoftwareVersions;
ieeg_json.InstitutionName                   = cfg.InstitutionName;
ieeg_json.InstitutionAddress                = cfg.InstitutionAddress;
ieeg_json.InstitutionalDepartmentName       = cfg.InstitutionalDepartmentName;

ch_label                                    = metadata.ch_label;

%% IEEG inherited fields used
ieeg_json.ECOGChannelCount             = sum(metadata.ch2use_included);
ieeg_json.ECGChannelCount              = sum(~cellfun(@isempty,regexpi(ch_label,'ECG')));
ieeg_json.RecordingDuration            = header.Num_Samples/header.Rate_Min;
ieeg_json.RecordingType                = 'continuous';
ieeg_json.EpochLength                  = 0;


%% IEEG specific fields
ieeg_json.SamplingFrequency            = header.Rate_Min;
ieeg_json.PowerLineFrequency           = 50;
ieeg_json.SoftwareFilters              = 'n/a';
ieeg_json.iEEGReference                = 'probably mastoid';
ieeg_json.ElectrodeManufacturer        = 'AD-TECH';
ieeg_json.iEEGElectrodeGroups          = metadata.format_info;

                                        
   
fn = {'name' 'type' 'units' 'description' 'sampling_frequency' 'low_cutoff' 'high_cutoff' 'reference'...
    'group' 'notch' 'software_filters' 'status' 'status_description'};
for i=1:numel(fn)
    if numel(cfg.channels.(fn{i}))==1
        cfg.channels.(fn{i}) = repmat(cfg.channels.(fn{i}), header.Num_Chan, 1);
    end
end

%% iEEG  channels.tsv file
name                                = mergevector({header.elec(:).Name}', cfg.channels.name)                                   ;

type                                = cell(size(name))                                                                         ;
if(any(metadata.ch2use_included))
    [type{metadata.ch2use_included}]    = deal('ECOG')                                                                             ;
end
if(any(~metadata.ch2use_included))
    [type{~metadata.ch2use_included}]   = deal('OTHER');
end
idx_ecg                             = ~cellfun(@isempty,regexpi(ch_label,'ECG'))                                               ;
idx_ecg                             = idx_ecg'                                                                                 ;

if(any(idx_ecg))
    [type{idx_ecg}]                     = deal('ECG')                                                                              ;                                       
end

units                               = mergevector({header.elec(:).Unit}', cfg.channels.units)                                  ;
sampling_frequency                  = mergevector(repmat(header.Rate_Min, header.Num_Chan, 1), cfg.channels.sampling_frequency);
low_cutoff                          = repmat(468,header.Num_Chan, 1); %{header.elec(:).Prefiltering_LowPass_Limit}';  468                                           ;
high_cutoff                         = repmat(0.15,header.Num_Chan, 1); %{header.elec(:).Prefiltering_HiPass_Limit}';%/1000  0.15                                       ;
%high_cutoff                         = cellfun(@(x)x./1000,high_cutoff,'UniformOutput',false);
reference                           = {header.elec(:).Ref}'                                                                    ;

group                               = extract_group_info(metadata)                                                             ;

notch                               = repmat('n/a',header.Num_Chan, 1)                                                         ;
software_filters                    = repmat('n/a',header.Num_Chan, 1)                                                         ;

[ch_status,ch_status_desc]          = status_and_description(metadata)                                                         ;
status                              = ch_status                                                                                ;
status_description                  = ch_status_desc                                                                           ;



channels_tsv                        = table(name, type, units, low_cutoff,    ...
                                            high_cutoff, reference, group, sampling_frequency, notch, software_filters,  ...
                                            status, status_description                                                        );


                                     
%% electrode table
fn = {'name' 'x' 'y' 'z' 'size' 'group' 'material' 'manufacturer','resected','edge','cavity'};
for i=1:numel(fn)
    if numel(cfg.electrodes.(fn{i}))==1
        cfg.electrodes.(fn{i}) = repmat(cfg.electrodes.(fn{i}), header.Num_Chan, 1);
    end
end                                  
                                        
                                        
%name                                = mergevector({header.elec(:).Name}', cfg.electrodes.name)                                   ;
x                                         = repmat({'0'},header.Num_Chan,1);                                                            ;      
y                                         = repmat({'0'},header.Num_Chan,1);                                                           ;
z                                         = repmat({'0'},header.Num_Chan,1);                                                            ;
e_size                                    = repmat({'n/a'},header.Num_Chan,1);                                                          ; %TODO ask
material                                  = repmat({'n/a'},header.Num_Chan,1);                                                          ; %TODO ask
manufacturer                              = repmat({'n/a'},header.Num_Chan,1);                                                          ; %TODO ask
resected                                  = repmat({'n/a'},header.Num_Chan,1);
edge                                      = repmat({'n/a'},header.Num_Chan,1);
cavity                                    = repmat({'n/a'},header.Num_Chan,1);

if(any(metadata.ch2use_included))
    [e_size{metadata.ch2use_included}]        = deal('2.1')         ;                                                                      ;
end

if(any(metadata.ch2use_included))
    [material{metadata.ch2use_included}]      = deal('Platinum')    ;                                                                            ;
end

if(any(metadata.ch2use_included))
    [manufacturer{metadata.ch2use_included}]  = deal('AD-Tech')     ;                                                                               ;
end

if(any(metadata.ch2use_resected))
    [resected{metadata.ch2use_resected}]      = deal('resected')    ;                                                                            ;
end

if(any(metadata.ch2use_edges))
    [edge{metadata.ch2use_edges}]             = deal('edge')        ;                                                                            ;
end

if(any(metadata.ch2use_cavity))
    [cavity{metadata.ch2use_cavity}]          = deal('cavity')      ;                                                                            ;
end




electrodes_tsv                            = table(name, x , y, z, e_size, ...
                                                  group, material, manufacturer, ...
                                                  resected,edge,cavity, ...
                                             'VariableNames',{'name', 'x', 'y', 'z',...
                                                              'size', 'group', 'material', 'manufacturer',...
                                                              'resected','edge','cavity' ...
                                                              } ...
                                                  )     ;


if ~isempty(ieeg_json)
    [p, f, x] = fileparts(cfg.outputfile);
    filename = fullfile(p, [f '.json']);
    if isfile(filename)
        existing = read_json(filename);
    else
        existing = [];
    end
    write_json(filename, mergeconfig(existing, ieeg_json))
end

if ~isempty(channels_tsv)
    [p, f, x] = fileparts(cfg.outputfile);
    % sub-<label>/
    %[ses-<label>]/
    %  ieeg/
    %    [sub-<label>[_ses-<label>]_task-<label>[_run-<index>]_channels.tsv]
    filename = fullfile(p, [f '_channels.tsv']);
    filename = replace(filename,'_ieeg','');
    if isfile(filename)
        existing = read_tsv(filename);
    else
        existing = [];
    end % try
    if ~isempty(existing)
        ft_error('existing file is not empty');
    end
    write_tsv(filename, channels_tsv);
end

if ~isempty(electrodes_tsv)
    [p, f, x] = fileparts(cfg.outputfile);
    %sub-<label>/
    %[ses-<label>]/
    %  ieeg/
    %     sub-<label>[_ses-<label>][_space-<label>]_electrodes.tsv
    filename = fullfile(p, [f '_electrodes.tsv']);
    filename = replace(filename,'_task-acute_ieeg','');
    if isfile(filename)
        existing = read_tsv(filename);
    else
        existing = [];
    end % try
    if ~isempty(existing)
        ft_error('existing file is not empty');
    end
    write_tsv(filename, electrodes_tsv);
end
