clear
close all
clc

addpath(genpath('utility_functions'));
load_data = true;
plot_parsed_cmds = true;

%% select data file
cmpc_folder = 'cmpc_sweep_grid/';
cmpc_cmds = readmatrix(['BO/',cmpc_folder,'cmd_sweep.csv']);

if isfile("cmpc_data.mat")
%     load_data = false;
end

%% check for success/fail
if load_data
    N_cmpc = size(cmpc_cmds,1);
    cmpc_cmds(:,end+1) = ones(N_cmpc,1);
    
    for i = 1:N_cmpc
        try
            filename = ['cmd_sweep_' num2str(i)];
            BO_data = append('BO/',cmpc_folder,filename,'.json');
            [cmpc_cmds(i, 5), ~, ~, ~, ~] = loadData_BO(BO_data);
        catch
            cmpc_cmds(i,4) = 0;
            filename = ['cmd_sweep_' num2str(i) '_fail'];
            BO_data = append('BO/',cmpc_folder,filename,'.json');
            [cmpc_cmds(i, 5), ~, ~, ~, ~] = loadData_BO(BO_data);
        end
    end
    cmpc_data = parse_commands(cmpc_cmds, plot_parsed_cmds);
else
    load("cmpc_data.mat")
    cmpc_cmds = cmpc_data.sweep;
end



% bo_filename = 'Qsum_basis00_ei/';
% bo_cmds = readmatrix(['BO/', bo_filename, 'cmd_sweep.csv']);
% 
%     for i = 1:N_BO
%         try
%             filename = ['cmd_sweep_',num2str(i)];
%             BO_data = append('BO/',date_bo,filename,'.json');
%             [bo_cmds(i, 5), ~, ~, ~, ~] = loadData_BO(BO_data);
%         catch
%             bo_cmds(i,4) = 0;
%             bo_cmds(i,5) = 0;
%         end
%     end


%% parse commands
save("cmpc_data.mat", "cmpc_data")

%% plotting
figure; hold on
plot3(cmpc_data.success(:, 1), cmpc_data.success(:, 2), cmpc_data.success(:, 3), 'r*')
% plot3(bo_cmds(bo_cmds(:,4) == 1,1),bo_cmds(bo_cmds(:,4) == 1,2),bo_cmds(bo_cmds(:,4) == 1,3),'bd')
grid on
xlabel('v_x')
ylabel('v_y')
zlabel('\omega_z')
% legend('cMPC', 'BO')

%% function to parse and sort commands
function data_sorted = parse_commands(commands, plot_parsed_commands)
    cmds = commands;
    
    success = cmds(:, 4);
    success = ~~success;  % stupid way to convert to logicals
    good_cmds = [cmds(success, 1:3) cmds(success, 5)];
    bad_cmds = [cmds(~success, 1:3) cmds(~success, 5)];
%     scaling = [4.5 3 8];
%     good_cmds(:, 1) = good_cmds(:, 1)./0.75;
%     good_cmds(:, 2) = good_cmds(:, 2)./0.3;
%     good_cmds(:, 3) = good_cmds(:, 3);
%     bad_cmds(:, 1) = bad_cmds(:, 1)./0.75;
%     bad_cmds(:, 2) = bad_cmds(:, 2)./0.3;
%     bad_cmds(:, 3) = bad_cmds(:, 3)./1;

    cmd_dist = min(pdist2(bad_cmds(:, 1:3), good_cmds(:,1:3)),[], 2);
    [sorted_bad_cmds, sorted_idx] = sort(cmd_dist);
    sorted_cmds = bad_cmds(sorted_idx, :);
    if plot_parsed_commands
        figure;
        hold on;
        scatter3(good_cmds(:,1),good_cmds(:,2),good_cmds(:,3),'g','filled')
        from = 1;
        until = 200;
        scatter3(sorted_cmds(from:until, 1), sorted_cmds(from:until, 2), sorted_cmds(from:until, 3), 'b', 'filled')
        from = 201;
        until = 400;
        scatter3(sorted_cmds(from:until, 1), sorted_cmds(from:until, 2), sorted_cmds(from:until, 3))
        scatter3(sorted_cmds(from:until, 1), sorted_cmds(from:until, 2), sorted_cmds(from:until, 3), 'r', 'filled')
        from = 500;
        until = 700;
        scatter3(sorted_cmds(from:until, 1), sorted_cmds(from:until, 2), sorted_cmds(from:until, 3), 'k')
        xlabel('xdot cmd')
        ylabel('ydot cmd')
        zlabel('yaw_dot cmd')
        legend('successes','closest 200', 'next 200', 'rather far 200');
    end
    
    cmpc_data = struct();
    cmpc_data.sweep = cmds;
    cmpc_data.success = good_cmds;
    cmpc_data.fail_sorted = sorted_cmds;
    data_sorted = cmpc_data;
end