%% Calibration matrix correction script
% estimate new calibration matrices
% assuming is run at the end of calibrateFTsensor, or after calibrateFTsensor

%using insitu
% NOTE: only use when position of center of mass is constant
%TODO: procedure for choosing when to use insitu or not required
%% Calibration
narin=0;
varInput={};
if isstruct(extraSample)
    varInput{narin+1}='useExtraSample';
    varInput{narin+3}='extraSample';
    varInput{narin+2}=true;
    varInput{narin+4}=extraSample;
    narin=narin+4;
    extraSampleAvailable=true;
else
    extraSampleAvailable=false;
end
dataFields=fieldnames(dataset);
if calibOptions.useTemperature
    if ~ismember('temperature',dataFields)
        calibOptions.useTemperature=false;
        warning('calibrateAndCheck: expected temperature info but not available, calibration will be perform without temperature');
    else        
    varInput{narin+1}='withTemperature';
    varInput{narin+2}=true;
    narin=narin+2;
    end
end
[calibMatrices,fullscale,offset,temperatureCoeff]=useLinearModelToCalibrate(dataset,sensorsToAnalize,...
    'estimationType',calibOptions.estimateType,'cMat',dataset.cMat,'lambda',lambda,'useFilteredData',true,...
    varInput{:});
reCabData.calibMatrices=calibMatrices;
reCabData.fullscale=fullscale;
reCabData.offset=offset;
reCabData.temperatureCoeff=temperatureCoeff;
%% Write calibration matrices file
if(calibOptions.saveMat)
    names=fieldnames(dataset.ftData);
    if ~exist(strcat('data/',experimentName,'/calibrationMatrices'),'dir')
        mkdir(strcat('data/',experimentName,'/calibrationMatrices'));
    end
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        i=find(strcmp(ft, names));
        if (round(dataset.cMat.(ft))==eye(6))
            scriptOptions.firstTime=true;
        else
            scriptOptions.firstTime=false;
        end
        if (scriptOptions.firstTime)
            if (any(strcmp('calibOutputNames', fieldnames(input))))
                filename=strcat('data/',experimentName,'/calibrationMatrices/', input.calibOutputNames{i},lambdaName);
            else
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
            end
        else
            filename=strcat('data/',experimentName,'/calibrationMatrices/',dataset.calibMatFileNames{i},lambdaName);
        end
        firmwareMat=calibMatrices.(ft);
        full_scale=fullscale.(ft);
        writeCalibMat(firmwareMat, full_scale, filename)
    end
end
%% Generate wrenches with new calibration matrix
datasetToUse=dataset;
if extraSampleAvailable
    extraSampleNames=fieldnames(extraSample);
     for eSampleIDNum =1:length(extraSampleNames)
        eSampleID = extraSampleNames{eSampleIDNum};
        if (isstruct(extraSample.(eSampleID)))
            datasetToUse=addDatasets(datasetToUse,extraSample.(eSampleID));
        end
     end
end
for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    recabnarin=0;
    recabInput={};
    if calibOptions.useTemperature
        recabInput{recabnarin+1}='addLinVarVal';
        recabInput{recabnarin+3}='varCoeff';
        recabInput{recabnarin+2}=datasetToUse.temperature.(ft);
        recabInput{recabnarin+4}=temperatureCoeff.(ft);
        recabnarin=recabnarin+4;
    end

    [reCalibData.(ft),offsetInWrenchSpace.(ft)]=recalibrateData(datasetToUse.rawData.(ft),calibMatrices.(ft),...
        'offset',offset.(ft),recabInput{:});
end
reCabData.offsetInWrenchSpace=offsetInWrenchSpace;
reCabData.reCalibData=reCalibData;
reCabData.calibMatFileNames=dataset.calibMatFileNames;
%% Plotting section
% plot 3D graph
if (calibOptions.plotForceSpace)
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        if (round(dataset.cMat.(ft))==eye(6))
            namesdatasets={'estimatedData','reCalibratedData'};
            force3DPlots(namesdatasets,(ft),datasetToUse.estimatedFtData.(ft),reCalibData.(ft));
        else
            filteredOffset.(ft)=(dataset.cMat.(ft)*offset.(ft)')';
            filteredNoOffset.(ft)=datasetToUse.filteredFtData.(ft) -repmat(filteredOffset.(ft),size(datasetToUse.filteredFtData.(ft),1),1);
            namesdatasets={'measuredDataNoOffset','estimatedData','reCalibratedData'};
            force3DPlots(namesdatasets,(ft),filteredNoOffset.(ft),datasetToUse.estimatedFtData.(ft),reCalibData.(ft));
        end
        
    end
end
if(calibOptions.plotForceVsTime)
% FTPLOTs
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        FTplots(struct(ft,reCalibData.(ft),strcat('estimate',ft),datasetToUse.estimatedFtData.(ft)),datasetToUse.time,'forcecomparison');
        %FTplots(struct(strcat('measure',ft),filteredNoOffset.(ft),strcat('estimate',ft),modifiedDataset.estimatedFtData.(ft)),modifiedDataset.time,'forcecomparison');
        %FTplots(struct(ft,reCalibData.(ft),strcat('measure',ft),filteredNoOffset.(ft)),modifiedDataset.time,'forcecomparison');
    end
end
%% Evaluation and secondary matrix generation
for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    % plot secondary matrix format
    if (calibOptions.secMatrixFormat)
        secMat.(ft)= calibMatrices.(ft)/dataset.cMat.(ft);
        xmlStr=cMat2xml(secMat.(ft),ft)% print in required format to use by WholeBodyDynamics
    end
    % Evaluation of results
    if (calibOptions.resultEvaluation)
        disp(ft)
        %Workbench_no_offset_mse=mean((filteredNoOffset.(ft)-modifiedDataset.estimatedFtData.(ft)).^2)
        New_calibration_no_offset_mse=mean((reCalibData.(ft)-datasetToUse.estimatedFtData.(ft)).^2)
        %Workbench_mse=mean((modifiedDataset.ftData.(ft)-modifiedDataset.estimatedFtData.(ft)).^2)
    end
end
%% Save the workspace again to include calib Matrices, scale and offset
%     %save recalibrated matrices, offsets, new wrenches, sensor serial
%     numbers
if(scriptOptions.saveData)
        save(strcat('data/',experimentName,'/reCabData.mat'),'reCabData')   
end