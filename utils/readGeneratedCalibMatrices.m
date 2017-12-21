function [cMat,secMat,WorkbenchMat]=readGeneratedCalibMatrices(experimentNames,scriptOptions,sensorsToAnalize,names2use,lambdasNames)

for i=1:length(experimentNames)
    paramScript=strcat('../data/',experimentNames{i},'/params.m');
    run(paramScript)
    ftNames=input.ftNames;
    if(scriptOptions.testDir==false)
        prefixDir='';
    else
        prefixDir='../';
    end
    
    for ii=1:size(input.calibMatFileNames,1)
        WorkbenchMat.(ftNames{ii})=getWorkbenchCalibMat(strcat(prefixDir,input.calibMatPath),input.calibMatFileNames{ii});
         secMat.(names2use{1}).(ftNames{ii})=eye(6);
    end
    
    cMat.(names2use{1})=WorkbenchMat; %first dataset to compare is the orignal workbench
    
    for lam=1:length(lambdasNames)
        (names2use{(i-1)*length(lambdasNames)+1+lam})
        for j=1:length(sensorsToAnalize)
            sIndx= find(strcmp(ftNames,sensorsToAnalize{j}));
            cMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j}) = readCalibMat(strcat('../data/',experimentNames{i},'/calibrationMatrices/',input.calibMatFileNames{sIndx},lambdasNames{lam}));
             if (scriptOptions.IITfirmwareFriendly) % assumes workbench is from the old way of doing. Need to verify if what we get from getWorkbenchCalibMat is the matrix in the sensor
                cMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j})=swapCMat(cMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j}));                
            end
            secMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j})= cMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j})/WorkbenchMat.(sensorsToAnalize{j});
        end
    end
    
end