%% Anonymization for .TRC files
%  It removes the patient information (Surname,Name,montage names) from the
%  binary file.
%
%  fileName - file name of the TRC
%  respName - name to write in the surname and name field of the TRC header.
%             If present it will be written in the file otherwise only the 
%             the montages will be anonymized
%  status   - 0 if the operation terminated successfully, 1 otherwise
%  msg      - String with the reason of the failure
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

function [status,msg] = anonymized_asRecorded(fileName,respName)

status = 0; %ok
msg    = '';%ok
try
    MAX_HISTORY = 30;
    MAX_SAMPLE  = 128;

    [fid message]= fopen(fileName,'r+');
    % check if the Header is 4 the following code assume that binary layout
    fseek(fid,175,-1);
    Header_Type=string(fread(fid,1,'uchar'));
    if ~strcmp(Header_Type,"4")
      error('*.trc file is not Micromed System98 Header type 4')
    end
    
    %% Anonymization of the name and surname

    if(nargin>1)

        fseek(fid,64,-1);
        subj_surname   = char(fread(fid,22,'char'))';

        fseek(fid,86,-1);
        subj_name   = char(fread(fid,20,'char'))';

        disp(sprintf('surname: %s',subj_surname))
        disp(sprintf('name: %s',subj_name))
        disp(sprintf('to be replaced with : %s\n',respName))

        % fill with blanks
        a = blanks(22);
        fseek(fid,64,-1);
        fwrite(fid,a,'char');
        a = blanks(20);
        fseek(fid,86,-1);
        fwrite(fid,a,'char');

        %fill with respectName

        fseek(fid,64,-1);
        fwrite(fid,respName,'char');
        fseek(fid,86,-1);
        fwrite(fid,respName,'char');

        % read the new values
        fseek(fid,64,-1);
        subj_surname   = char(fread(fid,22,'char'))';

        fseek(fid,86,-1);
        subj_name   = char(fread(fid,20,'char'))';

        disp(sprintf('surname: %s',subj_surname))
        disp(sprintf('name: %s',subj_name))
    end

    %% anonymization of as Recorded part

    size_montage_block = 2376+1720; % last offset + value unsigned char[]

    %% Read History header

    fseek(fid,336,-1);
    history_NAME   = char(fread(fid,8,'char'))';

    fseek(fid,336+8,-1);
    history_offset = fread(fid,1,'ulong');

    fseek(fid,336+12,-1);
    history_length = fread(fid,1,'ulong');

    tot_len = history_offset + history_length;

    %% Read History Area & Read specific montage 


    fseek(fid,history_offset,-1);
    change_montage_sample = fread(fid,MAX_SAMPLE,'ulong');

    offset = history_offset+MAX_SAMPLE*4;

    while(offset < tot_len)

        %fseek(fid,offset,-1);
        %nlines = fread(fid,1,'ushort');

        %fseek(fid,offset+2,-1);
        %sectors = fread(fid,1,'ushort');

        %fseek(fid,offset+4,-1);
        %basetime = fread(fid,1,'ushort');

        %fseek(fid,offset+6,-1);
        %notch_field = fread(fid,1,'ushort');

        fseek(fid,offset+264,-1); %unsigned long int[]
        description = char(fread(fid,64,'char'))';
        disp(sprintf('Montage Name: %s',description))
        %fill with blanks
        a = blanks(64);
        fseek(fid,offset+264,-1);
        fwrite(fid,a,'char');

        str2replace = ['anon']';
        fseek(fid,offset+264,-1);
        fwrite(fid,str2replace,'char');


        fseek(fid,offset+264,-1);
        description = char(fread(fid,64,'char'))';
        disp(sprintf('Replaced Name: %s',description))


        %fseek(fid,offset+840,-1);
        %HiPass = fread(fid,128,'ulong');
        %HiPass = HiPass/100;
        %fseek(fid,offset+1352,-1);
        %LowPass = fread(fid,128,'ulong');
        %LowPass = LowPass/100;

        %fseek(fid,offset+1864,-1);
        %reference = fread(fid,128,'ulong');

        offset = offset + size_montage_block;
    end

    fclose(fid);

catch ME
    status = 1;
    msg    = sprintf('%s err:%s --func:%s',fileName,ME.message,ME.stack(1).name);
end