function [q]=findJointValuesFromWrench(jointData,ftData,Wrench)
indx=findForceIndex(ftData,Wrench);
q=jointData(indx,:);