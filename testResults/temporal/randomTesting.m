%%


dataStateDirs={strcat('data/',experimentName,'/icub/head/',stateDataName);
    strcat('data/',experimentName,'/icub/left_arm/',stateDataName);
    strcat('data/',experimentName,'/icub/left_leg/',stateDataName);
    strcat('data/',experimentName,'/icub/right_arm/',stateDataName);
    strcat('data/',experimentName,'/icub/right_leg/',stateDataName);
    strcat('data/',experimentName,'/icub/torso/',stateDataName);
    };
[qj_all,dqj_all,ddqj_all,time]=readStateExt(16,dataStateDirs{2});

index = find(strcmp(fNames,'torso'))

index = find(strcmp(names, '3'))
isempty(index)


l_arm_ft_sensor
r_arm_ft_sensor
l_leg_ft_sensor
r_leg_ft_sensor
l_foot_ft_sensor
r_foot_ft_sensor

 strcmp(sens.getName(),'r_foot_ft_sensor')
 
   dataset = {};

    % read ft data 
    [dataset.ft, dataset.time] = readDataDumper(dataFTDirs{1});
    
    left_arm=-left_arm;
    timeStampinit=time1(1);
figure,    
    plot(time1-timeStampinit,left_arm(:,3));hold on;
plot(time1-timeStampinit,left_arm(:,4));hold on;
plot(time1-timeStampinit,left_arm(:,5));hold on;
% plot(left_arm(:,2)-timeStampinit,left_arm(:,6));hold on;
% plot(left_arm(:,2)-timeStampinit,left_arm(:,7));hold on;
% plot(left_arm(:,2)-timeStampinit,left_arm(:,8));hold on;
legend('Fx','Fy','Fz','Location','west');
xlabel('TimeStamp');
ylabel('N@Nm');
title('left arm');

figure,
plot(time1-timeStampinit,e_left_arm(:,3));hold on;
plot(time1-timeStampinit,e_left_arm(:,4));hold on;
plot(time1-timeStampinit,e_left_arm(:,5));hold on;
% plot(left_arm(:,2)-timeStampinit,left_arm(:,6));hold on;
% plot(left_arm(:,2)-timeStampinit,left_arm(:,7));hold on;
% plot(left_arm(:,2)-timeStampinit,left_arm(:,8));hold on;
legend('Fx','Fy','Fz','Location','west');
xlabel('TimeStamp');
ylabel('N@Nm');
title('estimated left arm');

figure,
plot(time1-timeStampinit,left_arm(:,3)-e_left_arm(:,3));hold on;
plot(time1-timeStampinit,left_arm(:,4)-e_left_arm(:,4));hold on;
plot(time1-timeStampinit,left_arm(:,5)-e_left_arm(:,5));hold on;
% plot(left_arm(:,2)-timeStampinit,left_arm(:,6));hold on;
% plot(left_arm(:,2)-timeStampinit,left_arm(:,7));hold on;
% plot(left_arm(:,2)-timeStampinit,left_arm(:,8));hold on;
legend('Fx','Fy','Fz','Location','west');
xlabel('TimeStamp');
ylabel('N@Nm');
title('left arm- estimation');

%% right leg test
[right_leg,time5]=readDataDumper(dataFTDirs{5});
right_leg=resampleFt(time1,time5,right_leg);
right_leg=-right_leg;

figure,    
    plot(time1-timeStampinit,right_leg(:,3),'.');hold on;
plot(time1-timeStampinit,right_leg(:,4),'.');hold on;
plot(time1-timeStampinit,right_leg(:,5),'.');hold on;

legend('Fx','Fy','Fz','Location','west');
xlabel('TimeStamp');
ylabel('N@Nm');
title('right leg');

figure,
plot(time1-timeStampinit,e_right_leg(:,3),'.');hold on;
plot(time1-timeStampinit,e_right_leg(:,4),'.');hold on;
plot(time1-timeStampinit,e_right_leg(:,5),'.');hold on;

legend('Fx','Fy','Fz','Location','west');
xlabel('TimeStamp');
ylabel('N@Nm');
title('estimated right leg');

figure,
plot(time1-timeStampinit,right_leg(:,3)-e_right_leg(:,3));hold on;
plot(time1-timeStampinit,right_leg(:,4)-e_right_leg(:,4));hold on;
plot(time1-timeStampinit,right_leg(:,5)-e_right_leg(:,5));hold on;

legend('Fx','Fy','Fz','Location','west');
xlabel('TimeStamp');
ylabel('N@Nm');
title('right leg- estimation');

%% checking comparisong among the singular values of different experiments
% the idea is to find a way to discriminate cases where insitu offest
% estimation can be used (ideally rank should be 3, but in all cases the
% rank is 6)
addpath ../figs

sv1L=load(strcat('../figs/sVals1.mat'),'S_ft_raw')
sv2L=  load(strcat('../figs/sVals2.mat'),'S_ft_raw')
  sv1R=  load(strcat('../figs/sVals1rightleg.mat'),'S_ft_raw')
  sv2R=    load(strcat('../figs/sVals2rightleg.mat'),'S_ft_raw')
  sv3L=  load(strcat('../figs/sVals3.mat'),'S_ft_raw')
  sv3R=  load(strcat('../figs/sVals3rightleg.mat'),'S_ft_raw')
  
  sv1L=load(strcat('figs/sVals1.mat'),'S_ft_raw')
sv2L=  load(strcat('figs/sVals2.mat'),'S_ft_raw')
  sv1R=  load(strcat('figs/sVals1rightleg.mat'),'S_ft_raw')
  sv2R=    load(strcat('figs/sVals2rightleg.mat'),'S_ft_raw')
  sv3L=  load(strcat('figs/sVals3.mat'),'S_ft_raw')
  sv3R=  load(strcat('figs/sVals3rightleg.mat'),'S_ft_raw')
  
  sv1L.S_ft_raw
sv2L.S_ft_raw
  sv1R.S_ft_raw
  svR.S_ft_raw
  
%    sv1L.S_ft_raw(3,3)- sv1L.S_ft_raw(4,4)
 diff(1)=   sv2L.S_ft_raw(3,3)- sv2L.S_ft_raw(4,4)
 diff(2)=    sv1R.S_ft_raw(3,3)- sv1R.S_ft_raw(4,4)
 diff(3)=     sv2R.S_ft_raw(3,3)- sv2R.S_ft_raw(4,4)
 diff(4)=   sv3L.S_ft_raw(3,3)- sv3L.S_ft_raw(4,4)
 diff(5)=     sv3R.S_ft_raw(3,3)- sv3R.S_ft_raw(4,4)
      
%        sv1L.S_ft_raw(3,3)/ sv1L.S_ft_raw(4,4)
 div(1)=   sv2L.S_ft_raw(3,3)/ sv2L.S_ft_raw(4,4)
 div(2)=    sv1R.S_ft_raw(3,3)/ sv1R.S_ft_raw(4,4)
 div(3)=     sv2R.S_ft_raw(3,3)/ sv2R.S_ft_raw(4,4)
 div(4)=  sv3L.S_ft_raw(3,3)/ sv3L.S_ft_raw(4,4)
 div(5)=     sv3R.S_ft_raw(3,3)/ sv3R.S_ft_raw(4,4)

 diff(2)/diff(3)
 
 

