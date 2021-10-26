function [ C, R, Mc ] = hough_find_seed( img )
% hough_find: Find seed from image by performing Hough Transform
% Parameter
% - img: image in gray scale
[C, R, Mc] = imfindcircles(img, [round(max(size(img))/16) round(max(size(img))/4)]);
end
