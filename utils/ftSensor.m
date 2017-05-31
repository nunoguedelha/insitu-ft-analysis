%requires utils from insitu-ft-analysis to be in the path
classdef ftSensor
    properties
        rMatrix %rotation matrix, rotation usually around the z axis due to a difference required in the mounting of the sensor
        data %actual force torque data
        name %which type of sensor is it (ftsense, ATI, optoForce, AME )
        technology % silicon strain gauge, metalic foil, optical
        time %time of the data
        fData %filtered data using sgolay
        cMatrix %calibration matrix of the sensor
        rData %raw data
        offset% offset of the sensor also called bias, can be used for zeroing
        fullscale% the full scale of the sensor
    end
    methods
        %constructor
        function obj=ftSensor(varargin)
            if nargin>0
                if nargin==2
                    obj.name=varargin{1};
                    obj.technology=varargin{2};
                    
                end
                
                
                if nargin==4
                    obj.name=varargin{1};
                    obj.technology=varargin{2};
                    if isa(varargin{3},'numeric')
                        if(size( varargin{3},2)==6)
                            obj.data=varargin{3};
                        else
                            error('Data provided is not a the right size (should have 6 columns)')
                        end
                        
                    end
                    if isa(varargin{4},'numeric')
                        if(size( varargin{3},1)==length( varargin{4}))
                            obj.time=varargin{4};
                        else
                            error('Time provided should have the same amount of rows as ftData')
                        end
                    end
                end
                
                if nargin~=4
                    error('Expecting either  (sensorName,technology,data,time)')
                end
            end
            obj.rMatrix=eye(3,3);
        end
        
        
        %gets the data but premultiplies by the rotation matrix
        function data= getData(obj)
            data=obj.data;% times the rotationMatrix or the rMatrix should go to constructor?
            
        end
        
        %gets the data without the offset
        function data= getDataNoOffset(obj)
            %TODO: should generalize what the offset is in case of insitu is + in
            %case of others is -
            data=obj.data-repmat(obj.offset,size(obj.data,1),1);%  data - offset
            % data=obj.data+repmat(obj.offset,size(obj.data,1),1);%  data + offset
        end
        
        %filters the data using sgolay filter, can be forced to filter
        %again
        function fData=filterData(obj,varargin)
            if nargin==2
                if islogical(varargin{1})
                    forced=varargin{1};
                else
                    disp('error variable not boolean')
                end
            else
                forced=false;
            end
            if (isempty(obj.fData) || forced)
                N=2;
                F=101;%size(obj.fData,1)/20; % would it be better to be proportional to the size of the dataset?
                filteredFtData=zeros(size(obj.fData));
                for channel=1:size(obj.data,2)
                    y = obj.data(:,channel);
                    nrOfSamples = length(obj.data);
                    [~,g] = sgolay(N,F);
                    HalfWin  = ((F+1)/2) -1;
                    
                    for n = (F+1)/2:nrOfSamples-(F+1)/2,
                        % Zeroth derivative (smoothing only)
                        filteredFtData(n,channel) = dot(g(:,1),y(n - HalfWin:n + HalfWin));
                    end
                end
                %mask= filteredFtData.(ftNames{i})(:,channel)~=0;
                obj.fData=filteredFtData;
            end
            fData=obj.fData;
        end
        
        %sampling to reduce the amount of data to be handled but keeps
        %original data
        function sData=sample(obj,N)
            [sData,~]= dataSampling(obj,N);
        end
        
        %resamples such that it matches the reference given time frame, it
        %keeps the changes in the object
        function obj=resample(obj,time)
            [ftData] = resampleFt(time, obj.time, obj.data);
            obj.data=ftData;
        end
        
        function obj=zeroing(obj)
            if ~isempty(obj.offset)
                obj.data=obj.data- repmat(obj.offset,size(obj.data,1),1);
            else
                error('Can not apply zeroing when offset is empty, set offset first');
            end
        end
        
        function obj=recalibrate(obj,sMat,direct)
            if direct %can be premultiplied directly
                for j=1:size(obj.data,1)
                    obj.data(j,:)=sMat*(obj.data(j,:)'+obj.offset');
                end
                obj.offset=sMat*obj.offset';
                obj.offset=obj.offset';
                obj=zeroing(obj);
                
            else % assuming this a totally different calibration matrix
                if ~isempty(obj.cMatrix) % if the calibration matrix is available
                    smat=sMat/obj.cMatrix; %calculate the required matrix to premultiply to recalibrate data
                    obj=recalibrate(obj,smat,true);
                else
                    if ~isempty(obj.rData) % if the raw data is available
                        %it is assumed the raw data has no offset removal
                        %required to be considered
                        for j=1:size(obj.rData,1)
                            obj.data(j,:)=sMat*(obj.rData(j,:)');
                        end
                    else
                        error('There is no calibration matrix inserted or raw data to work with, not enough information to recalibrate');
                    end
                end
                
            end
        end
    end
end