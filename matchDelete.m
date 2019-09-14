function [matches1, matches2] = matchDelete(pts1, pts2, height, width)

%% delete the wrong matches (one-to-more)
[~, ind_1] = unique(pts1', 'rows');
pts1 = pts1(:,ind_1');
pts2 = pts2(:,ind_1');
[~, ind_2] = unique(pts2', 'rows');
pts1 = pts1(:,ind_2');
pts2 = pts2(:,ind_2');

%% use histogram (horizontal and vertical orientation) delete outliers
thr = 0.1;  
% horizontal histogram
xbins = (-width+width*thr/2:width*thr:width-width*thr/2);
counts1 = hist(pts1(1,:)-pts2(1,:), xbins);
[~,ia1] = max(counts1);
C1 = find(pts1(1,:)-pts2(1,:)>=max(-width,-width+(ia1-2)*width*thr) & pts1(1,:)-pts2(1,:)<=min(width,-width+(ia1+1)*width*thr));
% vertical histogram
ybins = (-height+height*thr/2: height*thr: height-height*thr/2);
counts2 = hist(pts1(2,:)-pts2(2,:), ybins);
[~, ia2] = max(counts2);
C2 = find(pts1(2,:)-pts2(2,:)>=max(-height,-height+(ia2-2)*height*thr) & pts1(2,:)-pts2(2,:)<=min(height, -height+(ia2+1)*height*thr));
% final inliers after 1st filter
C = intersect(C1,C2);
pts1 = pts1(:,C);
pts2 = pts2(:,C); 

%% RANSAC delete
coef.minPtNum = 4; %max(min(round(size(pts1,2)/4),10),4);
coef.iterNum = 1000;
coef.thDist = 5;
coef.thInlrRatio = .1;
 
[~,corrPtIdx1] = ransacx(pts2, pts1, coef); %, @DLT_Homo,@calcDist);
matches1 = pts1(:, corrPtIdx1);
matches2 = pts2(:, corrPtIdx1);

end