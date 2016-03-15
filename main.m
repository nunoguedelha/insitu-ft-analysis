%% Comparing FT data vs estimated data
%add required folders for use of functions
addpath external/quadfit
addpath utils

%% name and paths of the data files
experimentName='dumperRightLegNoIMU';% Name of the experiment
ftDataName='analog:o/data.log'; % (arm, foot and leg have FT data)
stateDataName='stateExt:o/data.log'; % (only foot has no state data)

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

%% load state and calculate estimated wrenches for comparison
[estimatedFtMeasures]=obtainEstimatedWrenches(dataStateDirs,stateExtNames,robotName,time1);
sensorNames=fieldnames(estimatedFtMeasures);

%match field names with sensor loaded through readDataDumper
% strcmp(sens.getName(),'r_foot_ft_sensor')
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

%match FT vs estimated for comparison
l_arm='leftArm'; value1=left_arm;
e_l_arm='estimatedLeftArm'; value2=e_left_arm;
vs_l_arm='leftArmDataVsEstimation'; value3=left_arm-e_left_arm;
 leftArm=struct(l_arm,value1,e_l_arm, value2,vs_l_arm, value3);
 FTplots(leftArm,time1)

 r_arm='rightArm'; value1=right_arm;
e_r_arm='estimatedRightArm'; value2=e_right_arm;
vs_r_arm='rightArmDataVsEstimation'; value3=right_arm-e_right_arm;
 rightArm=struct(r_arm,value1,e_r_arm, value2,vs_r_arm, value3);
 FTplots(rightArm,time1)
 
 l_leg='leftLeg'; value1=left_leg;
e_l_leg='estimatedLeftLeg'; value2=e_left_leg;
vs_l_leg='leftLegDataVsEstimation'; value3=left_leg-e_left_leg;
 leftleg=struct(l_leg,value1,e_l_leg, value2,vs_l_leg, value3);
 FTplots(leftleg,time1)
 
  r_leg='rightLeg'; value1=right_leg;
e_r_leg='estimatedRightLeg'; value2=e_right_leg;
vs_r_leg='rightLegDataVsEstimation'; value3=right_leg-e_right_leg;
 rightleg=struct(r_leg,value1,e_r_leg, value2,vs_r_leg, value3);
 FTplots(rightleg,time1)
 
 l_foot='leftFoot'; value1=left_foot;
e_l_foot='estimatedLeftFoot'; value2=e_left_foot;
vs_l_foot='leftFootDataVsEstimation'; value3=left_foot-e_left_foot;
 leftfoot=struct(l_foot,value1,e_l_foot, value2,vs_l_foot, value3);
 FTplots(leftfoot,time1)
 
 r_foot='rightFoot'; value1=right_foot;
e_r_foot='estimatedRightFoot'; value2=e_right_foot;
vs_r_foot='rightFootDataVsEstimation'; value3=right_foot-e_right_foot;
 rightfoot=struct(r_foot,value1,e_r_foot, value2,vs_r_foot, value3);
 FTplots(rightfoot,time1)