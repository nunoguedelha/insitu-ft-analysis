function [dataset]=estimateDynamicsUsingIntervals(dataset,estimator,input,useInertial)
%% Manage intervals
if (any(strcmp('intervals', fieldnames(input))))
    intervalsNames=fieldnames(input.intervals);
    if(~isempty(intervalsNames))        
        if (any(strcmp('hanging', intervalsNames)) && isfield(dataset,'inertialData'))
            mask=dataset.time>=dataset.time(1)+input.intervals.hanging.initTime & dataset.time<=dataset.time(1)+input.intervals.hanging.endTime;
            fprintf('estimateDynamicsUsingIntervals: estimating interval hanging with contact frame %s from %d s to %d s \n',input.intervals.hanging.contactFrame,input.intervals.hanging.initTime,input.intervals.hanging.endTime);
            [inertialEstimatedFtData]=obtainEstimatedWrenches(estimator,dataset.time,{input.intervals.hanging.contactFrame},dataset,mask,dataset.inertialData);
            
            inertial.ftData=inertialEstimatedFtData.ftData;
            inertial.time=inertialEstimatedFtData.time;
            
            sensorNames=fieldnames(inertialEstimatedFtData.estimatedFtData);
            % match field names with sensor loaded through readDataDumper
            %
            matchup=zeros(size(input.sensorNames,1),1);
            for i=1:size(input.sensorNames,1)
                matchup(i) = find(strcmp(sensorNames, input.sensorNames{i}));
            end
            %replace the estored estimatedFtData for one with the same order as the
            %ftData
            for i=1:size(input.ftNames,1)
                inertial.estimatedFtData.(input.ftNames{i})=inertialEstimatedFtData.estimatedFtData.(sensorNames{matchup(i)});
            end
            
        end
        %% This part of code needs to be revised copied from previous version of read estimate experiment enables converting to an array of contact frames it might allow to have a continuos experiment without necesarily separating calculation of external forces by support contact
        %%mask=dataset.time<0;
        %             contactFrameName='';
        %             for index=1:length(intervalsNames)
        %                 if(~strcmp('hanging', intervalsNames{index}))
        %                     intName=intervalsNames{index};
        %                     maskTemp=dataset.time>=dataset.time(1)+input.intervals.(intName).initTime & dataset.time<=dataset.time(1)+input.intervals.(intName).endTime;
        %                     contactTemp(1:length(find(maskTemp)))={input.intervals.(intName).contactFrame};
        %                     mask=or(mask,maskTemp);
        %
        %                     %TODO: have to match the contactFrame vectors with the time
        %                     %the interval happens (compare init time of all intervals
        %                     %to order it
        %                     % contactFrameName=[contactFrameName,contactTemp];
        %                     contactFrameName=[contactTemp,contactFrameName];
        %                 end
        %
        %             end
        %
        %             dataset=applyMask(dataset,mask);
        for index=1:length(intervalsNames)
            
            if(~strcmp('hanging', intervalsNames{index}))
                intName=intervalsNames{index};
                mask=dataset.time>=dataset.time(1)+input.intervals.(intName).initTime & dataset.time<=dataset.time(1)+input.intervals.(intName).endTime;
                fprintf('estimateDynamicsUsingIntervals: estimating interval %s with contact frame %s from %d s to %d s \n',(intName),input.intervals.(intName).contactFrame,input.intervals.(intName).initTime,input.intervals.(intName).endTime);
            
                if (useInertial && isfield(dataset,'inertialData'))
                    disp('estimateDynamicsUsingIntervals: using floating base for estimation');
                    [dataset2]=obtainEstimatedWrenches(estimator,dataset.time,{input.intervals.(intName).contactFrame},dataset,mask,dataset.inertialData);
                else
                    disp('estimateDynamicsUsingIntervals: using fixed base for estimation');
                    [dataset2]=obtainEstimatedWrenches(estimator,dataset.time,{input.intervals.(intName).contactFrame},dataset,mask);
                end
                sensorNames=fieldnames(dataset2.estimatedFtData);
                
                % match field names with sensor loaded through readDataDumper
                matchup=zeros(size(input.sensorNames,1),1);
                for i=1:size(input.sensorNames,1)
                    matchup(i) = find(strcmp(sensorNames, input.sensorNames{i}));
                end
                
                %replace the estored estimatedFtData for one with the same order and name as the
                %ftData
                for i=1:size(input.ftNames,1)
                    estimatedFtData.(input.ftNames{i})=dataset2.estimatedFtData.(sensorNames{matchup(i)});
                end
                dataset2.estimatedFtData=estimatedFtData;
                
                if (any(strcmp('hanging', intervalsNames)))
                    if(strcmp('hanging', intervalsNames{index-1}))
                        data=dataset2;
                    end
                else
                    if (length(intervalsNames)==1)
                        data=dataset2;
                    else
                        if (input.intervals.(intervalsNames{index-1}).initTime<input.intervals.(intName).initTime)
                            data=addDatasets(data,dataset2);
                        else
                            data=addDatasets(dataset2,data);
                        end
                    end
                end
            end
        end
        dataset=data;
        
        if (any(strcmp('hanging', intervalsNames)))
            dataset.inertial=inertial;
        end
    else
        disp('estimateDynamicsUsingIntervals: intervals is empty avoiding all estimation');
    end    
else
    disp('estimateDynamicsUsingIntervals: input.intervals needs to exist to estimate, no estimation has been done');
end