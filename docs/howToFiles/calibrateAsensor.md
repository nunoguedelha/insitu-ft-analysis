## Calibrate a sensor

This script allows to calibrate six axis force torque (F/T) sensors once they are mounted on the robot. This procedure
takes advantage of the knowledge of the model of the robot to generate the expected wrenches of the sensors during
some arbitrary motions. It then uses this information to train and validate new calibration matrices, taking into account
the calibration matrix obtained with a classical Workbench calibration. The data from an experiment is typically logged using yarpDataDumper directly form [statesAndFtSensorsInertial.xml][5] or
using [sensorSelfCalibrator][1] and stored in [3] or [4].
For more on the theory behind this script, check [1,2].

1. : [Traversaro, Silvio, Daniele Pucci, and Francesco Nori.
      "In situ calibration of six-axis force-torque sensors using accelerometer measurements."
      Robotics and Automation (ICRA), 2015 IEEE International Conference on. IEEE, 2015.](http://ieeexplore.ieee.org/document/7139477/)
2. : [F. J. A. Chavez, S. Traversaro, D. Pucci and F. Nori, 
      "Model based in situ calibration of six axis force torque sensors," 
      2016 IEEE-RAS 16th International Conference on Humanoid Robots (Humanoids), Cancun, 2016](http://ieeexplore.ieee.org/document/7803310/)
[1]:https://github.com/robotology-playground/sensors-calib-inertial/blob/feature/integrateFTSensors/src/app/sensorSelfCalibrator.m
[2]:https://github.com/robotology-playground/insitu-ft-analysis/blob/master/docs/yarpManagerApps/statesAndFtSensorsInertial.xml
[3]:https://gitlab.com/dynamic-interaction-control/green-iCub-Insitu-Datasets
[4]:https://gitlab.com/dynamic-interaction-control/icub-insitu-ft-analysis-big-datasets 
[5]:https://github.com/robotology-playground/insitu-ft-analysis/blob/master/docs/yarpManagerApps/statesAndFtSensorsInertial.xml

### Instructions before running script
- Log the experiment using [statesAndFtSensorsInertial.xml][5] or
using [sensor-calib-inertial][1]
- [Edit a file params.m](https://github.com/robotology-playground/insitu-ft-analysis/blob/master/docs/howToFiles/prepareData.md) based on [paramsTemplate.m](https://github.com/robotology-playground/insitu-ft-analysis/blob/master/paramsTemplate.m) to match the 
characteristics of the experiment and put it in the experiment folder
- Verify there is a folder named calibrationMatrices inside the experiment 
folder to store resulting calibration matrices
   ~ Remark: if nothing changed between experiments (logging method, sensor replacement or use of another robot) params.m can be
   directly copied for another experiment.
- Select desired options for [reading the experiment](https://github.com/robotology-playground/insitu-ft-analysis/blob/master/docs/howToFiles/readAnExperiment.md). Typically:
```
scriptOptions = {};
scriptOptions.forceCalculation=true;
scriptOptions.printPlots=true;
scriptOptions.raw=true;
scriptOptions.saveData=true;
scriptOptions.testDir=false;
scriptOptions.filterData=true;
scriptOptions.estimateWrenches=true;
scriptOptions.useInertial=false;
scriptOptions.matFileName='ftDataset';
```
  
**required options to be on are `scriptOptions.raw scriptOptions.filterData scriptOptions.estimateWrenches` others are optional**

- Change `experimentName='';` to desired experiment folder
- Select desired options of the calibration procedure. Typycally
```
calibOptions.saveMat=true;
calibOptions.usingInsitu=true;
calibOptions.plot=true;
calibOptions.onlyWSpace=true;
calibOptions.IITfirmwareFriendly=true; 
```
### Explaining calibOptions
The options are the following:
 -  calibOptions.saveData=true;
       - posible values:true ,false
       - behavior: if true it will save the dataset structure into a  "reCabData or reCabDataInsitu".mat file (depending on `calibOptions.usingInsitu`)  in the experiment directory 
 -  calibOptions.usingInsitu=true;
       - posible values:true ,false
       - behavior: if true it will calculate the offset by removing the position of the center of the ellipsoid generated from fitting the raw data to a sphere. The offset will be in the raw data. Otherwise the offset is calculated as the difference of the mean estimated values - (calculated calibration matrix )* mean raw data.
       - it is adviced to use insitu when possible. It is** not valid** if the data does not form an ellipsoid. This could be because the movements do not expand enough circular motions or because the center of mass changed during the experiment.
 -  calibOptions.plot=true;
       - posible values:true ,false
       - behavior: if true it will plot the results to visualize performance of the results
-  calibOptions.onlyWSpace=true;
       - posible values:true ,false
       - behavior: if `calibOptions.plot=true` then it will plot only the [wrench space plot](https://github.com/robotology-playground/insitu-ft-analysis/blob/master/utils/wrenchSpacePlots.m). Otherwise it will plot the [forces vs time](https://github.com/robotology-playground/insitu-ft-analysis/blob/master/utils/FTplots.m)
-  calibOptions.IITfirmwareFriendly=true;
       - posible values:true ,false
       - behavior: if true it will save calibration matrix such that it avoids [bugs detected](https://github.com/loc2/component_ft-sensors/issues/1#issuecomment-349793471) and a swap in channels from interaction with the IIT firmware
       
- scriptOptions.firstTime : is a hidden feature that activates when it detects that the calibration matrix is the identity. This assumes that the sensor has not been calibrated before and will prompt the user to give it a name.
![hidden feature](https://user-images.githubusercontent.com/11043189/33843192-f9f32c04-de9c-11e7-9007-9ad5083fd389.png)
      
       
### Understanding Results
While calibrating the sensor the script will realease a series of messages.

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
