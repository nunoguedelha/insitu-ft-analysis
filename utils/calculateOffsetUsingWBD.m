function [offset]=calculateOffsetUsingWBD(estimator,dataset,sampleInit,sampleEnd,input)
%% estimate ft to calculate offset used when starting wbd using iterative mean
sNames=fieldnames(dataset.ftData);
for n=1:length(sNames)        
    offset.(sNames{n})=[0;0;0;0;0;0];
end

% OBTAINESTIMATEDWRENCH Get (model) estimated wrenches for a iCub dataset
%   estimator       : variable which contains the model of the robot
%   dataset         : contains the joint position velocities and
%   accelerations
%   resampleTime   : time that will be used as reference time
%   contactFrameName : the name of the frame on which it is assumed that an
%                      external contact is (tipically the
%                      root_link, r_sole or l_sole)

% assuming contact doesnt change%
%% Prerpare joint variables

dofs = estimator.model().getNrOfDOFs();
grav_idyn = iDynTree.Vector3();
grav = [0.0;0.0;-9.81];
grav_idyn.fromMatlab(grav);


%    % velocity and acceleration to 0 to prove if they are neglegible. (slow
%    % experiment scenario)
%     dqj=zeros(size(qj));
%     ddqj=zeros(size(qj));

qj_idyn   = iDynTree.JointPosDoubleArray(dofs);
dqj_idyn  = iDynTree.JointDOFsDoubleArray(dofs);
ddqj_idyn = iDynTree.JointDOFsDoubleArray(dofs);




%% Prepare estimator variables
%store number of sensors
nrOfFTSensors = estimator.sensors().getNrOfSensors(iDynTree.SIX_AXIS_FORCE_TORQUE);

% The estimated FT sensor measurements
estFTmeasurements = iDynTree.SensorsMeasurements(estimator.sensors());

% The estimated external wrenches
estContactForces = iDynTree.LinkContactWrenches(estimator.model());

% The estimated joint torques
estJointTorques = iDynTree.JointDOFsDoubleArray(dofs);

%match names of sensors
for ftIndex = 0:(nrOfFTSensors-1)
    sens = estimator.sensors().getSensor(iDynTree.SIX_AXIS_FORCE_TORQUE,ftIndex).getName();
    matchup(ftIndex+1) = find(strcmp(input.sensorNames,sens ));
end

 estimator.model().toString();
%% Iterate over joint positions from sample Init to sample End
for sample=sampleInit:sampleEnd
    
    q=dataset.qj(sample,:);
    dq=zeros(size(dataset.dqj(sample,:)));
    ddq=dataset.ddqj(sample,:);
    
    qj_idyn.fromMatlab(q);
    dqj_idyn.fromMatlab(dq);
    ddqj_idyn.fromMatlab(ddq);
    
    %% Update robot kinematics
    
      
    
    disp(strcat('using contact frame ',char(input.contactFrameName)));
    % Set the contact information in the estimator
    contact_index = estimator.model().getFrameIndex(char(input.contactFrameName));
    ok = estimator.updateKinematicsFromFixedBase(qj_idyn,dqj_idyn,ddqj_idyn,contact_index,grav_idyn);
    
    
    
    %% Specify unknown wrenches
    
    % We need to set the location of the unknown wrench. For the time being it
    % is assumed that the contact will not change
    
    unknownWrench = iDynTree.UnknownWrenchContact();
    %% Run the prediction of FT measurements
    
    % There are three output of the estimation, FT measurements, contact
    % forces and joint torques (they are declared outside the loop for
    % performance reason)
    
    fullBodyUnknowns = iDynTree.LinkUnknownWrenchContacts(estimator.model());
    fullBodyUnknowns.clear();
    unknownWrench.unknownType = iDynTree.FULL_WRENCH;
    %fullBodyUnknowns.addNewContactForLink(contact_index,unknownWrench);
    fullBodyUnknowns.addNewContactInFrame(estimator.model(),contact_index,unknownWrench);
    % Print the unknowns to make sure that everything is properly working
    %fullBodyUnknowns.toString(estimator.model())
    % Sensor wrench buffer
    estimatedSensorWrench = iDynTree.Wrench();
    % run the estimation
    
    estimator.computeExpectedFTSensorsMeasurements(fullBodyUnknowns,estFTmeasurements,estContactForces,estJointTorques);
    
    % store the estimated measurements
    for ftIndex = 0:(nrOfFTSensors-1)
        ok = estFTmeasurements.getMeasurement(iDynTree.SIX_AXIS_FORCE_TORQUE,ftIndex,estimatedSensorWrench);
        estimatedFT.(sNames{matchup(ftIndex+1)})=estimatedSensorWrench.toMatlab()';
    end
    %estimatedFT
    
    %% Calculate offset with iterative mean
    count=sample-sampleInit+1;
    for n=1:length(sNames)
       
        offset.(sNames{n})=((count-1)/count)*offset.(sNames{n}) + (1/count)*(estimatedFT.(sNames{n})-dataset.ftData.(sNames{n})(sample,:))';
       
    end
    
    
end