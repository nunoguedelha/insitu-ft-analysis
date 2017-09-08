function [data, time] = readTorqueData(s)

allData = load(s);
time = allData(:,2);
data = allData(:,4:end);
