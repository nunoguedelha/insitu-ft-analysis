function []=FTplots(data,time)
%Function to plot data from FT sensors
%data is a struct type which includes data with sets wrenches 
%for which two different figures will be created
%It assumes wrenches are in a double matrix (time x wrench), wrench [F,T] 

xPlotOptions = 'r.';
yPlotOptions = 'g.';
zPlotOptions = 'b.';

timeStampinit=time(1);
fields=fieldnames(data);
for i=1:size(fields,1) 
figure,
plot(time-timeStampinit,data.(fields{i})(:,1),xPlotOptions);hold on;
plot(time-timeStampinit,data.(fields{i})(:,2),yPlotOptions);hold on;
plot(time-timeStampinit,data.(fields{i})(:,3),zPlotOptions);hold on;
legend('Fx','Fy','Fz','Location','west');
title((fields{i}));
xlabel('TimeStamp');
ylabel('N');
end

for  i=1:size(fields,1)
figure,
plot(time-timeStampinit,data.(fields{i})(:,4),xPlotOptions);hold on;
plot(time-timeStampinit,data.(fields{i})(:,5),yPlotOptions);hold on;
plot(time-timeStampinit,data.(fields{i})(:,6),zPlotOptions);hold on;
legend('Tx','Ty','Tz','Location','west');
title((fields{i}));
xlabel('TimeStamp');
ylabel('Nm');

end

%if (mod(size(fields,1),2)==0)
if (size(fields,1)==2)
    for i=1:2:size(fields,1)-1
        figure,
        plot(time-timeStampinit,data.(fields{i})(:,1),xPlotOptions);hold on;
        plot(time-timeStampinit,data.(fields{i})(:,2),yPlotOptions);hold on;
        plot(time-timeStampinit,data.(fields{i})(:,3),zPlotOptions);hold on;
        plot(time-timeStampinit,data.(fields{i+1})(:,1),xPlotOptions);hold on;
        plot(time-timeStampinit,data.(fields{i+1})(:,2),yPlotOptions);hold on;
        plot(time-timeStampinit,data.(fields{i+1})(:,3),zPlotOptions);hold on;
        legend('Fx','Fy','Fz','Fx2','Fy2','Fz2','Location','west');
        title(strcat((fields{i}),' and','  ',(fields{i+1})));
        xlabel('TimeStamp');
        ylabel('N');
    end
    
    for  i=1:2:size(fields,1)-1
        figure,
        plot(time-timeStampinit,data.(fields{i})(:,4),xPlotOptions);hold on;
        plot(time-timeStampinit,data.(fields{i})(:,5),yPlotOptions);hold on;
        plot(time-timeStampinit,data.(fields{i})(:,6),zPlotOptions);hold on;
        plot(time-timeStampinit,data.(fields{i+1})(:,4),xPlotOptions);hold on;
        plot(time-timeStampinit,data.(fields{i+1})(:,5),yPlotOptions);hold on;
        plot(time-timeStampinit,data.(fields{i+1})(:,6),zPlotOptions);hold on;
        legend('Tx','Ty','Tz','Tx2','Ty2','Tz2','Location','west');
        title(strcat((fields{i}),' and  ',(fields{i+1})));
        xlabel('TimeStamp');
        ylabel('Nm');
        
    end
    for  i=1:2:size(fields,1)-1
        figure,
        plot(time-timeStampinit,data.(fields{i})(:,1)-data.(fields{i+1})(:,1),xPlotOptions);hold on;
        plot(time-timeStampinit,data.(fields{i})(:,2)-data.(fields{i+1})(:,2),yPlotOptions);hold on;
        plot(time-timeStampinit,data.(fields{i})(:,3)-data.(fields{i+1})(:,3),zPlotOptions);hold on;
        legend('Fx','Fy','Fz','Location','west');
        title(strcat((fields{i}),' vs  ',(fields{i+1})));
        xlabel('TimeStamp');
        ylabel('N');
    end
    
    for  i=1:2:size(fields,1)-1
        figure,
        plot(time-timeStampinit,data.(fields{i})(:,4)-data.(fields{i+1})(:,4),xPlotOptions);hold on;
        plot(time-timeStampinit,data.(fields{i})(:,5)-data.(fields{i+1})(:,5),yPlotOptions);hold on;
        plot(time-timeStampinit,data.(fields{i})(:,6)-data.(fields{i+1})(:,6),zPlotOptions'.');hold on;
        legend('Tx','Ty','Tz','Location','west');
        title(strcat((fields{i}),' vs  ',(fields{i+1})));
        xlabel('TimeStamp');
        ylabel('Nm');
    end
end