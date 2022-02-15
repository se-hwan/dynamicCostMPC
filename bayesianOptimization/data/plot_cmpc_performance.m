clear all
close all
clc

%% select data file
date = 'cmpc_1/';
cmds = readmatrix(['RS/',date,'cmd_sweep.csv']);
addpath(genpath('plotting_functions'));

%% check for success/fail
N = size(cmds,1);
cmds(:,end+1) = ones(N,1);
figure
for i = 1:N
   try 
       filename = ['cmd_sweep_',num2str(i)];
       RS_data = append('RS/',date,filename,'.bin');
       loadData_RS(RS_data);
       figure(1)
       plot3(cmds(i,1),cmds(i,2),cmds(i,3),'go')
       hold on
       figure(2)
       plot(cmds(i,1),cmds(i,3),'go')
       hold on
   catch
       cmds(i,end) = 0;
       figure(1)
       plot3(cmds(i,1),cmds(i,2),cmds(i,3),'rx')
       hold on
       figure(2)
       plot(cmds(i,1),cmds(i,3),'rx')
       hold on
   end
end
figure(1)
grid on
xlabel('v_x')
ylabel('v_y')
zlabel('\omega_z')

figure(2)
grid on
xlabel('v_x')
ylabel('\omega_z')

save('cmpc_data.mat','cmds')

