function write_to_excel(struct,write_variable,file_out)

f_names = fieldnames(struct.measures);
for file_ind = 1:length(f_names)
    data = struct.measures.(f_names{file_ind}).(write_variable);
    tab = table;
    tab.Group = cell2mat(struct.group');
    n_wi_fact = size(data,ndims(data));
    wi_labels = struct.wi_factor.levels;
    for wi_ind = 1:n_wi_fact
        wi_temp = [num2str(wi_ind),' (',wi_labels{wi_ind},')'];
        tab.(wi_temp) = (data(:,wi_ind));
    end
    writetable(tab,[file_out,'/',f_names{file_ind},'.xlsx'])
end