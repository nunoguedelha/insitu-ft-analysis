function [ fullPath ] = getSensorWorkBenchCalibrationDataFolder( sensNum )
%getSensorWorkBenchCalibrationData Get folder of workbench calibration data
%
%   Get the full folder where workbench calibration data is stored
fullPath = ['../external/ftSensCalib/software/sensAquisitionArchive/' char(sensNum) '/'];

end

