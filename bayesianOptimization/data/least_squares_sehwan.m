%% Load all trials
clear; clc;
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
BO_path = 'BO/2022-02-04_17-26-01/';

RS_files = dir(strcat(RS_path,'*.bin'));
BO_files = dir(strcat(BO_path,'*.json'));
n_trials = numel(BO_files);
cmd_sweep = readmatrix('BO/2022-02-04_17-26-01/cmd_sweep.csv');
cmd_sweep = cmd_sweep(1:n_trials, :);  % only keep relevant ones
N_eigs = 12;
all_eigvals = zeros(N_eigs, n_trials);

success_idx = false(n_trials, 1);
all_values = zeros(n_trials, 1);

cmd_success = zeros(1, 3);
cmd_fail = zeros(1, 3);

% Load successes
for idx=1:n_trials
    if ~contains(BO_files(idx).name, 'fail')
        BO_name = append(BO_files(idx).folder, '/', BO_files(idx).name);
        [max_target, max_idx, max_eig, target_val, param_val] = loadData_BO(BO_name);
        all_values(idx) = max_target;
        all_eigvals(:, idx) = max_eig;
        success_idx(idx) = true;
        cmd_success(idx,:) = cmd_sweep(idx,:);
    else
        cmd_fail(idx,:) = cmd_sweep(idx,:);
    end
end

% trim out failures
cmds = cmd_sweep(success_idx, :);
values = all_values(success_idx);
eigvals = all_eigvals(:, success_idx);


%%
figure; hold on; grid on;
for i = 1:length(cmd_success(:,1))
    plot3(cmd_success(i,1),cmd_success(i,2),cmd_success(i,3), 'ko')
end
for i = 1:length(cmd_fail(:,1))
    plot3(cmd_fail(i,1),cmd_fail(i,2),cmd_fail(i,3), 'ro')
end

plot3(cmd_fail(5,1),cmd_fail(5,2),cmd_fail(5,3), 'b*')

%%
b_norm = zeros(length(cmd_fail), 1);
for i = 1:length(cmd_fail)
    b_norm(i) = norm(cmd_fail(5,:) - cmd_success(i,:));
end
% b_norm = nonzeros(b_norm);

%% least-squares
poly_order = 1;

test_size = 0.1;
train_set = true(size(values));
train_set(1:floor(test_size*size(values,1))) = false;
train_set = train_set(randperm(length(train_set)));
test_set = ~train_set;

%%
N = length(values);
A = zeros(12*N, 48);
z = zeros(12*N, 1);
for i = 1:N
    z(12*i-11:12*i) = eigvals(:,i);
    A(12*i-11:12*i, :) = [cmds(i,1)*eye(12) cmds(i,2)*eye(12) cmds(i,3)*eye(12) eye(12)];
end

x = A\z;

M = reshape(x(1:36), [12, 3])
b = x(37:end)

%%
eig_fit = zeros(N, 12);
for i = 1:N
    eig_fit(i,:) = M*cmds(i,:)' + b;
end

%%
figure; hold on;

plot(eig_fit')

