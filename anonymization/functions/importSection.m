function sectionData=importSection(fid,section_NAME,section_offset,section_length)
switch section_NAME
    case 'MONTAGE '
        sectionData=struct([]);
        max_mont=30;
        max_can_view=128;
        for l=1:max_mont
            offset=section_offset+4096*(l-1);
            fseek(fid,offset,-1);
            sectionData(l).lines=fread(fid,1,'*ushort')';
            sectionData(l).sectors=fread(fid,1,'*ushort')';
            sectionData(l).base_time=fread(fid,1,'*ushort')';
            sectionData(l).notch=fread(fid,1,'*ushort')';
            sectionData(l).colour=fread(fid,max_can_view,'*uchar')';
            sectionData(l).selection=fread(fid,max_can_view,'*uchar')';
            sectionData(l).description=fread(fid,64,'*char')';
            sectionData(l).inputs=fread(fid,2*max_can_view,'*ushort')';
            sectionData(l).hiPass_filter=fread(fid,max_can_view,'*ulong')';
            sectionData(l).lowPass_filter=fread(fid,max_can_view,'*ulong')';
            sectionData(l).reference=fread(fid,max_can_view,'*ulong')';
            sectionData(l).free=fread(fid,1720,'*uchar')';
        end
        fprintf('%u entries of %s imported in sectionData for review\n',l,section_NAME);
    case 'LABCOD  '
        sectionData=struct([]);
        for l=1:section_length/128
            offset=section_offset+128*(l-1);
            fseek(fid,offset,-1);
            sectionData(l).status=fread(fid,1,'*uchar')';
            sectionData(l).type=fread(fid,1,'*uchar')';
            sectionData(l).positive_input_label=fread(fid,6,'*char')';
            sectionData(l).negative_input_label=fread(fid,6,'*char')';
            sectionData(l).logic_min=fread(fid,1,'*long')';
            sectionData(l).logic_max=fread(fid,1,'*long')';
            sectionData(l).logic_ground=fread(fid,1,'*long')';
            sectionData(l).physic_min=fread(fid,1,'*long')';
            sectionData(l).physic_max=fread(fid,1,'*long')';
            sectionData(l).measurement_unit=fread(fid,1,'*ushort')';
            sectionData(l).hiPass_lim=fread(fid,1,'*ushort')';
            sectionData(l).hiPass_type=fread(fid,1,'*ushort')';
            sectionData(l).lowPass_lim=fread(fid,1,'*ushort')';
            sectionData(l).lowPass_type=fread(fid,1,'*ushort')';
            sectionData(l).rate_coefficient=fread(fid,1,'*ushort')';
            sectionData(l).position=fread(fid,1,'*ushort')';
            sectionData(l).latitudine=fread(fid,1,'*float')';
            sectionData(l).longitudine=fread(fid,1,'*float')';
            sectionData(l).presentInMap=fread(fid,1,'*uchar')';
            sectionData(l).isInAvg=fread(fid,1,'*uchar')';
            sectionData(l).description=fread(fid,32,'*char')';
            sectionData(l).x=fread(fid,1,'*float')';
            sectionData(l).y=fread(fid,1,'*float')';
            sectionData(l).z=fread(fid,1,'*float')';
            sectionData(l).coordinate_type=fread(fid,1,'*ushort')';
            sectionData(l).free=fread(fid,24,'*uchar')';
        end
        fprintf('%u entries of %s imported in sectionData for review\n',l,section_NAME);   
    case 'NOTE    '
        sectionData=struct([]);
        %max_note=200;
        for l=1:section_length/44
            offset=section_offset+44*(l-1);
            fseek(fid,offset,-1);
            sectionData(l).sample=fread(fid,1,'*ulong')';
            sectionData(l).comment=fread(fid,40,'*char')';
        end 
        fprintf('%u entries of %s imported in sectionData for review\n',l,section_NAME);   
    otherwise
        warning('Missing module to import %s; or invalid name',section_NAME);
        sectionData=struct([]);
        return
end