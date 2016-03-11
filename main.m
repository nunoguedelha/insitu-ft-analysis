%% Comparing FT data vs estimated data
%add required folders for use of functions
addpath external/quadfit
addpath utils

%% name and paths of the data files
experimentName='dumperLeftLeg';% Name of the experiment
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

%% load FT data
[left_arm,time1]=readDataDumper(dataFTDirs{1});
[left_leg,time2]=readDataDumper(dataFTDirs{2});
[left_foot,time3]=readDataDumper(dataFTDirs{3});
[right_arm,time4]=readDataDumper(dataFTDirs{4});
[right_leg,time5]=readDataDumper(dataFTDirs{5});
[right_foot,time6]=readDataDumper(dataFTDirs{6});

%% load state and calculate estimated wrenches for comparison
[estimated_left_arm,estimated_left_leg,estimated_left_foot,estimated_right_arm,...
    estimated_right_leg,estimated_right_foot,estimated_time]=obtainEstimatedWrenches(dataStateDirs);