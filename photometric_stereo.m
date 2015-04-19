% Photometric stereo
%
%Author: Xiuming Zhang (GitHub: xiumingzhang), National Univ. of Singapore
%

clear;
close all;
clc;

addpath(genpath('../psmImages/'));

IMAGE = 'buddha';

% Read in mask
mask = tga_read_image([IMAGE '.mask.tga']);
mask = rgb2gray(mask);

%------------------------ Get light directions, L

fileID = fopen('lights.txt', 'r');
s = textscan(fileID, '%f %f %f', 'HeaderLines', 1, 'Delimiter', ' ');
fclose(fileID);
L = [s{1} s{2} s{3}];

%------------------------ Get images, I (same order as L)

I = cell(12, 1);
for idx = 1:size(I, 1)
    im = tga_read_image([IMAGE '.' num2str(idx-1) '.tga']);
    I{idx} = im;
end

%========================= SURFACE NORMALS =========================%

N = compute_surfNorm(I, L, mask);
% Visualization
show_surfNorm(N, 4);

%========================= HEIGHT MAP =========================%

Z = compute_heightMap(N, mask);
% Visualization
figure;
imshow(uint8(Z));
