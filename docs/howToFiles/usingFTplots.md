## How to use FTplots
This function plots the information received from an FT sensor be it the wrenches or the raw data.
It assumes wrenches are in a 6D matrix, wrench [F,T]. 
The x axis is the relative time of the experiment. This means it considers the first sample as time 0 always.

Inputs
- data: the actual information of the sensor
- time: a vector the same size as the rows of data containing the timestamp
- varargin: this allows to receive multiple configuration parameters.
    - if varargin is a string it assumes it is one of the configuration variables:
       - onlyForce: if enabled it will only plot the forces (first 3 columns)
       - raw: if enabled it will change the legends to reflect the raw channels
       - byChannel: if enable it will generate a different plot for every axis or
 channel.
      - otherwise it assumes that is the desired name for the  reference data
    - if varagin is a struct it assumes is another set of FT sensor data that will be used to compare the main data information configurations
 
 
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
