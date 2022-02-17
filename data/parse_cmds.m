load 'cmpc_data.mat'

success = cmds(:, 4);
success = ~~success;  % stupid way to convert to logicals
good_cmds = cmds(success, 1:3);
bad_cmds = cmds(~success, 1:3);
cmd_dist = min(pdist2(bad_cmds, good_cmds),[], 2);
[sorted_bad_cmds, sorted_idx] = sort(cmd_dist);
sorted_cmds = bad_cmds(sorted_idx, :);

% 
% figure;
hold on;
scatter3(good_cmds(:,1),good_cmds(:,2),good_cmds(:,3),'g','filled')
from = 1;
until = 200;
scatter3(sorted_cmds(from:until, 1), sorted_cmds(from:until, 2), sorted_cmds(from:until, 3), 'b', 'filled')
from = 201;
until = 400;
scatter3(sorted_cmds(from:until, 1), sorted_cmds(from:until, 2), sorted_cmds(from:until, 3))
scatter3(sorted_cmds(from:until, 1), sorted_cmds(from:until, 2), sorted_cmds(from:until, 3), 'r', 'filled')
from = 1000;
until = 1200;
scatter3(sorted_cmds(from:until, 1), sorted_cmds(from:until, 2), sorted_cmds(from:until, 3), 'k')
xlabel('xdot cmd')
ylabel('ydot cmd')
zlabel('yaw_dot cmd')
legend('successes','closest 200', 'next 200', 'rather far 200');

cmpc_cmds = struct();
cmpc_cmds.sweep = cmds;
cmpc_cmds.success = good_cmds;
cmpc_cmds.fail_sorted = sorted_cmds;

save("cmpc_cmds.mat")