function [time, cop ,force,torque,normalDirection,geomCenter, bodyparts,wrench]=readSkinEvents(filename)
%n i sthe number of degrees of freedom of the part of the robot
%filename is the name of the file containing the data from stateEXT:o port
n=3;
format = '%d %f (';
fid    = fopen(filename);  

for j = 1 : 10
    if ismember(j,[1:6])
        format = [format, '('];
        if j==1
            for i = 1 : n+1
                format = [format, '%d '];
            end
        else
            for i = 1 : n
                format = [format, '%f '];
            end
        end
        format = [format, ') '];
    else
        if j==7
            format = [format, '( '];
            for ids=1:10 %find a better way to read the correct amount of ids even if changing
                format = [format, '%d '];
            end
            format = [format, ') '];
        else
            if j==8
                format = [format, '%f '];
            else
                
                format = [format, '%*s '];
            end
        end
    end
end

format = [format, ' %d) '];

% parse file into an array of cells. As all file lines (L lines) have the same
% format, textscan parses the j_th matched elements of every line into one
% single cell C(1,j) = matrix(Lx1).
C    = textscan(fid, format);
% 2nd column is defined as C{1,2} and will be a column vector of
% timestamps.
time = C{1, 2};
bodyparts    = cell2mat(C(1, 3    :6)); % 4 columns of bodyparts value
cop   = cell2mat(C(1, 7:7+n-1)); % n columns of "center of pressure" value
force   = cell2mat(C(1, 7+n:7+2*n-1)); % n columns of "force" value
torque  = cell2mat(C(1, 7+2*n:7+3*n-1)); % n columns of "torque" value
geomCenter   = cell2mat(C(1, 7+3*n:7+4*n-1)); % n columns of "geometric center" value
normalDirection  = cell2mat(C(1, 7+4*n:7+5*n-1)); % n columns of "normal direction " value
% the rest of the message is discarded it includes skin taxel ids ,
% pressure, link name , frame name , forceTorqueConfidence


[tu,iu] = unique(time);
time              = tu';
bodyparts         = bodyparts(iu, :)';
cop               = cop(iu, :)';
force             = force(iu, :)';
torque            = torque(iu, :)';
geomCenter        = geomCenter(iu, :)';
normalDirection   = normalDirection(iu, :)';
wrench=[force;torque];

if fclose(fid) == -1
   error('[ERROR] there was a problem in closing the file')
end