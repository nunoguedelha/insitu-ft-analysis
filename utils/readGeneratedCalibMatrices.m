function [cMat,secMat,WorkbenchMat]=readGeneratedCalibMatrices(experimentNames,scriptOptions,sensorsToAnalize,names2use,lambdasNames)

for i=1:length(experimentNames)
    if(scriptOptions.testDir==false)
        prefixDir='';
    else
        prefixDir='../';
    end
    
    paramScript=strcat(prefixDir,'data/',experimentNames{i},'/params.m');
    run(paramScript)
    ftNames=input.ftNames;
    
    
    for ii=1:size(input.calibMatFileNames,1)
        WorkbenchMat.(ftNames{ii})=getWorkbenchCalibMat(strcat(prefixDir,input.calibMatPath),input.calibMatFileNames{ii});
         secMat.(names2use{1}).(ftNames{ii})=eye(6);
    end
    
    cMat.(names2use{1})=WorkbenchMat; %first dataset to compare is the orignal workbench
    
    for lam=1:length(lambdasNames)
        (names2use{(i-1)*length(lambdasNames)+1+lam})
        for j=1:length(sensorsToAnalize)
            sIndx= find(strcmp(ftNames,sensorsToAnalize{j}));
            cMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j}) = readCalibMat(strcat(prefixDir,'data/',experimentNames{i},'/calibrationMatrices/',input.calibMatFileNames{sIndx},lambdasNames{lam}));
            if (scriptOptions.IITfirmwareFriendly) % assumes workbench is from the old way of doing. Need to verify if what we get from getWorkbenchCalibMat is the matrix in the sensor
                cMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j})=swapCMat(cMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j}));                
             secMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j})= cMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j})/swapCMat(WorkbenchMat.(sensorsToAnalize{j}));
           % not entirely sure I need to swap also the workbench matrix in
           % all cases we have th IITfirmwareFriendly it depends on how
           % that matrix was calculated anyway it will be deprecated since
           % the bug has been fixed
            else
            secMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j})= cMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j})/WorkbenchMat.(sensorsToAnalize{j});
           end
        end
    end
    
end