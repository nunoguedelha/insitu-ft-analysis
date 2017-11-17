%add required folders for use of functions
addpath external/quadfit
addpath utils

% name and paths of the data files
%experimentName='skinTest20170903';% 
%experimentName='skinTest20170911_3';
%experimentName='skintest2017_09_14_1';
%experimentName='dumper'
%experimentName='heavyWeight'
%experimentName='skinMutipleWeights'
experimentName='angles'


scriptOptions = {};
scriptOptions.forceCalculation=false;%false;
scriptOptions.printPlots=false;%true
scriptOptions.saveData=true;%true
scriptOptions.raw=true;% to calculate the raw data, for recalibration always true
% Script of the mat file used for save the intermediate results 
%scriptOptions.saveDataAll=true;
scriptOptions.matFileName='iCubDataset';
inspectdata=false;
% read experiment data
[dataset,estimator,input]=readExperiment(experimentName,scriptOptions);


% 
% figure,plot(dataset.time-dataset.time(1));

% filtered ft data for easy reading 
        [filteredFtData,mask]=filterFtData(dataset.ftData);
        
        dataset=applyMask(dataset,mask);
        filterd=applyMask(filteredFtData,mask);
        dataset.filteredFtData=filterd;
        dataset.estimatedFtData=dataset.filteredFtData;        
       
        
cMat.Workbench = readCalibMat('data/sensorCalibMatrices/matrix_SN269.txt');
lambda='_l500000';
cMat.right_leg = readCalibMat(strcat('data/secCalibMat/',strcat(input.calibMatFileNames{4},lambda)));
sCalibMat=cMat.right_leg/(cMat.Workbench);%calculate secondary calibration matrix 

for s=1:length(dataset.time)
     dataset.ftDataOld.right_leg(s,:)=dataset.ftData.right_leg(s,:);
    ftTemp=sCalibMat*dataset.ftData.right_leg(s,:)';
    dataset.ftData.right_leg(s,:)=ftTemp;
end
%% inspect data
if inspectdata
% inspect torque data
figure,plot (dataset.skinTau.time-dataset.skinTau.time(1),dataset.skinTau.right_leg(:,4),'r'); hold on;
plot (dataset.ftTau.time-dataset.ftTau.time(1),dataset.ftTau.right_leg(:,4),'b'); hold on;
legend ('skin torque ','ft torque ');

% inspect force data
figure,plot (dataset.skinData.time-dataset.time(1),dataset.skinData.force); hold on;
plot (dataset.time-dataset.time(1),dataset.ftData.right_leg(:,1:3)-dataset.ftData.right_leg(1,1:3)); hold on;
legend ('skin force ','ft force ');
end
timeDiff=88.68-71.7;
%% estimate ft to calculate offset used when starting wbd
sample=100;
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
%% check correction
% for s=1:length(dataset.time)
%     newFT(s,:)=dataset.ftData.right_leg(s,1:3)+offset.right_leg(1:3);
% end
% plot (dataset.time-dataset.time(1),dataset.ftData.right_leg(:,1:3)-dataset.ftData.right_leg(1,1:3))+offset.right_leg; hold on;
%% do the torque calculation with skin
sampleIni=16;
sT=0;
fT=0;
time=0;
for sample=sampleIni:50:length(dataset.time)-1000
skinSample=findSkinSample(dataset.time,sample,dataset.skinData.time,timeDiff);
contactIndex=estimator.model.getFrameIndex(input.skinFrame);
link_h_skinFrame_temp=estimator.model.getFrameTransform(contactIndex);
link_h_skinFrame=link_h_skinFrame_temp.asAdjointTransformWrench.toMatlab();
% estimateTorquesOneSample variables
framesNames={'l_sole','r_sole','l_lower_leg','root_link','l_elbow_1','r_elbow_1'}; %there has to be atleast 6
q=dataset.qj(sample,:);
dq=zeros(size(dataset.dqj(sample,:)));
ddq=dataset.ddqj(sample,:);
externalWrench=link_h_skinFrame*dataset.skinData.wrench(skinSample,:)';
%externalWrench=dataset.skinData.wrench(skinSample,:)'%*-1;

useSkin=true; % use skin for torque calculation
estimateFT=false; % for initial offset
for n=1:length(sNames)
%ftData.(sNames{n})=dataset.ftData.(sNames{n})(sample,:)-dataset.ftData.(sNames{n})(1,:);%
%to use with modelNoMasses
ftData.(sNames{n})=dataset.ftData.(sNames{n})(sample,:);
end

[extWrenchesSkin,skinTorques]=estimateTorquesOneSample(estimator,q,dq,ddq,externalWrench,useSkin,input,ftData,framesNames,offset,estimateFT);

%% estimate torques without the skin
useSkin=false;
[extWrenchesFt,ftTorques]=estimateTorquesOneSample(estimator,q,dq,ddq,externalWrench,useSkin,input,ftData,framesNames,offset,estimateFT);

%% Ground truth
% reference=[0,0,9.81];
% contactLocation_s=[dataset.skinData.geomCenter(skinSample,:),1];
% contactLocation_l=link_h_skinFrame_temp.asHomogeneousTransform.toMatlab()*contactLocation_s';
% externalWrench=link_h_skinFrame*
% referenceWrench=[reference,cross(reference,contactLocation_l(1:3)')]

%% store results
sT=[sT;skinTorques(4)];
fT=[fT;ftTorques(4)];
%gT=[gT;gtTorques(4)];
time=[time;dataset.time(sample)-dataset.time(1)];
%plot (dataset.time(sample)-dataset.time(1),dataset.skinTau.right_leg(sample,4),'go'); hold on;
%figure,plot (dataset.skinTau.right_leg(sample-15000,4),'ro'); hold on;
%plot (dataset.time(sample)-dataset.time(1),dataset.ftTau.right_leg(sample,4),'k*'); hold on;

end
% legend ('skin torque ','ft torque ',' skin calculated torque','ft calculated torque');
% figure,
% plot (dataset.time(sample)-dataset.time(1),skinTorques(4),'ro'); hold on;
% plot (dataset.time(sample)-dataset.time(1),ftTorques(4),'b'); hold on;
% legend ('skin torque ','ft torque ');

% figure,
% plot (time(2:end),sT(2:end),'r'); hold on;
% plot (time(2:end),fT(2:end),'b'); hold on;
% legend ('skin torque ','ft torque ');
% 
%% filter for beauty fig
temp=sT
N=2;
F=21;
for i=1:size(temp,1)
    sktF=zeros(size(temp));
    
        y = temp;
        nrOfSamples = length(temp);
        [b,g] = sgolay(N,F);
        HalfWin  = ((F+1)/2) -1;
        
        for n = (F+1)/2:nrOfSamples-(F+1)/2,
            % Zeroth derivative (smoothing only)
            sktF(n) = dot(g(:,1),y(n - HalfWin:n + HalfWin));
        end
end
    
temp=fT
N=2;
F=21;
for i=1:size(temp,1)
    fTT=zeros(size(temp));
    
        y = temp;
        nrOfSamples = length(temp);
        [b,g] = sgolay(N,F);
        HalfWin  = ((F+1)/2) -1;
        
        for n = (F+1)/2:nrOfSamples-(F+1)/2,
            % Zeroth derivative (smoothing only)
            fTT(n) = dot(g(:,1),y(n - HalfWin:n + HalfWin));
        end
    end
%%

n=110
figure,
plot (time(12:end-n),sktF(12:end-n),'r'); hold on;
plot (time(12:end-n),fTT(12:end-n),'b'); hold on;
legend ('skin torque ','ft torque ');
xlabel('Time')
ylabel('N.m')
title('1kg at different angles')


% figure, plot (dataset.qj(:,:))
% contactIndex=estimator.model.getFrameIndex('r_sole');
% link_h_skinFrame_temp=estimator.model.getFrameTransform(contactIndex);
% link_h_skinFrame=link_h_skinFrame_temp.asAdjointTransformWrench.toMatlab();