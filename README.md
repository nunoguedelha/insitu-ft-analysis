# insitu-ft-analysis
Data and code for analysis of the [FTSens](http://wiki.icub.org/wiki/FT_sensor) iCub Facility Force/Torque sensor. 


## Installation 
The scripts in this repo uses the [iDynTree matlab bindings](https://github.com/robotology/idyntree).

### External repositories 

#### quadfit 
The external directory external repositories. It contains a copy of the [quadfit](http://www.mathworks.com/matlabcentral/fileexchange/45356-fitting-quadratic-curves-and-surfaces) toolbox 
for fitting quadratics surfaces. 

#### ftSensCalib
If you have access to the ftSensCalib repository, checkout it in the external directory to make it available to the script into this repo, i.e. from the root of the repo 
you can run this command:
~~~
svn co https://svn.icub.iit.local/repos/mecha/ftSensCalib/trunk/ ./external/ftSensCalib
~~~

#### [icub-insitu-ft-analysis-big-datasets](https://gitlab.com/dynamic-interaction-control/icub-insitu-ft-analysis-big-datasets)
You can download the https://gitlab.com/dynamic-interaction-control/icub-insitu-ft-analysis-big-datasets repository in the data directory to make the data from that repo available: 
~~~
git clone https://gitlab.com/dynamic-interaction-control/icub-insitu-ft-analysis-big-datasets.git ./data/icub-insitu-ft-analysis-big-datasets
~~~
