%% functions to read, load, and parse data

function [max_target, max_idx, max_param, target_val, param_val] = loadData_BO(file_name)
    % load and parse json data
    fid = fopen(file_name); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid);
    idx_entries = find(raw == 10);
    idx_entries = [1; idx_entries];
    
    simulations = cell(length(idx_entries)-1, 1);
    target_val = zeros(length(simulations), 1);
    param_val = zeros(length(simulations), 12);
    
    entry = jsondecode(str(idx_entries(1):idx_entries(2)));
    param_names = fieldnames(entry.params);
    
    for i = 1:length(idx_entries)-1
        entry = jsondecode(str(idx_entries(i):idx_entries(i+1)));
        target_val(i) = entry.target;
        for j = 1:12
            param_val(i, j) = entry.params.(param_names{j});
        end
    end
    [max_target, max_idx] = max(target_val);
    max_param = param_val(max_idx, :);

end