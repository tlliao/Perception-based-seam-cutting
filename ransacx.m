function [f,inlierIdx] = ransacx( x,y, ransacCoef )%, funcFindF, funcDist)
%[f inlierIdx] = ransacx( x,y,ransacCoef,funcFindF,funcDist )
%	Use RANdom SAmple Consensus to find a fit from X to Y.
%	X is M*n matrix including n points with dim M, Y is N*n;
%	The fit, f, and the indices of inliers, are returned.
%
%	RANSACCOEF is a struct with following fields:
%	minPtNum,iterNum,thDist,thInlrRatio
%	MINPTNUM is the minimum number of points with whom can we 
%	find a fit. For line fitting, it's 2. For homography, it's 4.
%	ITERNUM is the number of iteration, 
%   THDIST is the inlier distance threshold and 
%   ROUND(THINLRRATIO*n) is the inlier number threshold.
%
%	FUNCFINDF is a func handle, f1 = funcFindF(x1,y1)
%	x1 is M*n1 and y1 is N*n1, n1 >= ransacCoef.minPtNum
%	f1 can be of any type.

%	FUNCDIST is a func handle, d = funcDist(f,x1,y1)
%	It uses f returned by FUNCFINDF, and return the distance
%	between f and the points, d is 1*n1.
%	For line fitting, it should calculate the dist between the line and the
%	points [x1;y1]; for homography, it should project x1 to y2 then
%	calculate the dist between y1 and y2.
%	Yan Ke @ THUEE, 20110123, xjed09@gmail.com


minPtNum = ransacCoef.minPtNum;
iterNum = ransacCoef.iterNum;
thInlrRatio = ransacCoef.thInlrRatio;
thDist = ransacCoef.thDist;
ptNum = size(x,2);
thInlr = round(thInlrRatio*ptNum);

inlrNum = zeros(1,iterNum);
fLib = cell(1,iterNum);

parfor p = 1:iterNum
	% 1. fit using  random points
	sampleIdx = randIndex(ptNum,minPtNum);
	f1 = calcHomo(x(:,sampleIdx),y(:,sampleIdx));%funcFindF(x(:,sampleIdx),y(:,sampleIdx));    % For homography: f1 is H
	
	% 2. count the inliers, if more than thInlr, refit; else iterate
	dist = calcDist(f1,x,y);%funcDist(f1,x,y);
	inlier1 = find(dist < thDist);      %caculate count of inlier
%     if size(distance,1)==0
%     inlrNum(p) = length(inlier1); %original RANSAC =func(inlier1,distance,para):para=0:length;para=1:distance
%     else
%     if length(inlier1)>=4
%         inlrNum(p) = length(inlier1); %sum(distance(:,inlier1)); %distance RANSAC
%         fLib{p} = inlier1;  % re-caculate H
%     else
%         inlrNum(p) = 0;
%     end
%     end
%     inlrNum(p) = length(inlier1);
	if length(inlier1) < thInlr, continue; end
    inlrNum(p) = length(inlier1);
    fLib{p} = inlier1;  % re-caculate H
end

% 3. choose the coef with the most inliers
[max_inlier, idx] = max(inlrNum);  
if max_inlier==0
    inlierIdx = [];
    f = [];
    return;
end
f = calcHomo(x(:,fLib{idx}),y(:,fLib{idx}));       %most inliers
dist = calcDist(f,x,y);     % find match point
inlierIdx = find(dist < thDist);
f = calcHomo(x(:,inlierIdx),y(:,inlierIdx));
% fprintf('> Select %d matches in 2nd round.\n', length(inlierIdx));
	
end