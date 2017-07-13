%This script will be used to load, compare and analise the behaviour of 4 torque sensors to a known set of forces and torques.

% addpath external/quadfit
% addpath utils
% name and paths of the data files
%/home/francisco/dev/forcetorque-yarp-devices/dataAnalysis/data/trash/ft
%test directory
experimentName='dumper';% Name of the experiment;
paramScript=strcat('data/',experimentName,'/ft/benchparams.m');
run(paramScript)

names=fieldnames(sensors);

for i=1:length(names)
    [data.(names{i}), time.(names{i})] = readMultiDataConnections(strcat('data/',experimentName,'/ft/',names{i},'/analog:o/data.log'),n);

end

    [data]=preprocessOptoforce(data);
    bench=benchmark;
    bench=fillTestsFromAllData(bench,data,time,sensors,bias);
    r=compareAllTests(bench);
    bench.plots=true;
    [ellipsoids]=checkSphereBehaviour(bench,false);
     [ellipsoids]=checkSphereBehaviour(bench,true);
     
     averageError=sum(abs(r.errors))/size(r.errors,1);
     averageStd=sum(abs(r.stds))/size(r.stds,1);
     
     %todo: include sensor full scale
     for i=1:length(names)
         fullScaleError(:,:,i)=r.errors(:,:,i)./repmat(sensors.(names{i}).fullscale,size(r.errors,1),1);
         
     end
     
     
   
     