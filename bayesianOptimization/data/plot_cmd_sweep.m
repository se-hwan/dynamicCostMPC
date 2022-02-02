clear; clc;

%% velocity command spread
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

%% save command sweep

SAVE_MATRIX = false;
if SAVE_MATRIX
    writematrix(cmd_sweep, 'cmd_sweep_tmp.csv');
end