clear all
close all
clc

%% select data file
% date = 'cmpc_2/';
% cmds = readmatrix(['RS/',date,'cmd_sweep.csv']);
% addpath(genpath('plotting_functions'));

load("cmpc_data.mat")
cmds = cmpc_cmds.sweep;

%% check for success/fail
N = size(cmds,1);
cmds(:,end+1) = ones(N,1);
figure
for i = 1:N
    try
        filename = ['cmd_sweep_',num2str(i)];
        RS_data = append('RS/',date,filename,'.bin');
        loadData_RS(RS_data);
    catch
        cmds(i,end) = 0;
    end
end

figure(1)
plot3(cmds(cmds(:,4) == 1,1),cmds(cmds(:,4) == 1,2),cmds(cmds(:,4) == 1,3),'go')
hold on
plot3(cmds(cmds(:,4) == 0,1),cmds(cmds(:,4) == 0,2),cmds(cmds(:,4) == 0,3),'rx')
grid on
xlabel('v_x')
ylabel('v_y')
zlabel('\omega_z')

% save('cmpc_data.mat','cmds')

