%% Calibration matrix correction
%main2
% filtered ft data
% [filteredFtData,mask]=filterFtData(dataset.ftDataNoOffset);
[filteredFtData,mask]=filterFtData(dataset.ftData);

dataset2=applyMask(dataset,mask);
filterd=applyMask(filteredFtData,mask);
dataset2.filteredFtData=filterd;
 for i=1:size(input.ftNames,1)
        [ftDataNoOffset.(input.ftNames{i}),offsetX.(input.ftNames{i})]=removeOffset(dataset.ftData.(input.ftNames{i}),dataset.estimatedFtData.(input.ftNames{i}));
    end

for i=4:4
    %     for i=1:size(input.ftNames,1)
    FTplots(struct(input.ftNames{i},filterd.(input.ftNames{i}),strcat('estimated',input.ftNames{i}),dataset2.estimatedFtData.(input.ftNames{i})),dataset2.time);
end

%getting raw datat
[dataset2.rawData,cMat]=getRawData(dataset2.filteredFtData,input.calibMatPath,input.calibMatFileNames);

lambda=.5;
n=1; %n=3 usually start from 3rd, start from first
%add offset removal here? estimateOffsetusingInsitu(rawData(:,1:3), estimatedFtData(:.1:3))
for i=n:6
   
% [calibMatrices.(input.ftNames{i}),fullscale.(input.ftNames{i})]=estimateCalibMatrixWithReg(dataset2.rawData.(input.ftNames{i}),dataset2.estimatedFtData.(input.ftNames{i}),cMat.(input.ftNames{i}),lambda);
[calibMatrices.(input.ftNames{i}),fullscale.(input.ftNames{i}),ofst.(input.ftNames{i})]=estimateCalibMatrixWithRegAndOff(dataset2.rawData.(input.ftNames{i}),dataset2.estimatedFtData.(input.ftNames{i}),cMat.(input.ftNames{i}),lambda,offsetX.(input.ftNames{i})');

end

eC=cMat.left_leg-calibMatrices.left_leg;

for i=3:6
    for j=1:size(dataset2.rawData.(input.ftNames{i}),1)
        reCalibData.(input.ftNames{i})(j,:)=calibMatrices.(input.ftNames{i})*(dataset2.rawData.(input.ftNames{i})(j,:)');%-ofst.(input.ftNames{i}));
    end
end


for i=4:4
    %     for i=1:size(input.ftNames,1)
    FTplots(struct(input.ftNames{i},reCalibData.(input.ftNames{i}),strcat('estimated',input.ftNames{i}),dataset2.estimatedFtData.(input.ftNames{i})),dataset2.time);
end


 for i=3:size(input.ftNames,1)
                         recabNoOffset.(input.ftNames{i})=reCalibData.(input.ftNames{i})+repmat(ofst.(input.ftNames{i})',size(reCalibData.(input.ftNames{i}),1),1);

  
%      [recabNoOffset.(input.ftNames{i}),offsety]=removeOffset(reCalibData.(input.ftNames{i}),dataset2.estimatedFtData.(input.ftNames{i}));
 end

 
 for i=4:4
    filtrdNO.(input.ftNames{i})=filterd.(input.ftNames{i});%+repmat(offset.(input.ftNames{i}),size(filterd.(input.ftNames{i}),1),1);
    %     for i=1:size(input.ftNames,1)
%       figure,plot3_matrix(reCalibData.(input.ftNames{i})(:,1:3));hold on;
%     figure,plot3_matrix(dataset.estimatedFtData.(input.ftNames{i})(:,1:3)); grid on;
    figure,plot3_matrix(reCalibData.(input.ftNames{i})(:,1:3));hold on;
    plot3_matrix(dataset.estimatedFtData.(input.ftNames{i})(:,1:3)); grid on;
     hold on; plot3_matrix(filtrdNO.(input.ftNames{i})(:,1:3)); grid on;
     hold on; plot3_matrix(recabNoOffset.(input.ftNames{i})(:,1:3)); grid on;
end
 
dataset2.calibMatrices=calibMatrices;
dataset2.offset=ofst;
dataset2.fullscale=fullscale;
 %% Save the workspace
    %     %save meaninful data, estimated data, meaninful data no offset
    save(strcat('data/',experimentName,'/dataset2.mat'),'dataset2')
  
 %%write calibration matrices file
for i=3:6
    
      filename=strcat('data/',experimentName,'/calibrationMatrices/',input.calibMatFileNames{i});
    writeCalibMat(calibMatrices.(input.ftNames{i}), fullscale.(input.ftNames{i}), filename)
end