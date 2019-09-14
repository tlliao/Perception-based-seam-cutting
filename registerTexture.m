function [warped_img1, warped_pmap1, warped_img2, warped_pmap2] = registerTexture(img1, pmap1, img2, pmap2, txtpath)
% given two images£¨img1 target£¬ img2 reference£©£¬
% detect and match sift features, estimate homography transformation
% and calculate alignment result

[pts1, pts2] = siftMatch(img1, img2);
Sz1 = max(size(img1,1),size(img2,1)); % to avoid the two images have different resolution
Sz2 = max(size(img1,2),size(img2,2));
[matches_1, matches_2] = matchDelete(pts1, pts2, Sz1, Sz2); % delete wrong match features

init_H = calcHomo(matches_1, matches_2);  % fundamental homography

[warped_img1, warped_pmap1, warped_img2, warped_pmap2] = homographyAlign(img1, pmap1, img2, pmap2, init_H);

end