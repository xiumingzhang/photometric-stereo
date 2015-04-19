function Z = compute_heightMap(N, mask)
%COMPUTE_HEIGHTMAP Computes the height map given images, their
%corresponding light directions, and the gray mask
%
%   Z = compute_heightMap(N, mask)
%
%computes the height map "Z", a m-by-n matrix, from the
%surface normals "N", a m-by-n-by-3 matrix whose each element is a
%3-vector and the gray mask "mask".
%
%Author: Xiuming Zhang (GitHub: xiumingzhang), National Univ. of Singapore
%

[im_h, im_w, ~] = size(N);

% 2D index to 1D object index
[obj_h, obj_w] = find(mask);
no_pix = size(obj_h, 1);
full2obj = zeros(im_h, im_w);
for idx = 1:size(obj_h, 1)
    full2obj(obj_h(idx), obj_w(idx)) = idx;
end

M = sparse(2*no_pix, no_pix);
u = sparse(2*no_pix, 1);

%------------------------ Assemble M and u

failed_rows = [];
for idx = 1:no_pix
    % Position in 2D image
    h = obj_h(idx);
    w = obj_w(idx);
    % Surface normal
    n_x = N(h, w, 1);
    n_y = N(h, w, 2);
    n_z = N(h, w, 3);
    % First row - vertical neighbors
    row_idx = (idx-1)*2+1;
    % Filter our potentially harmful points
    if mask(h+1, w) % check if down neighbor is in bound
        idx_vertN = full2obj(h+1, w);
        u(row_idx) = n_y;
        M(row_idx, idx) = -n_z;
        M(row_idx, idx_vertN) = n_z;
    elseif mask(h-1, w) % check if up neighbor is in bound
        idx_vertN = full2obj(h-1, w);
        u(row_idx) = -n_y;
        M(row_idx, idx) = -n_z;
        M(row_idx, idx_vertN) = n_z;
    else % no vertical neighbors
        failed_rows = [failed_rows; row_idx];
    end
    % Second row - horizontal neighbors
    row_idx = (idx-1)*2+2;
    if mask(h, w+1) % check if right neighbor is in bound
        idx_horizN = full2obj(h, w+1);
        u(row_idx) = -n_x;
        M(row_idx, idx) = -n_z;
        M(row_idx, idx_horizN) = n_z;
    elseif mask(h, w-1) % check if left neighbor is in bound
        idx_horizN = full2obj(h, w-1);
        u(row_idx) = n_x;
        M(row_idx, idx) = -n_z;
        M(row_idx, idx_horizN) = n_z;
    else % no horizontal neighbors
        failed_rows = [failed_rows; row_idx];
    end
end

% Remove those all-zero rows
M(failed_rows, :) = [];
u(failed_rows, :) = [];

%------------------------ Solve

z = (M.'*M)\(M.'*u);
% z = qmr(M.'*M, M.'*u);
% z = lsqr(M, u);

% From sparse back to full matrix
z = full(z);

% Outliers due to singularity
outlier_ind = abs(zscore(z))>10;
z_min = min(z(~outlier_ind));
z_max = max(z(~outlier_ind));

%------------------------ Reassemble z back to 2D

Z = double(mask);
for idx = 1:no_pix
    % Position in 2D image
    h = obj_h(idx);
    w = obj_w(idx);
    % Rescale
    Z(h, w) = (z(idx)-z_min)/(z_max-z_min)*255;
end

