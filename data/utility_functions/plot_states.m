function p = plot_states(time, state, cmd, idx)
    % Variables:  var{i}(j, k) ith simulation, at jth time index, with kth element of the variable (state, cmd, etc.)
    % N_runs:     number of simulations performed for BO process
    % iter:       iteration of simulation number
    % time:       time for ith simulation
    % States:     [roll pitch yaw, x y z, omega_x, omega_y, omega_z, v_X, v_y, v_z]
    %             [n_time x 12]
    % Commands:   [v_xc, v_yv, omega_zc]
    %             [n_time x 3]
    
    % plots state and command of highest performance BO simulation
    figure; hold on;
    xlabel('Time (s)'); ylabel('Angular velocity (rad/s)')
    plot(time{idx+1}, state{idx+1}(:,9))
    plot(time{idx+1}, cmd{idx+1}(:,3))
    
    figure; hold on;
    xlabel('Time (s)'); ylabel('Longitudinal velocity (m/s)')
    plot(time{idx+1}, state{idx+1}(:,10))
    plot(time{idx+1}, cmd{idx+1}(:,1))
    
    figure; hold on;
    xlabel('Time (s)'); ylabel('Lateral velocity (m/s)')
    plot(time{idx+1}, state{idx+1}(:,11))
    plot(time{idx+1}, cmd{idx+1}(:,2))
end