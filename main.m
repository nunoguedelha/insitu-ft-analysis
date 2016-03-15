%% Comparing FT data vs estimated data
%add required folders for use of functions
addpath external/quadfit
addpath utils

%% name and paths of the data files
experimentName='dumperLeftLegNoIMU';% Name of the experiment
ftDataName='analog:o/data.log'; % (arm, foot and leg have FT data)
stateDataName='stateExt:o/data.log'; % (only foot has no state data)
contactInfo=0; % 1 if is on the right , 0 if is on the left
rData=load(strcat('data/',experimentName,'/relevantData'));

dataFTDirs={strcat('data/',experimentName,'/icub/left_arm/',ftDataName);
    strcat('data/',experimentName,'/icub/left_leg/',ftDataName);
    strcat('data/',experimentName,'/icub/left_foot/',ftDataName);
    strcat('data/',experimentName,'/icub/right_arm/',ftDataName);
    strcat('data/',experimentName,'/icub/right_leg/',ftDataName);
    strcat('data/',experimentName,'/icub/right_foot/',ftDataName);
    }; %to acces this as a string later {} should be used exampple: dataFTDirs{1}...

dataStateDirs={strcat('data/',experimentName,'/icub/head/',stateDataName);
    strcat('data/',experimentName,'/icub/left_arm/',stateDataName);
    strcat('data/',experimentName,'/icub/left_leg/',stateDataName);
    strcat('data/',experimentName,'/icub/right_arm/',stateDataName);
    strcat('data/',experimentName,'/icub/right_leg/',stateDataName);
    strcat('data/',experimentName,'/icub/torso/',stateDataName);
    };
%DoF=[6,16,6,16,6,3];% degrees of freedom in the same order of dataStateDirs (head, left_arm _leg, right_arm _leg, torso)
head='head'; value1={'neck_pitch';'neck_roll';'neck_yaw';'eyes_tilt';'eyes_tilt';'eyes_tilt'};
left_arm='left_arm'; value2={'l_shoulder_pitch';'l_shoulder_roll';'l_shoulder_yaw';'l_shoulder_yaw';'l_shoulder_yaw';'l_shoulder_yaw';'l_shoulder_yaw';'l_hand_finger';...
    'l_thumb_oppose';'l_thumb_proximal';'l_thumb_distal';'l_index_proximal';'l_index_distal';'l_middle_proximal';'l_middle_distal';' l_pinky'};
left_leg='left_leg'; value3={'l_hip_pitch';'l_hip_roll';'l_hip_yaw';'l_knee';'l_ankle_pitch';'l_ankle_roll'};
right_arm='right_arm'; value4={'r_shoulder_pitch';'r_shoulder_roll';'r_shoulder_yaw';'r_shoulder_yaw';'r_shoulder_yaw';'r_shoulder_yaw';'r_shoulder_yaw';'r_hand_finger';...
    'r_thumb_oppose';'r_thumb_proximal';'r_thumb_distal';'r_index_proximal';'r_index_distal';'r_middle_proximal';'r_middle_distal';' r_pinky'};
right_leg='right_leg'; value5={'r_hip_pitch';'r_hip_roll';'r_hip_yaw';'r_knee';'r_ankle_pitch';'r_ankle_roll'};
torso='torso'; value6={'torso_yaw';'torso_roll';'torso_pitch'};

stateExtNames=struct(head,{value1},left_arm,{value2},left_leg,{value3},right_arm,{value4},right_leg,{value5},torso,{value6});
robotName='iCubGenova02';

%% load FT data
[left_arm,time1]=readDataDumper(dataFTDirs{1});
[left_leg,time2]=readDataDumper(dataFTDirs{2});
[left_foot,time3]=readDataDumper(dataFTDirs{3});
[right_arm,time4]=readDataDumper(dataFTDirs{4});
[right_leg,time5]=readDataDumper(dataFTDirs{5});
[right_foot,time6]=readDataDumper(dataFTDirs{6});

%% resample FT data
left_leg=resampleFt(time1,time2,left_leg);
left_foot=resampleFt(time1,time3,left_foot);
right_arm=resampleFt(time1,time4,right_arm);
right_leg=resampleFt(time1,time5,right_leg);
right_foot=resampleFt(time1,time6,right_foot);

%%extract relevant data from FT data
time=time1(time1>time1(1)+rData(1) & time1<time1(1)+rData(2));
mask=time1>time1(1)+rData(1) & time1<time1(1)+rData(2);
left_arm=left_arm(mask,:);
left_leg=left_leg(mask,:);
left_foot=left_foot(mask,:);
right_arm=right_arm(mask,:);
right_leg=right_leg(mask,:);
right_foot=right_foot(mask,:);

%% load state and calculate estimated wrenches for comparison
[estimatedFtMeasures]=obtainEstimatedWrenches(dataStateDirs,stateExtNames,robotName,time1,contactInfo);
sensorNames=fieldnames(estimatedFtMeasures);

%match field names with sensor loaded through readDataDumper
% sensorNames={'l_arm_ft_sensor';% 'r_arm_ft_sensor';% 'l_leg_ft_sensor';% 'r_leg_ft_sensor';% 'l_foot_ft_sensor';% 'r_foot_ft_sensor';};
index = find(strcmp(sensorNames, 'l_arm_ft_sensor'));
e_left_arm=estimatedFtMeasures.(sensorNames{index});

index = find(strcmp(sensorNames, 'r_arm_ft_sensor'));
e_right_arm=estimatedFtMeasures.(sensorNames{index});

index = find(strcmp(sensorNames, 'l_leg_ft_sensor'));
e_left_leg=estimatedFtMeasures.(sensorNames{index});

index = find(strcmp(sensorNames, 'r_leg_ft_sensor'));
e_right_leg=estimatedFtMeasures.(sensorNames{index});

index = find(strcmp(sensorNames, 'l_foot_ft_sensor'));
e_left_foot=estimatedFtMeasures.(sensorNames{index});

index = find(strcmp(sensorNames, 'r_foot_ft_sensor'));
e_right_foot=estimatedFtMeasures.(sensorNames{index});

%%%%extract relevant data from estimation wrenches
e_left_arm=e_left_arm(mask,:);
e_left_leg=e_left_leg(mask,:);
e_left_foot=e_left_foot(mask,:);
e_right_arm=e_right_arm(mask,:);
e_right_leg=e_right_leg(mask,:);
e_right_foot=e_right_foot(mask,:);

%match FT vs estimated for comparison and plotting
l_arm='leftArm'; value1=left_arm;
e_l_arm='estimatedLeftArm'; value2=e_left_arm;
leftArm=struct(l_arm,value1,e_l_arm, value2);

 r_arm='rightArm'; value1=right_arm;
e_r_arm='estimatedRightArm'; value2=e_right_arm;
 rightArm=struct(r_arm,value1,e_r_arm, value2);


 l_leg='leftLeg'; value1=left_leg;
e_l_leg='estimatedLeftLeg'; value2=e_left_leg;
leftleg=struct(l_leg,value1,e_l_leg, value2);

  r_leg='rightLeg'; value1=right_leg;
e_r_leg='estimatedRightLeg'; value2=e_right_leg;
 rightleg=struct(r_leg,value1,e_r_leg, value2);

 l_foot='leftFoot'; value1=left_foot;
e_l_foot='estimatedLeftFoot'; value2=e_left_foot;
  leftfoot=struct(l_foot,value1,e_l_foot, value2);

 r_foot='rightFoot'; value1=right_foot;
e_r_foot='estimatedRightFoot'; value2=e_right_foot;
 rightfoot=struct(r_foot,value1,e_r_foot, value2);

 %ploting
 %FTplots(leftArm,time)
% FTplots(rightArm,time)
 FTplots(leftleg,time)
 FTplots(rightleg,time)
 %FTplots(leftfoot,time)
 %FTplots(rightfoot,time)

 %% Data exploration
 %simple visual exploration suggests only offset problem, this parts aims
 %to calculate the offset and then compare the data with the offset
 %removed
 
 %compute offset on meaningful data
 
left_arm_noOffset=removeOffset(left_arm,e_left_arm);
right_arm_noOffset=removeOffset(right_arm,e_right_arm);
 left_leg_noOffset=removeOffset( left_leg,e_left_leg);
 right_leg_noOffset=removeOffset( right_leg,e_right_leg);
 left_foot_noOffset=removeOffset( left_foot,e_left_foot);
 right_foot_noOffset=removeOffset( right_foot,e_right_foot);

l_arm_noOffset='leftArmNoOffset'; value1=left_arm_noOffset;
e_l_arm='estimatedLeftArm'; value2=e_left_arm;
leftArm_noOffset=struct(l_arm_noOffset,value1,e_l_arm, value2);

r_arm_noOffset='rightArmNoOffset'; value1=right_arm_noOffset;
e_r_arm='estimatedRightArm'; value2=e_right_arm;
rightArm_noOffset=struct(r_arm_noOffset,value1,e_r_arm, value2);


 l_leg_noOffset='leftLegNoOffset'; value1=left_leg_noOffset;
e_l_leg='estimatedLeftLeg'; value2=e_left_leg;
leftleg_noOffset=struct(l_leg_noOffset,value1,e_l_leg, value2);

  r_leg_noOffset='rightLegNoOffset'; value1=right_leg_noOffset;
e_r_leg='estimatedRightLeg'; value2=e_right_leg;
 rightleg_noOffset=struct(r_leg_noOffset,value1,e_r_leg, value2);

 l_foot_noOffset='leftFootNoOffset'; value1=left_foot_noOffset;
e_l_foot='estimatedLeftFoot'; value2=e_left_foot;
  leftfoot_noOffset=struct(l_foot_noOffset,value1,e_l_foot, value2);

 r_foot_noOffset='rightFootNoOffset'; value1=right_foot_noOffset;
e_r_foot='estimatedRightFoot'; value2=e_right_foot;
 rightfoot_noOffset=struct(r_foot_noOffset,value1,e_r_foot, value2);

 %ploting
 %FTplots(leftArm_noOffset,time)
% FTplots(rightArm_noOffset,time)
 FTplots(leftleg_noOffset,time)
 FTplots(rightleg_noOffset,time)
 %FTplots(leftfoot_noOffset,time)
 %FTplots(rightfoot_noOffset,time)
 
 
    %% Save the workspace 
    %save meaninful data, estimated data, meaninful data no offset
    ftData=struct(l_arm,left_arm,r_arm,right_arm,l_leg,left_leg,r_leg,right_leg,l_foot,left_foot,r_foot,right_foot);
    estimatedData=struct(e_l_arm,e_left_arm,e_r_arm,e_right_arm,e_l_leg,e_left_leg,e_r_leg,e_right_leg,e_l_foot,e_left_foot,e_r_foot,e_right_foot);
    ftDataNoOffset=struct(l_arm_noOffset,left_arm_noOffset,r_arm_noOffset,right_arm_noOffset,l_leg_noOffset,left_leg_noOffset,r_leg_noOffset,right_leg_noOffset,l_foot_noOffset,left_foot_noOffset,r_foot_noOffset,right_foot_noOffset);

    save(strcat(experimentFolder,'/ftData.mat'),'ftData')
     save(strcat(experimentFolder,'/estimatedData.mat'),'estimatedData')
      save(strcat(experimentFolder,'/ftDataNoOffset.mat'),'ftDataNoOffset')
      save(strcat(experimentFolder,'/time.mat'),'time')