%add required folders for use of functions
addpath external/quadfit
addpath utils

% name and paths of the data files
experimentName='skinTest20170903';% 
%experimentName='ihmc2';% 

scriptOptions = {};
scriptOptions.forceCalculation=false;%false;
scriptOptions.printPlots=false;%true
scriptOptions.saveData=true;%true
scriptOptions.raw=true;% to calculate the raw data, for recalibration always true
% Script of the mat file used for save the intermediate results 
%scriptOptions.saveDataAll=true;
scriptOptions.matFileName='iCubDataset';

% read experiment data
[dataset,estimator,input]=readExperiment(experimentName,scriptOptions);

% inspect torque data
% figure,plot (dataset.skinTau.time-dataset.skinTau.time(1),dataset.skinTau.right_leg(:,4),'r'); hold on;
% plot (dataset.ftTau.time-dataset.ftTau.time(1),dataset.ftTau.right_leg(:,4),'b'); hold on;
% legend ('skin torque ','ft torque ');
% 
% figure,plot(dataset.time-dataset.time(1));

% filtered ft data for easy reading 
%         [filteredFtData,mask]=filterFtData(dataset.ftData);
%         
%         dataset=applyMask(dataset,mask);
%         filterd=applyMask(filteredFtData,mask);
%         dataset.filteredFtData=filterd;
%         dataset.estimatedFtData=dataset.filteredFtData;
%% estimate ft to calculate offset used when starting wbd
sample=5;
% estimateTorquesOneSample variables
framesNames={'l_sole','r_sole','l_lower_leg','root_link','l_elbow_1','r_elbow_1'}; %there has to be atleast 6
q=dataset.qj(sample,:);
dq=zeros(size(dataset.dqj(sample,:)));
ddq=dataset.ddqj(sample,:);
externalWrench=[0,0,0,0,0,0];
useSkin=false;
estimateFT=true;
sNames=fieldnames(dataset.ftData);
for n=1:length(sNames)
%ftData1.(sNames{n})=dataset.ftData.(sNames{n})(sample,:)-dataset.ftData.(sNames{n})(1,:);%
%to use with modelNoMasses
ftData1.(sNames{n})=dataset.ftData.(sNames{n})(sample,:);
offset.(sNames{n})=[0,0,0,0,0,0];
end

[~,~,estimated]=estimateTorquesOneSample(estimator,q,dq,ddq,externalWrench,useSkin,input,ftData1,framesNames,offset,estimateFT);

for n=1:length(sNames)
offset.(sNames{n})=estimated.(sNames{n})-ftData1.(sNames{n});
end
%% do the torque calculation with skin
skinSample= 35;
contactIndex=estimator.model.getFrameIndex(input.skinFrame);
link_h_skinFrame_temp=estimator.model.getFrameTransform(contactIndex);
link_h_skinFrame=link_h_skinFrame_temp.asAdjointTransformWrench.toMatlab();
sample=29800;
% estimateTorquesOneSample variables
framesNames={'l_sole','r_sole','l_lower_leg','root_link','l_elbow_1','r_elbow_1'}; %there has to be atleast 6
q=dataset.qj(sample,:);
dq=zeros(size(dataset.dqj(sample,:)));
ddq=dataset.ddqj(sample,:);
externalWrench=link_h_skinFrame*dataset.skinData.wrench(skinSample,:)';
%externalWrench=dataset.skinData.wrench(skinSample,:)'%*-1;

useSkin=true;
estimateFT=false;
for n=1:length(sNames)
%ftData.(sNames{n})=dataset.ftData.(sNames{n})(sample,:)-dataset.ftData.(sNames{n})(1,:);%
%to use with modelNoMasses
ftData.(sNames{n})=dataset.ftData.(sNames{n})(sample,:);
end

[extWrenchesSkin,skinTorques]=estimateTorquesOneSample(estimator,q,dq,ddq,externalWrench,useSkin,input,ftData,framesNames,offset,estimateFT);

%% estimate torques without the skin
useSkin=false;
[extWrenchesFt,ftTorques]=estimateTorquesOneSample(estimator,q,dq,ddq,externalWrench,useSkin,input,ftData,framesNames,offset,estimateFT);

%figure,plot (dataset.skinTau.right_leg(sample,4),'ro'); hold on;
figure,plot (dataset.skinTau.right_leg(sample-15000,4),'ro'); hold on;
plot (dataset.ftTau.right_leg(sample,4),'b*'); hold on;
plot (skinTorques(4),'go'); hold on;
plot (ftTorques(4),'m*'); hold on;
legend ('skin torque ','ft torque ',' skin calculated torque','ft calculated torque');


% figure, plot (dataset.qj(:,:))
% contactIndex=estimator.model.getFrameIndex('r_sole');
% link_h_skinFrame_temp=estimator.model.getFrameTransform(contactIndex);
% link_h_skinFrame=link_h_skinFrame_temp.asAdjointTransformWrench.toMatlab();