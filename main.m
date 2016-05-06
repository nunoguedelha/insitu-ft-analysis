%% Comparing FT data vs estimated data
% %create input parameter is done through params.m for each experiment

%add required folders for use of functions
addpath external/quadfit
addpath utils
% name and paths of the data files
% experimentName='icub-insitu-ft-analysis-big-datasets/16_03_2016/leftRightLegsGrid';% Name of the experiment;
%  experimentName='icub-insitu-ft-analysis-big-datasets/21_03_2016/yogaLeft1';% Name of the experiment;
 experimentName='icub-insitu-ft-analysis-big-datasets/2016_05_06';% Name of the experiment;
% experimentName='icub-insitu-ft-analysis-big-datasets/2016_04_21/extendedYoga4StandingOnLeft';% Name of the experiment;
paramScript=strcat('data/',experimentName,'/params.m');
run(paramScript)
forceCalculation=true;
if (exist(strcat('data/',experimentName,'/dataset.mat'),'file')==2 && forceCalculation==false)
    %% Load from workspace
    %     %load meaninful data, estimated data, meaninful data no offset
    load(strcat('data/',experimentName,'/dataset.mat'),'dataset')
    
else
    ftDataName=strcat(input.ftPortName,'/data.log'); % (arm, foot and leg have FT data)
    stateDataName=strcat(input.statePortName,'/data.log');  % (only foot has no state data)
    %params.m is expected to have contactInfo (1 right ,0 left ), relevant (if
    %there is an specific interval desired to study (1 true, 0 false ) and
    %rData which is a double array 1x2 that has begining and ending of interval in seconds
    
    
    for i=1:size(input.ftNames,1)
        dataFTDirs{i}=strcat('data/',experimentName,'/icub/',input.ftNames{i},'/',ftDataName);
        
    end
    stateNames=fieldnames(input.stateNames);
    for i=1:size(stateNames,1)
        dataStateDirs{i}=strcat('data/',experimentName,'/icub/',stateNames{i},'/',stateDataName);
        
    end
    %TODO: replace "icub" for robot model? so that it can be used for other
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
    end
    
    %% load state and calculate estimated wrenches for comparison
    
    [dataset]=obtainEstimatedWrenches(dataStateDirs,input.stateNames,input.robotName,time,contactFrameName);
    
    dataset.time=time;
    dataset.ftData=ftData;
    
    sensorNames=fieldnames(dataset.estimatedFtData);
    
    %match field names with sensor loaded through readDataDumper
    %
    matchup=zeros(size(input.sensorNames,1),1);
    for i=1:size(input.sensorNames,1)
        matchup(i) = find(strcmp(sensorNames, input.sensorNames{i}));
    end
    
    %replace the estored estimatedFtData for one with the same order as the
    %ftData
    for i=1:size(input.ftNames,1)
        estimatedFtData.(input.ftNames{i})=dataset.estimatedFtData.(sensorNames{matchup(i)});
    end
    dataset.estimatedFtData=estimatedFtData;
    
    if (relevant==1)
        mask=dataset.time>dataset.time(1)+rData(1) & dataset.time<dataset.time(1)+rData(2);
        dataset=applyMask(dataset,mask);
    end
    
    
     %% Save the workspace
    %     %save meaninful data, estimated data, meaninful data no offset
    save(strcat('data/',experimentName,'/dataset.mat'),'dataset')
    
    
   
end
%% Data exploration/manipulation
%simple visual exploration suggests an offset problem, this parts aims
    %to calculate the offset and then compare the data with the offset
    %removed
    
    %compute offset on meaningful data
    for i=1:size(input.ftNames,1)
        [ftDataNoOffset.(input.ftNames{i}),offset.(input.ftNames{i})]=removeOffset(dataset.ftData.(input.ftNames{i}),dataset.estimatedFtData.(input.ftNames{i}));
    end
    dataset.ftDataNoOffset=ftDataNoOffset;
  
    % filtered ft data
[filteredFtData,mask]=filterFtData(dataset.ftData);

dataset2=applyMask(dataset,mask);
filterd=applyMask(filteredFtData,mask);
dataset2.filteredFtData=filterd;
    
 %getting raw data
[dataset2.rawData,cMat]=getRawData(dataset2.filteredFtData,input.calibMatPath,input.calibMatFileNames);

for i=1:size(input.ftNames,1)
    [filteredNoOffset.(input.ftNames{i}),filteredOffset.(input.ftNames{i})]=removeOffset(filterd.(input.ftNames{i}),dataset2.estimatedFtData.(input.ftNames{i}));
end
dataset2.filteredNoOffset=filteredNoOffset;
dataset2.filteredOffset=filteredOffset;

%% Save the workspace
    %     %save meaninful data, estimated data, meaninful data no offset
    save(strcat('data/',experimentName,'/dataset2.mat'),'dataset2')

%run('plottinScript.m')

run('CalibMatCorrection.m')

%% Save the workspace again to include calib Matrices, scale and offset
    %     %save meaninful data, estimated data, meaninful data no offset
    save(strcat('data/',experimentName,'/dataset2.mat'),'dataset2')