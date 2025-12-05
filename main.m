clear; clc; close all; 
%----------------------
addpath('modelspecific'); 
addpath('MBS');   % for saliency detection

imgpath = 'Imgs\';

img_format = '*.jpg';
outpath = [imgpath, 'results\'];%testpatch
dir_folder = dir(strcat(imgpath, img_format));
if ~exist(outpath,'dir'); mkdir(outpath); end

path1 =  sprintf('%s%s',imgpath, dir_folder(1).name); %
path2 =  sprintf('%s%s',imgpath, dir_folder(2).name); %
img1 = im2double(imread(path1));  % target image
img2 = im2double(imread(path2));  % reference image

%% saliency detection

pMap_1 = mbs_saliency(img1);
pMap_2 = mbs_saliency(img2);

%% image alignment
fprintf('> image alignment...');tic;
[warped_img1, warped_pmap1, warped_img2, warped_pmap2] = registerTexture(img1, pMap_1, img2, pMap_2, imgpath);
fprintf('done (%fs)\n', toc);

%% image composition
fprintf('> seam cutting...');tic;
imgout = blendTexture(warped_img1, warped_pmap1, warped_img2, warped_pmap2);
fprintf('done (%fs)\n', toc);
