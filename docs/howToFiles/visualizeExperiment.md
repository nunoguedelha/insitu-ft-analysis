## Use the experiment visualizer
To visualize an experiment you can use [visualizeExperiment.m](https://github.com/robotology-playground/insitu-ft-analysis/blob/master/utils/visualizeExperiment.m).

This function has the aim of been able to see the icub posture while seen the devolpment of the ft forces in the wrench space.
Input
- dataset: has the joint and forces information
- input: variable resulting in reading the params.m files. For this variable it assumes it has the following fields
  - robotName: is used to load the robot model to know which joints to add, it is asumed its the same type of robot than the one found in external/iCubViz/model.urdf
  - calibFlag: if calibration flag form yarp device is enabled
-sensorsToAnalize: has the names of the sensors to plot, the names correspond to fileds in the dataset structure

Default behavior: It will show an iCub whose pose depends on the joint position of the experiment matching the slider position in the wrench plot assuming the root link frame is fixed. Moving the slider will change the pose of the iCub and will display the forces if the experiment from the start up to the sample chosen through the slider.

Variable options (not required):
- char acting as boolean:

  - 'testDir': enables testDir boolean, use if in test directory. False by default
  - 'video': this will play the experiment with a subsample n that is 100 by default, at the end there will be a video of the forces evolving over time in the wrench space.
  
- char to understand next variable
  - 'fixedFrame': it will expect to have another char variable afterwards that will be used as the fixed frame reference for the visualizer. 'root_link' by default. Other accepted code names for this behaviour is 'contactFrame'.
  
- numeric
   - if video option has been enabled then the numeric value 'n' will be used to subsample the experiment. 


**Remark**: install also the irrlicht library (sudo apt install -libirrlicht-dev ) required , and enable the `IDYNTREE_USES_MATLAB` and `IDYNTREE_USES_IRRLICHT`

**Note**: it is not possible to close the window with the iCub without closing the wrench plot.

### Examples of usage
To obtain the required inputs dataset and input we need to load the experiment data for this the [readExperiment](https://github.com/robotology-playground/insitu-ft-analysis/blob/master/utils/readExperiment.m) funciton can be used. Details on how to use is can be found [here](https://github.com/robotology-playground/insitu-ft-analysis/blob/master/docs/howToFiles/readAnExperiment.md)

Once the experiment is loaded select the sensors to be displayed. The sensors should be part of the experiment data. The possible options are 'left_arm','right_arm','left_leg','right_leg','left_foot','right_foot'. More than one sensor can be selected it will display them together in different subplots.

A temporary ready script for using this function is [testIcubVizSynchro](https://github.com/robotology-playground/insitu-ft-analysis/blob/master/testIcubVizSynchro.m)

Example:
```
sensorsToAnalize = {'left_leg'};  
  robotName='iCubGenova04';
  input.robotName='model';
  visualizeExperiment(dataset,input,sensorsToAnalize,'contactFrame','r_sole')
```
![Visualization example](https://user-images.githubusercontent.com/11043189/35084305-a37c41fe-fc23-11e7-913b-96381c6b88c2.png)
