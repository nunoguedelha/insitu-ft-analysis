function [calibM,full_scale,offset]=estimateCalibMatrixWithRegAndOff(rawData,expectedWrench,C_w,lambda,O_w)
% This functions augments the calibration matrix to consider also the
% offset. So that the offset is estimated during the process.
% inputs:
%  rawData: is the raw data coming from ft sensors
%  expectedWrench: is the reference of the regression
%  C_w: is a previous calibration matrix
%  lambda: is the regularization parameter
%  O_w: in case there is a known offset we can use that information in the
%  regularization
%
% outputs:
%  calibM: the resulting calibration matrix
%  full_scale: the values obtained if the raw values are maxed out
%  offset: the resulting offset

%%
[n,wrenchSize] = size(expectedWrench);
C_wTrans=C_w';
R = rawData;
W = expectedWrench;
overlineR = [R ones(n,1)];
Wtrans = W';
b = Wtrans(:);
kA = kron(overlineR,eye(6,6));
toPenalize=zeros(42);
toPenalize(1:36,1:36)=eye(36); % this evades to try to minimize the offset
A=kA'*kA+lambda*toPenalize;
b=kA'*b+lambda*[C_wTrans(:);O_w];
x = pinv(A)*b;

calibM = reshape(x(1:36), 6, 6);
offset=x(37:42);
%Change offset sign to match the other estimation functions
offset=-offset;
% calculate full scale range
maxs = sign(calibM)*32767;
full_scale = diag(calibM*maxs');
max_Fx = ceil(full_scale(1));
max_Fy = ceil(full_scale(2));
max_Fz = ceil(full_scale(3));
max_Tx = ceil(full_scale(4));
max_Ty = ceil(full_scale(5));
max_Tz = ceil(full_scale(6));