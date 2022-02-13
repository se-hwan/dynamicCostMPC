%% metadata
%  Description: demonstration of eigendecomposition and random basis vector
%               generation
%  Author:      Se Hwan Jeon

clear; clc;

%% eigendecomposition
N = 12;                  % dimension
H = rand(N, N);         % NxN matrix from random uniform distribution [0,1]
Q = H'*H;               % Positive semi-definite matrix

[V, D] = eig(Q);        % eigendecomposition of Q
v_space = V*sqrt(D);
disp("Q"); disp(Q)
disp("Q decomposition"); disp(V*D*V');
disp("Q vector space"); disp(v_space*v_space');

%% random basis vector generation
N_basis = 12;
basis = zeros(N_basis, N_basis);

basis(:,1) = randn(N_basis, 1);
basis(:,1) = basis(:,1)./norm(basis(:,1));

for i = 2:N_basis
    basis_vec = basis(:,1:i-1);
    v2 = randn(N_basis,1);
    orth = v2;
    for j = 1:length(basis_vec(1,:))
        v1 = basis_vec(:,j);
        orth = orth - (dot(v1, v2)/dot(v1,v1))*v1;
    end
    orth = orth./norm(orth);
    basis(:,i) = orth;
end

disp("Random orthogonal basis vectors");
disp(basis);

test = basis*diag(randn(1, N_basis))*basis';
try chol(test)
    disp('Matrix is symmetric positive definite.')
catch ME
    disp('Matrix is not symmetric positive definite')
end

writematrix(basis, "basis.csv")


%% plot unit sphere with orthogonal basis for sanity check
figure; hold on;
axis equal; grid on;
xlabel('X'); ylabel('Y'); zlabel('Z')
colors = {'r','g','b','c','m','y','k','w','#0072BD','#D95319','#EDB120','#7E2F8E'};
[X, Y, Z] = sphere(50);
surf(X, Y, Z, 'facecolor', 'blue', 'edgecolor', 'None', 'faceAlpha', 0.2)
for i = 1:N_basis
    x_c = [0; basis(1,i)];
    y_c = [0; basis(2,i)];
    z_c = [0; basis(3,i)];
    plot3(x_c, y_c, z_c, 'Color', colors{i}, 'LineWidth', 2.0);
end

