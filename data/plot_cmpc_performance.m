clear
close all
clc

%% select data file
date_cmpc = 'cmpc_sweep_grid/';
date_bo = 'dataset_Q_basis_00/';
cmpc_cmds = readmatrix(['BO/',date_cmpc,'cmd_sweep.csv']);
addpath(genpath('utility_functions'));
bo_cmds = readmatrix(['BO/',date_bo, 'cmd_sweep.csv']);
% load("cmpc_data.mat")
% cmds = cmpc_cmds.sweep;

%% check for success/fail
N_cmpc = size(cmpc_cmds,1);
N_BO = size(bo_cmds, 1);
cmpc_cmds(:,end+1) = ones(N_cmpc,1);
bo_cmds(:,end+1) = ones(N_BO,1);

for i = 1:N_cmpc
    try
        filename = ['cmd_sweep_',num2str(i)];
        BO_data = append('BO/',date_cmpc,filename,'.json');
        [cmpc_cmds(i, 5), ~, ~, ~, ~] = loadData_BO(BO_data);
    catch
        cmpc_cmds(i,4) = 0;
    end
end
for i = 1:N_BO
    try
        filename = ['cmd_sweep_',num2str(i)];
        BO_data = append('BO/',date_bo,filename,'.json');
        [bo_cmds(i, 5), ~, ~, ~, ~] = loadData_BO(BO_data);
    catch
        bo_cmds(i,4) = 0;
        bo_cmds(i,5) = 0;
    end
end

%% plotting

figure; hold on
plot3(cmpc_cmds(cmpc_cmds(:,4) == 1,1),cmpc_cmds(cmpc_cmds(:,4) == 1,2),cmpc_cmds(cmpc_cmds(:,4) == 1,3),'r+')
plot3(bo_cmds(bo_cmds(:,4) == 1,1),bo_cmds(bo_cmds(:,4) == 1,2),bo_cmds(bo_cmds(:,4) == 1,3),'bd')
% plot3(cmpc_cmds(cmpc_cmds(:,4) == 0,1),cmpc_cmds(cmpc_cmds(:,4) == 0,2),cmpc_cmds(cmpc_cmds(:,4) == 0,3),'rx')
grid on
xlabel('v_x')
ylabel('v_y')
zlabel('\omega_z')
% legend('cMPC', 'BO')
save('cmpc_sweep.mat','cmpc_cmds')

figure; hold on;
plot(sort(cmpc_cmds([find(cmpc_cmds(:,5)>0)], 5)))
plot(sort(bo_cmds([find(bo_cmds(:,5)>0)], 5)))
ylabel("High-level reward"); xlabel("Sorted commands")
legend('cMPC', 'BO')
