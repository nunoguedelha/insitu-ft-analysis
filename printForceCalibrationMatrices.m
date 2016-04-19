%% Script for plotting the force data from the F/T sensors in the 3D force space 

%%
%add required folders for use of functions
addpath external/quadfit
addpath utils

% name and paths of the data files
% experimentName='icub-insitu-ft-analysis-big-datasets/2016_04_13/dumper';% Name of the experiment;
experimentName='icub-insitu-ft-analysis-big-datasets/16_03_2016/leftRightLegsGrid/';% Name of the experiment;

% Load parameters file, see 
paramScript=strcat('data/',experimentName,'/params.m');
run(paramScript)

% In params we should have the input.sensNumList and input.ftNames
figure;
nrOfFTSens = length(input.ftNames);
if( nrOfFTSens == 6 )
    plotSideX = 2;
    plotSideY = 3;
else
    plotSideX = ceil(sqrt(nrOfFTSens));
    plotSideY = plotSideX;
end;
for i=1:nrOfFTSens
    [calibMat,fullScale]=readCalibMat(strcat(input.calibMatPath,'matrix_',input.calibMatFileNames{i},'.txt'));
    fprintf('Sensor %s ( %s ) calibration matrix.\n', input.ftNames{i},input.calibMatFileNames{i});
    fprintf('Full scale F/T (N,Nm)\n');
    fullScale
    fprintf('Calib matrix RAW [-2^15,2^15) ---> F/T (N,Nm)\n');
    calibMat
    fprintf('Measurement matrix F/T (N,Nm) ---> RAW [-2^15,2^15)\n');
    inv(calibMat)  
end