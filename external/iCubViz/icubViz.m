mdlLdr = iDynTree.ModelLoader();
consideredJoints = iDynTree.StringVector();
consideredJoints.push_back('torso_pitch');
consideredJoints.push_back('torso_roll');
consideredJoints.push_back('torso_yaw');
consideredJoints.push_back('l_shoulder_pitch');
consideredJoints.push_back('l_shoulder_roll');
consideredJoints.push_back('l_shoulder_yaw');
consideredJoints.push_back('l_elbow');
consideredJoints.push_back('r_shoulder_pitch');
consideredJoints.push_back('r_shoulder_roll');
consideredJoints.push_back('r_shoulder_yaw');
consideredJoints.push_back('r_elbow');
consideredJoints.push_back('l_hip_pitch');
consideredJoints.push_back('l_hip_roll');
consideredJoints.push_back('l_hip_yaw');
consideredJoints.push_back('l_knee');
consideredJoints.push_back('l_ankle_pitch');
consideredJoints.push_back('l_ankle_roll');
consideredJoints.push_back('r_hip_pitch');
consideredJoints.push_back('r_hip_roll');
consideredJoints.push_back('r_hip_yaw');
consideredJoints.push_back('r_knee');
consideredJoints.push_back('r_ankle_pitch');
consideredJoints.push_back('r_ankle_roll');

init_time = 1000;
end_time = length(q_meas(:,1));


mdlLdr.loadReducedModelFromFile('model.urdf',consideredJoints);
model = mdlLdr.model();


viz3 = iDynTree.Visualizer();

%  work around 
viz3.init();
viz3.addModel(model,'icub');
viz3.draw();


for i=init_time:end_time
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
odom2.init('l_sole','l_sole');

viz3.modelViz(0).setPositions(odom2.getWorldLinkTransform(model.getDefaultBaseLink()),jointPos3);

viz3.draw();
t = toc;
pause(max(0,0.01-t))

end

viz = iDynTree.Visualizer();

%  work around 
viz.init();
viz.draw();
viz.addModel(model,'icub');


for i=init_time: end_time
tic
%viz.draw();
w_H_bin = w_H_b(:,:,i);
pos = iDynTree.Position();
pos.fromMatlab(w_H_bin(1:3,4));
rot = iDynTree.Rotation();
rot.fromMatlab(w_H_bin(1:3,1:3));
world_H_base = iDynTree.Transform();
world_H_base.setPosition(pos);
world_H_base.setRotation(rot);


jointPos = iDynTree.JointPosDoubleArray(model);
joints = q_meas(i,:)';
jointPos.fromMatlab(joints);

viz.modelViz(0).setPositions(world_H_base,jointPos);

viz.draw();
t = toc;
pause(max(0,0.01-t))
end


viz2 = iDynTree.Visualizer();

%  work around 
viz2.init();
viz2.draw();
viz2.addModel(model,'icub');


for i=init_time:end_time
tic
%viz2.draw();

jointPos2 = iDynTree.JointPosDoubleArray(model);
joints2 = q_inv_kin(i,:)';
jointPos2.fromMatlab(joints2);

% Assuming that the l_sole frame is fixed and it is the world, compute the 
% world_H_base that correspond to the specified joints 
odom = iDynTree.SimpleLeggedOdometry();
odom.setModel(model);
odom.updateKinematics(jointPos2);
odom.init('l_sole','l_sole');

viz2.modelViz(0).setPositions(odom.getWorldLinkTransform(model.getDefaultBaseLink()),jointPos2);

viz2.draw();
t = toc;
pause(max(0,0.01-t))
end



pause()
viz.close()
viz2.close()
viz3.close()
