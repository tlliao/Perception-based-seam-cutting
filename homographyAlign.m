function [ homo1, homo_pmap1, homo2, homo_pmap2 ] = homographyAlign( img1,pmap1,img2,pmap2,init_H )
%input: target image and reference image, saliency map of the two images
%output: homography-warped target and reference, with their corresponding
%saliency maps
tform = projective2d(init_H');
img1mask = imwarp(true(size(img1,1),size(img1,2)), tform, 'nearest');

img1To2 = imwarp(img1, tform);  % 单应性变形图
img1To2 = cat(3,img1mask, img1mask, img1mask).*img1To2;

pmap1To2 = imwarp(pmap1, tform); % 显著性变形图
pmap1To2 = img1mask.*pmap1To2;

pt = [1, 1, size(img1,2), size(img1,2);
      1, size(img1,1), 1, size(img1,1);
      1, 1, 1, 1]; 
H_pt = init_H*pt; H_pt = H_pt(1:2,:)./repmat(H_pt(3,:),2,1);

% calculate the convas
off = ceil([ 1 - min([1 H_pt(1,:)]) + 1 ; 1 - min([1 H_pt(2,:)]) + 1 ]);
cw = max(size(img1To2,2)+max(1,floor(min(H_pt(1,:))))-1, size(img2,2)+off(1)-1);
ch = max(size(img1To2,1)+max(1,floor(min(H_pt(2,:))))-1, size(img2,1)+off(2)-1);

homo1 = zeros(ch,cw,3); homo2 = zeros(ch,cw,3); % 变形结果图
homo_pmap1 = zeros(ch,cw);  homo_pmap2 = zeros(ch,cw);

% 变形后待拼接图和基准图
homo1(floor(min(H_pt(2,:)))+off(2)-1:floor(min(H_pt(2,:)))+off(2)-2+size(img1To2,1),...
    floor(min(H_pt(1,:)))+off(1)-1:floor(min(H_pt(1,:)))+off(1)-2+size(img1To2,2),:) = img1To2;
homo2(off(2):(off(2)+size(img2,1)-1),off(1):(off(1)+size(img2,2)-1),:) = img2;
% 变形后显著性图
homo_pmap1(floor(min(H_pt(2,:)))+off(2)-1:floor(min(H_pt(2,:)))+off(2)-2+size(pmap1To2,1),...
    floor(min(H_pt(1,:)))+off(1)-1:floor(min(H_pt(1,:)))+off(1)-2+size(pmap1To2,2)) = pmap1To2;
homo_pmap2(off(2):(off(2)+size(pmap2,1)-1),off(1):(off(1)+size(pmap2,2)-1)) = pmap2;


end

