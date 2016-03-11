function [ a_g ] = gravityInFrame( q, linkName )
% Get the gravity in the specified frame
%   

%% Allocate the model with the desired degrees of freedom 
estimator = iDynTree.ExtWrenchesAndJointTorquesEstimator();
estimator.loadModelAndSensorsFromFile('./iCubGenova02.urdf');
model = estimator.model();
traversal = iDynTree.Traversal();
model.computeFullTreeTraversal(traversal);

model.toString()

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


% We fill a nice map between the indices of the joint that we consider 
% in this experiment (0-5) and the joint in the full model
jointNames = { 'r_shoulder_pitch', 'r_shoulder_roll', 'r_shoulder_yaw'}
nrOfJointsInReducedModel = size(jointNames,2);
reduced2full = zeros(nrOfJointsInReducedModel,1);
for jnt = 1:nrOfJointsInReducedModel
    reduced2full(jnt) = model.getJointIndex(jointNames{jnt})+1;
end

ftLinkIndex = model.getLinkIndex(linkName);


    % update the full model state 
    for jnt = 1:nrOfJointsInReducedModel
        qjFullModel(reduced2full(jnt))  = q(jnt);
    end
    
    qjFullModel
    
    jointPos.fromMatlab(qjFullModel);
    jointVel.fromMatlab(dqjFullModel);
    jointAcc.fromMatlab(d2qjFullModel);
    
    % run forward kinematics 
    iDynTree.dynamicsEstimationForwardVelAccKinematics(model,traversal,baseProperAcceleration,zeroVec3,zeroVec3,jointPos,jointVel,jointAcc,linkVels,linkAccs);
    
    a_g = linkAccs.paren(ftLinkIndex).toMatlab();

end

