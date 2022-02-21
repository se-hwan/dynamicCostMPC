clear; clc;

%% select data files
filename = 'DCMPC_sim_data';
date = 'cmpc_sweep_grid/';
date = '';
RS_data = append('RS/',date,filename,'.bin');
BO_data = append('BO/',date,filename,'.json');
addpath(genpath('plotting_functions'));

%% load and parse data
[N_runs, iter, time, cmd, state]                           = loadData_RS(RS_data);
% [max_target, max_idx, max_param, target_val, param_val]    = loadData_BO(BO_data);

%% plot states and commands
plot_states(time, state, cmd, 0);

%% compare optimal Q values 


%% plot heatmap from matrix
load('basis_RS.csv');

% choose lambda, "max_param" variable is highest performing optimized eigenvalues
lambda = max_param;

Q_star = basis_RS*diag(lambda)*basis_RS';
plot_heatmap(Q_star)

%% plot radargraph from vectors [n datasets x m data elements]
plot_radar(lambda)
