%% clear things
% close all
% clear all
%clc

%% Add the utils to the path
addpath('../utils')
addpath('../external/quadfit')

%% select sensor to calibrate
% sensNum = 'SN199';      % sensor to calibrate
crossVersion = 'V3';    % calibration structure used to acquire the data
useMaxRange = 1;        %set to 1 for true, set to 0 for false


%% load calibration data
numRep = 1000;
sensNum
dataPath = getSensorWorkBenchCalibrationDataFolder(sensNum);
dataPath

o1 = load([dataPath 'output1.dat']); o1m=mean(o1(1:1000,1:7));
o3 = load([dataPath 'output3.dat']); o3m=mean(o3(1:1000,1:7));
o4 = load([dataPath 'output4.dat']); o4m=mean(o4(1:1000,1:7));
o5 = load([dataPath 'output5.dat']); o5m=mean(o5(1:1000,1:7));
o6 = load([dataPath 'output6.dat']); o6m=mean(o6(1:1000,1:7));
o81 = load([dataPath 'output81.dat']); o81m=mean(o81(1:1000,1:7));
o82 = load([dataPath 'output82.dat']); o82m=mean(o82(1:1000,1:7));
o83 = load([dataPath 'output83.dat']); o83m=mean(o83(1:1000,1:7));
o84 = load([dataPath 'output84.dat']); o84m=mean(o84(1:1000,1:7));
o85 = load([dataPath 'output85.dat']); o85m=mean(o85(1:1000,1:7));
o86 = load([dataPath 'output86.dat']); o86m=mean(o86(1:1000,1:7));
o87 = load([dataPath 'output87.dat']); o87m=mean(o87(1:1000,1:7));
o88 = load([dataPath 'output88.dat']); o88m=mean(o88(1:1000,1:7));
A = [];

current_o = o1;
mean_d = mean(current_o(1:1000,2:7));
[m,n] = size(current_o(1001:end,2:7));
current_A = current_o(1001:end,2:7) - repmat(mean_d,m,1);
A = [A; current_A];

current_o = o3;
mean_d = mean(current_o(1:1000,2:7));
[m,n] = size(current_o(1001:end,2:7));
current_A = current_o(1001:end,2:7) - repmat(mean_d,m,1);
A = [A; current_A];

current_o = o4;
mean_d = mean(current_o(1:1000,2:7));
[m,n] = size(current_o(1001:end,2:7));
current_A = current_o(1001:end,2:7) - repmat(mean_d,m,1);
A = [A; current_A];

current_o = o5;
mean_d = mean(current_o(1:1000,2:7));
[m,n] = size(current_o(1001:end,2:7));
current_A = current_o(1001:end,2:7) - repmat(mean_d,m,1);
A = [A; current_A];

current_o = o6;
mean_d = mean(current_o(1:1000,2:7));
[m,n] = size(current_o(1001:end,2:7));
current_A = current_o(1001:end,2:7) - repmat(mean_d,m,1);
A = [A; current_A];

current_o = o81;
mean_d = mean(current_o(1:1000,2:7));
[m,n] = size(current_o(1001:end,2:7));
current_A = current_o(1001:end,2:7) - repmat(mean_d,m,1);
A = [A; current_A];

current_o = o82;
mean_d = mean(current_o(1:1000,2:7));
[m,n] = size(current_o(1001:end,2:7));
current_A = current_o(1001:end,2:7) - repmat(mean_d,m,1);
A = [A; current_A];

current_o = o83;
mean_d = mean(current_o(1:1000,2:7));
[m,n] = size(current_o(1001:end,2:7));
current_A = current_o(1001:end,2:7) - repmat(mean_d,m,1);
A = [A; current_A];

current_o = o84;
mean_d = mean(current_o(1:1000,2:7));
[m,n] = size(current_o(1001:end,2:7));
current_A = current_o(1001:end,2:7) - repmat(mean_d,m,1);
A = [A; current_A];

current_o = o85;
mean_d = mean(current_o(1:1000,2:7));
[m,n] = size(current_o(1001:end,2:7));
current_A = current_o(1001:end,2:7) - repmat(mean_d,m,1);
A = [A; current_A];
 
current_o = o86;
mean_d = mean(current_o(1:1000,2:7));
[m,n] = size(current_o(1001:end,2:7));
current_A = current_o(1001:end,2:7) - repmat(mean_d,m,1);
A = [A; current_A];

current_o = o87;
mean_d = mean(current_o(1:1000,2:7));
[m,n] = size(current_o(1001:end,2:7));
current_A = current_o(1001:end,2:7) - repmat(mean_d,m,1);
A = [A; current_A];
 
current_o = o88;
mean_d = mean(current_o(1:1000,2:7));
[m,n] = size(current_o(1001:end,2:7));
current_A = current_o(1001:end,2:7) - repmat(mean_d,m,1);
A = [A; current_A];

[mA,nA] = size(A);
for i = 0 : mA/1000-1;
    tmp(i+1,:) = mean(A(1+i*numRep:(i+1)*numRep,:),1);
end
A = tmp;

%% define the model
F1 = 5.2;
F2 = 25.2;
a = 0.1475;
b = 0.140;
if strcmp(crossVersion,'V3')
    c = 0.185;
    d = 0.005;
elseif strcmp(crossVersion,'V2')
    c = 0.1822;
    d = -0.0057;
else
    display('wrong selection of calibration strucutre')
    break
end

% known loads array 
B =  [
         0.0 ,   0.0 ,  F1  , -F1 * a ,  0.0    ,  0.0    ; %  5 kg on y- (1  *
         0.0 ,   0.0 ,  F1  ,  0.0    , -F1 * a ,  0.0    ; %  5 kg on x+ (2  *
         0.0 ,   0.0 ,  F1  ,  F1 * a ,  0.0    ,  0.0    ; %  5 kg on y+ (3  *
         0.0 ,   0.0 ,  F1  ,  0.0    ,  F1 * a ,  0.0    ; %  5 kg on x- (4
% axis x+ pointing up
        -F1  ,   0.0 ,  0.0 ,  0.0    , -F1 * d , -F1 * b ; % 5 kg on y-  (5
        -F1  ,   0.0 ,  0.0 ,  0.0    , -F1 * c ,  0.0    ; % 5 kg on z+  (6
        -F1  ,   0.0 ,  0.0 ,  0.0    , -F1 * d ,  F1 * b ; % 5 kg on y+  (7
% axis y+ pointing up
         0.0 ,  -F1  ,  0.0 ,  F1 * d ,  0.0    , -F1 * b ; % 5 kg on x+  (8   *
         0.0 ,  -F1  ,  0.0 ,  F1 * c ,  0.0    ,  0.0    ; % 5 kg on z+  (9
         0.0 ,  -F1  ,  0.0 ,  F1 * d ,  0.0    ,  F1 * b ; % 5 kg on x-  (10  *
% axis x- pointing up
         F1  ,   0.0 ,  0.0 ,  0.0    ,  F1 * d , -F1 * b ; % 5 kg on y+  (11
         F1  ,   0.0 ,  0.0 ,  0.0    ,  F1 * c ,  0.0    ; % 5 kg on z+ (12  *
         F1  ,   0.0 ,  0.0 ,  0.0    ,  F1 * d ,  F1 * b ; % 5 kg on y-  (13  
% axis y- pointing up
         0.0 ,   F1  ,  0.0 , -F1 * d ,  0.0    , -F1 * b ; % 5 kg on x- (14             
         0.0 ,   F1  ,  0.0 , -F1 * c ,  0.0    ,  0.0    ; % 5 kg on z+ (15
         0.0 ,   F1  ,  0.0 , -F1 * d ,  0.0    ,  F1 * b ; % 5 kg on x+  (16
% heavy loads on strain gauges axes
         0.0 ,   0.0 , -F2  ,  0.0    ,  0.0    ,  0.0    ; % 25 kg on z-    (17  *
         0.0 ,   0.0 ,  F2  ,  0.0    ,  0.0    ,  0.0    ; % 25 kg on z+   (18  *
        -F2  ,   0.0 ,  0.0 ,  0.0    , -F2 * d ,  0.0    ; % 25 kg on x+ strain gauge axis 1  (19
         F2  ,   0.0 ,  0.0 ,  0.0    ,  F2 * d ,  0.0    ; % 25 kg on x- strain gauge axis 1  (20
         F2 * cos(pi/3)    ,  F2 * sin(pi/3)    ,  0.0  , -F2 * sin(pi/3) * d    ,  F2 * cos(pi/3) * d    ,  0.0  ;    % 25 kg on strain gauge axis 2  (21  *
         F2 * cos(-2*pi/3) ,  F2 * sin(-2*pi/3) ,  0.0  , -F2 * sin(-2*pi/3) * d ,  F2 * cos(-2*pi/3) * d ,  0.0  ;    % 25 kg on strain gauge axis 2  (22  *
         F2 * cos(-pi/3)   ,  F2 * sin(-pi/3)   ,  0.0  , -F2 * sin(-pi/3) * d   ,  F2 * cos(-pi/3) * d   ,  0.0  ;    % 25 kg on strain gauge axis 3  (23  *
         F2 * cos(2*pi/3)  ,  F2 * sin(2*pi/3)  ,  0.0  , -F2 * sin(2*pi/3) * d  ,  F2 * cos(2*pi/3) * d  ,  0.0  ;    % 25 kg on strain gauge axis 3  (24  *
    ];

B = B * 9.81;       % multiply the loads for the gravitational acceleration
[mb, nb] = size(B);

kIA = kron(eye(6), A);
%kIAr = kron(eye(6), Ar);
for i = 0 : 5
    Anew = kIA(1+i*mb: (i+1)*mb,:);
    bnew = B(:,i+1);
    W = diag([ones(1,18), ones(1,6).*.3]);
    kIAw(1+i*mb: (i+1)*mb, :) = W*Anew;
    Bw(:,i+1) = W*bnew;
end

vec_xw = pinv(kIAw)*Bw(:);
Xw = reshape(vec_xw, 6, 6);
Bw_pred = A*Xw;

vec_x = pinv(kIA)*B(:);
X = reshape(vec_x, 6, 6);
B_pred = A*X;
%Br_pred = Ar*X;

Calib = X';

Br = B([ 1 2 3 8 10 12 17 18 19 20 21 22], :); 
Ar = A([ 1 2 3 8 10 12 17 18 19 20 21 22], :);

%Br = B([ 1 2 3 8 10 12 17 18 19 20 21 22], :); 
%Ar = A([ 1 2 3 8 10 12 17 18 19 20 21 22], :); 

[mbr, nbr] = size(Br);

kIAr = kron(eye(6), Ar);
for i = 0 : 5
    Anew = kIAr(1+i*mbr: (i+1)*mbr,:);
    bnew = Br(:,i+1);
    W = diag([ones(1,6), ones(1,6).*.3]); %%%check here
    %W = diag([ones(1,6), ones(1,6).*.3]); %%%check here
    kIAwr(1+i*mbr: (i+1)*mbr, :) = W*Anew;
    Bwr(:,i+1) = W*bnew;
end

vec_xwr = pinv(kIAwr)*Bwr(:);
Xwr = reshape(vec_xwr, 6, 6);
Bwr_pred = A*Xwr;

eLS = (B - B_pred);
eWLS = (B - Bw_pred);
eWLSr = (B - Bwr_pred);
% disp('Results using the all data set')
% disp('eLS [eLS_min eLS_max] eWLS [eWLS_min eWLS_max]  eWLSr [eWLSr_min eWLSr_max]')
% for i = 1 : 6    
%    message =strcat('F',num2str(i));    
%    message = strcat(message, sprintf('%5.2f [%5.2f, %5.2f] \t',sqrt(mean(eLS(:,i).*eLS(:,i))), min(eLS(:,i)), max(eLS(:,i))));
%    message = strcat(message, sprintf('%5.2f [%5.2f, %5.2f] \t',sqrt(mean(eWLS(:,i).*eWLS(:,i))), min(eWLS(:,i)), max(eWLS(:,i))));
%    message = strcat(message, sprintf('%5.2f [%5.2f, %5.2f] \t',sqrt(mean(eWLS(:,i).*eWLS(:,i))), min(eWLSr(:,i)), max(eWLSr(:,i))));
%    disp(message)
%end

C = Xw';

if useMaxRange
    % calculate full scale range
    maxs = sign(C)*32767;
    full_scale = diag(C*maxs');
    max_Fx = ceil(full_scale(1));
    max_Fy = ceil(full_scale(2));
    max_Fz = ceil(full_scale(3));
    max_Tx = ceil(full_scale(4));
    max_Ty = ceil(full_scale(5));
    max_Tz = ceil(full_scale(6));
    % disp(sprintf('%g -> %g N',  full_scale(1), max_Fx))
    % disp(sprintf('%g -> %g N',  full_scale(2), max_Fy))
    % disp(sprintf('%g -> %g N',  full_scale(3), max_Fz))
    % disp(sprintf('%g -> %g Nm', full_scale(4), max_Tx))
    % disp(sprintf('%g -> %g Nm', full_scale(5), max_Ty))
    % disp(sprintf('%g -> %g Nm', full_scale(6), max_Tz))
else
    max_Fx = 1000;
    max_Fy = 1000;
    max_Fz = 1000;
    max_Tx = 14;
    max_Ty = 14;
    max_Tz = 12;
end

Wf = diag([1/max_Fx 1/max_Fy 1/max_Fz 1/max_Tx 1/max_Ty 1/max_Tz]);
Ws = diag([1/32767 1/32767 1/32767 1/32767 1/32767 1/32767]);
Cs = Wf * C * inv(Ws);

test_vector = [6550    -6450  -1537  10900 -28550     38];
max_vector  = [32767  -32767  32767 -32767  32767  32767];
min_vector  = [-32000  32000 -32000  32000 -32000 -32000];
format short;
test_out=C*test_vector';
max_out=C*max_vector';
min_out=C*max_vector';

if(sum(sum(Cs>1))==0 && sum(sum(Cs<-1))==0)
    disp('Matrix can be implemented in the DSP (i.e. coeffs in [-1 1])')
else
    disp('ERROR!!!! Matrix cannot be implemented in the DSP (i.e. coeffs not in [-1 1])')
end

% To visualize the data, we split the B load data in two sets: the one 
% with 5 kg data, and the one with 25 kg data. 
LightWeightLoads = 1:16;
HeavyWeightLoads = 17:24;

B5 = B(LightWeightLoads,:);
B25 = B(HeavyWeightLoads,:);
% The a-priori known gravity acceleration are just the load force divided by the
% weight 
acc5 = B5(:,1:3)/F1;
acc25 = B25(:,1:3)/F2;
B_pred5 = B_pred(LightWeightLoads,:);
B_pred25 = B_pred(HeavyWeightLoads,:);

% do some nice plots on the forces
ellipsoidfit_smart(B_pred5(:,1:3),acc5);
% ellipsoidfit_smart(B_pred25(:,1:3),acc25);
% axis equal;


%% write calibration matrix to file
 write_matrix;

%% plot the results
% nicePlots

% don't pollute the output directorty for now
% copyfile('matrix_out.txt',['../' sensNum '/matrix_' sensNum '.txt'])
% delete('matrix_out.txt')
