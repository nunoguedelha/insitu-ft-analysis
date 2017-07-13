% Sensors included in the test should be an structure with the following
% info name, technology, individual info required for ground truth (cross
% values)
% sensors is a structure that will have the sensors to be considered in the
% benchmark
% name is the name to be used in both plots and for reading the data files
%tenchonology is just to keep a record of the kind of technology used in
%the sensor might be useful later
% benchInfo is the info required to get the ground truth for this benchmark
% it could be the case is slightly different for each sensor
ati_ethernet.name='ati_ethernet';
ati_ethernet.technology='silicon strain gauge';
ati_ethernet.benchInfo=[ 0.1475,0.140,0.187,0.00505];
ati_ethernet.fullscale=[580,580,1160,20,20,20];

ftsense.name='ftsense';
ftsense.technology='silicon strain gauge';
ftsense.benchInfo=[ 0.1475,0.140,0.187,0.00505];
ftsense.fullscale=[1500,1500,2000,35,35,25];

optoforce.name='optoforce';
optoforce.technology='optical';
optoforce.benchInfo=[ 0.1475,0.140,0.187,0.00516];
optoforce.fullscale=[300,300,800,15,15,10];

ame.name='ame';
ame.technology='metalic foil';
ame.benchInfo=[ 0.1475,0.140,0.187,0.00516];

sensors.ati_ethernet=ati_ethernet;
sensors.ftsense=ftsense;
sensors.optoforce=optoforce;
sensors.ame=ame;

n=36; % number of tests including bias test positions
bias=[1,7,9,11,13,15,17,19,21,25,29,33];  % log number to be considered as bias

%% Ground truth

    %% Known forces and torques
    %% define the model for ground truth as a function of benchInfo
    
%     function B=benchfunction(benchInfo)
%     %  BENCHFUNCTION function which gives the ground truth of the benchmark
%     a=benchInfo(1);
%     b=benchInfo(2);
%     c=benchInfo(3);
%     d=benchInfo(4);
%     F1 = 5.2; %need to weight weights with the long structure to verify, long piece alone is 300gr the old one 345gr the new one
%     F2 = 25.2;
%     
%     % known loads array
%     B =  [
%         0.0 ,   0.0 ,  F1  , -F1 * a ,  0.0    ,  0.0    ; %  5 kg on y- (1  *
%         0.0 ,   0.0 ,  F1  ,  0.0    , -F1 * a ,  0.0    ; %  5 kg on x+ (2  *
%         0.0 ,   0.0 ,  F1  ,  F1 * a ,  0.0    ,  0.0    ; %  5 kg on y+ (3  *
%         0.0 ,   0.0 ,  F1  ,  0.0    ,  F1 * a ,  0.0    ; %  5 kg on x- (4
%         % axis x+ pointing up
%         -F1  ,   0.0 ,  0.0 ,  0.0    , -F1 * d , -F1 * b ; % 5 kg on y-  (5
%         -F1  ,   0.0 ,  0.0 ,  0.0    , -F1 * c ,  0.0    ; % 5 kg on z+  (6
%         -F1  ,   0.0 ,  0.0 ,  0.0    , -F1 * d ,  F1 * b ; % 5 kg on y+  (7
%         % axis y+ pointing up
%         0.0 ,  -F1  ,  0.0 ,  F1 * d ,  0.0    , -F1 * b ; % 5 kg on x+  (8   *
%         0.0 ,  -F1  ,  0.0 ,  F1 * c ,  0.0    ,  0.0    ; % 5 kg on z+  (9
%         0.0 ,  -F1  ,  0.0 ,  F1 * d ,  0.0    ,  F1 * b ; % 5 kg on x-  (10  *
%         % axis x- pointing up
%         F1  ,   0.0 ,  0.0 ,  0.0    ,  F1 * d , -F1 * b ; % 5 kg on y+  (11
%         F1  ,   0.0 ,  0.0 ,  0.0    ,  F1 * c ,  0.0    ; % 5 kg on z+ (12  *
%         F1  ,   0.0 ,  0.0 ,  0.0    ,  F1 * d ,  F1 * b ; % 5 kg on y-  (13
%         % axis y- pointing up
%         0.0 ,   F1  ,  0.0 , -F1 * d ,  0.0    , -F1 * b ; % 5 kg on x- (14
%         0.0 ,   F1  ,  0.0 , -F1 * c ,  0.0    ,  0.0    ; % 5 kg on z+ (15
%         0.0 ,   F1  ,  0.0 , -F1 * d ,  0.0    ,  F1 * b ; % 5 kg on x+  (16
%         % heavy loads on strain gauges axes
%         0.0 ,   0.0 , -F2  ,  0.0    ,  0.0    ,  0.0    ; % 25 kg on z-    (17  *
%         0.0 ,   0.0 ,  F2  ,  0.0    ,  0.0    ,  0.0    ; % 25 kg on z+   (18  *
%         -F2  ,   0.0 ,  0.0 ,  0.0    , -F2 * d ,  0.0    ; % 25 kg on x+ strain gauge axis 1  (19
%         F2  ,   0.0 ,  0.0 ,  0.0    ,  F2 * d ,  0.0    ; % 25 kg on x- strain gauge axis 1  (20
%         F2 * cos(pi/3)    ,  F2 * sin(pi/3)    ,  0.0  , -F2 * sin(pi/3) * d    ,  F2 * cos(pi/3) * d    ,  0.0  ;    % 25 kg on strain gauge axis 2  (21  *
%         F2 * cos(-2*pi/3) ,  F2 * sin(-2*pi/3) ,  0.0  , -F2 * sin(-2*pi/3) * d ,  F2 * cos(-2*pi/3) * d ,  0.0  ;    % 25 kg on strain gauge axis 2  (22  *
%         F2 * cos(-pi/3)   ,  F2 * sin(-pi/3)   ,  0.0  , -F2 * sin(-pi/3) * d   ,  F2 * cos(-pi/3) * d   ,  0.0  ;    % 25 kg on strain gauge axis 3  (23  *
%         F2 * cos(2*pi/3)  ,  F2 * sin(2*pi/3)  ,  0.0  , -F2 * sin(2*pi/3) * d  ,  F2 * cos(2*pi/3) * d  ,  0.0  ;    % 25 kg on strain gauge axis 3  (24  *
%         ];
%     
%     B = B * 9.81;       % multiply the loads for the gravitational acceleration
%     
%     end
