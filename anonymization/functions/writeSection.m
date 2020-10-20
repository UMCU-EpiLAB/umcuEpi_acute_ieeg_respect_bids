function writeSection(fid,sectionData,section_NAME,section_offset,section_length)
switch section_NAME
    case 'MONTAGE '
        max_mont=30;
        max_can_view=128;
        for l=1:max_mont
            offset=section_offset+4096*(l-1);
            fseek(fid,offset,-1);
            fwrite(fid,sectionData(l).lines,'*ushort');
            fwrite(fid,sectionData(l).sectors,'*ushort');
            fwrite(fid,sectionData(l).base_time,'*ushort');
            fwrite(fid,sectionData(l).notch,'*ushort');
            fwrite(fid,sectionData(l).colour,'*uchar');
            fwrite(fid,sectionData(l).selection,'*uchar');
            fwrite(fid,sectionData(l).description,'*char');
            fwrite(fid,sectionData(l).inputs,'*ushort');
            fwrite(fid,sectionData(l).hiPass_filter,'*ulong');
            fwrite(fid,sectionData(l).lowPass_filter,'*ulong');
            fwrite(fid,sectionData(l).reference,'*ulong');
            fwrite(fid,sectionData(l).free,'*uchar');
        end
        fprintf('%u entries written in section %s\n',l,section_NAME);
    case 'LABCOD  '
       for l=1:section_length/128
           offset=section_offset+128*(l-1);
           fseek(fid,offset,-1);
           fwrite(fid,sectionData(l).status,'*uchar');
           fwrite(fid,sectionData(l).type,'*uchar');
           fwrite(fid,sectionData(l).positive_input_label,'*char');
           fwrite(fid,sectionData(l).negative_input_label,'*char');
           fwrite(fid,sectionData(l).logic_min,'*long');
           fwrite(fid,sectionData(l).logic_max,'*long');
           fwrite(fid,sectionData(l).logic_ground,'*long');
           fwrite(fid,sectionData(l).physic_min,'*long');
           fwrite(fid,sectionData(l).physic_max,'*long');
           fwrite(fid,sectionData(l).measurement_unit,'*ushort');
           fwrite(fid,sectionData(l).hiPass_lim,'*ushort');
           fwrite(fid,sectionData(l).hiPass_type,'*ushort');
           fwrite(fid,sectionData(l).lowPass_lim,'*ushort');
           fwrite(fid,sectionData(l).lowPass_type,'*ushort');
           fwrite(fid,sectionData(l).rate_coefficient,'*ushort');
           fwrite(fid,sectionData(l).position,'*ushort');
           fwrite(fid,sectionData(l).latitudine,'*float');
           fwrite(fid,sectionData(l).longitudine,'*float');
           fwrite(fid,sectionData(l).presentInMap,'*uchar');
           fwrite(fid,sectionData(l).isInAvg,'*uchar');
           fwrite(fid,sectionData(l).description,'*char');
           fwrite(fid,sectionData(l).x,'*float');
           fwrite(fid,sectionData(l).y,'*float');
           fwrite(fid,sectionData(l).z,'*float');
           fwrite(fid,sectionData(l).coordinate_type,'*ushort');
           fwrite(fid,sectionData(l).free,'*uchar');
       end
        fprintf('%u entries written in section %s\n',l,section_NAME);
    case 'NOTE    '
        for l=1:section_length/44
            offset=section_offset+44*(l-1);
            fseek(fid,offset,-1);
            fwrite(fid,sectionData(l).sample,'*ulong');
            fwrite(fid,sectionData(l).comment,'*char');
        end 
        fprintf('%u entries written in section %s\n',l,section_NAME);   
    otherwise
         warning('Missing module to write %s; or invalid name',section_NAME);
end