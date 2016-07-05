function [linAcc,angVel, time,euler,magnetic] = readInertial(s)
%The output consists in 12 double, organized as follows:

%    euler angles [3]: deg
%    linear acceleration [3]: m/s^2
%    angular speed [3]: deg/s (* see note1)
%    magnetic field [3]: arbitrary units 
[data, time] = readDataDumper(s);
euler=data(:,1:3);
linAcc=data(:,4:6);
angVel=data(:,7:9);
magnetic=data(:,10:12);