clear; clc;

%% velocity command spread

N_d = 6; % resolution of command discretization

vx_max = 4.5;
vy_max = 3.5;
omega_max = 7.5;


vx_sweep = linspace(-vx_max, vx_max, N_d);
vy_sweep = linspace(-vy_max, vy_max, N_d);
omega_sweep = linspace(-omega_max, omega_max, N_d);

[vx_grid, vy_grid, omega_grid] = meshgrid(vx_sweep, vy_sweep, omega_sweep);


figure;
hold on; grid on;
xlabel('v_x (m/s)'); ylabel('v_y (m/s)'); zlabel('\omega_z (rad/s)')
plot3(vx_sweep,zeros(1, N_d),zeros(1, N_d),'r--')
plot3(zeros(1, N_d),vy_sweep,zeros(1, N_d), 'g--')
plot3(zeros(1, N_d),zeros(1, N_d),omega_sweep, 'c--')
for i = 1:N_d
    l = plot3(vx_grid(:,:,i), vy_grid(:,:,i), omega_grid(:,:,i), 'k.');
end


