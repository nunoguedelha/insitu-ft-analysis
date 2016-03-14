


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

%%

