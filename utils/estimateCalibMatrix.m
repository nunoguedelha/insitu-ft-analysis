function [calibM,full_scale]=estimateCalibMatrix(rawData,expectedWrench)
[mb, nb] = size(expectedWrench);

kIA = kron(eye(6), rawData);


vec_x = pinv(kIA)*expectedWrench(:);
X = reshape(vec_x, 6, 6);
B_pred = rawData*X;
%Br_pred = Ar*X;

C = X';

eLS = (expectedWrench - B_pred);

% calculate full scale range
maxs = sign(C)*32767;
full_scale = diag(C*maxs');
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


Wf = diag([1/max_Fx 1/max_Fy 1/max_Fz 1/max_Tx 1/max_Ty 1/max_Tz]);
Ws = diag([1/32767 1/32767 1/32767 1/32767 1/32767 1/32767]);
calibM = Wf * C * inv(Ws);
