%% Calibration matrix correction script
% estimate new calibration matrices
% assuming is run at the end of main, or after main
%script options
saveMat=true;
usingInsitu=false;
plot=true;
%using insitu
% NOTE: only use when position of center of mass is constant
%TODO: procedure for choosing when to use insitu or not required
if(usingInsitu)
          [calibMatrices,offset,fullscale]=estimateMatrices(dataset.rawData,dataset.estimatedFtData);
    %
    %     % with regularization
    %     [calibMatrices,offset,fullscale]=estimateMatricesReg(dataset.rawData,dataset.estimatedFtData,cMat);
    %
    for i=3:6
        for j=1:size(dataset.rawData.(ftNames{i}),1)
            reCalibData.(ftNames{i})(j,:)=calibMatrices.(ftNames{i})*(dataset.rawData.(ftNames{i})(j,:)'-offset.(ftNames{i})');
            offsetInsitu.(ftNames{i})=calibMatrices.(ftNames{i})*offset.(ftNames{i})';
        end
    end
    reCabData.offsetInsitu=offsetInsitu;
    
else
    %not using insitu
    
    lambda=.5;
    n=1; %n=3 usually start from 3rd, start from first
    
    for i=n:6
        [calibMatrices.(ftNames{i}),fullscale.(ftNames{i}),offsetC.(ftNames{i})]=...
            estimateCalibMatrixWithRegAndOff(...
            dataset.rawData.(ftNames{i}),... %raw data input
            dataset.estimatedFtData.(ftNames{i}),...% estimated wrenches as reference
            dataset.cMat.(ftNames{i}),...% previous calibration matrix for regularization
            lambda,...% weighting coefficient
            [0;0;0;0;0;0]);% reference offset
        % offsetX.(ftNames{i})');% reference offset
        
    end
    
end
reCabData.calibMatrices=calibMatrices;
reCabData.offset=offsetC;
reCabData.fullscale=fullscale;



%% write calibration matrices file

if(saveMat)
    for i=3:6
        
        filename=strcat('data/',experimentName,'/calibrationMatrices/',dataset.calibMatFileNames{i});
        writeCalibMat(calibMatrices.(ftNames{i}), fullscale.(ftNames{i}), filename)
    end
end
%% generate wrenches with new calibration matrix

for i=3:6
    for j=1:size(dataset.rawData.(ftNames{i}),1)
        reCalibData.(ftNames{i})(j,:)=calibMatrices.(ftNames{i})*(dataset.rawData.(ftNames{i})(j,:)')+offsetC.(ftNames{i});
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
    for i=3:4
        figure,
         plot3_matrix(filteredNoOffset.(ftNames{i})(:,1:3)); grid on;hold on;
        plot3_matrix(dataset.estimatedFtData.(ftNames{i})(:,1:3)); grid on;hold on;
        plot3_matrix(reCalibData.(ftNames{i})(:,1:3));
        
        legend('measuredDataNoOffset','estimatedData','reCalibratedData','Location','west');
        title(strcat({'Wrench space '},(ftNames{i})));
        xlabel('F_{x}');
        ylabel('F_{y}');
        zlabel('F_{z}');
    end
    
    
    for i=4:4
        FTplots(struct(ftNames{i},reCalibData.(ftNames{i}),strcat('estimated',ftNames{i}),dataset.estimatedFtData.(ftNames{i})),dataset.time);
    end
end
