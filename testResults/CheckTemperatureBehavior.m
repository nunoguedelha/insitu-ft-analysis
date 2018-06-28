% inspect variation of ft due to temperature.

run ('loadOrCalibrateMultipleDatasets.m'); 
% we assume the variable experimentNames has the following experiments
experimentNames={
 'green-iCub-Insitu-Datasets/baseline_16_24';
 'green-iCub-Insitu-Datasets/yoga_16_29';
 'green-iCub-Insitu-Datasets/2_yogas_16_32';
 'green-iCub-Insitu-Datasets/3_yogas_16_36';
 'green-iCub-Insitu-Datasets/stanby_16_42';
 'green-iCub-Insitu-Datasets/stanby_16_58';
 'green-iCub-Insitu-Datasets/stanby_17_13';
 'green-iCub-Insitu-Datasets/3_yogas_17_18';
 'green-iCub-Insitu-Datasets/stanby_17_35';
 'green-iCub-Insitu-Datasets/4_yogas_17_39_1_fail';
 'green-iCub-Insitu-Datasets/stanby_18_06';
 'green-iCub-Insitu-Datasets/3_yogas_18_10';
    };

names={
  'baseline';
  'yoga1';
  'yoga2';
  'yoga3';
  'stanby1';
  'stanby2';
  'stanby3';
  'yoga4';
  'stanby4';
  'yoga5';
  'stanby5';
  'yoga6'
};


yogas=[2;3;4;8;10;12];
stanby=[1,5,6,7,9,11]

%modify something in all datasets
% for in=1:length(experimentNames)
%     exp=strcat('e',num2str(in));
%     ftnames=fieldnames(data.(exp).temperature)
%     for ftIdx=1:length(ftnames)
%         ft=ftnames{ftIdx};
%     data.(exp).temperature.(ft)=data.(exp).temperature.(ft)';
%     end
% end



ft='right_leg';

force3DPlots(names(yogas),ft,data.e2.ftData.(ft),data.e3.ftData.(ft),data.e4.ftData.(ft),data.e8.ftData.(ft),data.e10.ftData.(ft),data.e12.ftData.(ft));
legendmarkeradjust(30)
force3DPlots(names(stanby),ft,data.e1.ftData.(ft),data.e5.ftData.(ft),data.e6.ftData.(ft),data.e7.ftData.(ft),data.e9.ftData.(ft),data.e11.ftData.(ft));
legendmarkeradjust(30)


% add same type of datasets
exp=strcat('e',num2str(stanby(1)));
allStanby=data.(exp);
for st=2:length(stanby)
    exp=strcat('e',num2str(stanby(st)));
   allStanby= addDatasets(allStanby,data.(exp));
end

exp=strcat('e',num2str(yogas(1)));
allYogas=data.(exp);
for yg=2:length(yogas)
    exp=strcat('e',num2str(yogas(yg)));
   allYogas= addDatasets(allYogas,data.(exp));
end