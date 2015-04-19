function h = show_surfNorm(N, step)
%SHOW_SURFNORM Shows the surface normals
%
%   show_surfNorm(N, step)
%
%displays the surface normals "N", a m-by-n-by-3 matrix. The density of the
%normal vectors is controlled by the sampling interval "step".
%
%Author: Xiuming Zhang (GitHub: xiumingzhang), National Univ. of Singapore
%

[im_h, im_w, ~] = size(N);

[X, Y] = meshgrid(1:step:im_w, im_h:-step:1);
U = N(1:step:im_h, 1:step:im_w, 1);
V = N(1:step:im_h, 1:step:im_w, 2);
W = N(1:step:im_h, 1:step:im_w, 3);

h = figure;
quiver3(X, Y, zeros(size(X)), U, V, W);
view([0, 90]);
axis off;
axis equal;

drawnow;
