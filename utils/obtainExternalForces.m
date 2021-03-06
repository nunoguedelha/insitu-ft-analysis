function [externalWrenches,time,jointTorques]= obtainExternalForces(robotName,dataset,secMat,sensorNames,contactFrameName,timeFrame,framesNames,offset,varargin)
%% Check varargin
useInertial=false;
if(~isempty(varargin))
    if (length(varargin)<3)
        if (length(varargin)==1) % it means mask available
            if (islogical(varargin{1}))
                mask=varargin{1};                
                if(size(mask)==size(resampledTime))
                    dataset=applyMask(dataset,mask);
                    resampledTime=applyMask(resampledTime,mask);
                else
                    disp('Mask is the wrong size');
                end
            else
                if(isstruct(varargin{1}))
                    inertialData=varargin{1};
                    inertialFields=fieldnames(inertialData);
                    if(length(inertialFields)==2)
                        useInertial=true;
                    else
                        disp('Error! Expected inertial data that has only 2 fields');
                    end
                else
                    disp('Not valid argument');
                end
            end
        end
        if (length(varargin)==2) % it means inertial data is provided
            if (islogical(varargin{1}))
                mask=varargin{1};
                if(size(mask)==size(resampledTime))
                    dataset=applyMask(dataset,mask);
                    resampledTime=applyMask(resampledTime,mask);
                else
                    disp('Mask is the wrong size');
                end
            end
            if(isstruct(varargin{2}))
                inertialData=varargin{2};
                inertialFields=fieldnames(inertialData);
                if(length(inertialFields)==2)
                    useInertial=true;
                else
                    disp('Error! Expected inertial data that has only 2 fields');
                end
            end
        end
        
    else
        disp('Too many arguments, check what you are sending (extra parameters ignored)')
    end
end

%% resize data to desired timeFrame
   mask=dataset.time>dataset.time(1)+timeFrame(1) & dataset.time<dataset.time(1)+timeFrame(2);
        dataset=applyMask(dataset,mask);
%TODO: might be easier to just get the indexes of the time start and finish
%of the time frame and just take those values for t
%% Load the estimator

% Create estimator class
estimator = iDynTree.ExtWrenchesAndJointTorquesEstimator();

% Load model and sensors from the URDF file
estimator.loadModelAndSensorsFromFile(strcat('./robots/',robotName,'.urdf'));

% Check if the model was correctly created by printing the model
%estimator.model().toString()

%store number of sensors
nrOfFTSensors = estimator.sensors().getNrOfSensors(iDynTree.SIX_AXIS_FORCE_TORQUE);

%For more info on iCub frames check: http://wiki.icub.org/wiki/ICub_Model_naming_conventions
grav_idyn = iDynTree.Vector3();
grav = [0.0;0.0;-9.81];
grav_idyn.fromMatlab(grav);
wrench_idyn= iDynTree.Wrench();
qj_all=dataset.qj;
dqj_all=dataset.dqj;
ddqj_all=dataset.ddqj;
if (useInertial)
    angVel_idyn = iDynTree.Vector3();
    angAcc_idyn = iDynTree.Vector3();
end
if (length(contactFrameName)==1)
% Set the contact information in the estimator
disp(strcat('using contact frame ',char(contactFrameName)));
contact_index = estimator.model().getFrameIndex(char(contactFrameName));
end

% The estimated FT sensor measurements
estFTmeasurements = iDynTree.SensorsMeasurements(estimator.sensors());

%% We can use the same class also for performing external wrenches estimation,
%% assuming that calibrated (i.e. without offset) F/T sensor measurements are available
%% For the sake of the example, we use the same FT measurements estimated, but
%% if actual FT sensor measurements were available we could set them in the SensorsMeasurements
%% object by calling the setMeasurements method.

% We first need a new set of unknowns, as we now need 7 unknown wrenches, one for
% each submodel in the estimator
fullBodyUnknownsExtWrenchEst = iDynTree.LinkUnknownWrenchContacts(estimator.model());

% We could fill this automatically, but in this example is interesting to have full control
% of the frames in which this wrenches are expressed (to see the link and frames of a model,
% just type idyntree-model-info -m nameOfUrdfFile.urdf -p in a terminal 

% % Foot contacts
% fullBodyUnknownsExtWrenchEst.addNewUnknownFullWrenchInFrameOrigin(estimator.model(),estimator.model().getFrameIndex('l_sole'));
% fullBodyUnknownsExtWrenchEst.addNewUnknownFullWrenchInFrameOrigin(estimator.model(),estimator.model().getFrameIndex('r_sole'));
% 
% % Knee contacts
% fullBodyUnknownsExtWrenchEst.addNewUnknownFullWrenchInFrameOrigin(estimator.model(),estimator.model().getFrameIndex('l_lower_leg'));
% fullBodyUnknownsExtWrenchEst.addNewUnknownFullWrenchInFrameOrigin(estimator.model(),estimator.model().getFrameIndex('r_lower_leg'));
% 
% % Contact on the central body
% fullBodyUnknownsExtWrenchEst.addNewUnknownFullWrenchInFrameOrigin(estimator.model(),estimator.model().getFrameIndex('root_link'));
% 
% % Contacts on the hands
% fullBodyUnknownsExtWrenchEst.addNewUnknownFullWrenchInFrameOrigin(estimator.model(),estimator.model().getFrameIndex('l_elbow_1'));
% fullBodyUnknownsExtWrenchEst.addNewUnknownFullWrenchInFrameOrigin(estimator.model(),estimator.model().getFrameIndex('r_elbow_1'));
% %
% framesNames={'l_sole','r_sole','l_lower_leg','r_lower_leg','root_link','l_elbow_1','r_elbow_1'};
for frame=1:length(framesNames) 
    fullBodyUnknownsExtWrenchEst.addNewUnknownFullWrenchInFrameOrigin(estimator.model(),estimator.model().getFrameIndex(framesNames{frame}));
end

% We also need to allocate the output of the estimation: a class for estimated contact wrenches and one for joint torques
dofs = estimator.model().getNrOfDOFs();
qj_idyn   = iDynTree.JointPosDoubleArray(dofs);
dqj_idyn  = iDynTree.JointDOFsDoubleArray(dofs);
ddqj_idyn = iDynTree.JointDOFsDoubleArray(dofs);
% The estimated external wrenches
estContactForcesExtWrenchesEst = iDynTree.LinkContactWrenches(estimator.model());

% The estimated joint torques
estJointTorquesExtWrenchesEst = iDynTree.JointDOFsDoubleArray(dofs);

%match names of sensors
for ftIndex = 0:(nrOfFTSensors-1)
    sens = estimator.sensors().getSensor(iDynTree.SIX_AXIS_FORCE_TORQUE,ftIndex).getName();
    matchup(ftIndex+1) = find(strcmp(sensorNames,sens ));
end

sNames=fieldnames(dataset.ftData);
sensorsToAnalize=fieldnames(secMat);

%size of array with the expected Data
ftData=zeros(length(framesNames),size(dataset.time,1),6);
jointTorques=zeros(size(qj_all));
%% For each time instant
fprintf('obtainedExternalForces: Computing the estimated wrenches\n');
for t=1:length(dataset.time)
    tic 
    qj=qj_all(t,:);
    dqj=dqj_all(t,:);
    ddqj=ddqj_all(t,:);
    
    
    qj_idyn.fromMatlab(qj);
    dqj_idyn.fromMatlab(dqj);
    ddqj_idyn.fromMatlab(ddqj);
    
    if(length(contactFrameName)>1)
        contact_index = estimator.model().getFrameIndex(char(contactFrameName(t)));
    end
    
    % print progress test 
    if( mod(t,10000) == 0 ) 
        fprintf('obtainedExternalForces: process the %d sample out of %d\n',t,length(dataset.time))
    end
     % store the estimated measurements
    for ftIndex = 0:(nrOfFTSensors-1)
       sIndx= find(strcmp(sensorsToAnalize,sNames(matchup(ftIndex+1))));
       
        if(~isempty(sIndx))
        wrench_idyn.fromMatlab( secMat.(sensorsToAnalize{sIndx})*dataset.ftData.(sNames{matchup(ftIndex+1)})(t,:)'+offset.(sNames{matchup(ftIndex+1)}));
        else
        wrench_idyn.fromMatlab( dataset.ftData.(sNames{matchup(ftIndex+1)})(t,:)'+offset.(sNames{matchup(ftIndex+1)}));
        end
        ok = estFTmeasurements.setMeasurement(iDynTree.SIX_AXIS_FORCE_TORQUE,ftIndex,wrench_idyn);
        
    end
    if (useInertial)
        grav_idyn.fromMatlab(inertialData.linAcc(t,:));
        angVel_idyn.fromMatlab(inertialData.angVel(t,:));
        angAcc_idyn.fromMatlab([0;0;0]);
        % Set the kinematics information in the estimator
        ok = estimator.updateKinematicsFromFloatingBase(qj_idyn,dqj_idyn,ddqj_idyn,contact_index,grav_idyn,angVel_idyn,angAcc_idyn);
        
    else
        ok = estimator.updateKinematicsFromFixedBase(qj_idyn,dqj_idyn,ddqj_idyn,contact_index,grav_idyn);
    end
% Now we can call the estimator
estimator.estimateExtWrenchesAndJointTorques(fullBodyUnknownsExtWrenchEst,estFTmeasurements,estContactForcesExtWrenchesEst,estJointTorquesExtWrenchesEst);
     

% We can now print the estimated external forces : as the FT sensor measurements where estimated
% under the assumption that the only external wrench is acting on the left foot, we should see
% that the only non-zero wrench is the one on the left foot (frame: l_sole)
% fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
% fprintf('External wrenches estimated using the F/T offset computed in the previous step\n');
% fprintf('%s',estContactForcesExtWrenchesEst.toString(estimator.model()));

% Wrenches values can easily be obtained as matlab vectors
%estContactForcesExtWrenchesEst.contactWrench(estimator.model().getLinkIndex('l_foot'),0).contactWrench().getLinearVec3().toMatlab()


% LinkContactWrenches is a structure that can contain multiple contact wrench for each link,
% but usually is convenient to just deal with a collection of net wrenches for each link
linkNetExtWrenches = iDynTree.LinkWrenches(estimator.model());%
estContactForcesExtWrenchesEst.computeNetWrenches(linkNetExtWrenches);

for i=1:length(framesNames)
wrench = linkNetExtWrenches(estimator.model().getFrameLink(estimator.model().getFrameIndex(framesNames{i})));
%wrench.toMatlab();
ftData(i,t,:)=wrench.toMatlab();
end 
    jointTorques(t,:)=estJointTorquesExtWrenchesEst.toMatlab();
end
for i=1:length(framesNames)
    
   externalWrenches.(framesNames{i})=squeeze(ftData(i,:,:));
end
time=dataset.time;
