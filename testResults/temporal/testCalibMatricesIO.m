% Test to make sure that readCalibMat and writeCalibMat are one the inverse
% of the another (to complete)
addpath external/quadfit
addpath utils
[calibMat1,fullscale] = readCalibMat('../data/sensorCalibMatrices/matrix_SN026.txt');
writeCalibMat(calibMat1,fullscale,'./calibMatTest.txt');
[calibMat2,fullscale2] = readCalibMat('calibMatTest.txt');

diff=calibMat1-calibMat2;

if( sum(sum(diff))==0)
   disp('loading and writing is working perfectly, difference between matrices = 0')
   success=true;
end