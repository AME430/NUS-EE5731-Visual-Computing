function [xmax,xmin,ymax,ymin] = getlimits(input,H)
% Multiplies homography matrix with the corner coordinates of input image to find the coordinates of
% input image in new coordinate frame.  
%   input 	= input image to find the limits of in the new coordinate frame
%   H       = homography matrix
%   limits	= coordinates of corners in new coordinate frame   
height = size(input,1);         % vertical y axis
length = size(input,2);         % horizontal x axis

tl = [1; 1; 1];               	% top left
tr = [length; 1; 1];        	% top right
bl = [1; height; 1];         	% bottom left
br = [length; height; 1];       % bottom right

limits = cat(2,tl,tr,bl,br);
T = H * limits;
T_H = T(1:2,:)./T(3,:);         % homogeneous coordinates of limits in img2 frame

xmax = max(T_H(1,:));
xmin = min(T_H(1,:));
ymax = max(T_H(2,:));
ymin = min(T_H(2,:));
end

