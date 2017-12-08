function [swaped,scale]=swapCMat(cmat,fullscale)
%The calibration matrix requires a double swap
%the reason for this swap is because the channels that multiply the matrix
%at firmware level are swaped with respect to yarp and when we calibrate
%also the reference is with respect to yarp 
% So the final matrix should have in the first 3 columns the channel
% notaion and in the last 3 rows the forces information
% The swap is then [a,b;c,d]->[d,c;b,a]
swaped=[cmat(4:6,4:6),cmat(4:6,1:3);
        cmat(1:3,4:6),cmat(1:3,1:3)];
scale=[fullscale(4:6);fullscale(1:3)];
% swaped=[cmat(:,4:6),cmat(:,1:3)];
% scale=fullscale;
