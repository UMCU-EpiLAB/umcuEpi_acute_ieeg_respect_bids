function metadata = look_for_electrode_manufacturer(metadata,elecmodel_idx,annots)

annots_elecmodel = annots(elecmodel_idx,2);

manufacturer = repmat({'n/a'},size(metadata.ch,1),1); 
ES = repmat({'n/a'},size(metadata.ch,1),1); 
IE = repmat({'n/a'},size(metadata.ch,1),1); 

for i = 1:size(annots_elecmodel,1)
    annotsmodelsplit = strsplit([annots_elecmodel{i,:}],{';','Elec_model;'});
    annotsmodelsplit = annotsmodelsplit(~cellfun(@isempty,annotsmodelsplit));
    if size(annotsmodelsplit,2) == 3
        [manufacturer{metadata.ch2use_included}] = deal(annotsmodelsplit{1});
        [ES{metadata.ch2use_included}] = deal(annotsmodelsplit{2});
        [IE{metadata.ch2use_included}] = deal(annotsmodelsplit{3});


    elseif size(annotsmodelsplit,2) >= 4
        ch_parsed = zeros(size(metadata.ch));
        input_str = 'Elec_model;';
        for j = 1:length(annotsmodelsplit)-3
            input_str = [input_str,annotsmodelsplit{j},';'];
        end

        ch_parsed = ch_parsed | parse_annotation(input_str,metadata.ch);% ; to use parse annotation
        [manufacturer{ch_parsed}]  = deal(annotsmodelsplit{length(annotsmodelsplit)-2});
        [ES{ch_parsed}]  = deal(annotsmodelsplit{length(annotsmodelsplit)-1});
        [IE{ch_parsed}]  = deal(annotsmodelsplit{length(annotsmodelsplit)});

    else
        error('Elec_model annotation incorrect')

    end

end

nNA_included = length(metadata.ch2use_included)-sum(metadata.ch2use_included);
nNA_ElecModel = length(strfind(char(join(manufacturer)),'n/a'));

if nNA_included ~= nNA_ElecModel
    error('Not all included electrodes have a corresponding elec_model!')
end

metadata.electrode_manufacturer = manufacturer;
metadata.electrode_size = ES;
metadata.interelectrode_distance = IE;
end