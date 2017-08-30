%% Calibration matrix correction script
% estimate new calibration matrices
% assuming is run at the end of main, or after main
%script options

saveMat=true;
usingInsitu=true;
plot=true;
onlyWSpace=true;
%using insitu
% NOTE: only use when position of center of mass is constant
%TODO: procedure for choosing when to use insitu or not required
if(usingInsitu)
         % [calibMatrices,offset,fullscale]=estimateMatrices(dataset.rawData,dataset.estimatedFtData,sensorsToAnalize);
 [calibMatrices,offset,fullscale]= estimateMatricesWthReg(dataset.rawData,dataset.estimatedFtData,sensorsToAnalize, dataset.cMat,lambda);
    
else
    %not using insitu
    
%    lambda=.5;
   
    
   [calibMatrices,offsetC,fullscale]=...
            estimateMatricesAndOffset(...
            dataset.rawData,... %raw data input
            dataset.estimatedFtData,...% estimated wrenches as reference
            dataset.cMat,...% previous calibration matrix for regularization
            lambda,...
            sensorsToAnalize);% weighting coefficient
        reCabData.offset=offsetC;
end
reCabData.calibMatrices=calibMatrices;

reCabData.fullscale=fullscale;



%% write calibration matrices file

if(saveMat)
    names=fieldnames(dataset.ftData);
     for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        i=find(strcmp(ft, names));
        filename=strcat('data/',experimentName,'/calibrationMatrices/',dataset.calibMatFileNames{i},lambdaName);
        writeCalibMat(calibMatrices.(ft), fullscale.(ft), filename)
    end
end
%% generate wrenches with new calibration matrix
if(usingInsitu)
    
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        for j=1:size(dataset.rawData.(ft),1)
            reCalibData.(ft)(j,:)=calibMatrices.(ft)*(dataset.rawData.(ft)(j,:)'-offset.(ft)');
            offsetInsitu.(ft)=calibMatrices.(ft)*offset.(ft)';
        end
    end
    reCabData.offsetInsitu=offsetInsitu;
else
 for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
    for j=1:size(dataset.rawData.(ft),1)
        reCalibData.(ft)(j,:)=calibMatrices.(ft)*(dataset.rawData.(ft)(j,:)')+offsetC.(ft);
    end
 end
end
reCabData.reCalibData=reCalibData;
reCabData.calibMatFileNames=dataset.calibMatFileNames;
% Save the workspace again to include calib Matrices, scale and offset
    %     %save recalibrated matrices, offsets, new wrenches, sensor serial
    %     numbers
    if(scriptOptions.saveData)
        if (usingInsitu)
             save(strcat('data/',experimentName,'/reCabDataInsitu.mat'),'reCabData')
        else
    save(strcat('data/',experimentName,'/reCabData.mat'),'reCabData')
        end
    end

if(plot)
    
    %% plot 3D graph
    if (onlyWSpace)
        for ftIdx =1:length(sensorsToAnalize)
            ft = sensorsToAnalize{ftIdx};
            if(usingInsitu)
                filteredOffset.(ft)=reCabData.offsetInsitu;
                 for j=1:size(dataset.rawData.(ft),1)
                    filteredNoOffset.(ft)(j,:)= (dataset.cMat.(ft)*(dataset.rawData.(ft)(j,:)'-offset.(ft)'))';
                 end
            else
                filteredOffset.(ft)=offsetC.(ft);
                filteredNoOffset.(ft)=dataset.filteredFtData.(ft) -repmat(filteredOffset.(ft)',size(dataset.filteredFtData.(ft),1),1);
            end
            %[filteredNoOffset.(ft),filteredOffset.(ft)]=removeOffset(dataset.filteredFtData.(ft),dataset.estimatedFtData.(ft));
            
            
            figure,
            plot3_matrix(filteredNoOffset.(ft)(:,1:3)); grid on;hold on;
            plot3_matrix(dataset.estimatedFtData.(ft)(:,1:3)); grid on;hold on;
            plot3_matrix(reCalibData.(ft)(:,1:3));
            
            legend('measuredDataNoOffset','estimatedData','reCalibratedData','Location','west');
            title(strcat({'Wrench space '},escapeUnderscores(ft)));
            xlabel('F_{x}');
            ylabel('F_{y}');
            zlabel('F_{z}');
        end
    else
        %% FTPLOTs
        for ftIdx =1:length(sensorsToAnalize)
            ft = sensorsToAnalize{ftIdx};
            FTplots(struct(ft,reCalibData.(ft),strcat('estimated',ft),dataset.estimatedFtData.(ft)),dataset.time);
        end
    end
end


