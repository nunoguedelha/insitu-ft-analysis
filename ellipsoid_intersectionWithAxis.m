function [ intersections ] = ellipsoid_intersectionWithAxis( ellipsoid_im )
%ellipsoid_intersectionWithAxis Get the intersection of an ellipsodi 
  % x interesection
  Qxx = ellipsoid_im(1);
  Qyy = ellipsoid_im(2);
  Qzz = ellipsoid_im(3);
  Q44 = ellipsoid_im(10);
  % I did this computation by doing the intersection of the center 
  % ellipsoid with the axis equations
  intersections(1) = sqrt(-Q44/Qxx);
  intersections(2) = sqrt(-Q44/Qyy);
  intersections(3) = sqrt(-Q44/Qzz);
end

