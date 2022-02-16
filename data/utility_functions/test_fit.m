function [residual, test_error] = test_fit(M, cmds, sols, train_set, test_set)

% if nargin <= 3  % default, all is train set
%     train_set = ones(1, size(sols, 2));
%     test_set = zeros(size(train_set));
% end

fit_train = M*cmds(:, train_set);
residual = vecnorm(fit_train - sols(:, train_set));
fit_test = M*cmds(:, test_set);
test_error = vecnorm(fit_test - sols(:, test_set));

display(strcat("Residual of ", num2str(mean(residual)), " Error of ", num2str(mean(test_error))))

end