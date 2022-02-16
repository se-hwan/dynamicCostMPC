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
BO_path = 'BO/';

RS_files = dir(strcat(RS_path,'*.bin'));
BO_files = dir(strcat(BO_path,'*.json'));
n_trials = numel(BO_files);
cmd_sweep = readmatrix('BO/cmd_sweep.csv');
cmd_sweep = cmd_sweep(1:n_trials, :);  % only keep relevant ones
N_eigs = 12;
all_eigvals = zeros(N_eigs, n_trials);

success_idx = false(n_trials, 1);
all_values = zeros(n_trials, 1);

% Load successes
for idx=1:n_trials
    if ~contains(BO_files(idx).name, 'fail')
        BO_name = append(BO_files(idx).folder, '/', BO_files(idx).name);
        [max_target, max_idx, max_eig, target_val, param_val] = loadData_BO(BO_name);
        all_values(idx) = max_target;
        all_eigvals(:, idx) = max_eig;
        success_idx(idx) = true;
    end
end

% trim out failures
cmds = cmd_sweep(success_idx, :);
values = all_values(success_idx);
eigvals = all_eigvals(:, success_idx);

%% least-squares
% n_trials = 4;


poly_order = 1;

test_size = 0.1;
train_set = true(size(values));
train_set(1:floor(test_size*size(values,1))) = false;
train_set = train_set(randperm(length(train_set)));
test_set = ~train_set;

for poly_order = 0:1:6

% pick = false(size(cmd_sweep, 1));
% pick(6:12) = true;
% pick(28:32) = true;
% pick(41:45) = true;
% pick(118:121) = true;
[lifted_cmds, lift_map] = lift_cmds(cmds.', poly_order, true);
M1 = eigvals(:, train_set)/lifted_cmds(:, train_set);
% M2 = eigvals(:, train_set)*pinv(lifted_cmds(:, train_set));

display(strcat('------------------', "With polynomial order: ", num2str(poly_order), '------------------'))
test_fit(M1, lifted_cmds, eigvals, train_set, test_set);
% fit2 = M2*lifted_cmds(:, test_set);
% error = vecnorm(fit2 - eigvals(:, test_set));
% display(strcat("Error of ", num2str(mean(error)), ' with Pinv'))
% display(norm(M1-M2, 'fro'))
end

%%
lifted_cmds
