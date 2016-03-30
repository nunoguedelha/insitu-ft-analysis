% Test to make sure that readCalibMat and writeCalibMat are one the inverse
% of the another (to complete)

[calibMat1,fullscale] = readCalibMat('../data/sensorCalibMatrices/matrix_SN026.txt');
writeCalibMat(calibMat1,fullscale,'./calibMatTest.txt');
[calibMat2,fullscale2] = readCalibMat('calibMatTest.txt');