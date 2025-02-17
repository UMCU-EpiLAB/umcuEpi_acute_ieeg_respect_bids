% this function reads the binary file of all EEGfiles that are present in a
% specific subject folder. 

% INPUT: 
% fileName      - directory folder and file where the trc-file is located
% notes         - 
% note_offset   - 

% Copyright (C) 2022 Dorien van Blooijs, SEIN Zwolle, the Netherlands

function writeNotesTRC(fileName, notes, note_offset)

% OPEN FILE
[fid, message]= fopen(fileName,'r+');

if fid == -1
    error(message)
end

% CHECK IF HEADER TYPE = 4, OTHERWISE CODE DOES NOT WORK CORRECTLY
fseek(fid,175,-1);
Header_Type = fread(fid,1,'uchar');
if Header_Type ~= 4
    error('*.trc file is not Micromed System98 Header type 4')
end

% maximal number of annotations possible
MAX_NOTE = 200;

% size of each note
size_note_block = 4+40; 

for i = 1:size(notes,1)

    % SAMPLE
    fseek(fid,note_offset,-1); 
    sample = fread(fid,1,'uint32');
    fprintf('Sample: %d \n', sample)
    % fill with sample
    fseek(fid,note_offset,-1);    
    fwrite(fid,notes{i,1},'uint32');
    fseek(fid,note_offset,-1);
    sample = fread(fid,1,'uint32');
    fprintf('Replaced sample: %d \n', sample)
   
    % NOTE
    fseek(fid,note_offset+4,-1);    
    note = cellstr(fread(fid,40,'*char')');
    fprintf('Note: %s \n',note{:})
    % fill with blanks
    a = blanks(40);
    fseek(fid,note_offset+4,-1);    
    fwrite(fid,a,'char');
    % fill with new annotation
    fseek(fid,note_offset+4,-1);    
    fwrite(fid,notes{i,2},'*char');
    fseek(fid,note_offset+4,-1);
    note = cellstr(fread(fid,40,'*char')');
    fprintf('Replaced by note: %s \n \n',note{:})
    
    note_offset = note_offset + size_note_block;

end

% fill remaining annotations with blanks
for i = size(notes,1)+1 : MAX_NOTE

    % SAMPLE
    fseek(fid,note_offset,-1); 
    % fill with sample 0
    fseek(fid,note_offset,-1);    
    fwrite(fid,0,'uint32');
   
    % NOTE
    fseek(fid,note_offset+4,-1);    
    % fill with blanks
    a = char(zeros(1,40));
    fseek(fid,note_offset+4,-1);    
    fwrite(fid,a,'char');
    
    note_offset = note_offset + size_note_block;

end

fclose(fid);
end