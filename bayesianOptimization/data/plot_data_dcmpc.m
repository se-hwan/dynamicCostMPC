clear; clc;

%% select data files
filename = 'cmd_sweep_1_fail';
RS_data = append('RS/',filename,'.bin');
BO_data = append('BO/',filename,'.json');

%% load and parse data
[N_runs, iter, time, cmd, state]                           = loadData_RS(RS_data);
[max_target, max_idx, max_param, target_val, param_val]    = loadData_BO(BO_data);

%% plot states and commands

% Variables:  var{i}(j, k) ith simulation, at jth time index, with kth element of the variable (state, cmd, etc.)
% N_runs:     number of simulations performed for BO process
% iter:       iteration of simulation number
% time:       time for ith simulation
% States:     [roll pitch yaw, x y z, omega_x, omega_y, omega_z, v_X, v_y, v_z]
%             [n_time x 12]
% Commands:   [v_xc, v_yv, omega_zc]
%             [n_time x 3]

% plots state and command of highest performance BO simulation
figure; hold on;
xlabel('Time (s)'); ylabel('Angular velocity (rad/s)')
plot(time{max_idx+1}, state{max_idx+1}(:,9))
plot(time{max_idx+1}, cmd{max_idx+1}(:,3))

figure; hold on;
xlabel('Time (s)'); ylabel('Longitudinal velocity (m/s)')
plot(time{max_idx+1}, state{max_idx+1}(:,10))
plot(time{max_idx+1}, cmd{max_idx+1}(:,1))

figure; hold on;
xlabel('Time (s)'); ylabel('Lateral velocity (m/s)')
plot(time{max_idx+1}, state{max_idx+1}(:,11))
plot(time{max_idx+1}, cmd{max_idx+1}(:,2))

%% compare optimal Q values 
[~, idx_star] = maxk(target_val, 20);
det_star = zeros(length(idx_star), 1);
lambda_star = zeros(length(idx_star), 12);
for i = 1:length(idx_star)
    lambda_star(i,:) = param_val(idx_star(i),:);
end

Q_idx = 1:12;
figure; hold on;
for i = 1:length(idx_star)
    det_star(i) = prod(lambda_star(i,:));
    plot(1:12, lambda_star(i, :), 'o-')
    plot(1:12, max_param,'*-')
    
end
xticks([1:12])
xticklabels({'\psi', '\phi', '\theta', 'x', 'y', 'z', '\omega_x', '\omega_y', '\omega_z', 'v_x', 'v_y', 'v_z'})


%% plot Q heatmap
load('basis_RS.txt');

% choose lambda, "max_param" variable is highest performing optimized eigenvalues
lambda = max_param;
% lambda = lambda_star(2,:); 

Q_star = basis_RS*diag(lambda)*basis_RS';

figure; hold on;
imagesc(Q_star)
% colormap("winter") % seasonal theme for plots
colormap("autumn") % for something spicier
% divergent colormap, change at 0
colorbar
axis tight
set(gca, 'YDir', 'reverse')


















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





