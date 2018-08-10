%TODO: possible to move dave to the end and everything else inside the same ft loop to make it into
%a function that receives the data directly and doesnt need to deal with
%the sensors themselves

% for each sensor to analize
for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    %% Generate wrenches with new calibration matrix
    recabnarin=0;
    recabInput={};
    if ~isempty(temperatureCoeff)
        recabInput{recabnarin+1}='addLinVarVal';
        recabInput{recabnarin+3}='varCoeff';
        recabInput{recabnarin+2}=datasetToUse.temperature.(ft);
        recabInput{recabnarin+4}=temperatureCoeff.(ft);
        recabnarin=recabnarin+4;
    end
    [reCalibData.(ft),offsetInWrenchSpace.(ft)]=recalibrateData(datasetToUse.rawData.(ft),calibMatrices.(ft),...
        'offset',offset.(ft),recabInput{:});
    
    %% Plotting section
    % plot 3D graph
    if (checkMatrixOptions.plotForceSpace)
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
    % plot forces with time as x axis
    if(checkMatrixOptions.plotForceVsTime)
        FTplots(struct(ft,reCalibData.(ft),strcat('estimate',ft),datasetToUse.estimatedFtData.(ft)),datasetToUse.time,'forcecomparison');
        %FTplots(struct(strcat('measure',ft),filteredNoOffset.(ft),strcat('estimate',ft),modifiedDataset.estimatedFtData.(ft)),modifiedDataset.time,'forcecomparison');
        %FTplots(struct(ft,reCalibData.(ft),strcat('measure',ft),filteredNoOffset.(ft)),modifiedDataset.time,'forcecomparison');
    end
    
    %%  secondary matrix format
    if (checkMatrixOptions.secMatrixFormat)
        secMat.(ft)= calibMatrices.(ft)/dataset.cMat.(ft);
        xmlStr=cMat2xml(secMat.(ft),ft)% print in required format to use by WholeBodyDynamics
    end
    
    %% Evaluation of results
    if (checkMatrixOptions.resultEvaluation)
        disp(ft)
        %Workbench_no_offset_mse=mean((filteredNoOffset.(ft)-modifiedDataset.estimatedFtData.(ft)).^2)
        New_calibration_no_offset_mse=mean((reCalibData.(ft)-datasetToUse.estimatedFtData.(ft)).^2)
        %Workbench_mse=mean((modifiedDataset.ftData.(ft)-modifiedDataset.estimatedFtData.(ft)).^2)
    end
end

%% Save the workspace again to include calib Matrices, scale and offset
%     %save recalibrated matrices, offsets, new wrenches, sensor serial
%     numbers
if(checkMatrixOptions.saveRecalibratedData)
    reCabData.calibMatrices=calibMatrices;
    reCabData.fullscale=fullscale;
    reCabData.offset=offset;
    reCabData.temperatureCoeff=temperatureCoeff;
    reCabData.offsetInWrenchSpace=offsetInWrenchSpace;
    reCabData.reCalibData=reCalibData;
    reCabData.calibMatFileNames=dataset.calibMatFileNames;
    save(strcat('data/',experimentName,'/reCabData.mat'),'reCabData')
end