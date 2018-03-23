## How to use force3Dplots
This will plot the 3D force space of the wrenches. It assumes that the matrix has at least 3 columns and they are respectively F <sub> x </sub>, F <sub> y </sub> and F <sub> z </sub>. It is able to receive more than one matrix that will be displayed in the same figure for visual comparison.

 Inputs:
- namesDatasets: Names of each data set to be ploted
- graphName: the title of the resulting figure
- varargin: variable that should contain either the data to plot. 

**Note**:Plotting options can be included but only after the datasets.

### Example of usage
Here you can find how an image using 
```
ft = 'right_leg';
    names={'measuredDataNoOffset','estimatedData','reCalibratedData};
force3DPlots(names,ft,dataset.ftData.(ft), reference.estimatedFtData.(ft), recalibratedData.ftData.(ft)) 
```

would look


![exampleResult](https://user-images.githubusercontent.com/11043189/33845375-915ba00c-dea3-11e7-8d5f-1d59d2353976.png)
