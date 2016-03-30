% Test to make sure that readCalibMat and writeCalibMat are one the inverse
% of the another (to complete)

calibMat1 = readCalibMat('../data/sensorCalibMatrices/matrix_SN026.txt');
writeCalibMat(calibMat1,'./calibMatTest.txt');
calibMat2 = readCalibMat('.calibdMatTest.txt');