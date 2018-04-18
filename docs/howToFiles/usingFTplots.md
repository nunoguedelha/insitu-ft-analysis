## How to use FTplots
This function plots the information received from an FT sensor be it the wrenches or the raw data.
It assumes wrenches are in a 6D matrix, wrench [F,T]. 
The x axis is the relative time of the experiment. This means it considers the first sample as time 0 always.

Inputs
- data: the actual information of the sensor
- time: a vector the same size as the rows of data containing the timestamp
- varargin: this allows to receive multiple configuration parameters.
    - if varargin is a string it assumes it is one of the configuration variables:
       - onlyForce: if enabled, it will only plot the forces (first 3 columns)
       - raw: if enabled, it will change the legends to reflect the raw channels
       - byChannel: if enable, it will generate a different plot for every axis or
 channel.
       - forceComparison: if enabled, it will fill the reference information with a second field of the data structure (if there are only 2). It will also try to plot the difference between data-reference when option byChannel is enabled.
       - noTimeStamp: if enabled, it will use the sample number as the x axis instead of the time of the experiment. It can also be enabled by typying  useSamples
      - otherwise it assumes that is the desired name for the  reference data
    - if varagin is a struct it assumes is another set of FT sensor data that will be used to compare the main data information configurations
    - if varagin is a vector it assumes is the time vector that corresponds to the struct reference that will be used to compare the main data information configurations
 
 
 Depending on the combination of the information contain in the structure with ft data and the extra variables it will have one of the following behaviours for each field in the structure:
   - Plot all 6 axis into one figure with their legends being forces and torques
   - Plot all 6 channels belonging to the order of raw data
   - Plot only the 3 axis belonging to the forces (the first three columns from the matrix with wrench information)
   - Plot a comparison between 3 force axis between a dataset and a given reference
   - Plot 2 comparisons one of the 3 force axis and another one with the 3 torque axis between a dataset and a given reference
     - Plot when comparison is consider active it will also plot the difference of the absolute values of the axis in another plot.
   - Plot each axis separately be it raw or wrench data
   - Plot a comparison for each axis separately between a dataset and a given reference
   - If the structure has only 2 fields and forceComparison is active then it will make a comparison between the two fields


### Examples of usage
Options: none
>FTplots(dataset.ftData,dataset.time)
![normal](https://user-images.githubusercontent.com/11043189/38038686-d6286646-32ab-11e8-9a20-23be3458aaeb.png)

Options: onlyForce, dataset strucutre contains multiple sensors (fields)
> FTplots(dataset.ftData,dataset.time,'onlyforce')
![of](https://user-images.githubusercontent.com/11043189/38038871-4e187cc2-32ac-11e8-9835-82ca2d393939.png)

**Note**: It can be seen that all sensors are plotted and can be navigated through the tabs
![of2](https://user-images.githubusercontent.com/11043189/38038908-628053ba-32ac-11e8-9957-d62d00f36136.png)

Options : raw , reference and referenceTime
>  FTplots(dataset.rawData,dataset.time,reference.ftData,'raw','referenceRaw',reference.time)
![example1](https://user-images.githubusercontent.com/11043189/38035176-1960d39c-32a4-11e8-806d-d21df70b72cd.png)\

Options : byChannel, reference
> FTplots(dataset1,dataset.time,dataset2,'bychannel')
![bc](https://user-images.githubusercontent.com/11043189/38039947-b475da3a-32ae-11e8-9ec3-6a77e55f6fa5.png)

**Note**: you can easily display all the resulting plots by clicking on the right top side the figure

![bc2](https://user-images.githubusercontent.com/11043189/38040100-16eeaf66-32af-11e8-8cba-87bb811e0cc5.png)

Options:reference, onlyForce, referenceName
> FTplots(dataset1,dataset.time,dataset2,'onlyforce','the Other one')
![refName](https://user-images.githubusercontent.com/11043189/38040530-009cb87e-32b0-11e8-9ef3-399fe8e13073.png)

Options: useSamples/noTimeStamp
>FTplots(toPlot,dataset.time,'useSamples');
![samples](https://user-images.githubusercontent.com/11043189/38932094-84c91a00-4315-11e8-8eb3-7eaa4c375372.png)
