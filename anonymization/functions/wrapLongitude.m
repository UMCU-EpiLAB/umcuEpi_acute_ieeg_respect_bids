function wrapLongitude(fid)

fseek(fid,192,-1);
labcod_NAME   = fread(fid,8,'*char')';                   
labcod_offset = fread(fid,1,'ulong');
labcod_length = fread(fid,1,'ulong');
fprintf('electrodes should be under %s (range %u:%u:%u)\n',labcod_NAME,labcod_offset,labcod_length,labcod_offset+labcod_length);
%% import
labcodData=importSection(fid,labcod_NAME,labcod_offset,labcod_length);
falselong=sum([labcodData.longitudine]<0);
if falselong
    fprintf('Wrapping %u longitude values in electrode configuration\n',falselong);
    
    %% fix longitudes
    wrapped=num2cell(wrapTo360([labcodData.longitudine]));
    [labcodData.longitudine]=wrapped{:};
else
    fprintf('No negative longitudes in electrode configuration\n');
    return
end
%% write
fprintf('Overwriting electrode section\n');
writeSection(fid,labcodData,labcod_NAME,labcod_offset,labcod_length);

%% check
labcodData2=importSection(fid,labcod_NAME,labcod_offset,labcod_length);
if sum([labcodData2.longitudine]<0)
    error('longitude data still contains negative values')
else
    fprintf('No negative longitudes in new electrode configuration\n');
    return
end

end %/function