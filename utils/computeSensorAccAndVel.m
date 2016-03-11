function [ datasetArg ] = computeSensorAccAndVel( datasetArg   )
%computeSensorAccAndVel compute the sensor spatial body acceleration and
%velocity 
%   

%% Allocate the model with the desired degrees of freedom 
estimator = iDynTree.ExtWrenchesAndJointTorquesEstimator();
estimator.loadModelAndSensorsFromFile('./iCubGenova02.urdf');
model = estimator.model();
traversal = iDynTree.Traversal();
model.computeFullTreeTraversal(traversal);

linkAccs = iDynTree.LinkAccArray(model);
linkVels = iDynTree.LinkVelArray(model);

jointPos = iDynTree.JointPosDoubleArray(model);
jointVel = iDynTree.JointDOFsDoubleArray(model);
jointAcc = iDynTree.JointDOFsDoubleArray(model);

nrOfDOFsFullModel = model.getNrOfDOFs();

qjFullModel = zeros(nrOfDOFsFullModel,1);
dqjFullModel = zeros(nrOfDOFsFullModel,1);
d2qjFullModel = zeros(nrOfDOFsFullModel,1);


% zero the joint that we don't use 
jointPos.zero();
jointVel.zero();
jointAcc.zero();

zeroVec3 = iDynTree.Vector3();
zeroVec3.zero();

baseProperAcceleration = iDynTree.Vector3();
baseProperAcceleration.fromMatlab([0.0 0.0 9.81]);

baseGravity = iDynTree.Vector3();
baseGravity.fromMatlab([0.0 0.0 -9.81]);

nrOfSamples = length(datasetArg.time);

% We fill a nice map between the indices of the joint that we consider 
% in this experiment (0-5) and the joint in the full model
nrOfJointsInReducedModel = size(datasetArg.jointNames,2);
reduced2full = zeros(nrOfJointsInReducedModel,1);
for jnt = 1:nrOfJointsInReducedModel
    reduced2full(jnt) = model.getJointIndex(datasetArg.jointNames{jnt})+1;
end

datasetArg.vel = zeros(nrOfSamples,6);
datasetArg.acc = zeros(nrOfSamples,6);
datasetArg.ftCAD = zeros(nrOfSamples,6);

ftLinkIndex = model.getLinkIndex('r_upper_arm');
baseIndex = model.getLinkIndex('root_link');
ftSensorIndex = estimator.sensors().getSensorIndex(iDynTree.SIX_AXIS_FORCE_TORQUE,'r_arm_ft_sensor');

% We need to set the location of the unknown wrench. We express the unknown
% wrench at the origin of the l_sole frame
unknownWrench = iDynTree.UnknownWrenchContact();
unknownWrench.unknownType = iDynTree.FULL_WRENCH;

% the position is the origin, so the conctact point wrt to l_sole is zero
unknownWrench.contactPoint.zero();

% The fullBodyUnknowns is a class storing all the unknown external wrenches
% acting on a class
fullBodyUnknowns = iDynTree.LinkUnknownWrenchContacts(estimator.model());
fullBodyUnknowns.clear();

fullBodyUnknowns.addNewContactInFrame(estimator.model(),baseIndex,unknownWrench);

% The estimated FT sensor measurements
estFTmeasurements = iDynTree.SensorsMeasurements(estimator.sensors());

% The estimated joint torques
estJointTorques = iDynTree.JointDOFsDoubleArray(estimator.model());

% The estimated contact forces
estContactForces = iDynTree.LinkContactWrenches(estimator.model());

for sample = 1:nrOfSamples
    % update the full model state 
    for jnt = 1:6
        qjFullModel(reduced2full(jnt))  = datasetArg.q(sample,jnt);
        dqjFullModel(reduced2full(jnt)) = datasetArg.dq(sample,jnt);
        d2qjFullModel(reduced2full(jnt)) = datasetArg.d2q(sample,jnt);
    end
    
    jointPos.fromMatlab(qjFullModel);
    jointVel.fromMatlab(dqjFullModel);
    jointAcc.fromMatlab(d2qjFullModel);
    
    % run forward kinematics 
    iDynTree.dynamicsEstimationForwardVelAccKinematics(model,traversal,baseProperAcceleration,zeroVec3,zeroVec3,jointPos,jointVel,jointAcc,linkVels,linkAccs);
    
    datasetArg.vel(sample,:) = linkVels.paren(ftLinkIndex).toMatlab();
    datasetArg.acc(sample,:) = linkAccs.paren(ftLinkIndex).toMatlab();

    % We also estimate the FT measurement to check the model 
    estimator.updateKinematicsFromFixedBase(jointPos,jointVel,jointAcc,baseIndex,baseGravity);
    
    estimator.computeExpectedFTSensorsMeasurements(fullBodyUnknowns,estFTmeasurements,estContactForces,estJointTorques);

    estimatedSensorWrench = iDynTree.Wrench();
    estFTmeasurements.getMeasurement(iDynTree.SIX_AXIS_FORCE_TORQUE,ftSensorIndex,estimatedSensorWrench);
    
    datasetArg.ftCAD(sample,:) = -estimatedSensorWrench.toMatlab();
    
    % We also estimate the FT measurement without gravity, to access the
    % dynamic effects 
    estimator.updateKinematicsFromFixedBase(jointPos,jointVel,jointAcc,baseIndex,zeroVec3);
    
    estimator.computeExpectedFTSensorsMeasurements(fullBodyUnknowns,estFTmeasurements,estContactForces,estJointTorques);

    estimatedSensorWrench = iDynTree.Wrench();
    estFTmeasurements.getMeasurement(iDynTree.SIX_AXIS_FORCE_TORQUE,ftSensorIndex,estimatedSensorWrench);
    
    datasetArg.ftCADnoGrav(sample,:) = -estimatedSensorWrench.toMatlab();

end

% we also compute the parameters for the subtree attached to the ft sensor 
% we exploit the existing CRBA algorithm that already computes the
% composite rigid body inertia for each link 
crbis = iDynTree.LinkInertias(model);
massMatrix = iDynTree.FreeFloatingMassMatrix(model);

% run CRBA 
iDynTree.CompositeRigidBodyAlgorithm(model,traversal,jointPos,crbis,massMatrix);
datasetArg.CADparams = crbis.paren(ftLinkIndex).asVector().toMatlab();

end

