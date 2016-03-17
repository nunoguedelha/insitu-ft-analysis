%% Comparing FT data vs estimated data

%create input parameter
input.experimentName='dumperLeftLegNoIMU';% Name of the experiment
input.ftPortName='analog:o'; % (arm, foot and leg have FT data)
input.statePortName='stateExt:o'; % (only foot has no state data)
input.ftNames={'left_arm';'right_arm';'left_leg';'right_leg';'left_foot';'right_foot'}; %name of folders that contain ft measures
sensorNames={'l_arm_ft_sensor'; 'r_arm_ft_sensor'; 'l_leg_ft_sensor'; 'r_leg_ft_sensor'; 'l_foot_ft_sensor'; 'r_foot_ft_sensor';};
input.sensorNames=sensorNames; %make sensor names match the order of the names of the folders

%input.stateNames={'head','left_arm','right_arm','left_leg','right_leg','torso'}; % name of the folders that contain state information
%DoF=[6,16,6,16,6,3];% degrees of freedom in the same order of dataStateDirs (head, left_arm _leg, right_arm _leg, torso)
head='head'; value1={'neck_pitch';'neck_roll';'neck_yaw';'eyes_tilt';'eyes_tilt';'eyes_tilt'};
left_arm='left_arm'; value2={'l_shoulder_pitch';'l_shoulder_roll';'l_shoulder_yaw';'l_shoulder_yaw';'l_shoulder_yaw';'l_shoulder_yaw';'l_shoulder_yaw';'l_hand_finger';...
    'l_thumb_oppose';'l_thumb_proximal';'l_thumb_distal';'l_index_proximal';'l_index_distal';'l_middle_proximal';'l_middle_distal';' l_pinky'};
left_leg='left_leg'; value3={'l_hip_pitch';'l_hip_roll';'l_hip_yaw';'l_knee';'l_ankle_pitch';'l_ankle_roll'};
right_arm='right_arm'; value4={'r_shoulder_pitch';'r_shoulder_roll';'r_shoulder_yaw';'r_shoulder_yaw';'r_shoulder_yaw';'r_shoulder_yaw';'r_shoulder_yaw';'r_hand_finger';...
    'r_thumb_oppose';'r_thumb_proximal';'r_thumb_distal';'r_index_proximal';'r_index_distal';'r_middle_proximal';'r_middle_distal';' r_pinky'};
right_leg='right_leg'; value5={'r_hip_pitch';'r_hip_roll';'r_hip_yaw';'r_knee';'r_ankle_pitch';'r_ankle_roll'};
torso='torso'; value6={'torso_yaw';'torso_roll';'torso_pitch'};

input.stateNames=struct(head,{value1},left_arm,{value2},left_leg,{value3},right_arm,{value4},right_leg,{value5},torso,{value6});
input.robotName='iCubGenova02';


%add required folders for use of functions
addpath external/quadfit
addpath utils
%% name and paths of the data files

experimentName=input.experimentName;
ftDataName=strcat(input.ftPortName,'/data.log'); % (arm, foot and leg have FT data)
stateDataName=strcat(input.statePortName,'/data.log');  % (only foot has no state data)
paramScript=strcat('data/',experimentName,'/params.m');
%params.m is expected to have contactInfo (1 right ,0 left ), relevant (if
%there is an specific interval desired to study (1 true, 0 false ) and
%rData which is a double array 1x2 that has begining and ending of interval in seconds 
run(paramScript)

for i=1:size(input.ftNames,1)
    dataFTDirs{i}=strcat('data/',experimentName,'/icub/',input.ftNames{i},'/',ftDataName);

end
    stateNames=fieldnames(input.stateNames);
for i=1:size(stateNames,1)
    dataStateDirs{i}=strcat('data/',experimentName,'/icub/',stateNames{i},'/',stateDataName);

end    
%TODO: replace "icub" for robot model? so that it can be used for other
%robots, although this is dependent on the output kind of the data dumper


%% load FT data
    [ftData.(input.ftNames{1}),time]=readDataDumper(dataFTDirs{1});

   
for i=2:size(input.ftNames,1)
    %read from dataDumper
    [ftData_temp,time_temp]=readDataDumper(dataFTDirs{i});
    %resample FT data
    ftData.(input.ftNames{i})=resampleFt(time,time_temp,ftData_temp);
end

%% load state and calculate estimated wrenches for comparison
[dataset]=obtainEstimatedWrenches(dataStateDirs,input.stateNames,input.robotName,time,contactInfo);

    dataset.time=time;
    dataset.ftData=ftData;
    
sensorNames=fieldnames(dataset.estimatedFtData);

%match field names with sensor loaded through readDataDumper
% 
matchup=zeros(size(input.sensorNames,1),1);
for i=1:size(input.sensorNames,1)
    matchup(i) = find(strcmp(sensorNames, input.sensorNames{i}));
end

%replace the estored estimatedFtData for one with the same order as the
%ftData
for i=1:size(input.ftNames,1)
        estimatedFtData.(input.ftNames{i})=dataset.estimatedFtData.(sensorNames{matchup(i)});
end
dataset.estimatedFtData=estimatedFtData;

  

if (relevant==1)
%    time1=dataset.time;
%      time=time1(time1>time1(1)+rData(1) & time1<time1(1)+rData(2));
    mask=time1>time1(1)+rData(1) & time1<time1(1)+rData(2);
    dataset=applyMask(dataset,mask);
 %   dataset.time=time;
end


%simple visual exploration suggests an offset problem, this parts aims
%to calculate the offset and then compare the data with the offset
%removed

%compute offset on meaningful data
for i=1:size(input.ftNames,1)
        ftDataNoOffset.(input.ftNames{i})=removeOffset(dataset.ftData.(input.ftNames{i}),dataset.estimatedFtData.(input.ftNames{i}));
end
dataset.ftDataNoOffset=ftDataNoOffset;


%% Save the workspace
%     %save meaninful data, estimated data, meaninful data no offset
%     ftData=struct(l_arm,left_arm,r_arm,right_arm,l_leg,left_leg,r_leg,right_leg,l_foot,left_foot,r_foot,right_foot);
%     estimatedData=struct(e_l_arm,e_left_arm,e_r_arm,e_right_arm,e_l_leg,e_left_leg,e_r_leg,e_right_leg,e_l_foot,e_left_foot,e_r_foot,e_right_foot);
%     ftDataNoOffset=struct(l_arm_noOffset,left_arm_noOffset,r_arm_noOffset,right_arm_noOffset,l_leg_noOffset,left_leg_noOffset,r_leg_noOffset,right_leg_noOffset,l_foot_noOffset,left_foot_noOffset,r_foot_noOffset,right_foot_noOffset);
%
%     save(strcat('data/',experimentName,'/ftData.mat'),'ftData')
%      save(strcat('data/',experimentName,'/estimatedData.mat'),'estimatedData')
%       save(strcat('data/',experimentName,'/ftDataNoOffset.mat'),'ftDataNoOffset')
%       save(strcat('data/',experimentName,'/time.mat'),'time')

% dataset.ftData=ftData; dataset.estimatedData= estimatedData;
% dataset.ftDataNoOffset=ftDataNoOffset;
%  save(strcat('data/',experimentName,'/dataset.mat'),'dataset')
%% Data exploration
for i=3:3
%     for i=1:size(input.ftNames,1)

      FTplots(struct(input.ftNames{i},dataset.ftDataNoOffset.(input.ftNames{i}),strcat('estimated',input.ftNames{i}),dataset.estimatedFtData.(input.ftNames{i})),dataset.time);
end




% Plot forces in 3D space
figure,plot3_matrix(left_arm_noOffset(:,1:3)); hold on; plot3_matrix(e_left_arm(:,1:3));grid on;
figure,plot3_matrix(right_arm_noOffset(:,1:3)); hold on; plot3_matrix(e_right_arm(:,1:3));grid on;
figure,plot3_matrix( left_leg_noOffset(:,1:3)); hold on; plot3_matrix(e_left_leg(:,1:3));grid on;
figure,plot3_matrix( right_leg_noOffset(:,1:3)); hold on; plot3_matrix(e_right_leg(:,1:3));grid on;
figure, plot3_matrix(left_foot_noOffset(:,1:3)); hold on; plot3_matrix(e_left_foot(:,1:3));grid on;
figure, plot3_matrix(right_foot_noOffset(:,1:3)); hold on; plot3_matrix(e_right_foot(:,1:3));grid on;

% figure,plot3_matrix(left_arm(:,1:3)); hold on; plot3_matrix(e_left_arm(:,1:3));grid on;
% figure,plot3_matrix(right_arm(:,1:3)); hold on; plot3_matrix(e_right_arm(:,1:3));grid on;
% figure,plot3_matrix( left_leg(:,1:3)); hold on; plot3_matrix(e_left_leg(:,1:3));grid on;
% figure,plot3_matrix( right_leg(:,1:3)); hold on; plot3_matrix(e_right_leg(:,1:3));grid on;
% figure, plot3_matrix(left_foot(:,1:3)); hold on; plot3_matrix(e_left_foot(:,1:3));grid on;
% figure, plot3_matrix(right_foot(:,1:3)); hold on; plot3_matrix(e_right_foot(:,1:3));grid on;
