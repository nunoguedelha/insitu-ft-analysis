# How to
Here we will have a description of the main functionalities of this repo and what to do to use it

## Log the experiment data 
To log all info required from and experiment log the analog, stateExt and inertial ports using [sensor calib][1] or this [yarpManagerApp][2].

## Prepare the experiment data 
To prepare the loged information to be used by the repo you need to create a [params.m](https://github.com/robotology-playground/insitu-ft-analysis/blob/master/paramsTemplate.m) file and put it in the directory of the experiment inside the data directory.
There are some variables that are common to all icub robots, some depend on the specific robot used, some depend on how and what you loged in the experiment and others depend on the characteristics of the experiment itslef. **Note:** a params.m copy from a previous similar experiment can be used directly.

Variables:
  - experiment related:
      - input.intervals=struct(): This will have the relevant intervals of the demos 4 possibilities hanging, fixed, right_leg, left_leg, each interval must have initTime, endTime, contactFrame. Examples:
         - input.intervals.hanging=struct('initTime',0,'endTime',0,'contactFrame','root_link');
         - input.intervals.fixed=struct('initTime',0,'endTime',0,'contactFrame','root_link');
         - input.intervals.rightLeg=struct('initTime',0,'endTime',0,'contactFrame','r_sole');
         - input.intervals.leftLeg=struct('initTime',0,'endTime',0,'contactFrame','l_sole');
      - input.extraSampleRight='': this can contain a link to another experiment where it is interesting to analyze the sensors on the right leg during the experiment. 
      - input.extraSampleLeft='': this can contain a link to another experiment where it is interesting to analyze the sensors on the left leg during the experiment
      
          **Note**: This info can also be used to augment the calibration data, although it will assume this experiments have the same offset as the main experiment.
            
      - input.type='random': to select a predefined type of experiment. Possible values:
          - right_leg_yoga
          - left_leg_yoga
          - grid
          - random
          - contactSwitching
          - standUp
          - walking
          
          **Note:** This will probably be used in the inspectionScript. (not ready yet).
      

     
 - related to how it was logged:
      - input.inertialName='inertial'; : IMU yarp port name
      - input.ftPortName='analog:o'; : force torque sensors yarp port name
      - input.statePortName='stateExt:i'; : stateExt torque sensors yarp port name
      - input.ftNames={''}; : name of the part of the robot doing the logging of the ft sensor (is a part of the full yarp port name)
          - usual values are {'left_arm';'right_arm';'left_leg';'right_leg';'left_foot';'right_foot'}; 
          - it should match name of folders that contain ft measures
     - input.calibFlag=true; : if the flag for obtaining calibrated data is on ( by default it is, unless raw data is specifically requested form the yarp device )
     
 - related to the specific robot
      - input.robotName='model'; :name of the robot being used (urdf file should be present in the robots folder). Example:
            - input.robotName='iCubGenova02'
      - input.calibMatPath=''; : path to where calibration matrices can be found. If no path provided a default path will be used that assumes ftSensCalib is installed in external folder
      - input.calibMatFileNames={}; : name of the files containing the calibration matrics in the same order specified in ftNames
      
      **Note:** calib variables will only be used when raw data needs to be calculated.
     
 - urdf dependent variables 
      - head='head'; value1={'neck_pitch';'neck_roll';'neck_yaw';'eyes_tilt';'eyes_tilt';'eyes_tilt'};
      - left_arm='left_arm'; value2={'l_shoulder_pitch';'l_shoulder_roll';'l_shoulder_yaw';'l_shoulder_yaw';'l_shoulder_yaw';'l_shoulder_yaw';'l_shoulder_yaw';'l_hand_finger';...
    'l_thumb_oppose';'l_thumb_proximal';'l_thumb_distal';'l_index_proximal';'l_index_distal';'l_middle_proximal';'l_middle_distal';' l_pinky'};
      - left_leg='left_leg'; value3={'l_hip_pitch';'l_hip_roll';'l_hip_yaw';'l_knee';'l_ankle_pitch';'l_ankle_roll'};
      - right_arm='right_arm'; value4={'r_shoulder_pitch';'r_shoulder_roll';'r_shoulder_yaw';'r_shoulder_yaw';'r_shoulder_yaw';'r_shoulder_yaw';'r_shoulder_yaw';'r_hand_finger';...
    'r_thumb_oppose';'r_thumb_proximal';'r_thumb_distal';'r_index_proximal';'r_index_distal';'r_middle_proximal';'r_middle_distal';' r_pinky'};
      - right_leg='right_leg'; value5={'r_hip_pitch';'r_hip_roll';'r_hip_yaw';'r_knee';'r_ankle_pitch';'r_ankle_roll'};
      - torso='torso'; value6={'torso_yaw';'torso_roll';'torso_pitch'};
      - input.stateNames=struct(head,{value1},left_arm,{value2},left_leg,{value3},right_arm,{value4},right_leg,{value5},torso,{value6}): this variable will be used also to create the paths to read the stateExt port data.

   **Remark:** not to change unless urdf has some modifications regarding joint and sensor names

      - input.sensorNames={'l_arm_ft_sensor'; 'r_arm_ft_sensor'; 'l_leg_ft_sensor'; 'r_leg_ft_sensor'; 'l_foot_ft_sensor'; 'r_foot_ft_sensor';}: this will be used for matching names used in the model to names used in %ftNames
           -  usual values : {'l_arm_ft_sensor'; 'r_arm_ft_sensor'; 'l_leg_ft_sensor'; 'r_leg_ft_sensor'; 'l_foot_ft_sensor'; 'r_foot_ft_sensor';};
           - Note: make sure sensor names match the order of the ftNames variable
           


   
 It is suggested a brief description of the experiment to be written **as a comment** at the end of the file for easier review of the experiment later on. Date and some special details noticed during the experiment can be added
 

## Read an experiment
To read and experiment you can use [readExperiment.m](https://github.com/robotology-playground/insitu-ft-analysis/blob/master/utils/readExperiment.m).

This function is meant to read all info available in a dataset from analog, stateExt, inertial and skin\_events ports logged using [sensor calib][1] or this [yarpManagerApp][2]. It gives some extra functionalities depending on the options enabled.

Obtained Information:
-  timeStamp of the experiment
-  joints positions, velocities and accelerations
-  force/torque measurements and estimation
-  motor side enconder positions, velocities and accelerations (optional not implemented at the moment but ready for it)
-  joint torques
-  inertial data 

Output variables:
-  dataset: structure containinng all obtained information. Fields are:
   - time: timestamp
   - qj: joint positions
   - dqj: joint velocities
   - ddqj: joint accelereations
   - ftData: measured forces and torques
   - estimatedFtData: estimated forces and torques
   - filteredFtData: filtered forces and torques
   - rawData: raw measurements
   - rawDataFiltered: raw measurements calculated from filteredFtData
   - cMat: calibration matrices
   - jointNames: names of joints from urdf model
   - calibMatFileName: the name of the file containing the cailbration matrix of a sensor
-  estimator: iDynTree.ExtWrenchesAndJointTorquesEstimator() class with a
  the model of the robot loaded
-  input: configuration variables read in the [params.m](https://github.com/robotology-playground/insitu-ft-analysis/blob/master/paramsTemplate.m) file
-  extraSample: structure containinng all obtained information from another subset of experiments 

Input variables:
-  experimentName: address and name of the experiment in the data folder
-  scriptOptions should include :
    -  scriptOptions.forceCalculation
       - posible values:true ,false
       - behavior: if true it will retrieve previously stored .mat files with the experiment data if available
    -  scriptOptions.testDir=false;
       - posible values:true ,false
       - behavior: if true it will consider to be in a directory below the main directory of the repository. Most common case the testResults dir
    -  scriptOptions.filterData=true;
       - posible values:true ,false
       - behavior: if true it will filter the ft data
    -  scriptOptions.raw=false;
       - posible values:true ,false
       - behavior: if true it will calculate what the raw values by pre-multiplying by the inverse calibratio matrix
    -  scriptOptions.estimateWrenches=true;
       - posible values:true ,false
       - behavior: if true it will estimate the forces and torques using iDyntree methods
    -  scriptOptions.useInertial=false;
       - posible values:true ,false
       - behavior: if true it will use the imu for calculating forces and torques from floating base
    -  scriptOptions.saveData=true;
       - posible values:true ,false
       - behavior: if true it will save the dataset structure into a  "scriptOptions.matFileName".mat file in the experiment directory 
    -  scriptOptions.matFileName='iCubDataset';
       - posible values: any string, most used iCubDataset or ftDataset
       - behavior: name of the file with which the data will be saved



[1]:https://github.com/robotology-playground/sensors-calib-inertial/tree/feature/integrateFTSensors
[2]:https://github.com/robotology-playground/insitu-ft-analysis/blob/master/docs/yarpManagerApps/statesAndFtSensorsInertial.xml
