%% load data

tol = 1e-6;
nearZero = @(x,tol) norm(x) < tol;
var_tol = 1.0;
RS_path = 'data/RS/2022-02-08_14-25-37/';
BO_path = 'data/BO/2022-02-08_14-25-37/';

RS_files = dir(strcat(RS_path,'*.bin'));
BO_files = dir(strcat(BO_path,'*.json'));
n_trials = numel(BO_files);
cmd_sweep = readmatrix('data/BO/2022-02-08_14-25-37/cmd_sweep.csv');
cmd_sweep = cmd_sweep(1:n_trials, :);  % only keep relevant ones
N_eigs = 12;
all_eigvals = zeros(N_eigs, n_trials);

success_idx = false(n_trials, 1);
all_values = zeros(n_trials, 1);

% Load successes
all_trials = cell(1, n_trials);

% check name explicitly, can have mismatch!
for idx=1:n_trials
    
    BO_file = append(BO_files(idx).folder, '/', BO_files(idx).name);
    [max_target, max_idx, max_eig, target_val, param_val] = loadData_BO(BO_file);
    RS_name = strcat(erase(BO_files(idx).name, '.json'), '.bin');
    RS_file = append(RS_files(idx).folder, '/', RS_name);
    [N_runs, iter, time, cmd, state] = loadData_RS(RS_file);

    % will now auto-fail since we're building up the name of RS from BO
%     if ~contains(BO_files(idx).name, 'fail')
%         assert(~contains(RS_file.name, 'fail'));
%         success_idx(idx) = true;
%     else
%         assert(contains(RS_file.name, 'fail'));
%     end
    if ~contains(BO_files(idx).name, 'fail')
        success_idx(idx) = true;
    end
    % now check if the trajectories fail in any other sense
    all_fail = true;
    for tdx = 1:numel(state)
        traj = state{tdx};
        if (check_failure(traj)~=true)
            all_fail = false;
            break
        end
    end
    if all_fail
        display(strcat('failed at ', num2str(idx)));
        success_idx(idx) = false;
    end

    trial.state_trajs = state;
    trial.cmd_trajs = cmd;
    trial.time = time;
    trial.bo_values = target_val;
    trial.eigenvals = param_val;
    trial.success = success_idx(idx);
    all_trials{idx} = trial;
end