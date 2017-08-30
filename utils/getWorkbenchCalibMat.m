function [calibMatrix]=getWorkbenchCalibMat(pathFile,serialNumber)
    if (exist(strcat(pathFile,'matrix_',serialNumber,'.txt'),'file')==2)
        calibMatrix=readCalibMat(strcat(pathFile,'matrix_',serialNumber,'.txt'));
    else
        disp(strcat({'getRawData: Calibration Matrix '},serialNumber,{' not found in the specified folder. Trying in default folders'}))
        if (exist(strcat('external/ftSensCalib/software/sensAquisitionArchive/',serialNumber,'/','matrix_',serialNumber,'.txt'),'file')==2)
            calibMatrix=readCalibMat(strcat('external/ftSensCalib/software/sensAquisitionArchive/',serialNumber,'/','matrix_',serialNumber,'.txt'));
        else
            disp(strcat({'getRawData: Calibration Matrix '},serialNumber,{' not found in the default folder.'}))
        end
    end
