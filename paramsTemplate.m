%% Parameter script template
%name of the file should be renamed to params.m and should be inside the
%experiment folder
%% creating input variable
%% Variables that depend on the type of experiment
input.intervals=struct(); %this will have the relevant intervals of the demos 4 possibilities hanging, fixed, right_leg, left_leg, each interval must have initTime, endTime, contactFrame.
% initTime is seconds at which the interval starts
% endTime is seconds at which the interval starts
% contactFrame is the frame assumed to be in contact during the experiment
%example
% input.intervals.hanging=struct('initTime',0,'endTime',0,'contactFrame','root_link');
% input.intervals.fixed=struct('initTime',0,'endTime',0,'contactFrame','root_link');
% input.intervals.rightLeg=struct('initTime',0,'endTime',0,'contactFrame','r_sole');
% input.intervals.leftLeg=struct('initTime',0,'endTime',0,'contactFrame','l_sole');

% for considering extra samples
%input.extraSampleRight='';  %input here the name of the other experiment from
%which to take the samples
%input.extraSampleLeft='';

% skin torque experiment variables
% input.torquesPortName='';
% input.wbdPortNames='';
% input.wbdNames='';
% input.subModels='';

%input.type='';%

%-----------------------------------------------------------
%% Variables that depend on the way information was logged

input.inertialName='inertial'; %enable in case there is info read from the
%IMU
input.ftPortName='analog:o'; % (arm, foot and leg have FT data), usually is 'analog:o'
input.statePortName='stateExt:i'; % (only foot has no state data), usually is 'stateExt:i'
input.ftNames={'left_arm';'right_arm';'left_leg';'right_leg';'left_foot';'right_foot'};
%usual values are {'left_arm';'right_arm';'left_leg';'right_leg';'left_foot';'right_foot'}; %name of folders that contain ft measures
input.calibFlag=true; %if the flag for obtaining calibrated data is on ( by default
%it is, unless raw data is specifically requested form the yarp port )

%-----------------------------------------------------------
%% Variables that depend on the specific robot used in the experiment

input.robotName='model'; %name of the robot being used (urdf file should be present in the robots folder),
%example input.robotName='iCubGenova02'
% calib variables will only be used when raw data needs to be calculated
input.calibMatPath='';%path to where calibration matrices can be found
input.calibMatFileNames={}; % name of the files containing the calibration matrics in the same order specified in ftNames


%-----------------------------------------------------------
%% Variables that depend on the urdf 

input.sensorNames={'l_arm_ft_sensor'; 'r_arm_ft_sensor'; 'l_leg_ft_sensor'; 'r_leg_ft_sensor'; 'l_foot_ft_sensor'; 'r_foot_ft_sensor';};
% usual values are {'l_arm_ft_sensor'; 'r_arm_ft_sensor'; 'l_leg_ft_sensor'; 'r_leg_ft_sensor'; 'l_foot_ft_sensor'; 'r_foot_ft_sensor';};
%make sure sensor names match the order of the ftNames variable
%this will be used for matching names used in the model to names used in
%ftNames

%input.stateNames=struct();% this should have a structure with the %knowledge 
%of the name of the degrees of freedom that are printed in each state data
%file (normally fixed for the general iCub robot)
% example
head='head'; value1={'neck_pitch';'neck_roll';'neck_yaw';'eyes_tilt';'eyes_tilt';'eyes_tilt'};
left_arm='left_arm'; value2={'l_shoulder_pitch';'l_shoulder_roll';'l_shoulder_yaw';'l_shoulder_yaw';'l_shoulder_yaw';'l_shoulder_yaw';'l_shoulder_yaw';'l_hand_finger';...
    'l_thumb_oppose';'l_thumb_proximal';'l_thumb_distal';'l_index_proximal';'l_index_distal';'l_middle_proximal';'l_middle_distal';' l_pinky'};
left_leg='left_leg'; value3={'l_hip_pitch';'l_hip_roll';'l_hip_yaw';'l_knee';'l_ankle_pitch';'l_ankle_roll'};
right_arm='right_arm'; value4={'r_shoulder_pitch';'r_shoulder_roll';'r_shoulder_yaw';'r_shoulder_yaw';'r_shoulder_yaw';'r_shoulder_yaw';'r_shoulder_yaw';'r_hand_finger';...
    'r_thumb_oppose';'r_thumb_proximal';'r_thumb_distal';'r_index_proximal';'r_index_distal';'r_middle_proximal';'r_middle_distal';' r_pinky'};
right_leg='right_leg'; value5={'r_hip_pitch';'r_hip_roll';'r_hip_yaw';'r_knee';'r_ankle_pitch';'r_ankle_roll'};
torso='torso'; value6={'torso_yaw';'torso_roll';'torso_pitch'};
input.stateNames=struct(head,{value1},left_arm,{value2},left_leg,{value3},right_arm,{value4},right_leg,{value5},torso,{value6});

%-----------------------------------------------------------
%% Mini checks
if(size (input.calibMatFileNames)~=size (input.ftNames))
    disp('amount of calibration matrix files does not match the amount of sensors available in the dataset')
end
if(size (input.sensorNames)~=size (input.ftNames))
    disp('amount of sensor names does not match the amount of sensors available in the dataset')
end

%-----------------------------------------------------------
%% Add a description of the experiment (optional)
