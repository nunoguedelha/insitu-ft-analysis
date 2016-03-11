%Loading of FT sensors, offset considered
% the ports are ROBOT_NAME/left@rigth_arm@leg@foot/analog:o
% Assuming to be in directory dumper/ROBOT_NAME (example dumper/icubGazeboSim
portname='analog:o/data.log';
left_arm=load(strcat('left_arm/',portname));
left_leg=load(strcat('left_leg/',portname));
left_foot=load(strcat('left_foot/',portname));
right_arm=load(strcat('right_arm/',portname));
right_leg=load(strcat('right_leg/',portname));
right_foot=load(strcat('right_foot/',portname));
timeStampinit=left_arm(1,2);
figure,
subplot(3,2,1)
plot(right_arm(:,2)-timeStampinit,right_arm(:,3));hold on;
plot(right_arm(:,2)-timeStampinit,right_arm(:,4));hold on;
plot(right_arm(:,2)-timeStampinit,right_arm(:,5));hold on;
% plot(right_arm(:,2)-timeStampinit,right_arm(:,6));hold on;
% plot(right_arm(:,2)-timeStampinit,right_arm(:,7));hold on;
% plot(right_arm(:,2)-timeStampinit,right_arm(:,8));hold on;
% legend('Fx','Fy','Fz','Tx','Ty','Tz','Location','west');
legend('Fx','Fy','Fz','Location','west');

title('right arm');
xlabel('TimeStamp');
ylabel('N@Nm');


subplot(3,2,2)
plot(left_arm(:,2)-timeStampinit,left_arm(:,3));hold on;
plot(left_arm(:,2)-timeStampinit,left_arm(:,4));hold on;
plot(left_arm(:,2)-timeStampinit,left_arm(:,5));hold on;
% plot(left_arm(:,2)-timeStampinit,left_arm(:,6));hold on;
% plot(left_arm(:,2)-timeStampinit,left_arm(:,7));hold on;
% plot(left_arm(:,2)-timeStampinit,left_arm(:,8));hold on;
legend('Fx','Fy','Fz','Location','west');
xlabel('TimeStamp');
ylabel('N@Nm');
title('left arm');

subplot(3,2,3)
plot(right_leg(:,2)-timeStampinit,right_leg(:,3));hold on;
plot(right_leg(:,2)-timeStampinit,right_leg(:,4));hold on;
plot(right_leg(:,2)-timeStampinit,right_leg(:,5));hold on;
% plot(right_leg(:,2)-timeStampinit,right_leg(:,6));hold on;
% plot(right_leg(:,2)-timeStampinit,right_leg(:,7));hold on;
% plot(right_leg(:,2)-timeStampinit,right_leg(:,8));hold on;
legend('Fx','Fy','Fz','Location','west');
title('right leg');
xlabel('TimeStamp');
ylabel('N@Nm');

subplot(3,2,4)
plot(left_leg(:,2)-timeStampinit,left_leg(:,3));hold on;
plot(left_leg(:,2)-timeStampinit,left_leg(:,4));hold on;
plot(left_leg(:,2)-timeStampinit,left_leg(:,5));hold on;
% plot(left_leg(:,2)-timeStampinit,left_leg(:,6));hold on;
% plot(left_leg(:,2)-timeStampinit,left_leg(:,7));hold on;
% plot(left_leg(:,2)-timeStampinit,left_leg(:,8));hold on;
legend('Fx','Fy','Fz','Location','west');
title('left leg');
xlabel('TimeStamp');
ylabel('N@Nm');

subplot(3,2,5)
plot(right_foot(:,2)-timeStampinit,right_foot(:,3));hold on;
plot(right_foot(:,2)-timeStampinit,right_foot(:,4));hold on;
plot(right_foot(:,2)-timeStampinit,right_foot(:,5));hold on;
% plot(right_foot(:,2)-timeStampinit,right_foot(:,6));hold on;
% plot(right_foot(:,2)-timeStampinit,right_foot(:,7));hold on;
% plot(right_foot(:,2)-timeStampinit,right_foot(:,8));hold on;
legend('Fx','Fy','Fz','Location','west');
title('right foot');
xlabel('TimeStamp');
ylabel('N@Nm');

subplot(3,2,6)
plot(left_foot(:,2)-timeStampinit,left_foot(:,3));hold on;
plot(left_foot(:,2)-timeStampinit,left_foot(:,4));hold on;
plot(left_foot(:,2)-timeStampinit,left_foot(:,5));hold on;
% plot(left_foot(:,2)-timeStampinit,left_foot(:,6));hold on;
% plot(left_foot(:,2)-timeStampinit,left_foot(:,7));hold on;
% plot(left_foot(:,2)-timeStampinit,left_foot(:,8));hold on;
legend('Fx','Fy','Fz','Location','west');
title('left foot');
xlabel('TimeStamp');
ylabel('N@Nm');

figure,
subplot(3,2,1)

plot(right_arm(:,2)-timeStampinit,right_arm(:,6));hold on;
plot(right_arm(:,2)-timeStampinit,right_arm(:,7));hold on;
plot(right_arm(:,2)-timeStampinit,right_arm(:,8));hold on;
legend('Tx','Ty','Tz','Location','west');
title('right arm torques');
xlabel('TimeStamp');
ylabel('Nm');


subplot(3,2,2)

plot(left_arm(:,2)-timeStampinit,left_arm(:,6));hold on;
plot(left_arm(:,2)-timeStampinit,left_arm(:,7));hold on;
plot(left_arm(:,2)-timeStampinit,left_arm(:,8));hold on;
legend('Tx','Ty','Tz','Location','west'); 
xlabel('TimeStamp');
ylabel('Nm');
title('left arm torques');

subplot(3,2,3)

plot(right_leg(:,2)-timeStampinit,right_leg(:,6));hold on;
plot(right_leg(:,2)-timeStampinit,right_leg(:,7));hold on;
plot(right_leg(:,2)-timeStampinit,right_leg(:,8));hold on;
legend('Tx','Ty','Tz','Location','west'); 
title('right leg torques');
xlabel('TimeStamp');
ylabel('N@Nm');

subplot(3,2,4)

plot(left_leg(:,2)-timeStampinit,left_leg(:,6));hold on;
plot(left_leg(:,2)-timeStampinit,left_leg(:,7));hold on;
plot(left_leg(:,2)-timeStampinit,left_leg(:,8));hold on;
legend('Tx','Ty','Tz','Location','west'); 
title('left leg torques');
xlabel('TimeStamp');
ylabel('Nm');

subplot(3,2,5)

plot(right_foot(:,2)-timeStampinit,right_foot(:,6));hold on;
plot(right_foot(:,2)-timeStampinit,right_foot(:,7));hold on;
plot(right_foot(:,2)-timeStampinit,right_foot(:,8));hold on;
legend('Tx','Ty','Tz','Location','west'); 
title('right foot torques');
xlabel('TimeStamp');
ylabel('N@Nm');

subplot(3,2,6)

plot(left_foot(:,2)-timeStampinit,left_foot(:,6));hold on;
plot(left_foot(:,2)-timeStampinit,left_foot(:,7));hold on;
plot(left_foot(:,2)-timeStampinit,left_foot(:,8));hold on;
legend('Tx','Ty','Tz','Location','west'); 
title('left foot torques');
xlabel('TimeStamp');
ylabel('Nm');
