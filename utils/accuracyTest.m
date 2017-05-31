classdef accuracyTest
   properties
   sensor=ftSensor; %and array containing the sensor data and info to compare in the test
   number % number of the test in the benchmark
   groundTruth % groundTruth used to compare the sensors
   name %if there is a name for the test it might be used for plotting
   meanVal % mean value of the test
   stdVal % standard deviation from the test
   errorVal % groundtruth-meanVal
   benchInfo % infor required to get the groundtruth for this kind of test (values of the calibration cross)
   end
    methods
        function obj=accuracyTest(varargin)
            if nargin>0
                if nargin==1
                    if isa(varargin{1},'ftSensor')
                        obj.sensor=varargin{1};
                        obj.meanVal= mean(obj.sensor.data);
                            obj.stdVal= std(obj.sensor.data);
                    end
                    
                    if isa(varargin{1},'numeric')
                        obj.benchInfo= varargin{1};
                    end
                    
                    obj.number=1;
                    obj.name='test1';
                else
                    if nargin==3
                        obj.number=varargin{1};
                        obj.groundTruth=varargin{2};
                        obj.name=strcat('test',num2str(varargin{1}));
                        obj.benchInfo= varargin{3};
                    end
                    
                    if nargin==4
                        obj.number=varargin{1};
                        obj.groundTruth=varargin{2};
                        if isa(varargin{3},'ftSensor')
                            obj.sensor=varargin{3};
                            obj.name=strcat('test',num2str(varargin{1}));
                            
                            obj.meanVal= mean(obj.sensor.data);
                            obj.stdVal= std(obj.sensor.data);
                            obj.errorVal= obj.groundTruth- obj.meanVal;
                            
                        else
                            if ( isa(varargin{3},'char') || isa(varargin{3},'cell'))
                                obj.name=varargin{3};
                            end
                        end
                        obj.benchInfo= varargin{4};
                    end
                    if nargin ~=3 && nargin~=4
                        error('Expecting either testedSensor(testNumber,groundtruth,benchInfo), testedSensor(testNumber,groundtruth,ftSensor,benchInfo) or testedSensor(testNumber,groundtruth,testName,benchInfo)')
                    end
                end
            else
                obj.number=0;
                obj.name='default';
            end
        end
        
        function [std,error,coeffVar]=getComparisonValues(obj)
            std=obj.stdVal;
            error=obj.errorVal;
            coeffVar=obj.stdVal./obj.meanVal; %coefficient of variation (adimensional)
        end
        
        function [forceMagnitude]=getForceMagnitude(obj)
            forceMagnitude=norm(obj.meanVal(1:3));
        end
        
        function [obj]=evaluateTest(obj)
            obj.meanVal= mean(obj.sensor.data);
            obj.stdVal= std(obj.sensor.data);
            if ~isempty(obj.groundTruth)
                obj.errorVal= obj.groundTruth- obj.meanVal;
            end
        end
       
    end
    
end