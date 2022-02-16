function [lifted_cmds, lift_map] = lift_cmds(cmds, A, is_affine)

if nargin<3
    is_affine = true;
end

n_commands = size(cmds, 1);
n_entries = size(cmds, 2);

% only this one for now
% if numel(A) == 1  % overall polynomial degree for all

% elseif size(A, 1) == 1  % list of polynomial degree

% else  % A is a matrix with exact combinations

n_poly = A;
num_coeffs = nchoosek(n_poly+n_commands, n_poly)-1;
lifted_cmds = zeros(num_coeffs, n_entries);

% A = eye(n_commands);
polybank = [0:n_poly].'*ones(1, n_commands);
polybank = reshape(polybank.', 1, []);
possibles = nchoosek(polybank, n_commands); % build up all possible polynomials
keep = unique(possibles(sum(possibles, 2) <= n_poly, :), 'rows'); % discard the ones that are too high
% lift_map = zeros(1, n_commands); % TODO save polynomial coefficients in a reasonable way
lift_map = [];

% for ddx = 1:n_entries  % for each data entry
entry_id = 1;
if is_affine
    start_with = 1;
else
    start_with = 2;
end
for kdx = start_with:size(keep, 1) % first is always zeros
     % get all possible combinations at given polynomial level
    poly_patterns = fliplr(unique(perms(keep(kdx, :)), 'rows')).';  % Hack: fliplr is a temporary solution
    lift_map = cat(1, lift_map, poly_patterns.');
    for pdx = 1:size(poly_patterns, 2)
        lifted_cmds(entry_id, :) = prod(cmds.^poly_patterns(:, pdx), 1);
        entry_id = entry_id +1;
    end
end
% 
% if is_affine
%     lifted_cmds = cat(1, ones(1, n_entries), lifted_cmds)
% end

end