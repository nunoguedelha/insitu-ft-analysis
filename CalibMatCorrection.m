%% Calibration matrix correction script
% estimate new calibration matrices
% assuming is run at the end of main, or after main
%script options
saveMat=false;
usingInsitu=false;
plot=true;
%using insitu
% NOTE: only use when position of center of mass is constant
%TODO: procedure for choosing when to use insitu or not required
if(usingInsitu)
    %      [calibMatrices,offset,fullscale]=estimateMatrices(dataset2.rawData,dataset2.estimatedFtData);
    %
    %     % with regularization
    %     [calibMatrices,offset,fullscale]=estimateMatricesReg(dataset2.rawData,dataset2.estimatedFtData,cMat);
    %
else
    %not using insitu
    
    lambda=1;
    n=1; %n=3 usually start from 3rd, start from first
    
    for i=n:6
        [calibMatrices.(input.ftNames{i}),fullscale.(input.ftNames{i}),offsetC.(input.ftNames{i})]=...
            estimateCalibMatrixWithRegAndOff(...
            dataset2.rawData.(input.ftNames{i}),... %raw data input
            dataset2.estimatedFtData.(input.ftNames{i}),...% estimated wrenches as reference
            cMat.(input.ftNames{i}),...% previous calibration matrix for regularization
            lambda,...% weighting coefficient
            [0;0;0;0;0;0]);% reference offset
        % offsetX.(input.ftNames{i})');% reference offset
        
    end
    
end
dataset2.calibMatrices=calibMatrices;
dataset2.offset=offsetC;
dataset2.fullscale=fullscale;



%% write calibration matrices file

if(saveMat)
    for i=3:6
        
        filename=strcat('data/',experimentName,'/calibrationMatrices/',input.calibMatFileNames{i});
        writeCalibMat(calibMatrices.(input.ftNames{i}), fullscale.(input.ftNames{i}), filename)
    end
end
%% generate wrenches with new calibration matrix

for i=3:6
    for j=1:size(dataset2.rawData.(input.ftNames{i}),1)
        reCalibData.(input.ftNames{i})(j,:)=calibMatrices.(input.ftNames{i})*(dataset2.rawData.(input.ftNames{i})(j,:)')+offsetC.(input.ftNames{i});
    end
end

if(plot)
    %% plot 3D graph
    for i=3:4
        figure,plot3_matrix(reCalibData.(input.ftNames{i})(:,1:3));hold on;
        plot3_matrix(dataset.estimatedFtData.(input.ftNames{i})(:,1:3)); grid on;
        hold on; plot3_matrix(filteredNoOffset.(input.ftNames{i})(:,1:3)); grid on;
        legend('reCalibratedData','estimatedData','measuredDataNoOffset','Location','west');
        title(strcat({'Wrench space '},(input.ftNames{i})));
        xlabel('F_{x}');
        ylabel('F_{y}');
        zlabel('F_{z}');
    end
    
    
    for i=4:4
        FTplots(struct(input.ftNames{i},reCalibData.(input.ftNames{i}),strcat('estimated',input.ftNames{i}),dataset2.estimatedFtData.(input.ftNames{i})),dataset2.time);
    end
end
