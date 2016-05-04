function [calibM,full_scale,offset]=estimateCalibMatrixWithRegAndOff(rawData,expectedWrench,C_w,lambda,O_w)
[mb, nb] = size(expectedWrench);

kIA = kron(eye(6), rawData);
kI=repmat(eye(6),size(rawData,1),1);
kIA=[kIA,kI];
A=kIA'*kIA+lambda*eye(42);
% b=kIA'*expectedWrench(:)+ lambda*[C_w(:);O_w];
b=kIA'*expectedWrench(:)+ lambda*[C_w(:);zeros(6,1)];
vec_x=pinv(A)*b;
X = reshape(vec_x(1:36), 6, 6);
offset=vec_x(37:42);
B_pred = rawData*X;
%Br_pred = Ar*X;

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

