function [externalWrenches,jointTorques]=estimateTorquesOneSample(estimator,q,dq,ddq,externalWrench,useSkin,input,ftData,framesNames,offset)
% OBTAINESTIMATEDWRENCH Get (model) estimated wrenches for a iCub dataset
%   estimator       : variable which contains the model of the robot
%   dataset         : contains the joint position velocities and
%   accelerations
%   resampleTime   : time that will be used as reference time
%   contactFrameName : the name of the frame on which it is assumed that an 
%                      external contact is (tipically the
%                      root_link, r_sole or l_sole)

%TODO: add contactInfo (which part of the robot is in contact) obtained from minimal knowledge on the FT sensors
% contactInfo should in the end have this information for every time step,
% for now assuming contact doesnt change% 


dofs = estimator.model().getNrOfDOFs();

grav_idyn = iDynTree.Vector3();
grav = [0.0;0.0;-9.81];
grav_idyn.fromMatlab(grav);

wrench_idyn= iDynTree.Wrench();
%store number of sensors
nrOfFTSensors = estimator.sensors().getNrOfSensors(iDynTree.SIX_AXIS_FORCE_TORQUE);

%% Specify unknown wrenches

% We need to set the location of the unknown wrench. For the time being it
% is assumed that the contact will not change 

unknownWrench = iDynTree.UnknownWrenchContact();

unknownWrench.unknownType = iDynTree.NO_UNKNOWNS;
% the position is the origin, so the conctact point wrt to l_sole is zero
unknownWrench.contactPoint.zero();

% The fullBodyUnknowns is a class storing all the unknown external wrenches
% acting on a class
fullBodyUnknowns = iDynTree.LinkUnknownWrenchContacts(estimator.model());
fullBodyUnknowns.clear();
contact_index = estimator.model().getLinkIndex(input.skinLinkFrame);
fullBodyUnknowns.addNewContactForLink(estimator.model(),contact_index,unknownWrench);

% Print the unknowns to make sure that everything is properly working
fullBodyUnknowns.toString(estimator.model())

% Prepare the datastructure that we used in the loop outside the loop 
% (to improve performances, as otherwise we allocate memory at each 
% loop step, and allocating memory is usually quite a slow operation) 
qj_idyn   = iDynTree.JointPosDoubleArray(dofs);
dqj_idyn  = iDynTree.JointDOFsDoubleArray(dofs);
ddqj_idyn = iDynTree.JointDOFsDoubleArray(dofs);

    
% The estimated FT sensor measurements
estFTmeasurements = iDynTree.SensorsMeasurements(estimator.sensors());
        


    %    % velocity and acceleration to 0 to prove if they are neglegible. (slow
    %    % experiment scenario)
    %     dqj=zeros(size(qj));
    %     ddqj=zeros(size(qj));
    
    qj_idyn.fromMatlab(q);
    dqj_idyn.fromMatlab(dq);
    ddqj_idyn.fromMatlab(ddq);
    
    if useSkin %TODO: input condition to select type of wrench     
        unknownWrench.knownWrench = externalWrench;
    else        
        unknownWrench.unknownType = iDynTree.FULL_WRENCH;
    end
    
    contact_index = estimator.model().getLinkIndex(input.skinLinkFrame);
fullBodyUnknowns.addNewContactForLink(estimator.model(),contact_index,unknownWrench);
    %% Run the prediction of FT measurements
    
    % There are three output of the estimation, FT measurements, contact 
    % forces and joint torques (they are declared outside the loop for 
    % performance reason)

for frame=1:length(framesNames) 
    fullBodyUnknowns.addNewUnknownFullWrenchInFrameOrigin(estimator.model(),estimator.model().getFrameIndex(framesNames{frame}));
end

% The estimated external wrenches
estContactForces = iDynTree.LinkContactWrenches(estimator.model());

% The estimated joint torques
estJointTorques = iDynTree.JointDOFsDoubleArray(dofs);

% Names of the ft Sensors
sNames=fieldnames(ftData);

%match names of sensors
for ftIndex = 0:(nrOfFTSensors-1)
    sens = estimator.sensors().getSensor(iDynTree.SIX_AXIS_FORCE_TORQUE,ftIndex).getName();
    matchup(ftIndex+1) = find(strcmp(input.sensorNames,sens ));
end

  % store the estimated measurements
    for ftIndex = 0:(nrOfFTSensors-1)   %TODO: how to get the offset used by wholebodydynamics or load the forces used by wbd
        wrench_idyn.fromMatlab(ftData.(sNames{matchup(ftIndex+1)})(:)'+offset.(sNames{matchup(ftIndex+1)}));        
        ok = estFTmeasurements.setMeasurement(iDynTree.SIX_AXIS_FORCE_TORQUE,ftIndex,wrench_idyn);
        
    end
 
    ok = estimator.updateKinematicsFromFixedBase(qj_idyn,dqj_idyn,ddqj_idyn,contact_index,grav_idyn);  
    
  
fprintf('obtainEstimatedWrenches: Computing the estimated torques\n');
    % Now we can call the estimator
estimator.estimateExtWrenchesAndJointTorques(fullBodyUnknownsExtWrenchEst,estFTmeasurements,estContactForces,estJointTorques);
     
linkNetExtWrenches = iDynTree.LinkWrenches(estimator.model());%
estContactForces.computeNetWrenches(linkNetExtWrenches);

for i=1:length(framesNames)
wrench = linkNetExtWrenches(estimator.model().getFrameLink(estimator.model().getFrameIndex(framesNames{i})));
%wrench.toMatlab();
wrenchEst(i,:)=wrench.toMatlab();
end 
    
for i=1:length(framesNames)
    
   externalWrenches.(framesNames{i})=squeeze(wrenchEst(i,:));
end

jointTorques=estJointTorques.toMatlab();

