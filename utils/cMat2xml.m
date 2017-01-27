function [str]=cMat2xml(cMat,sensorName)
%output example
% + *      <group name="FT_SECONDARY_CALIBRATION">
% + *             <param name="l_arm_ft_sensor">(1.0,0.0,0.0,0.0,0.0,0.0,
% + *                                            0.0,1.0,0.0,0.0,0.0,0.0,
% + *                                            0.0,0.0,1.0,0.0,0.0,0.0,
% + *                                            0.0,0.0,0.0,1.0,0.0,0.0,
% + *                                            0.0,0.0,0.0,0.0,1.0,0.0,
% + *                                            0.0,0.0,0.0,0.0,0.0,1.0)</param>
% + *             <param name="r_arm_ft_sensor">(1.0,0.0,0.0,0.0,0.0,0.0,
% + *                                            0.0,1.0,0.0,0.0,0.0,0.0,
% + *                                            0.0,0.0,1.0,0.0,0.0,0.0,
% + *                                            0.0,0.0,0.0,0.001,0.0,0.0,
% + *                                            0.0,0.0,0.0,0.0,0.001,0.0,
% + *                                            0.0,0.0,0.0,0.0,0.0,0.001)</param>
% + *      </group>

%cMat=cMat';%to easily print in the right order
str=sprintf(' <group name="FT_SECONDARY_CALIBRATION"> \n  <param name="%s"> (',sensorName);
for i=1:size(cMat,1)
    for j=1:size(cMat,2)
        if(j==1)
            str=strcat(str,sprintf('%d',cMat(i,j)));
        else
            str=strcat(str,sprintf(',%d',cMat(i,j)));
        end
    end
    if (i~=size(cMat,1))
        str=strcat(str,sprintf(' \n ,'));
    end
end
str=strcat(str,sprintf(')</param> \n </group>'));
