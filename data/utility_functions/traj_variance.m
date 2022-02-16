%% Load all trials

% Map:   M*F*c=lambda
% adaptive_map * feature_map * cmds = eigenvalues
% M = 12x(m)
% F = mx(3+1)
% c = (3+1)x1 --> +1 for affine instead of linear
% lambda = 12x1

%% load data

tol = 1e-6;
nearZero = @(x,tol) norm(x) < tol;
RS_path = 'RS/';
% BO_path = 'BO/';

RS_files = dir(strcat(RS_path,'*.bin'));
% BO_files = dir(strcat(BO_path,'*.json'));
n_trials = numel(RS_files);
% cmd_sweep = readmatrix('BO/cmd_sweep.csv');
% cmd_sweep = cmd_sweep(1:n_trials, :);  % only keep relevant ones

state_idx = zeros(1, 12);

N_eigs = 12;
% all_eigvals = zeros(N_eigs, n_trials);

% success_idx = false(n_trials, 1);
% all_values = zeros(n_trials, 1);


% Load successes
err_std = zeros(3, n_trials);
err_mean = zeros(3, n_trials);
success_idx = false(n_trials, 1);

for idx=1:n_trials
    RS_name = append(RS_files(idx).folder, '/', RS_files(idx).name);
%         BO_name = append(BO_files(idx).folder, '/', BO_files(idx).name);
    [N_runs, iter, time, cmd, state] = loadData_RS(RS_name);
    x = state{end};
    cmd_traj = cmd{end};
    cmd_err = cmd_traj(1:end, :) - x(:, 9:11);
    err_mean(:, idx) = mean(cmd_err).';
    err_std(:, idx) = std(cmd_err).';
    if ~contains(RS_files(idx).name, 'fail')
        success_idx(idx) = true;
    end
end
