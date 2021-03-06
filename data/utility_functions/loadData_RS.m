function [N_runs, iter, time, cmd, state] = loadData_RS(file_name)
    % load and parse binary data from Robot-Software
    % Binary write structure:
    % iter:         uint32
    % t_sim:        float32
    % vel_cmd_x:    float32
    % vel_cmd_y:    float32
    % vel_cmd_yaw:  float32
    % rpy_x:        float32
    % posn_x:       float32
    % omega_x:      float32
    % v_x:          float32
    % rpy_y:        float32
    % posn_y:       float32
    % omega_y:      float32
    % v_y:          float32
    % rpy_y:        float32
    % posn_y:       float32
    % omega_y:      float32
    % v_y:          float32
    
    N_dataTypes = 17; % number of logged simulations values per iteration
    
    % for now, will change after adding parameters (impulses + parameters?)
    bytes_offset = [0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64];
    bytes_skip = 64;
    bytes_sim = bytes_skip + 4; % size of bytes for one simulation run
    
    file_info = dir(file_name);
    data_size = file_info.bytes;
    
    N_iter = cast(data_size/bytes_sim, 'int64');
    data_full = zeros(N_iter, N_dataTypes);
    
    % Read integer iteration values
    file = fopen(file_name);
    fseek(file, bytes_offset(1), 'bof');
    data_full(:, 1) = fread(file, inf, 'uint32', bytes_skip);
    
    for i = 2:N_dataTypes
        file = fopen(file_name);
        fseek(file, bytes_offset(i), 'bof');
        data_full(:, i) = fread(file, inf, 'float32', bytes_skip);
    end
    
    data_iter = data_full(:,1);
    data_time = data_full(:,2);
    data_cmd = data_full(:, 3:5);
    data_state = [data_full(:, 6) data_full(:,10) data_full(:,14) ...
                  data_full(:, 7) data_full(:,11) data_full(:,15) ...
                  data_full(:, 8) data_full(:,12) data_full(:,16) ...
                  data_full(:, 9) data_full(:,13) data_full(:,17)];
    % data_imp = zeros(N_iter, 3);

    % parse separate simulation runs
    idx_runs = find(data_iter == 0);
    N_runs = length(idx_runs);
    iter = cell(N_runs, 1);
    time = cell(N_runs, 1);
    cmd = cell(N_runs, 1);
    % imp = cell(N_runs, 1);
    state = cell(N_runs, 1);
    
    for i = 1:N_runs-1
        iter{i} = data_iter(idx_runs(i):idx_runs(i+1)-1);
        time{i} = data_time(idx_runs(i):idx_runs(i+1)-1);
        cmd{i} = data_cmd(idx_runs(i):idx_runs(i+1)-1, :);
    %     imp{i} = data_imp(idx_runs(i):idx_runs(i+1)-1, :);
        state{i} = data_state(idx_runs(i):idx_runs(i+1)-1, :);
    end
    iter{end} = data_iter(idx_runs(end):end);
    time{end} = data_time(idx_runs(end):end);
    cmd{end} = data_cmd(idx_runs(end):end, :);
    % imp{end} = data_imp(idx_runs(end):end, :);
    state{end} = data_state(idx_runs(end):end, :);

end


