   experimentName='icub-insitu-ft-analysis-big-datasets/2017_01_18/GreenRobotTests/Left_leg';

scriptOptions = {};
scriptOptions.forceCalculation=false;%false;
scriptOptions.printPlots=true;%true
scriptOptions.raw=false;
scriptOptions.saveData=true;
% Script of the mat file used for save the intermediate results 
scriptOptions.matFileName='dataEllipsoidAnalysis'; %newName
%scriptOptions.matFileName='datasetEllipsoidAnalys';
% [dataset]=read_estimate_experimentData2(experimentName,scriptOptions);
% % % load the script of parameters relative 
  load(strcat('../data/',experimentName,'/',scriptOptions.matFileName,'.mat'),'dataset')

 q_des=dataset.qj;
  q_meas=q_des;
 
 q_des=dataset.qj(:,1:23);

  % Create estimator class
    estimator = iDynTree.ExtWrenchesAndJointTorquesEstimator();
    
    % Load model and sensors from the URDF file
    estimator.loadModelAndSensorsFromFile(strcat('./','iCubGenova04','.urdf'));
    
     dofs = estimator.model().getNrOfDOFs();
   



mdlLdr = iDynTree.ModelLoader();
consideredJoints = iDynTree.StringVector();

     for i=0:dofs-4
 %for i=0:dofs-1
        % disp(strcat('name=',estimator.model().getJointName(i),' , index=',num2str(i)))
        names{i+1}=estimator.model().getJointName(i);
        
        consideredJoints.push_back( (names{i+1}));
    end

init_time = 1;
end_time = length(q_meas(:,1));


mdlLdr.loadReducedModelFromFile('model.urdf',consideredJoints);
model = mdlLdr.model();

%
viz3 = iDynTree.Visualizer();

%  work around 
viz3.init();
viz3.addModel(model,'icub');
viz3.draw();


cPos=iDynTree.Position(1,1,1.5);
viz3.camera().setPosition(cPos);
h_old=plot3(0,0,0);
h_old2=plot3(0,0,0);
axis([-75.1969   22.9577   -0.0001   97.5441  -17.4692   46.4963]);
for i=init_time:100:end_time
tic
%viz3.draw();

jointPos3 = iDynTree.JointPosDoubleArray(model);
joints3 = q_des(i,:)';
jointPos3.fromMatlab(joints3);

% Assuming that the l_sole frame is fixed and it is the world, compute the 
% world_H_base that correspond to the specified joints 
odom2 = iDynTree.SimpleLeggedOdometry();
odom2.setModel(model);
odom2.updateKinematics(jointPos3);
odom2.init('root_link','r_sole');
% odom2.init('l_sole','l_sole');

viz3.modelViz(0).setPositions(odom2.getWorldLinkTransform(model.getDefaultBaseLink()),jointPos3);

viz3.draw();
t = toc;


   ft = 'left_leg';
       h= plot3_matrix(dataset.filteredFtData.(ft)(1:i,1:3));%
        hold on;
      h2= plot3_matrix(dataset.estimatedFtData.(ft)(1:i,1:3));
        delete(h_old);
        h_old=h;
        delete(h_old2);
        h_old2=h2;
          legend('measuredData','estimatedData','Location','west');
        title(strcat({'Wrench space '},escapeUnderscores(ft)));
        xlabel('F_{x}');
        ylabel('F_{y}');
        zlabel('F_{z}');
        %axis equal;
        axis([-75.1969   22.9577   -0.0001   97.5441  -17.4692   46.4963]);
        grid on;
        drawnow;
%pause(max(0,0.01-t))

end
%%
% viz = iDynTree.Visualizer();
% 
% %  work around 
% viz.init();
% viz.draw();
% viz.addModel(model,'icub');
% 
% 
% for i=init_time: end_time
% tic
% %viz.draw();
% w_H_bin = w_H_b(:,:,i);
% pos = iDynTree.Position();
% pos.fromMatlab(w_H_bin(1:3,4));
% rot = iDynTree.Rotation();
% rot.fromMatlab(w_H_bin(1:3,1:3));
% world_H_base = iDynTree.Transform();
% world_H_base.setPosition(pos);
% world_H_base.setRotation(rot);
% 
% 
% jointPos = iDynTree.JointPosDoubleArray(model);
% joints = q_meas(i,:)';
% jointPos.fromMatlab(joints);
% 
% viz.modelViz(0).setPositions(world_H_base,jointPos);
% 
% viz.draw();
% t = toc;
% pause(max(0,0.01-t))
% end

