## Analyze a sensor performance

The type of experiment should be the grid or similar.
The required configuration options for reading the file are:

```
scriptOptions = {};
scriptOptions.forceCalculation=true;%false;
scriptOptions.printPlots=true;%true
scriptOptions.raw=false;
scriptOptions.saveData=false;
scriptOptions.testDir=false;% to calculate the raw data, for recalibration always true
scriptOptions.filterData=true;
scriptOptions.estimateWrenches=true;
scriptOptions.useInertial=false;
scriptOptions.matFileName='iCubDataset';```
