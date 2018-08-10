function [H]=plotForceAndVizFromSample(i,dataset,sensorsToAnalize,odom,viz3,H,whichFtData,estimatedAvailable,fixedFrame,jointPos,model,varargin)
useTorque=false;
for v=1:length(varargin)    
        if (ismember({'torque'},varargin{v}))
            useTorque=true;
        end
   
end

i = round(i);
numberOfJoints=size(jointPos.toMatlab());
%joints = dataset.qj(i,1:23)'; %TODO:This depends in the model used that
%outputs the considerd joints. Is the robot model not the one in external
%icubViz
joints = dataset.qj(i,1:numberOfJoints)';
jointPos.fromMatlab(joints);

odom.updateKinematics(jointPos);
odom.init(fixedFrame,fixedFrame);
%baseT=odom.getWorldLinkTransform(model.getDefaultBaseLink());
%baseT=odom.getWorldLinkTransform(odom.model().getFrameLink(odom.model().getFrameIndex(fixedFrame)));
baseT=odom.getWorldLinkTransform(odom.model.getDefaultBaseLink());
%baseT=odom.getWorldLinkTransform(0);
pos = iDynTree.Position();
pos.fromMatlab([0;0;0.5]);
baseT.setPosition(pos);

viz3.modelViz(0).setPositions(baseT,jointPos);
viz3.draw();
if useTorque
    dataToPlot=4:6;
else
    dataToPlot=1:3;
end
for indx=1:length(sensorsToAnalize)
    ft =sensorsToAnalize{indx};
    subplot( H.(ft).sub)
    [az,el]=view;
    hold off
    h= plot3_matrix(dataset.(whichFtData).(ft)(1:i,dataToPlot),'r');%
    hold on;
    delete(H.(ft).old);
    H.(ft).old=h;
    if estimatedAvailable
        h2= plot3_matrix(dataset.estimatedFtData.(ft)(1:i,dataToPlot),'b');
        delete(H.(ft).old2);
        H.(ft).old2=h2;
        legend('measuredData','estimatedData','Location','west');
    else
        legend('measuredData','Location','west');
    end
    title(strcat({'Wrench space '},escapeUnderscores(ft)));
    if useTorque
        xlabel('\tau_{x}');
        ylabel('\tau_{y}');
        zlabel('\tau_{z}');
    else
        xlabel('F_{x}');
        ylabel('F_{y}');
        zlabel('F_{z}');
    end
    
    axis(H.(ft).minMaxForces);
    pbaspect([1 1 1]);
    axis vis3d;
    grid on;
    view(az,el);
    %axis manual;
    %axis equal;   
    drawnow;    
end
%pause(max(0,0.01-t))

