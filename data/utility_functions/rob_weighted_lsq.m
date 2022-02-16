%% Load all trials

% Map:   M*F*c=lambda
% adaptive_map * feature_map * cmds = eigenvalues
% M = 12x(m)
% F = mx(3+1)
% c = (3+1)x1 --> +1 for affine instead of linear
% lambda = 12x1



%% Process Data, gets weights

data_weight = zeros(N_eigs, n_trials);
cutoff_threshold = 0.75; % use only samples in top x%
% eig_data = []; 
% cmd_data = [];
eig_data = zeros(N_eigs, n_trials);
cmd_data = zeros(3, n_trials);

removed = false(1, n_trials);

failed_cmds = zeros(3, numel(success_idx)-sum(success_idx));
fdx = 1;
for idx=1:n_trials
    state_trajs = all_trials{idx}.state_trajs;
    cmd_trajs = all_trials{idx}.cmd_trajs{1}.';  % always all the same
    time = all_trials{idx}.time;  % this? Could be shorter if failed?
    bo_values = all_trials{idx}.bo_values;
    eigenvals = all_trials{idx}.eigenvals;
    success = all_trials{idx}.success;
    
    if ~success
        removed(idx) = true;
%         failed_cmds(fdx) = 
%         continue
    end
    % possibly re-evaluate value
    value = bo_values;
    % todo: can do something smarter, using histograms
    cutoff_value = cutoff_threshold*(max(value)-min(value)) + min(value);
%     [sorted_vals, sort_idx] = sort(value);
    cutoff_idx = find(value > cutoff_value);
    eig_batch = eigenvals(cutoff_idx, :).'; % should be nx12
    if numel(cutoff_idx)<10  % todo: can handle better. But it seems like an outlier case.
        display(strcat("Dropped: ", num2str(idx)));
        removed(idx) = true;
%         continue
    else
        display(strcat("Using a set of ", num2str(numel(cutoff_idx))))
        eig_var = var(eig_batch.', value(cutoff_idx)).' + var_tol;  % weighted variance
        weights = ones(size(eig_var))./eig_var;
        data_weight(:, idx) = weights;
    end
    cmd = cmd_trajs(:, end);
%   avg_eig = mean(weights.*eig_batch, 2);
%   weighted average
    avg_eig =mean(value(cutoff_idx).'.*eig_batch, 2)/mean(value(cutoff_idx).');

%     eig_data = cat(2, eig_data, eig_batch);
    eig_data(:, idx) = avg_eig;
%     cmd_data = cat(2, cmd_data, cmd_batch);
    cmd_data(:, idx) = cmd;

end

eig_fails = eig_data(:, removed);
cmd_fails = cmd_data(:, removed);
weight_fails = data_weight(:, removed);

eig_data_succ = eig_data(:, ~removed);
cmd_data_succ = cmd_data(:, ~removed);
data_weight_succ = data_weight(:, ~removed);


%% least-squares
% n_trials = 4;
seed = randi(1000);
display("=========================================")
display(strcat("Using random seed: ", num2str(seed)));
display("=========================================")
rng(seed);

test_size = 0.8;
train_set = true(size(eig_data_succ, 2));
train_set(1:floor(test_size*size(eig_data_succ,1))) = false;
train_set = train_set(randperm(length(train_set)));
test_set = ~train_set;
%
for poly_order = 1:10
    % pick = false(size(cmd_sweep, 1));
    % pick(6:12) = true;
    % pick(28:32) = true;
    % pick(41:45) = true;
    % pick(118:121) = true;
    [lifted_cmds, lift_map] = lift_cmds(cmd_data_succ, poly_order, true);
    M1 = eig_data_succ(:, train_set)/lifted_cmds(:, train_set);
    Mw = (data_weight_succ(:, train_set).*eig_data_succ(:, train_set))/lifted_cmds(:, train_set);
    % M2 = eigvals(:, train_set)*pinv(lifted_cmds(:, train_set));

    display(strcat('------------------', "With polynomial order: ", num2str(poly_order), '------------------'))
    [res, err] = test_fit(M1, lifted_cmds, eig_data_succ, train_set, test_set);
    display(strcat('*****   ', "With weighting: ", num2str(poly_order)))
    [res, err] = test_fit(Mw, lifted_cmds, eig_data_succ, train_set, test_set);

    folder_name = strcat('Fit_',num2str(seed), "/_poly_" ,num2str(poly_order), '_res_', num2str(round(mean(res))), '_err_', num2str(round(mean(err))));
    mkdir(folder_name);
    writematrix(lift_map, strcat(folder_name, '/lift_map.csv'));
    writematrix(M1, strcat(folder_name, '/fit.csv'));
    writematrix(Mw, strcat(folder_name, '/fitWeighted.csv'));
    

    % fit2 = M2*lifted_cmds(:, test_set);
    % error = vecnorm(fit2 - eigvals(:, test_set));
    % display(strcat("Error of ", num2str(mean(error)), ' with Pinv'))
    % display(norm(M1-M2, 'fro'))
end