function [str]=cMat2xml(cMat,sensorName)
%output example
% \code{.xml}
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
% + * \endcode
cMat=cMat';%to easily print in the right order
str=sprintf('\\code{.xml} \n <group name="FT_SECONDARY_CALIBRATION"> \n  <param name="%s"> (',sensorName);
for i=1:length(cMat(:))-1
str=strcat(str,sprintf('%d,',cMat(i)));
end
str=strcat(str,sprintf('%d)</param> \n </group> \n \\endcode',cMat(end)));
