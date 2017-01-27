stru.(names2use{i})='workbench';
for i=1:length(experimentNames)
   indx=(i-1)*length(lambdasNames)+2
    name=names2use{(i-1)*length(lambdasNames)+2}
    exp=experimentNames{i}
    stru.(name)=name;
    stru.(name).exp=experimentNames{i};
    for lam=1:length(lambdasNames)
        for j=1:length(sensorsToAnalize)
          innx2use=  (i-1)*length(lambdasNames)+1+lam
          sens=sensorsToAnalize{j}
         name2use=   (names2use{(i-1)*length(lambdasNames)+1+lam})
         lamdn=   lambdasNames{lam}
         stru.(name2use).(sens)=lamdn
         end
        n2use=names2use{(i-1)*length(lambdasNames)+1+lam}
        n=names2use{(i-1)*length(lambdasNames)+2}
       stru.(n2use).parentData=n
    end
end





% sequence for creating the names based on the experiment and lambda value
names={'Workbench';
%    'Yoga';
    'Yogapp1st';
%    'fastYogapp';
%    'Yogapp2nd';
    'fastYogapp2';
%    'gridMin30';
%    'gridMin45'
};% except for the first one all others are short names for the expermients in experimentNames
lambdasNames={'';
    '_l1';
    '_l1_5';
    '_l2';
    '_l4';
    '_l6';
    '_l8';
    '_l10'};

names2use{1}=names{1};
num=2;
for i=2:length(names)
    for j=1:length(lambdasNames)
        names2use{num}=(strcat(names{i},lambdasNames{j}));
        num=num+1;
    end
end
names2use=names2use';
toCompareWith='Yogapp1st'; %choose in which experiment will comparison be made, it must have inertial data stored

  paramScript=strcat('..//data/',experimentNames{1},'/params.m');
run(paramScript)
  ftNames=input.ftNames;

sensorsToAnalize = {'right_foot','right_leg'};  %load the new calibration matrices
framesNames={'l_sole','r_sole','l_lower_leg','r_lower_leg','root_link','l_elbow_1','r_elbow_1'}; %there has to be atleast 6
%framesNames={'r_sole','r_lower_leg','root_link'};
%load the experiment measurements

for i=1:length(experimentNames)
    paramScript=strcat('../data/',experimentNames{i},'/params.m');
    run(paramScript)
    [data.(names{(i-1)*length(lambdasNames)+2}),WorkbenchMat]=load_measurements_and_cMat(experimentNames{i},scriptOptions,26);
    if(input.hangingInit==1)
        load(strcat('../data/',experimentNames{i},'/',scriptOptions.matFileName,'.mat'),'dataset');
        [inertialData.(names{(i-1)*length(lambdasNames)+2})]=dataset.inertial;
    end
    for lam=1:length(lambdasNames)
        for j=1:length(sensorsToAnalize)
            sIndx= find(strcmp(ftNames,sensorsToAnalize{j}));
            cMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j}) = readCalibMat(strcat('../data/',experimentNames{i},'/calibrationMatrices/',input.calibMatFileNames{sIndx},lambdasNames{lam}));
            secMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j})= cMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j})/WorkbenchMat.(sensorsToAnalize{j});
        end
        data.(names2use{(i-1)*length(lambdasNames)+1+lam})=data.(names{(i-1)*length(lambdasNames)+2});
        inertialData.(names2use{(i-1)*length(lambdasNames)+1+lam}) =inertialData.(names{(i-1)*length(lambdasNames)+2});
    end
    
    %     if   (exist(strcat('../data/',experimentNames{i},'/',scriptOptions.matFileName,'.mat'),'file')==2)
    %          recabInsitu=load(strcat('../data/',experimentNames{i},'/',scriptOptions.matFileName,'.mat'));
    %     end
    
end
%set worbench calibration matrix information to general format
