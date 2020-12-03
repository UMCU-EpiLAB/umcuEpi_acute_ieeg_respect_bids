%% Anonymization for .TRC files
%  It removes the patient information (Surname,Name,montage names) from the
%  binary file.
%
%  INPUT
%  fileName - file name of the TRC
%  respName - name to write in the surname and name field of the TRC header.
%             If present it will be written in the file otherwise only the 
%             the montages will be anonymized
%  patterns - [optional] string or char array of terms to scan header for. 
%
%  OUTPUT
%  status   - 0 if the operation terminated successfully, 1 otherwise
%  msg      - String with the reason of the failure
     
%     Copyright (C) 2019 Matteo Demuru
%     Copyright (C) 2019-2020 Paul L. Smits
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

function [status,msg] = anonymized_asRecorded(fileName,respName,patterns)
addpath('./functions/');
status = 0; %ok
msg    = '';%ok
try
    MAX_HISTORY = 30;
    MAX_SAMPLE  = 128;
    
    [fid,~]= fopen(fileName,'r+');
    % check if the Header is 4 the following code assume that binary layout
    fseek(fid,175,-1);
    Header_Type=string(fread(fid,1,'uchar'));
    if ~strcmp(Header_Type,"4")
      error('*.trc file is not Micromed System98 Header type 4')
    end
    
    %% Anonymization of the name and surname and dates/reserved
    % Added date of birth and reserved (Paul Smits 2019)

    if(nargin>1)

        fseek(fid,64,-1);
        subj_surname1   = char(fread(fid,22,'char'))';

        fseek(fid,86,-1);
        subj_name1   = char(fread(fid,20,'char'))';
        
        fseek(fid,106,-1);
        subj_day1   = fread(fid,1,'*uchar')';
        subj_month1   = fread(fid,1,'*uchar')';
        subj_year1   = fread(fid,1,'*uchar')';
        subj_reserved1= fread(fid,19,'*uchar')';
        rec_day1   = fread(fid,1,'*uchar')';
        rec_month1   = fread(fid,1,'*uchar')';
        rec_year1   = fread(fid,1,'*uchar')';
        rec_hour1   = fread(fid,1,'*uchar')';
        rec_min1   = fread(fid,1,'*uchar')';
        rec_sec1   = fread(fid,1,'*uchar')';

        disp(sprintf('surname: %s',subj_surname1))
        disp(sprintf('name: %s',subj_name1))
        disp(sprintf('to be replaced with : %s\n',respName))
        fprintf('Date of birth in trace: %u-%u-%u.\n',subj_day1,subj_month1,uint16(subj_year1)+1900)
        fprintf('to be replaced with : %s-%u.\n',"1-1",uint16(subj_year1)+1900)
        fprintf('Reserved chars : [%s]\n',uint16(subj_reserved1))
        fprintf('Date of recording in trace: %u-%u-%u.\n',rec_day1,rec_month1,uint16(rec_year1)+1900)
        fprintf('to be replaced with : %s-%u.\n',"1-1",uint16(rec_year1)+1900)
        fprintf('Time of recording in trace: %u:%u:%u.\n',rec_hour1,rec_min1,rec_sec1)

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
        
        %fill with 1-1 date (birth)
        dateones=uint8(ones(1,2));
        fseek(fid,106,-1);
        fwrite(fid,dateones,'*uchar');
        fwrite(fid,subj_year1,'*uchar');
        
        %fill reserved zeros
        reservedzeros=uint8(zeros(1,19));
        fwrite(fid,reservedzeros,'*uchar');
           
        %fill with 1-1 date (recording)
        fwrite(fid,dateones,'*uchar');
        fwrite(fid,rec_year1,'*uchar');

        %(if necessary add time of recording overwrite too)
        
        % read the new values
        fprintf('New values: \n');
        fseek(fid,64,-1);
        subj_surname   = char(fread(fid,22,'char'))';

        fseek(fid,86,-1);
        subj_name   = char(fread(fid,20,'char'))';
        
        fseek(fid,106,-1);
        subj_month   = fread(fid,1,'*uchar')';
        subj_day  = fread(fid,1,'*uchar')';
        subj_year   = fread(fid,1,'*uchar')';
        subj_reserved= fread(fid,19,'*uchar')';
        rec_day   = fread(fid,1,'*uchar')';
        rec_month   = fread(fid,1,'*uchar')';
        rec_year   = fread(fid,1,'*uchar')';
        rec_hour   = fread(fid,1,'*uchar')';
        rec_min   = fread(fid,1,'*uchar')';
        rec_sec   = fread(fid,1,'*uchar')';

        disp(sprintf('surname: %s',subj_surname))
        disp(sprintf('name: %s',subj_name))
        fprintf('Date of birth: %u-%u-%u.\n',subj_day,subj_month,uint16(subj_year)+1900);
        fprintf('Reserved chars : [%s]\n',uint16(subj_reserved))
        fprintf('Date of recording: %u-%u-%u.\n',rec_day,rec_month,uint16(rec_year)+1900)
    end
    addpath('./functions/');
%% Overwrite longitude
% if negative values are presentaddpath('./functions/');

    wrapLongitude(fid)
    
%% Anonymisation of montages

% Get amount of montages
    fseek(fid,152,-1);
    Montages=fread(fid,1,'uint8');
    
    fprintf('%u custom montage names found in header.\n',Montages)
    

%% Read Montage header
%     fseek(fid,288,-1);
%     Montage_NAME   = char(fread(fid,8,'char'))';

    fseek(fid,288+8,-1);
    Montage_offset = fread(fid,1,'ulong');

%     fseek(fid,288+12,-1);
%     Montage_length = fread(fid,1,'ulong');

%% Clean montages
    Block_length=4096;
    
for MontageID=0:Montages-1
    offset=Montage_offset+MontageID*Block_length;
        
    fseek(fid,offset+264,-1);
    description=fread(fid,64,'*char')';
    fprintf('Montage %u description: %s\n',MontageID+1,description)
    
% % Unessesary cleaning if done manually: % %
%     a = blanks(64);
%     fseek(fid,offset+264,-1);
%     fwrite(fid,a,'char');
%     
%     str2replace = ['corrupt']';
%     fseek(fid,offset+264,-1);
%     fwrite(fid,str2replace,'char');
% 
%     fseek(fid,offset+264,-1);
%     description = fread(fid,64,'*char')';
%     fprintf('Replaced Montage description: %s\n',description)
 
    
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

    %%  Remaining occurences  
    if nargin==2
        patterns=[];
    end
        check_patterns=[{strtrim(subj_name1),strtrim(subj_surname1)} patterns];
    
%% Scan entire header for name occurences
% Establish header size (triggers are last part of header)
    fseek(fid,400+8,-1);                % 400 is trigger area
    Trig_offset = fread(fid,1,'ulong');
    fseek(fid,400+12,-1);
    Trig_length = fread(fid,1,'ulong');
    headersize=Trig_offset+Trig_length;

    fseek(fid,100,-1);                        % read entire header
    header=fread(fid,headersize,'char')';   
    ix=[];
    for i=1:numel(check_patterns)           %for each pattern
        pattern=check_patterns{i};   %Find occurences of specified pattern
        ixp=strfind(header,pattern);  %(MATLAB) indices of occurences
        fprintf('name \"%s\" still found %u time(s)\n',pattern,numel(ixp));
        ix=[ix ixp];
    end
    if ~isempty(ix)
        warning("name or other pattern still occurs in header")
        snippets=nan(numel(ix),51);
        for j=1:numel(ix)
            snippets(j,:)=header(ix(j):ix(j)+50);
        end
        occurences=char(snippets);
        fprintf('Preview:\n%s', [occurences repmat(newline,size(occurences,1),1)]');
        % Research location
        for k=1:numel(ix)
            if ix(k)>640 && ix(k)<headersize
                for next_start=176+16:16:400                % all pointers
                    fseek(fid,next_start+8,-1);             % seek next offset
                    next_offset = fread(fid,1,'ulong');     
                    if next_offset>ix(k)                        % if k is smaller than offset
                        fseek(fid,next_start-16,-1);        % get previous values
                        other_NAME   = fread(fid,8,'*char')';                   
                        fseek(fid,next_start-8,-1);         
                        other_offset = fread(fid,1,'ulong');
                        fseek(fid,next_start-4,-1);
                        other_length = fread(fid,1,'ulong');
                        fprintf('index %u occurs in %s (range %u:%u:%u)\n',ix(k),other_NAME,other_offset,other_length,next_offset);
                        %section{k}=importSection(fid,other_NAME,other_offset,other_length);
                        break
                    elseif next_start==400
                        fprintf('index %u occurs in TRIGGER\n',ix(k));
                    end 
                end
            else
                fprintf('index %u occurs in header start or outside header. Check if patient data have been anonymised yet.\n',ix(k));
            end
        end
    else
        fprintf('header clean of names (and specified patterns)!');
    end    
%%
    fclose(fid);

catch ME
    status = 1;
    msg    = sprintf('%s err:%s --func:%s',fileName,ME.message,ME.stack(1).name);
end

end