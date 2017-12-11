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
       
 An image of how the dataset Structure looks in matlab:
       
![dataset Structure](https://user-images.githubusercontent.com/11043189/33834203-837347ea-de82-11e7-926f-4ea896f64d44.png)

### Message examples
>An example of a calibrateFTsensor using readExperiment.

When no data has been read from the experiment or force calculation is on we will see:

```
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material green not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material green not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material black not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material red not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material blue not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material yellow not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material pink not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material cyan not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material green not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material white not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material dblue not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material dgreen not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material gray not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material green not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material black not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material red not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material blue not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material yellow not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material pink not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material cyan not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material green not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material white not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material dblue not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material dgreen not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material gray not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material green not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material black not found in model database.
[WARNING]  :: parseURDFMaterial : Impossible to parse URDF material, material red not found in model database.
readExperiment: reading FT data
readExperiment: Reading the FT data for the part right_leg
readExperiment: Disabling inertial data since inertial file does not exist
readExperiment: Reading the stateExt
readExperiment: Resampling the state for the part head
readExperiment: Resampling the state for the part left_arm
readExperiment: Resampling the state for the part left_leg
readExperiment: Resampling the state for the part right_arm
readExperiment: Resampling the state for the part right_leg
readExperiment: Resampling the state for the part torso
estimateDynamicsUsingIntervals: estimating interval fixed with contact frame root_link from 0 s to 3500 s 
estimateDynamicsUsingIntervals: using fixed base for estimation
obtainEstimatedWrenches: Computing the estimated wrenches
obtainedEstimatedWrenches: process the 10000 sample out of 30976
obtainedEstimatedWrenches: process the 20000 sample out of 30976
obtainedEstimatedWrenches: process the 30000 sample out of 30976
readExperiment: Filtering FT data
readExperiment: Calculating raw FT values
```
When .mat file already exists it will only display the warning messages.

[1]:https://github.com/robotology-playground/sensors-calib-inertial/tree/feature/integrateFTSensors
[2]:https://github.com/robotology-playground/insitu-ft-analysis/blob/master/docs/yarpManagerApps/statesAndFtSensorsInertial.xml

