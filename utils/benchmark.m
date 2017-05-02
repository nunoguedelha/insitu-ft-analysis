classdef benchmark
    properties
        tests=accuracyTest; % matrix that contains a trial/test structure where row is the test number and column is the position of the sensor in the fielnames of sensors structure
        sensors=struct([]); %and array containing all the sensors to compare in the test
        name=blanks(1); % name of the benchmark
        n % number of tests
        testPlots=false; % boolean for ploting all the individual tests
        plots=false; % booelan for plotting general plots
    end
    methods
        function obj=benchmark(varargin)
            if nargin>0
                
                
            end
        end
        
        function obj=fillTestsFromAllData(obj,allData,allTimes,sensors,bias)
            sNames=fieldnames(sensors);
            allDNames=fieldnames(allData.(sNames{1}));
            rows=length(allDNames)-length(bias);
            columns=length(sNames);
            obj.n=rows; %assumes first data is to be used to estimate bias
            obj.tests(rows,columns)=accuracyTest();
            obj.sensors=sensors;
            
            for i=1:columns
                B=obj.groundtruth(sensors.(sNames{i}).benchInfo);
                testNumber=0;
                nb=1;
                nextBias=1;
                for j=1:length(allDNames)
                    if j==nextBias
                        currentBias=mean(allData.(sNames{i}).(allDNames{j}));
                        nb=nb+1;
                        if(nb<=length(bias))
                            nextBias=bias(nb);
                        end
                    else
                        testNumber=testNumber+1;
                        tempSensor=ftSensor(sensors.(sNames{i}).name,sensors.(sNames{i}).technology,...
                            allData.(sNames{i}).(allDNames{j}),allTimes.(sNames{i}).(allDNames{j})); %create temporal sensor
                        tempSensor.offset=currentBias; %set bias for this test
                        tempSensor=zeroing(tempSensor); % remove bias
                        obj.tests(testNumber,i)=accuracyTest(testNumber,B(testNumber,:),tempSensor,sensors.(sNames{i}).benchInfo);
                        
                    end
                end
                
            end
            
            
        end
        
        function [mostAccurate,mostPrecise,stds,errors]=compareTest(obj,testNumber)
            %mostAccurate,mostPrecise are 1x2 vectors in which first column
            %is for forces and second is for torques
           numberSensors=size(obj.tests,2);
            stds=zeros(6,numberSensors); %rows=axis, column = sensor
            errors=zeros(6,numberSensors);%rows=axis, column = sensor
            for i=1:numberSensors
            [stds(:,i),errors(:,i)]=getComparisonValues( obj.tests(testNumber,i));
            end
            [~,mostPrecise]=min(sum(stds(1:3,:)));
             [~,mostPrecise(2)]=min(sum(stds(4:6,:)));
              [~,mostAccurate]=min(sum(errors(1:3,:).^2));
               [~,mostAccurate(2)]=min(sum(errors(4:6,:).^2));
            
               if (obj.testPlots)
                   [sNames]=getSensorNames (obj,testNumber);
                   figure,
                   bar(sum(stds));
                   title('Std');
                   set(gca,'xticklabel',sNames)
                   
                   figure,
                   bar(sum(errors(1:3,:).^2));
                   title('Squared Error in Forces');
                   set(gca,'xticklabel',sNames)
                    
                   figure,
                   bar(sum(errors(4:6,:).^2));
                   title('Squared Error in Torques');
                   set(gca,'xticklabel',sNames)
                   
                   
               end
        end
        
        function [results]=compareAllTests(obj)
            for i=1:obj.n
                [mostAccurate(i,:),mostPrecise(i,:),stds(i,:,:),errors(i,:,:)]=compareTest(obj,i);
                
            end
             modeAcc=mode(mostAccurate);
             modePrec=mode(mostPrecise);
             for axis=1:6
             [bestStdbyAxis(axis),precisebyAxis(axis)]=min(sum(stds(:,axis,:)));
              [minErrorbyAxis(axis),accuratebyAxis(axis)]=min(sum(errors(:,axis,:).^2));
             end
             
             forceErrorTotal=squeeze( sum(sum(errors(:,1:3,:).^2)));
             torqueErrorTotal=squeeze(sum(sum(errors(:,4:6,:).^2)));
             
               [~,mostPrec]=min(sum(sum(stds(:,1:3,:))));
             [~,mostPrec(2)]=min(sum(sum(stds(:,4:6,:))));
              [~,mostAcc]=min(forceErrorTotal);
               [~,mostAcc(2)]=min(torqueErrorTotal);
             
             results.modeAcc=modeAcc;
             results.modePrec=modePrec;
             results.bestStdbyAxis=bestStdbyAxis./obj.n;
             results.precisebyAxis=precisebyAxis;
             results.minErrorbyAxis=minErrorbyAxis./obj.n;
             results.accuratebyAxis=accuratebyAxis;
             results.errors=errors;
             results.stds=stds;
             results.mostAccurate=mostAcc;
             results.mostPrecise=mostPrec;
             
             if (obj.plots)
                 [sNames]=getSensorNames (obj,1);
                 figure,
                 bar(squeeze(sum(sum(stds))));
                 title('Std');
                 set(gca,'xticklabel',sNames)
                 
                 figure,
                 bar(forceErrorTotal);
                 title('Squared Error in Forces');
                 set(gca,'xticklabel',sNames)
                 
                 figure,
                 bar(torqueErrorTotal);
                 title('Squared Error in Torques');
                 set(gca,'xticklabel',sNames)
                
             end
             
        end
        
        function [ellipsoids]=checkSphereBehaviour(obj,heavy)
            % To visualize the data, we split the B load data in two sets: the one
            % with 5 kg data, and the one with 25 kg data.
             F1 = 5.2; %need to weight weights with the long structure to verify, long piece alone is 300gr the old one 345gr the new one
            F2 = 25.2;
            sNames=fieldnames(obj.sensors);
            for i=1:length(sNames)
                B=obj.groundtruth(obj.sensors.(sNames{i}).benchInfo);
                if heavy
                    loads = 5:12;
                    subB = B(loads,:);
                    acc = subB(:,1:3)/F2;
                    titles=strcat(sNames{i} ,' Heavy weights sphere');
                else
                    loads = [1:4,13:24];
                    subB = B(loads,:);
                    acc = subB(:,1:3)/F1;
                    titles=strcat(sNames{i} ,' Light weights sphere');
                end
                 sensorData=zeros(length(loads),6);
                for j=1:length(loads)
                   sensorData(j,:)= obj.tests(loads(j),i).meanVal;
                    
                end
                
                ellipsoids.(sNames{i}).data=sensorData(:,1:3);
                % do some nice plots on the forces
                ellipsoids.(sNames{i}).implicit=ellipsoidfit_smart(sensorData(:,1:3),acc);
               ellipsoids.(sNames{i}).groundtruth=ellipsoidfit_smart(subB(:,1:3),acc);
                
                if obj.plots
                  ellipsoids.(sNames{i}).handle=figure;
                  plot3_matrix(sensorData(:,1:3),'b.'); hold on;
                  %  plot_ellipsoid_im(ellipsoids.(sNames{i}).implicit,'EdgeColor',rand(1,3));
                    plot_ellipsoid_im(ellipsoids.(sNames{i}).implicit,'EdgeColor','k'); hold on;
                    plot_ellipsoid_im(ellipsoids.(sNames{i}).groundtruth,'EdgeColor','m');  hold on;
                     axis equal;
                     title(titles);
                end
                
            end
        end
        
        function [names,plotString]=getSensorNames(obj,testNumber)
            plotString=blanks(1);
            for i=1:size(obj.tests,2)
                names(i)={obj.tests(testNumber,i).sensor.name};
                plotString=strcat(plotString,escapeUnderscores(names(i)),',');
            end
        end
        
        function [sphereFunction]=sphere()
        end
        
    end
        methods (Static)
        function B=groundtruth(benchInfo)
            %  BENCHFUNCTION function which gives the ground truth of the benchmark
            a=benchInfo(1);
            b=benchInfo(2);
            c=benchInfo(3);
            d=benchInfo(4);
            F1 = 5.2; %need to weight weights with the long structure to verify, long piece alone is 300gr the old one 345gr the new one
            F2 = 25.2;
            
            % known loads array
%             B =  [
%                 0.0 ,   0.0 ,  F1  , -F1 * a ,  0.0    ,  0.0    ; %  5 kg on y- (1  *
%                 0.0 ,   0.0 ,  F1  ,  0.0    , -F1 * a ,  0.0    ; %  5 kg on x+ (2  *
%                 0.0 ,   0.0 ,  F1  ,  F1 * a ,  0.0    ,  0.0    ; %  5 kg on y+ (3  *
%                 0.0 ,   0.0 ,  F1  ,  0.0    ,  F1 * a ,  0.0    ; %  5 kg on x- (4
%                 % axis x+ pointing up
%                 -F1  ,   0.0 ,  0.0 ,  0.0    , -F1 * d , -F1 * b ; % 5 kg on y-  (5
%                 -F1  ,   0.0 ,  0.0 ,  0.0    , -F1 * c ,  0.0    ; % 5 kg on z+  (6
%                 -F1  ,   0.0 ,  0.0 ,  0.0    , -F1 * d ,  F1 * b ; % 5 kg on y+  (7
%                 % axis y+ pointing up
%                 0.0 ,  -F1  ,  0.0 ,  F1 * d ,  0.0    , -F1 * b ; % 5 kg on x+  (8   *
%                 0.0 ,  -F1  ,  0.0 ,  F1 * c ,  0.0    ,  0.0    ; % 5 kg on z+  (9
%                 0.0 ,  -F1  ,  0.0 ,  F1 * d ,  0.0    ,  F1 * b ; % 5 kg on x-  (10  *
%                 % axis x- pointing up
%                 F1  ,   0.0 ,  0.0 ,  0.0    ,  F1 * d , -F1 * b ; % 5 kg on y+  (11
%                 F1  ,   0.0 ,  0.0 ,  0.0    ,  F1 * c ,  0.0    ; % 5 kg on z+ (12  *
%                 F1  ,   0.0 ,  0.0 ,  0.0    ,  F1 * d ,  F1 * b ; % 5 kg on y-  (13
%                 % axis y- pointing up
%                 0.0 ,   F1  ,  0.0 , -F1 * d ,  0.0    , -F1 * b ; % 5 kg on x- (14
%                 0.0 ,   F1  ,  0.0 , -F1 * c ,  0.0    ,  0.0    ; % 5 kg on z+ (15
%                 0.0 ,   F1  ,  0.0 , -F1 * d ,  0.0    ,  F1 * b ; % 5 kg on x+  (16
%                 % heavy loads on strain gauges axes
%                 0.0 ,   0.0 , -F2  ,  0.0    ,  0.0    ,  0.0    ; % 25 kg on z-    (17  *
%                 0.0 ,   0.0 ,  F2  ,  0.0    ,  0.0    ,  0.0    ; % 25 kg on z+   (18  *
%                 -F2  ,   0.0 ,  0.0 ,  0.0    , -F2 * d ,  0.0    ; % 25 kg on x+ strain gauge axis 1  (19
%                 F2  ,   0.0 ,  0.0 ,  0.0    ,  F2 * d ,  0.0    ; % 25 kg on x- strain gauge axis 1  (20
%                 F2 * cos(pi/3)    ,  F2 * sin(pi/3)    ,  0.0  , -F2 * sin(pi/3) * d    ,  F2 * cos(pi/3) * d    ,  0.0  ;    % 25 kg on strain gauge axis 2  (21  *
%                 F2 * cos(-2*pi/3) ,  F2 * sin(-2*pi/3) ,  0.0  , -F2 * sin(-2*pi/3) * d ,  F2 * cos(-2*pi/3) * d ,  0.0  ;    % 25 kg on strain gauge axis 2  (22  *
%                 F2 * cos(-pi/3)   ,  F2 * sin(-pi/3)   ,  0.0  , -F2 * sin(-pi/3) * d   ,  F2 * cos(-pi/3) * d   ,  0.0  ;    % 25 kg on strain gauge axis 3  (23  *
%                 F2 * cos(2*pi/3)  ,  F2 * sin(2*pi/3)  ,  0.0  , -F2 * sin(2*pi/3) * d  ,  F2 * cos(2*pi/3) * d  ,  0.0  ;    % 25 kg on strain gauge axis 3  (24  *
%                 ];
            
%this might be order from the protocol
 B =  [
                0.0 ,   0.0 ,  F1  , -F1 * a ,  0.0    ,  0.0    ; %  5 kg on y- (1  *
                0.0 ,   0.0 ,  F1  ,  0.0    , -F1 * a ,  0.0    ; %  5 kg on x+ (2  *
                0.0 ,   0.0 ,  F1  ,  F1 * a ,  0.0    ,  0.0    ; %  5 kg on y+ (3  *
                0.0 ,   0.0 ,  F1  ,  0.0    ,  F1 * a ,  0.0    ; %  5 kg on x- (4
                 % heavy loads on strain gauges axes
                0.0 ,   0.0 ,  F2  ,  0.0    ,  0.0    ,  0.0    ; % 25 kg on z+   (18  *
                0.0 ,   0.0 , -F2  ,  0.0    ,  0.0    ,  0.0    ; % 25 kg on z-    (17  *
                -F2  ,   0.0 ,  0.0 ,  0.0    , -F2 * d ,  0.0    ; % 25 kg on x+ strain gauge axis 1  (19
                F2  ,   0.0 ,  0.0 ,  0.0    ,  F2 * d ,  0.0    ; % 25 kg on x- strain gauge axis 1  (20
                F2 * cos(pi/3)    ,  F2 * sin(pi/3)    ,  0.0  , -F2 * sin(pi/3) * d    ,  F2 * cos(pi/3) * d    ,  0.0  ;    % 25 kg on strain gauge axis 2  (21  *
                F2 * cos(-2*pi/3) ,  F2 * sin(-2*pi/3) ,  0.0  , -F2 * sin(-2*pi/3) * d ,  F2 * cos(-2*pi/3) * d ,  0.0  ;    % 25 kg on strain gauge axis 2  (22  *
                F2 * cos(-pi/3)   ,  F2 * sin(-pi/3)   ,  0.0  , -F2 * sin(-pi/3) * d   ,  F2 * cos(-pi/3) * d   ,  0.0  ;    % 25 kg on strain gauge axis 3  (23  *
                F2 * cos(2*pi/3)  ,  F2 * sin(2*pi/3)  ,  0.0  , -F2 * sin(2*pi/3) * d  ,  F2 * cos(2*pi/3) * d  ,  0.0  ;    % 25 kg on strain gauge axis 3  (24  *
                % axis x+ pointing up
                -F1  ,   0.0 ,  0.0 ,  0.0    , -F1 * d , -F1 * b ; % 5 kg on y-  (5
                -F1  ,   0.0 ,  0.0 ,  0.0    , -F1 * c ,  0.0    ; % 5 kg on z+  (6
                -F1  ,   0.0 ,  0.0 ,  0.0    , -F1 * d ,  F1 * b ; % 5 kg on y+  (7
                % axis y+ pointing up
                0.0 ,  -F1  ,  0.0 ,  F1 * d ,  0.0    , -F1 * b ; % 5 kg on x+  (8   *
                0.0 ,  -F1  ,  0.0 ,  F1 * c ,  0.0    ,  0.0    ; % 5 kg on z+  (9
                0.0 ,  -F1  ,  0.0 ,  F1 * d ,  0.0    ,  F1 * b ; % 5 kg on x-  (10  *
                % axis x- pointing up
                F1  ,   0.0 ,  0.0 ,  0.0    ,  F1 * d , -F1 * b ; % 5 kg on y+  (11
                F1  ,   0.0 ,  0.0 ,  0.0    ,  F1 * c ,  0.0    ; % 5 kg on z+ (12  *
                F1  ,   0.0 ,  0.0 ,  0.0    ,  F1 * d ,  F1 * b ; % 5 kg on y-  (13
                % axis y- pointing up
                0.0 ,   F1  ,  0.0 , -F1 * d ,  0.0    , -F1 * b ; % 5 kg on x- (14
                0.0 ,   F1  ,  0.0 , -F1 * c ,  0.0    ,  0.0    ; % 5 kg on z+ (15
                0.0 ,   F1  ,  0.0 , -F1 * d ,  0.0    ,  F1 * b ; % 5 kg on x+  (16
               ];


            B = B * 9.81;       % multiply the loads for the gravitational acceleration
            
        end
        
      
     end
end

