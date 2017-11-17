function [H]=iCubVizAndForcesSynchronized(dataset,robotName,sensorsToAnalize,fixedFrame,n)
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
prefixOn=true; % true if in test directory
if prefixOn
 currentDir=pwd;
 cd ('../')
end
addpath external/iCubViz

% take joints till 23th joint to avoid the neck joints
dataset.qj(:,1:23);

%selecting which ft Data to plot
if (any(strcmp('ftDataNoOffset', fieldnames(dataset))))
    whichFtData='ftDataNoOffset';
else
    if (any(strcmp('filteredFtData', fieldnames(dataset))))
        whichFtData='filteredFtData';
    else
        whichFtData='ftData';
    end
end

 if (any(strcmp('estimatedFtData', fieldnames(dataset))))
     estimatedAvailable=true;
 else
     estimatedAvailable=false;     
 end

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
viz3 = iDynTree.Visualizer();
viz3.init();
viz3.addModel(model,'icub');
viz3.draw();

%camara positioning
cPos=iDynTree.Position(-1,-1,1.5); %depends on the initial position of the reference frame. Root link has a -x direction 
viz3.camera().setPosition(cPos);
%% Setting axis and handlers for forces plots
figure,
for indx=1:length(sensorsToAnalize)
    ft =sensorsToAnalize{indx};
    H.(ft).sub=subplot(length(sensorsToAnalize),1,indx);
    H.(ft).old=plot3(0,0,0); hold on;
    H.(ft).old2=plot3(0,0,0);
    
    %get axis values
    if estimatedAvailable
        minF=[min(dataset.(whichFtData).(ft));
            min(dataset.estimatedFtData.(ft))];
        maxF=[max(dataset.(whichFtData).(ft));
            max(dataset.estimatedFtData.(ft))];
        
        minF=min(minF);
        maxF=max(maxF);
    else
        minF=min(dataset.(whichFtData).(ft));
        maxF=max(dataset.(whichFtData).(ft));
    end
      
    
    tempMax=max(abs(minF-maxF));
    H.(ft).minMaxForces=[minF(1),minF(1)+tempMax,minF(2),minF(2)+tempMax,minF(3),minF(3)+tempMax];
    %H.(ft).minMaxForces=[minF(1),maxF(1),minF(2),maxF(2),minF(3),maxF(3)];
    
    axis(H.(ft).minMaxForces);
    %axis equal;
end
%% Start variables for viz

jointPos = iDynTree.JointPosDoubleArray(model);
     joints = dataset.qj(i,1:23)';
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

%% Plot and visualize at each time sample
init_time = 1;
  %create view vector for rotating the view on the plot figure
  % 360 is a full turn default view starts at -37.5  322.5
nViews= round(length(dataset.qj(:,1))-init_time)/n;
views=-37.5:720/nViews:682.5;
for i=init_time:n:length(dataset.qj(:,1));
    tic
     
       
       
     joints = dataset.qj(i,1:23)';
    jointPos.fromMatlab(joints);
    
%      odom.updateKinematics(jointPos);
%     odom.init(fixedFrame,fixedFrame);
  
    %viz3.modelViz(0).setPositions(odom.getWorldLinkTransform(model.getDefaultBaseLink()),jointPos);
    viz3.modelViz(0).setPositions(baseT,jointPos);
    viz3.draw();
    t = toc;
    
    for indx=1:length(sensorsToAnalize)
        ft =sensorsToAnalize{indx};
        subplot( H.(ft).sub)
        h= plot3_matrix(dataset.(whichFtData).(ft)(1:i,1:3),'r');%
        hold on;
        delete(H.(ft).old);
        H.(ft).old=h;
        if estimatedAvailable
            h2= plot3_matrix(dataset.estimatedFtData.(ft)(1:i,1:3),'b');
            delete(H.(ft).old2);
            H.(ft).old2=h2;
            legend('measuredData','estimatedData','Location','west');
        else
            legend('measuredData','Location','west');
        end
        title(strcat({'Wrench space '},escapeUnderscores(ft)));
        xlabel('F_{x}');
        ylabel('F_{y}');
        zlabel('F_{z}');
        axis(H.(ft).minMaxForces);
        %axis equal;
        grid on;
        axis equal;
        view(views(round(i/n)+1),30);
        drawnow;
        F(i) = getframe(gcf);
    end
    %pause(max(0,0.01-t))
    
end

%make the video of the plot.
v = VideoWriter('forces.avi');
open(v);
for k = init_time:n:length(dataset.qj(:,1));
  writeVideo(v,F(k));
end
close(v);

if prefixOn
 cd ( currentDir)
end