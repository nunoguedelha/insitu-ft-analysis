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

ftDataName=strcat(input.ftPortName,'/data.log'); % (arm, foot and leg have FT data)
stateDataName=strcat(input.statePortName,'/data.log');  % (only foot has no state data)
%params.m is expected to have contactInfo (1 right ,0 left ), relevant (if
%there is an specific interval desired to study (1 true, 0 false ) and
%rData which is a double array 1x2 that has begining and ending of interval in seconds
    
for i=1:size(input.ftNames,1)
    dataFTDirs{i}=strcat('data/',experimentName,'/icub/',input.ftNames{i},'/',ftDataName);  
end
    
%robots, although this is dependent on the output kind of the data dumper
%% load FT data
[ftData.(input.ftNames{1}),time]=readDataDumper(dataFTDirs{1});
nanIndex=0;
nanCount=0;
for i=2:size(input.ftNames,1)
    %read from dataDumper
    [ftData_temp,time_temp]=readDataDumper(dataFTDirs{i});
    %resample FT data
    ftData.(input.ftNames{i})=resampleFt(time,time_temp,ftData_temp);
    %if the initial time of the time_temp is less than time it might return
    %NaN values for the those first values, so we will take into account
    %which has the biggest amount of nans and remove those values with
    %applyMask later
    if (sum(isnan(ftData.(input.ftNames{i})(:,1)))>nanCount)
       nanIndex=i;
       nanCount=sum(isnan(ftData.(input.ftNames{i})(:,1)));
    end
end
    
dataset.time=time;
dataset.ftData=ftData;

%% Data exploration

% Plot ftData
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
    subplot(plotSide,plotSide,i);
    plot3_matrix(dataset.ftData.(input.ftNames{i})(:,1:3));
    xlabel('x (N)');
    ylabel('y (N)');
    zlabel('z (N)');
    title(input.ftNames{i}, 'Interpreter', 'none'); 
end
