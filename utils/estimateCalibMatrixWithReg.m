function [calibM,full_scale]=estimateCalibMatrixWithReg(rawData,expectedWrench,C_w,lambda)
C_w=C_w'; 
kIA = kron(eye(6), rawData);
n=size(kIA,1);
A=(kIA'*kIA)/n+lambda*eye(36);
b=(kIA'*expectedWrench(:))/n+lambda*C_w(:);
vec_x=pinv(A)*b;
X = reshape(vec_x, 6, 6);
B_pred = rawData*X;


calibM = X';

eLS = (expectedWrench - B_pred);

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

