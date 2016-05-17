%% Calibration matrix correction script
% estimate new calibration matrices
% assuming is run at the end of main, or after main
%script options
saveMat=true;
usingInsitu=true;
plot=true;
%using insitu
% NOTE: only use when position of center of mass is constant
%TODO: procedure for choosing when to use insitu or not required
if(usingInsitu)
          [calibMatrices,offset,fullscale]=estimateMatrices(dataset.rawData,dataset.estimatedFtData);
  
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        for j=1:size(dataset.rawData.(ft),1)
            reCalibData.(ft)(j,:)=calibMatrices.(ft)*(dataset.rawData.(ft)(j,:)'-offset.(ft)');
            offsetInsitu.(ft)=calibMatrices.(ft)*offset.(ft)';
        end
    end
    reCabData.offsetInsitu=offsetInsitu;
    
else
    %not using insitu
    
    lambda=.5;
    n=1; %n=3 usually start from 3rd, start from first
    
   [calibMatrices,offsetC,fullscale]=...
            estimateMatriceS(...
            dataset.rawData,... %raw data input
            dataset.estimatedFtData,...% estimated wrenches as reference
            dataset.cMat,...% previous calibration matrix for regularization
            lambda);% weighting coefficient
end
reCabData.calibMatrices=calibMatrices;
reCabData.offset=offsetC;
reCabData.fullscale=fullscale;



%% write calibration matrices file

if(saveMat)
     for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        
        filename=strcat('data/',experimentName,'/calibrationMatrices/',dataset.calibMatFileNames{i});
        writeCalibMat(calibMatrices.(ft), fullscale.(ft), filename)
    end
end
%% generate wrenches with new calibration matrix

 for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
    for j=1:size(dataset.rawData.(ft),1)
        reCalibData.(ft)(j,:)=calibMatrices.(ft)*(dataset.rawData.(ft)(j,:)')+offsetC.(ft);
    end
end
reCabData.reCalibData=reCalibData;
reCabData.calibMatFileNames=dataset.calibMatFileNames;
% Save the workspace again to include calib Matrices, scale and offset
    %     %save recalibrated matrices, offsets, new wrenches, sensor serial
    %     numbers
    if(scriptOptions.saveData)
    save(strcat('data/',experimentName,'/reCabData.mat'),'reCabData')
    end

if(plot)
    
    %% plot 3D graph
     for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
            [filteredNoOffset.(ft),filteredOffset.(ft)]=removeOffset(dataset.filteredFtData.(ft),dataset.estimatedFtData.(ft));

        
        figure,
         plot3_matrix(filteredNoOffset.(ft)(:,1:3)); grid on;hold on;
        plot3_matrix(dataset.estimatedFtData.(ft)(:,1:3)); grid on;hold on;
        plot3_matrix(reCalibData.(ft)(:,1:3));
        
        legend('measuredDataNoOffset','estimatedData','reCalibratedData','Location','west');
        title(strcat({'Wrench space '},(ft)));
        xlabel('F_{x}');
        ylabel('F_{y}');
        zlabel('F_{z}');
    end
    
    
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        FTplots(struct(ft,reCalibData.(ft),strcat('estimated',ft),dataset.estimatedFtData.(ft)),dataset.time);
    end
end
