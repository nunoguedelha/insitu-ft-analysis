function [ftData] = resampleFt(t, ts, data)

ftData(:,1) = interp1(ts, data(:,1)  , t)';
ftData(:,2) = interp1(ts, data(:,2)  , t)';
ftData(:,3) = interp1(ts, data(:,3)  , t)';
ftData(:,4) = interp1(ts, data(:,4)  , t)';
ftData(:,5) = interp1(ts, data(:,5)  , t)';
ftData(:,6) = interp1(ts, data(:,6)  , t)';

end