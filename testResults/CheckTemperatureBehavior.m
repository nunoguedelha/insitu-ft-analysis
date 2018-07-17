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
    %'yoga6'
    };


yogas=[2;3;4;8;10];%;12];
stanby=[1,5,6,7,9,11];

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

% check normal ft data
ftnames=fieldnames(data.(exp).temperature)
for ftIdx=1:length(ftnames)
    ft=ftnames{ftIdx};
    figure,
    plot(allStanby.temperature.(ft),allStanby.ftData.(ft),'.')
    legend('F_{x}','F_{y}','F_{z}','\tau_{x}','\tau_{y}','\tau_{z}','Location','west');
    
    title(escapeUnderscores(ft));
    xlabel('Degrees (C)');
    ylabel('N');
    legendmarkeradjust(30)
    
end


%check raw data filtered
ftnames=fieldnames(data.(exp).temperature)
for ftIdx=1:length(ftnames)
    ft=ftnames{ftIdx};
    figure,
    plot(allStanby.temperature.(ft),allStanby.rawDataFiltered.(ft),'.')
    legend('ch1','ch2','ch3','ch4','ch5','ch6','Location','west');
    
    title(escapeUnderscores(ft));
    xlabel('Degrees (C)');
    ylabel('N');
    legendmarkeradjust(30)
    
end


%check raw data filtered in yogas
ftnames=fieldnames(data.(exp).temperature)
for ftIdx=1:length(ftnames)
    ft=ftnames{ftIdx};
    figure,
    plot(allYogas.temperature.(ft),allYogas.rawDataFiltered.(ft),'.')
    legend('ch1','ch2','ch3','ch4','ch5','ch6','Location','west');
    
    title(escapeUnderscores(ft));
    xlabel('Degrees (C)');
    ylabel('N');
    legendmarkeradjust(30)
    
end



% plot secondary matrix format
for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    
    if (calibOptions.secMatrixFormat)
        secMat.(ft)= calibMatrices.(ft)/dataset.cMat.(ft);
        xmlStr=cMat2xml(secMat.(ft),ft)% print in required format to use by WholeBodyDynamics
    end
    % Evaluation of results
    if (calibOptions.resultEvaluation)
        disp(ft)
        %Workbench_no_offset_mse=mean((filteredNoOffset.(ft)-dataset.estimatedFtData.(ft)).^2)
        New_calibration_no_offset_mse=mean((reCalibData.(ft)-dataset.estimatedFtData.(ft)).^2)
        %Workbench_mse=mean((dataset.ftData.(ft)-dataset.estimatedFtData.(ft)).^2)
    end
end
