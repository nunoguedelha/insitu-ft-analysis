%% Comparing FT data vs estimated data
% %create input parameter is done through params.m for each experiment

%add required folders for use of functions
addpath ../external/quadfit
addpath ../utils
addpath ../data
% name and paths of the data files
%     experimentName='icub-insitu-ft-analysis-big-datasets/16_03_2016/leftRightLegsGrid';% Name of the experiment;
%      experimentName='icub-insitu-ft-analysis-big-datasets/21_03_2016/yogaLeft1';% Name of the experiment;
%   experimentName='icub-insitu-ft-analysis-big-datasets/2016_04_21/extendedYoga4StandingOnLeft';% Name of the experiment;
%experimentName='icub-insitu-ft-analysis-big-datasets/2016_05_19/blackBothLegs';% Name of the experiment;
%experimentName='icub-insitu-ft-analysis-big-datasets/2016_04_19/blackUsingOldSensor';% Name of the experiment;
%    experimentName='icub-insitu-ft-analysis-big-datasets/2016_06_08/extendedYoga';% Name of the experiment;
%      experimentName='icub-insitu-ft-analysis-big-datasets/2016_06_08/yoga';% Name of the experiment;
%  experimentName='icub-insitu-ft-analysis-big-datasets/2016_06_17/normal';% Name of the experiment;
% experimentName='icub-insitu-ft-analysis-big-datasets/2016_06_17/fast';% Name of the experiment;
% experimentName='icub-insitu-ft-analysis-big-datasets/2016_07_04/normal';% Name of the experiment;
%  experimentName='icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin30';% Name of the experiment;
%  experimentName='icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin45';% Name of the experiment;
experimentName='/green-iCub-Insitu-Datasets/2017_12_5_TestGrid';% first sample with cable corrected ;



scriptOptions = {};
scriptOptions.forceCalculation=false;%false;
scriptOptions.printPlots=false;%true
scriptOptions.saveData=false;%true
scriptOptions.raw=true;% to calculate the raw data, for recalibration always true
% Script of the mat file used for save the intermediate results
%scriptOptions.saveDataAll=true;
scriptOptions.matFileName='ftDataset';
cd ..
[dataset]=read_estimate_experimentData2(experimentName,scriptOptions);
cd testResults/
% We carry the analysis just for a subset of the sensors
%sensorsToAnalize = {'left_leg','right_leg'};
%sensorsToAnalize = {'right_foot','right_leg'};
sensorsToAnalize = {'right_leg'};

% if( scriptOptions.printPlots )
% run('plottinScript.m')
% end

lambda=0;
lambdaName='';

num=length(dataset.time);



for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    
    interval=length(dataset.time)/10;
    rawNorm=normalizeMatrix(dataset.rawData.(ft));
    estNorm=normalizeMatrix(dataset.estimatedFtData.(ft));
    %rawSet=dataset.rawData.(ft)(1:interval-1:end,:);
    %refSet=dataset.estimatedFtData.(ft)(1:interval-1:end,:);
    Obs=zeros(1000,1);
    sample=1:interval-1:length(dataset.time);
    sample=int64(sample);
    %firstSample=randperm(length(dataset.time),10);
    rawSet=rawNorm(sample,:);
    refSet=estNorm(sample,:);
    obTemp=99999999;
    counter=0;
    
    newIndex= randperm(length(dataset.time));
    for n=1:num
        %     not_done = true;
        %   while not_done
        %     newIndex= randperm(length(dataset.time),1);
        %     if (
        %     not_done = condition;
        %   end
        
        
        
        temprawSet=rawNorm([sample,newIndex(n)],:);
        temprefSet=estNorm([sample,newIndex(n)],:);
        % [calibMatrices,offset,fullscale]=estimateMatrices(dataset.rawData,dataset.estimatedFtData,sensorsToAnalize);
        [s,offset,A]= checkSVD(temprawSet,temprefSet, dataset.cMat.(ft),lambda);
        eigMax(n)=max(diag(s));
        eigMin(n)=min(diag(s));
        Obs(n)=eigMax(n)/eigMin(n);
        if ( Obs(n)<=obTemp)
            counter=counter+1;
            sample= [sample,newIndex(n)];
            obsRec(counter)=Obs(n);
            obTemp=Obs(n);
        end
    end
    figure,
    %for i=1:6
    plot(Obs); hold on;
    %plot(eigMax(1:num,i)); hold on;
    % plot(eigMin(1:num,i)); hold on;
    %end
    figure,
    plot(obsRec);
    
    figure,
    %for i=1:6
    % plot(Obs(1:500,i)); hold on;
    plot(eigMax(1:num)); hold on;
    plot(eigMin(1:num)); hold on;
    %end
    
    
    [st,offsett,At]= checkSVD(rawNorm,estNorm, dataset.cMat.(ft),lambda);
    eigMaxt=max(diag(st));
    eigMint=min(diag(st));
    Obst=eigMaxt/eigMint;
    
end