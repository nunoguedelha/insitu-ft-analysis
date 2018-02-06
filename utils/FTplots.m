function []=FTplots(data,time,varargin)
% This function plots the information received from an FT sensor be it the wrenches or the raw data.
% It assumes wrenches are in a double matrix (time x wrench), wrench [F,T]
% The x axis is the relative time of the experiment. This means it
% considers the first sample as time 0 always.
%% inputs
% data: the actual information of the sensor
% time: a vector the same size as the rows of data containing the timestamp
% varargin: this allows to receive multiple configuration parameters.
%  if varargin is a string it assumes it is one of the configuration
%  variables otherwise it assumes that is the desired name for the
%  reference data
%  if varagin is a struct it assumes is another set of FT sensor data that
%  will be used to compare the main data information
%% configurations
%  onlyFOrce: if enabled it will only plot the forces (first 3 columns)
%  raw: if enabled it will change the legends to reflect the raw channels
%  (channel swap considered due to IIT firmware)
%  byChannel: if enable it will generate a different plot for every axis or
%  channel.
onlyForce=false;
raw=false;
byChannel=false;
reference={};
referenceName='reference';
if (length(varargin)==1)
    if(ischar(  varargin{1}))
        switch varargin{1}
            case {'onlyForce','OnlyForce','onlyforce'}
                onlyForce=true;
            case {'raw','Raw','RAW'}
                raw=true;
            case {'byChannel','ByChannel','bychannel'}
                byChannel=true;
            otherwise
                warning('Unexpected option going by default options.')
        end
    end
    if(isstruct(varargin{1}))
        reference=varargin{1};
    end
else
    if (length(varargin)>1 && length(varargin)<6)
        for count=1:length(varargin)
            if(ischar(  varargin{count}))
                switch varargin{count}
                    case {'onlyForce','OnlyForce','onlyforce'}
                        onlyForce=true;
                    case {'raw','Raw','RAW'}
                        raw=true;
                    case {'byChannel','ByChannel','bychannel'}
                        byChannel=true;
                    otherwise
                        referenceName=varargin{count};
                end
            else
                if(isstruct(varargin{count}))
                    reference=varargin{count};
                else
                    warning('Not an option for FTplots. Ignored');
                end
            end
        end
    end
end


xPlotOptions = 'r.';
yPlotOptions = 'g.';
zPlotOptions = 'b.';
x2PlotOptions = 'm.';
y2PlotOptions = 'y.';
z2PlotOptions = 'c.';

timeStampinit=time(1);
fields=fieldnames(data);

if (size(fields,1)==2)
    temp.(fields{1})=data.(fields{1});
    reference.(fields{1})=data.(fields{2});
    referenceName=(fields{2});
    %FTplots(temp,time,(fields{2}),reference);
end

if (~byChannel && isempty(reference))
    for i=1:size(fields,1)
         figure('WindowStyle','docked'),
        plot(time-timeStampinit,data.(fields{i})(:,1),xPlotOptions);hold on;
        plot(time-timeStampinit,data.(fields{i})(:,2),yPlotOptions);hold on;
        plot(time-timeStampinit,data.(fields{i})(:,3),zPlotOptions);hold on;
        if raw
            legend('ch4','ch5','ch6','Location','west');
        else
            legend('F_{x}','F_{y}','F_{z}','Location','west');
        end
        title(escapeUnderscores((fields{i})));
        xlabel('TimeStamp');
        ylabel('N');
    end
    if(~onlyForce)
        for  i=1:size(fields,1)
             figure('WindowStyle','docked'),
            plot(time-timeStampinit,data.(fields{i})(:,4),xPlotOptions);hold on;
            plot(time-timeStampinit,data.(fields{i})(:,5),yPlotOptions);hold on;
            plot(time-timeStampinit,data.(fields{i})(:,6),zPlotOptions);hold on;
            if raw
                legend('ch1','ch2','ch3','Location','west');
            else
                legend('\tau_{x}','\tau_{y}','\tau_{z}','Location','west');
            end
            title(escapeUnderscores((fields{i})));
            xlabel('TimeStamp');
            ylabel('Nm');
            
        end
    end
end

if (~isempty(reference) && ~byChannel)
    for i=1:size(fields,1)
         figure('WindowStyle','docked'),
        plot(time-timeStampinit,data.(fields{i})(:,1),xPlotOptions);hold on;
        plot(time-timeStampinit,data.(fields{i})(:,2),yPlotOptions);hold on;
        plot(time-timeStampinit,data.(fields{i})(:,3),zPlotOptions);hold on;
        plot(time-timeStampinit,reference.(fields{i})(:,1),x2PlotOptions);hold on;
        plot(time-timeStampinit,reference.(fields{i})(:,2),y2PlotOptions);hold on;
        plot(time-timeStampinit,reference.(fields{i})(:,3),z2PlotOptions);hold on;
        if raw
            legend('ch4','ch5','ch6','ch4_2','ch5_2','ch6_2','Location','west');
        else
            legend('F_{x}','F_{y}','F_{z}','F_{x2}','F_{y2}','F_{z2}','Location','west');
        end
        title(escapeUnderscores( strcat((fields{i}),{' and  '},referenceName)));
        xlabel('TimeStamp');
        ylabel('N');
    end
    if(~onlyForce)
        for  i=1:size(fields,1)
             figure('WindowStyle','docked'),
            plot(time-timeStampinit,data.(fields{i})(:,4),xPlotOptions);hold on;
            plot(time-timeStampinit,data.(fields{i})(:,5),yPlotOptions);hold on;
            plot(time-timeStampinit,data.(fields{i})(:,6),zPlotOptions);hold on;
            plot(time-timeStampinit,reference.(fields{i})(:,4),x2PlotOptions);hold on;
            plot(time-timeStampinit,reference.(fields{i})(:,5),y2PlotOptions);hold on;
            plot(time-timeStampinit,reference.(fields{i})(:,6),z2PlotOptions);hold on;
            if raw
                legend('ch1','ch2','ch3','ch1_2','ch2_2','ch3_2','Location','west');
            else
                legend('\tau_{x}','\tau_{y}','\tau_{z}','\tau_{x2}','\tau_{y2}','\tau_{z2}','Location','west');
            end
            title(escapeUnderscores( strcat((fields{i}),{' and  '},referenceName)));
            xlabel('TimeStamp');
            ylabel('Nm');
            
        end
    end
    for  i=1:size(fields,1)
         figure('WindowStyle','docked'),
        plot(time-timeStampinit,abs(data.(fields{i})(:,1))-abs(reference.(fields{i})(:,1)),xPlotOptions);hold on;
        plot(time-timeStampinit,abs(data.(fields{i})(:,2))-abs(reference.(fields{i})(:,2)),yPlotOptions);hold on;
        plot(time-timeStampinit,abs(data.(fields{i})(:,3))-abs(reference.(fields{i})(:,3)),zPlotOptions);hold on;
        if raw
            legend('ch4','ch5','ch6','Location','west');
        else
            legend('F_{x}','F_{y}','F_{z}','Location','west');
        end
        title(escapeUnderscores( strcat((fields{i}),{' -  '},referenceName)));
        xlabel('TimeStamp');
        ylabel('N');
    end
    if(~onlyForce)
        for  i=1:size(fields,1)
             figure('WindowStyle','docked'),
            plot(time-timeStampinit,abs(data.(fields{i})(:,4))-abs(reference.(fields{i})(:,4)),xPlotOptions);hold on;
            plot(time-timeStampinit,abs(data.(fields{i})(:,5))-abs(reference.(fields{i})(:,5)),yPlotOptions);hold on;
            plot(time-timeStampinit,abs(data.(fields{i})(:,6))-abs(reference.(fields{i})(:,6)),zPlotOptions);hold on;
            if raw
                legend('ch1','ch2','ch3','Location','west');
            else
                legend('\tau_{x}','\tau_{y}','\tau_{z}','Location','west');
            end
            title(escapeUnderscores( strcat((fields{i}),{' -  '},referenceName)));
            xlabel('TimeStamp');
            ylabel('Nm');
        end
    end
end

if (byChannel)
    if raw
        legendNames={'ch4','ch5','ch6','ch1','ch2','ch3'};
    else
        legendNames={'F_{x}','F_{y}','F_{z}','\tau_{x}','\tau_{y}','\tau_{z}'};
    end
    if onlyForce
        count=3;
    else
        count=6;
    end
    for i=1:size(fields,1)
        for n=1:count
             figure('WindowStyle','docked'),
            plot(time-timeStampinit,data.(fields{i})(:,n),xPlotOptions);
            if ~isempty(reference)
                hold on; plot(time-timeStampinit,reference.(fields{i})(:,n),zPlotOptions);
                legend((legendNames{n}),strcat((legendNames{n}),'_2'));
                title(strcat((legendNames{n}),{' : '},escapeUnderscores((fields{i})),{' and  '},escapeUnderscores(referenceName)));
            else
                legend((legendNames{n}));
                title(strcat((legendNames{n}),{' : '},escapeUnderscores((fields{i})),(legendNames{n})));
            end           
            
            xlabel('TimeStamp');
            if n<4
                ylabel('N');
            else
                ylabel('Nm');
            end
        end
    end
end