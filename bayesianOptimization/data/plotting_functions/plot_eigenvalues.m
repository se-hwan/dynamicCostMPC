function p = plot_eigenvalues()
[~, idx_star] = maxk(target_val, 20);
det_star = zeros(length(idx_star), 1);
lambda_star = zeros(length(idx_star), 12);
for i = 1:length(idx_star)
    lambda_star(i,:) = param_val(idx_star(i),:);
end

Q_idx = 1:12;
figure; hold on;
for i = 1:length(idx_star)
    det_star(i) = prod(lambda_star(i,:));
    plot(1:12, lambda_star(i, :), 'o-')
    plot(1:12, max_param,'*-')
    
end
xticks([1:12])
xticklabels({'\psi', '\phi', '\theta', 'x', 'y', 'z', '\omega_x', '\omega_y', '\omega_z', 'v_x', 'v_y', 'v_z'})

end