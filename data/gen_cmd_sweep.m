clear; clc;

%% 3D velocity command sweep
N_s = 500; % velocity command samples

vx_max = 4.5; % 4,5
vy_max = 3.0; % 3.5
omega_max = 7.0; % 7.5

cmd_sweep = zeros(N_s, 3);

%% load cmpc range
load("cmpc_data.mat")

%% sampling options

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
% vx_ls = linspace(-vx_max, vx_max, 20); % uniform grid
% vy_ls = linspace(0, vy_max, 10);
% wz_ls = linspace(0, omega_max, 10);
% [vx_grid, vy_grid, wz_grid] = meshgrid(vx_ls, vy_ls, wz_ls);
% cmd_sweep = [vx_grid(:) vy_grid(:) wz_grid(:)];


N_success = length(cmpc_data.success(:,1));

cmd_sweep(1:N_success,:) = cmpc_data.success(:,1:3);
cmd_sweep(N_success+1:end, :) = cmpc_data.fail_sorted(1:(N_s-N_success), 1:3);

figure;
hold on; grid on; axis equal;
xlabel('v_x (m/s)'); ylabel('v_y (m/s)'); zlabel('\omega_z (rad/s)')
plot3(linspace(-vx_max, vx_max, 10),zeros(1, 10),zeros(1, 10),'r--')
plot3(zeros(1, 10),linspace(-vy_max, vy_max, 10),zeros(1, 10),'g--')
plot3(zeros(1, 10), zeros(1, 10),linspace(-omega_max, omega_max, 10),'b--')
for i = 1:N_s
    plot3(cmd_sweep(i, 1), cmd_sweep(i,2), cmd_sweep(i,3), 'k.')
end
axis([-vx_max*1.1, vx_max*1.1, 0, vy_max*1.1, 0, omega_max*1.1])

%% save 3D command sweep
SAVE_CMD_SWEEP = true;
if SAVE_CMD_SWEEP
    writematrix(cmd_sweep, 'cmd_sweep.csv');
end

%% 2D velocity command slice
N_s = 200; 
vx_vy_sweep = zeros(N_s, 3);
vx_wz_sweep = zeros(N_s, 3);
vy_wz_sweep = zeros(N_s, 3);

for i = 1:N_s
    vx_samp = vx_max/2 * randn(1, 1);
    vy_samp = vy_max/2 * randn(1, 1);
    wz_samp = omega_max/2 * randn(1, 1);
    vx_vy_sweep(i,:) = [vx_samp, vy_samp, 0];
    vx_wz_sweep(i,:) = [vx_samp, 0, wz_samp];
    vy_wz_sweep(i,:) = [0, vy_samp, wz_samp];
end

f = figure; f.Position = [500 100 2500 750];
subplot(1,3,1); hold on; grid on; axis equal;
xlabel('v_x (m/s)'); ylabel('v_y (m/s)')
xline(0); yline(0);
plot(vx_vy_sweep(:,1), vx_vy_sweep(:,2), 'bo')

subplot(1,3,2); hold on; grid on; axis equal;
xlabel('v_x (m/s)'); ylabel('\omega_z (rad/s)')
xline(0); yline(0);
plot(vx_wz_sweep(:,1), vx_wz_sweep(:,3), 'bo')

subplot(1,3,3); hold on; grid on; axis equal;
xlabel('v_y (m/s)'); ylabel('\omega_z (rad/s)')
xline(0); yline(0);
plot(vy_wz_sweep(:,2), vy_wz_sweep(:,3), 'bo')


%% save 2D command slices
SAVE_CMD_SLICE = false;
if SAVE_CMD_SLICE
    writematrix(vx_vy_sweep, 'vx_vy_sweep.csv');
    writematrix(vx_wz_sweep, 'vx_wz_sweep.csv');
    writematrix(vy_wz_sweep, 'vy_wz_sweep.csv');
end






