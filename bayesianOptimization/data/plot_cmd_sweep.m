clear; clc;

%% 3D velocity command sweep
N_s = 500; % velocity command samples

vx_max = 4.5;
vy_max = 3.5;
omega_max = 7.5;

cmd_sweep = zeros(N_s, 3);
for i = 1:N_s
    vx_samp = vx_max/3 * randn(1, 1);
    vy_samp = vy_max/3 * randn(1, 1);
    wz_samp = omega_max/3 * randn(1, 1);
    cmd_sweep(i,:) = [vx_samp, vy_samp, wz_samp];
end

figure;
hold on; grid on;
xlabel('v_x (m/s)'); ylabel('v_y (m/s)'); zlabel('\omega_z (rad/s)')
plot3(linspace(-vx_max, vx_max, 10),zeros(1, 10),zeros(1, 10),'r--')
plot3(zeros(1, 10),linspace(-vy_max, vy_max, 10),zeros(1, 10),'g--')
plot3(zeros(1, 10), zeros(1, 10),linspace(-omega_max, omega_max, 10),'c--')
for i = 1:N_s
    plot3(cmd_sweep(i, 1), cmd_sweep(i,2), cmd_sweep(i,3), 'k.')
end

%% save 3D command sweep
SAVE_CMD_SWEEP= false;
if SAVE_CMD_SWEEP
    writematrix(cmd_sweep, 'cmd_sweep_tmp.csv');
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
SAVE_CMD_SLICE = true;
if SAVE_CMD_SLICE
    writematrix(vx_vy_sweep, 'vx_vy_sweep_tmp.csv');
    writematrix(vx_wz_sweep, 'vx_wz_sweep_tmp.csv');
    writematrix(vy_wz_sweep, 'vy_wz_sweep_tmp.csv');
end






