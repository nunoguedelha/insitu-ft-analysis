function [H]=plotForceAndVizFromSample(i,dataset,sensorsToAnalize,odom,viz3,H,whichFtData,estimatedAvailable,fixedFrame,jointPos,model)
i = round(i);  
joints = dataset.qj(i,1:23)';
jointPos.fromMatlab(joints);

odom.updateKinematics(jointPos);
odom.init(fixedFrame,fixedFrame);
%baseT=odom.getWorldLinkTransform(model.getDefaultBaseLink());
baseT=odom.getWorldLinkTransform(0);
pos = iDynTree.Position();
pos.fromMatlab([0;0;0.5]);
baseT.setPosition(pos);

viz3.modelViz(0).setPositions(baseT,jointPos);
viz3.draw();


for indx=1:length(sensorsToAnalize)
    ft =sensorsToAnalize{indx};
    subplot( H.(ft).sub)
    [az,el]=view;
    hold off
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
    grid on;
    view(az,el);
    %axis manual;
    %axis equal;   
    drawnow;    
end
%pause(max(0,0.01-t))

