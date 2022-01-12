clear; clc; close all

%% load and parse RS data
table = readtable("longVel_RS.csv",'NumHeaderLines',1);
N = length(table.Var1);
data_iter = table.Var1;
data_time = table.Var2;
data_cmd = zeros(N, 3);    
    
data_imp = zeros(N, 6);
data_state = zeros(N, 12);
for i = 1:length(data_time)
    data_cmd(i,:) = str2num(table.Var3{i});
    data_imp(i,:) = str2num(table.Var4{i});
    data_state(i,:) = str2num(table.Var5{i});
end

%% parse separate simulation runs
idx_runs = find(data_iter == 0);
N_runs = length(idx_runs);
iter = cell(N_runs, 1);
time = cell(N_runs, 1);
cmd = cell(N_runs, 1);
imp = cell(N_runs, 1);
state = cell(N_runs, 1);

for i = 1:N_runs-1
    iter{i} = data_iter(idx_runs(i):idx_runs(i+1)-1);
    time{i} = data_time(idx_runs(i):idx_runs(i+1)-1);
    cmd{i} = data_cmd(idx_runs(i):idx_runs(i+1)-1, :);
    imp{i} = data_imp(idx_runs(i):idx_runs(i+1)-1, :);
    state{i} = data_state(idx_runs(i):idx_runs(i+1)-1, :);
end
iter{end} = data_iter(idx_runs(end):end);
time{end} = data_time(idx_runs(end):end);
cmd{end} = data_cmd(idx_runs(end):end, :);
imp{end} = data_imp(idx_runs(end):end, :);
state{end} = data_state(idx_runs(end):end, :);

%% load and parse json data
fname = 'spinning_BO.json'; 
fid = fopen(fname); 
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


%% plotting and analysis
[max_target, max_idx] = max(target_val);
max_param = param_val(max_idx, :)

%% plotting

plot(time{max_idx}, state{max_idx}(:, 5))
xlabel("Time")
ylabel("Impulse")
legend('v_x', 'v_y', '\omega')

figure;
plot(time{2}, imp{2})
xlabel("Time")
ylabel("Impulse")
legend('\tau_x','\tau_y','\tau_z','f_x','f_y','f_z')