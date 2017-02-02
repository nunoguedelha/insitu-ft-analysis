function []=iCubVizJointPos(q,robotName,fixedFrame)
%Author: Francisco Andrade
%% This function has the aim of been able to see the icub posture while seen the devolpment of the ft forces in the wrench space
%Input
% dataset: has the joint and forces information
% robotName: is used to load the robot model to know which joints to add the
% visualization part, it is asumed its the same type of robot than the one found in
% model.urdf
%sensorsToAnalize: is to plot only the relevant sensors
%fixedFrame: is to give a reference for the visualizer which frame is fixed
%TODO: a way to add also the reference from world to fixed frame
%Outuput
%H: struct containing the plots handlers with their axis
%Remark: install also the irrlicht library (sudo apt install
%libirrlicht-dev ) required , and enable the `IDYNTREE_USES_MATLAB` and `IDYNTREE_USES_IRRLICHT`

addpath external/iCubViz

%% Getting names to put into visualizer
% Create estimator class
estimator = iDynTree.ExtWrenchesAndJointTorquesEstimator();

% Load model and sensors from the URDF file
estimator.loadModelAndSensorsFromFile(strcat('./',robotName,'.urdf'));

dofs = estimator.model().getNrOfDOFs();
consideredJoints = iDynTree.StringVector();
for i=0:dofs-4 %-4 ensures avoiding the 3 last neck joints
    %for i=0:dofs-1
    % disp(strcat('name=',estimator.model().getJointName(i),' , index=',num2str(i)))
    names{i+1}=estimator.model().getJointName(i);
    
    consideredJoints.push_back( (names{i+1}));
end
%% set iCubViz variables

mdlLdr = iDynTree.ModelLoader();
mdlLdr.loadReducedModelFromFile(strcat('external/iCubViz/','model.urdf'),consideredJoints);
model = mdlLdr.model();
%
viz = iDynTree.Visualizer();
viz.init();
viz.addModel(model,'icub');
viz.draw();

%camara positioning
cPos=iDynTree.Position(-1,-1,1.5); %depends on the initial position of the reference frame. Root link has a -x direction 
viz.camera().setPosition(cPos);

%% Start variables for viz
tic
jointPos = iDynTree.JointPosDoubleArray(model);
     joints = q(1:23)';
    jointPos.fromMatlab(joints);
    
    
  % Assuming that the l_sole frame is fixed and it is the world, compute the
    % world_H_base that correspond to the specified joints
    odom = iDynTree.SimpleLeggedOdometry();
    odom.setModel(model);
    %odom.init(fixedFrame,'r_sole');
     odom.updateKinematics(jointPos);
    odom.init(fixedFrame,fixedFrame);
    baseT=odom.getWorldLinkTransform(model.getDefaultBaseLink());
    pos = iDynTree.Position();
    pos.fromMatlab([0;0;0.5]);
    baseT.setPosition(pos);

     
    %viz.modelViz(0).setPositions(odom.getWorldLinkTransform(model.getDefaultBaseLink()),jointPos);
    viz.modelViz(0).setPositions(baseT,jointPos);
    viz.draw();
    t = toc;
    pause()
viz.close()