%% Test calibration matrices obtained from different datasets
%use from test directory
%load calibration matrices to compare with workbench calibration matrix
% clear all;
addpath ../utils
addpath ../external/quadfit
serialNumber='SN026';

%Use only datasets where the same sensor is used
experimentNames={
    'icub-insitu-ft-analysis-big-datasets/16_03_2016/leftRightLegsGrid';...% Name of the experiment;
    'icub-insitu-ft-analysis-big-datasets/21_03_2016/yogaLeft1';...% Name of the experiment;
    'icub-insitu-ft-analysis-big-datasets/2016_04_21/extendedYoga4StandingOnLeft';...% Name of the experiment;
    };
names2use={'Workbench','Grid','Yoga','ExtendedYoga'};% except for the first one all others are short names for the expermients in experimentNames
toCompareWith='ExtendedYoga'; %choose in which experiment will comparison be made

scriptOptions.matFileName='ftDataset';

%% Load matrices and rawData
cMat.(names2use{1}) = readCalibMat(strcat('../data/sensorCalibMatrices/matrix_',serialNumber,'.txt'));

for i=1:length(experimentNames)
    cMat.(names2use{i+1}) = readCalibMat(strcat('../data/',experimentNames{i},'/calibrationMatrices/',serialNumber));
    load(strcat('../data/',experimentNames{i},'/',scriptOptions.matFileName,'.mat'),'dataset');
   [data.(names2use{i+1})]=dataset;
    
end

index=0;

for in=1:length(data.(names2use{2}).calibMatFileNames)
    if( find(strcmp(serialNumber, data.(names2use{2}).calibMatFileNames{in})))
        index=in;
    end
end

if (index~=0)
    ftNames= fieldnames( data.(names2use{2}).ftData);
    sensorsToAnalize=ftNames{index};
    
    for i=1:length(names2use)
        
        for j=1:size(data.(toCompareWith).rawData.( sensorsToAnalize),1)
            reCalibData.(names2use{i})(j,:)=cMat.(names2use{i})*(data.(toCompareWith).rawData.( sensorsToAnalize)(j,:)');
        end
        
        ftDataNoOffset.(names2use{i})=removeOffset(reCalibData.(names2use{i}),data.(toCompareWith).estimatedFtData.(sensorsToAnalize));
        
    end
    
    %remove offset
    for i=2:length(names2use)
        figure,plot3_matrix( ftDataNoOffset.(names2use{i})(:,1:3));hold on;
        plot3_matrix(data.(toCompareWith).estimatedFtData.(sensorsToAnalize)(:,1:3)); grid on;
        legend(names2use{i},'estimatedData','Location','west');
        title('Wrench space');
        xlabel('F_{x}');
        ylabel('F_{y}');
        zlabel('F_{z}');
    end
    figure,
    plot3_matrix(data.(toCompareWith).estimatedFtData.(sensorsToAnalize)(:,1:3)); grid on;  hold on;
    for i=1:length(names2use)
        plot3_matrix( ftDataNoOffset.(names2use{i})(:,1:3));hold on;
    end
    legend([{'estimatedData'},names2use],'Location','west');
    
    title('Wrench space');
    xlabel('F_{x}');
    ylabel('F_{y}');
    zlabel('F_{z}');
    
    %error calculation
    %
    %     dif1=data.(names2use{i}).estimatedFtData.(ftNames{4})(:,1:3)-ftDataNoOffset1(:,1:3);
    %     dif2=data.(names2use{i}).estimatedFtData.(ftNames{4})(:,1:3)-ftDataNoOffset2(:,1:3);
    %     dif3=data.(names2use{i}).estimatedFtData.(ftNames{4})(:,1:3)-ftDataNoOffset3(:,1:3);
    %     dif4=data.(names2use{i}).estimatedFtData.(ftNames{4})(:,1:3)-ftDataNoOffset4(:,1:3);
    %
    %     figure, plot(dif1);
    %     figure, plot(dif2);
    %     figure, plot(dif3);
    %     figure, plot(dif4);
    %
    %     sum(sum(abs(dif1)))
    %     sum(sum(abs(dif2)))
    %     sum(sum(abs(dif3)))
    %     sum(sum(abs(dif4)))
    %
    %     sum(abs(dif1))
    %     sum(abs(dif2))
    %     sum(abs(dif3))
    %     sum(abs(dif4))
    
end
