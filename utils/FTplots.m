function []=FTplots(data,time)
%Function to plot data from FT sensors
%data is a struct type which includes data with sets wrenches 
%for which two different figures will be created
%It assumes wrenches are in a double matrix (time x wrench), wrench [F,T] 

timeStampinit=time(1);
fields=fieldnames(data);
for i=1:size(fields,1) 
figure,
plot(time-timeStampinit,data.(fields{i})(:,1),'.');hold on;
plot(time-timeStampinit,data.(fields{i})(:,2),'.');hold on;
plot(time-timeStampinit,data.(fields{i})(:,3),'.');hold on;
legend('Fx','Fy','Fz','Location','west');
title((fields{i}));
xlabel('TimeStamp');
ylabel('N');
end

for  i=1:size(fields,1)
figure,
plot(time-timeStampinit,data.(fields{i})(:,4),'.');hold on;
plot(time-timeStampinit,data.(fields{i})(:,5),'.');hold on;
plot(time-timeStampinit,data.(fields{i})(:,6),'.');hold on;
legend('Tx','Ty','Tz','Location','west');
title((fields{i}));
xlabel('TimeStamp');
ylabel('Nm');

end
