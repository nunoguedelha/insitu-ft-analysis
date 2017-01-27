fittedEllipsoid_im2 = ellipsoidfit_smart(dataset.filteredFtData.(ft)(:,1:3),dataset.estimatedFtData.(ft)(:,1:3));       
     % If the measure was perfect, the radius of the force measurements
     % would be exactly m*|g| ~ m*9.81 
     % We then can print the "mass" as seen by the sensor axis, by
     % computing the intersection of the ellipsoid with the x,y,z sensor 
     % axis (if the x,y,z axis of the sensor are also the principal axis
     % of the ellipsoid, this are the radii of the ellipsoid in explicit form)
     intersections2 = ellipsoid_intersectionWithAxis(fittedEllipsoid_im2);
     g = 9.81;
     masses2 = intersections2/g;
     fprintf('The apparent mass attached (using gravity from kinematics) at the sensor %s for axis x,y,z are (%f,%f,%f)\n',ft,masses2(1),masses2(2),masses2(3));
     
    test= dataset.filteredFtData.(ft)(:,1:3)+repmat(100,size( dataset.filteredFtData.(ft)(:,1:3),1),3);
    
    fittedEllipsoid_im3 = ellipsoidfit_smart(test,dataset.estimatedFtData.(ft)(:,1:3));
        
     % If the measure was perfect, the radius of the force measurements
     % would be exactly m*|g| ~ m*9.81 
     % We then can print the "mass" as seen by the sensor axis, by
     % computing the intersection of the ellipsoid with the x,y,z sensor 
     % axis (if the x,y,z axis of the sensor are also the principal axis
     % of the ellipsoid, this are the radii of the ellipsoid in explicit form)
     intersections3 = ellipsoid_intersectionWithAxis(fittedEllipsoid_im3);
     g = 9.81;
     masses3 = intersections3/g;
     fprintf('The apparent mass attached (using gravity from kinematics) at the sensor %s for axis x,y,z are (%f,%f,%f)\n',ft,masses3(1),masses3(2),masses3(3));
     
      figure
 %    plot3(dataset.ftDataNoOffset.(ft)(:,1),dataset.ftDataNoOffset.(ft)(:,2),dataset.ftDataNoOffset.(ft)(:,3),'g.'); hold on;
  %   plot3_matrix(test); hold on;
   %  plot_ellipsoid_im(fittedEllipsoid_im3);hold on;
     plot_ellipsoid_im(fittedEllipsoid_im_circular,'EdgeColor','g'); hold on;
    %  plot_ellipsoid_im(fittedEllipsoid_im2,'EdgeColor','r'); hold on;
       plot_ellipsoid_im(fittedEllipsoid_im,'EdgeColor','b'); hold on;
       legend('measuredData','estimatedData','Location','west');
        title(strcat({'Wrench space '},escapeUnderscores(ft)));
        xlabel('F_{x}');
        ylabel('F_{y}');
        zlabel('F_{z}');
        axis equal;
        
        
        [center2,radii2,quat2,R2]=ellipsoid_im2ex(fittedEllipsoid_im2)
          [center,radii,quat,R]=ellipsoid_im2ex(fittedEllipsoid_im)
          [center3,radii3,quat3,R3]=ellipsoid_im2ex( fittedEllipsoid_im_circular)
          
          test= dataset.filteredFtData.(ft)(:,1:3)-repmat(center2',size( dataset.filteredFtData.(ft)(:,1:3),1),1);
          
            test= dataset.estimatedFtData.(ft)(:,1:3)+repmat(100,size( dataset.filteredFtData.(ft)(:,1:3),1),3);
            
             test= test+repmat(100,size( dataset.filteredFtData.(ft)(:,1:3),1),3);