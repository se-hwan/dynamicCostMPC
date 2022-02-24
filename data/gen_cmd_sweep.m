clear; clc;

%% 3D velocity command sweep
N_s = 92; % velocity command samples

vx_max = 4.5; % 4,5
vy_max = 3.0; % 3.5
omega_max = 8.0; % 7.5

gen_cmpc_commands = false;
save_cmd_sweep = false;

%% command sampling

if gen_cmpc_commands
    disp("Generating commands for cMPC sweep...")
    vx_ls = linspace(-vx_max, vx_max, 13); % uniform grid
    vy_ls = linspace(0, vy_max, 11);
    wz_ls = linspace(0, omega_max, 9);
    [vx_grid, vy_grid, wz_grid] = meshgrid(vx_ls, vy_ls, wz_ls);
    cmd_sweep = [vx_grid(:) vy_grid(:) wz_grid(:)];
else
%     cmd_sweep = zeros(1, 3);
    disp("Generating commands for BO from cMPC sweep...")
    load("cmpc_data.mat")
    N_success = length(cmpc_data.success(:,1));
    cmd_sweep = zeros(N_s, 3);
%     cmd_sweep(1:N_success,:) = cmpc_data.success(:,1:3);
%     sampled_failures = zeros(N_s-N_success, 3);
    cmd_sweep(1:N_s, :) = cmpc_data.fail_sorted(1:N_s, 1:3);
    
    manual_cmds = [[3.25:.25:4.0]' zeros(4,2)];
    cmd_sweep = [cmd_sweep; manual_cmds; -manual_cmds];
end

%% plot sampled commands

figure;
hold on; grid on;
xlabel('v_x (m/s)'); ylabel('v_y (m/s)'); zlabel('\omega_z (rad/s)')
axis([-vx_max*1.1, vx_max*1.1, 0, vy_max*1.1, 0, omega_max*1.1])
plot3(linspace(-vx_max, vx_max, 10),zeros(1, 10),zeros(1, 10),'r--')
plot3(zeros(1, 10),linspace(-vy_max, vy_max, 10),zeros(1, 10),'g--')
plot3(zeros(1, 10), zeros(1, 10),linspace(-omega_max, omega_max, 10),'b--')

if gen_cmpc_commands
    plot3(cmd_sweep(:,1), cmd_sweep(:,2), cmd_sweep(:,3), 'k.')
else
    plot3(cmd_sweep(1:N_success,1), cmd_sweep(1:N_success,2), cmd_sweep(1:N_success,3), 'b.')
    plot3(cmd_sweep(N_success+1:end,1), cmd_sweep(N_success+1:end,2), cmd_sweep(N_success+1:end,3), 'r.')
end

%% save 3D command sweep
if save_cmd_sweep
    writematrix(cmd_sweep, 'cmd_sweep.csv');
end






















%% other sampling options
% for i = 1:N_s % Gaussian sampling
%     vx_samp = vx_max/3 * randn(1, 1);
%     vy_samp = vy_max/3 * randn(1, 1);
%     wz_samp = omega_max/3 * randn(1, 1);
%     cmd_sweep(i,:) = [vx_samp, vy_samp, wz_samp];
% end
% for i = 1:N_s % Uniform sampling
%     vx_samp = 2.*vx_max*(rand - 0.5);
%     vy_samp = 2.*vy_max*(rand - 0.5);
%     wz_samp = 2.*omega_max*(rand - 0.5);
%     vy_samp = vy_max*rand;
%     wz_samp = omega_max*rand;
%     cmd_sweep(i,:) = [vx_samp, vy_samp, wz_samp];
% end

%% 2D velocity command slice
% N_s = 200; 
% vx_vy_sweep = zeros(N_s, 3);
% vx_wz_sweep = zeros(N_s, 3);
% vy_wz_sweep = zeros(N_s, 3);
% 
% for i = 1:N_s
%     vx_samp = vx_max/2 * randn(1, 1);
%     vy_samp = vy_max/2 * randn(1, 1);
%     wz_samp = omega_max/2 * randn(1, 1);
%     vx_vy_sweep(i,:) = [vx_samp, vy_samp, 0];
%     vx_wz_sweep(i,:) = [vx_samp, 0, wz_samp];
%     vy_wz_sweep(i,:) = [0, vy_samp, wz_samp];
% end
% 
% f = figure; f.Position = [500 100 2500 750];
% subplot(1,3,1); hold on; grid on; axis equal;
% xlabel('v_x (m/s)'); ylabel('v_y (m/s)')
% xline(0); yline(0);
% plot(vx_vy_sweep(:,1), vx_vy_sweep(:,2), 'bo')
% 
% subplot(1,3,2); hold on; grid on; axis equal;
% xlabel('v_x (m/s)'); ylabel('\omega_z (rad/s)')
% xline(0); yline(0);
% plot(vx_wz_sweep(:,1), vx_wz_sweep(:,3), 'bo')
% 
% subplot(1,3,3); hold on; grid on; axis equal;
% xlabel('v_y (m/s)'); ylabel('\omega_z (rad/s)')
% xline(0); yline(0);
% plot(vy_wz_sweep(:,2), vy_wz_sweep(:,3), 'bo')
% 
% SAVE_CMD_SLICE = false;
% if SAVE_CMD_SLICE
%     writematrix(vx_vy_sweep, 'vx_vy_sweep.csv');
%     writematrix(vx_wz_sweep, 'vx_wz_sweep.csv');
%     writematrix(vy_wz_sweep, 'vy_wz_sweep.csv');
% end
