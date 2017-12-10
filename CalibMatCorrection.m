%% Calibration matrix correction script
% estimate new calibration matrices
% assuming is run at the end of main, or after main

%using insitu
% NOTE: only use when position of center of mass is constant
%TODO: procedure for choosing when to use insitu or not required
if(calibOptions.usingInsitu) 
 [calibMatrices,offset,fullscale]= estimateMatricesWthReg(dataset.rawDataFiltered,dataset.estimatedFtData,sensorsToAnalize, dataset.cMat,lambda);
 
   if (isstruct(extraSample.right)||isstruct(extraSample.left))
       tempCmat=dataset.cMat;
         [calibMatrices,fullscale]= estimateMatricesWthRegExtraSamples(dataset,sensorsToAnalize, dataset.cMat,lambda...
             ,extraSample,offset,calibMatrices);
         if (isstruct(extraSample.right))
         dataset=addDatasets(dataset,extraSample.right);
         end
          if (isstruct(extraSample.left))
         dataset=addDatasets(dataset,extraSample.left);
          end
         
          dataset.cMat=tempCmat;
    end
    
else
    %not using insitu    
   [calibMatrices,offsetC,fullscale]=...
            estimateMatricesAndOffset(...
            dataset.rawDataFiltered,... %raw data input
            dataset.estimatedFtData,...% estimated wrenches as reference
            dataset.cMat,...% previous calibration matrix for regularization
            lambda,...
            sensorsToAnalize);% weighting coefficient
        reCabData.offset=offsetC;
end
reCabData.calibMatrices=calibMatrices;

reCabData.fullscale=fullscale;

%% write calibration matrices file

if(calibOptions.saveMat)
    names=fieldnames(dataset.ftData);
     for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        i=find(strcmp(ft, names));
        if (round(dataset.cMat.(ft))==eye(6))
            scriptOptions.firstTime=true;
        else
            scriptOptions.firstTime=false;
        end
        if (scriptOptions.firstTime)
            prompt={'First time sensor:                 insert serial number or      desired sensor name'};
            name = 'Sensor name';
            defaultans = {'SN00001'};
            answer = inputdlg(prompt,name,[1 30],defaultans);
            if (~isempty(answer))
            filename=strcat('data/',experimentName,'/calibrationMatrices/',answer{1},lambdaName);
            else
                disp('Sensor name canceled, not saving calibration matrix');
                filename=strcat('data/',experimentName,'/calibrationMatrices/',defaultans{1},lambdaName);
                break;
            end
        else
            filename=strcat('data/',experimentName,'/calibrationMatrices/',dataset.calibMatFileNames{i},lambdaName);
        end
        if calibOptions.IITfirmwareFriendly
            %CalibrationMatrix*rawData = [T,F]. When calibration flag = true, the values
            %are swapped before sending them to yarp port [F,T]. This swap function
            %accounts for this behavior
            [firmwareMat,full_scale]=swapCMat(calibMatrices.(ft));
            % enable when problem with fullscale is sovled in firmware
            %[firmwareMat,full_scale]=swapCMat(calibMatrices.(ft),fullscale.(ft));
        else
            firmwareMat=calibMatrices.(ft);
            full_scale=fullscale.(ft);
        end
        writeCalibMat(firmwareMat, full_scale, filename)
    end
end
%% generate wrenches with new calibration matrix
if(calibOptions.usingInsitu)   
    
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
        if (calibOptions.usingInsitu)
             save(strcat('data/',experimentName,'/reCabDataInsitu.mat'),'reCabData')
        else
    save(strcat('data/',experimentName,'/reCabData.mat'),'reCabData')
        end
    end
%% Plotting section
if(calibOptions.plot)    
    
    %% plot 3D graph
    if (calibOptions.onlyWSpace)
        for ftIdx =1:length(sensorsToAnalize)
            ft = sensorsToAnalize{ftIdx};
            if(calibOptions.usingInsitu)
                filteredOffset.(ft)=(dataset.cMat.(ft)*offset.(ft)')';               
            else
                filteredOffset.(ft)=offsetC.(ft)';
            end
            if (round(dataset.cMat.(ft))==eye(6))
                scriptOptions.firstTime=true;
            else
                scriptOptions.firstTime=false;
            end
            filteredNoOffset.(ft)=dataset.filteredFtData.(ft) -repmat(filteredOffset.(ft),size(dataset.filteredFtData.(ft),1),1);
            
            figure,
            if(~scriptOptions.firstTime)
                plot3_matrix(filteredNoOffset.(ft)(:,1:3)); grid on;hold on;
            end
            plot3_matrix(dataset.estimatedFtData.(ft)(:,1:3)); grid on;hold on;
            plot3_matrix(reCalibData.(ft)(:,1:3));
            
            if(~scriptOptions.firstTime)
                legend('measuredDataNoOffset','estimatedData','reCalibratedData','Location','west');
            else
                legend('estimatedData','reCalibratedData','Location','west');
            end
            title(strcat({'Wrench space '},escapeUnderscores(ft),{' '},escapeUnderscores(lambdaName)));
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


