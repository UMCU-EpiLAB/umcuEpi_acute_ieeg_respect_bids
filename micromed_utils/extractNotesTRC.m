% this function reads the binary file of a EEGfile and extracts the notes

% INPUT: 
% fileName - directory folder and file where the trc-file is located

% OUTPUT:
% annotationsTRC    -
% note_offset       -

% Copyright (C) 2022 Dorien van Blooijs, SEIN Zwolle, the Netherlands

function [annotationsTRC, note_offset] = extractNotesTRC(fileName)

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

% EXTRACT ANNOTATIONS
fseek(fid,208+8,-1);
note_offset = fread(fid,1,'uint32');

nCount=1;
annotationsTRC = cell(1,2);
fseek(fid,note_offset,-1);
while 1
    notesamp = fread(fid,1,'uint32');
    if notesamp == 0 % if the sample = 0, then it is the end of notes in this trc file
        break
    end
    note = cellstr(fread(fid,40,'*char')');
    annotationsTRC(nCount,1) = {notesamp};
    annotationsTRC(nCount,2) = note(1);
    nCount=nCount+1;
end

% housekeeping
% clear ans Header_Type i note notesamp 
end