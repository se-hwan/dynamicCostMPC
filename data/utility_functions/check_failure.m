function is_failure = check_failure(traj)
    is_failure = false;
    if any(abs(traj(:, 1) > 40./180*pi))
        is_failure = true;
    end

    if any(traj(:, 6) < 0.05)
        is_failure = true;
    end
    
    % ignoring foot position constraint.
%   for (int leg = 0; leg < 4; leg++) {
%     auto p_leg = _data->_legController->datas[leg]->p;
%     if (p_leg[2] > 0) {
%       printf("Unsafe locomotion: leg %d is above hip (%.3f m)\n", leg, p_leg[2]);
%       return false;
%     }
end