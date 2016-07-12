function [calibM,full_scale,offset]=estimateCalibMatrixAndOff(rawData,expectedWrench)
%ESTIMATEDCALIBMATRIXANDOFF Estimate joint the calibration matrix and
%offset
% The input are:
%  rawData (R) a n \times 6 matrix of the raw values 
%  expectedWrench (W) a n \times 6 matrix of wrenches 
% We can write the optimization problem as 
% A x = b 
% Where x \in \mathbb{R}^{36+6} 
%       is x = \vec{C}
%              offset 
% \overline{R} = [R ones(n,1)]
% A = kron(\overline{R},eye(6,6)) 
% b = vec(W') 


[n,wrenchSize] = size(expectedWrench);

R = rawData;
W = expectedWrench;
overlineR = [R ones(n,1)];
Wtrans = W';
b = Wtrans(:);
A = kron(overlineR,eye(6,6));

x = pinv(A)*b;

calibM = reshape(x(1:36), 6, 6);
offset=x(37:42);

% calculate full scale range
maxs = sign(calibM)*32767;
full_scale = diag(calibM*maxs');
max_Fx = ceil(full_scale(1));
max_Fy = ceil(full_scale(2));
max_Fz = ceil(full_scale(3));
max_Tx = ceil(full_scale(4));
max_Ty = ceil(full_scale(5));
max_Tz = ceil(full_scale(6));
% disp(sprintf('%g -> %g N',  full_scale(1), max_Fx))
% disp(sprintf('%g -> %g N',  full_scale(2), max_Fy))
% disp(sprintf('%g -> %g N',  full_scale(3), max_Fz))
% disp(sprintf('%g -> %g Nm', full_scale(4), max_Tx))
% disp(sprintf('%g -> %g Nm', full_scale(5), max_Ty))
% disp(sprintf('%g -> %g Nm', full_scale(6), max_Tz))

