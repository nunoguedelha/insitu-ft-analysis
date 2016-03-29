function [calibMat] = readCalibMat(filename)
%read the calibration matrix delivered by the calibration procedure

fid = fopen(filename);

if( fid == -1 )
    error(strcat('[ERROR] error in opening file ',filename))
end

format = '%X';
vec=fscanf(fid,format);
calibMat=reshape(vec(1:36),[6,6])';
calibMat=calibMat/(2^15);
if fclose(fid) == -1
   error('[ERROR] there was a problem in closing the file')
end