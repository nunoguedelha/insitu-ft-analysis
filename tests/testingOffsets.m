[inerOffset,inertialRaw]=calculateOffset(sensorsToAnalize,dataset.inertial.ftData,dataset.inertial.estimatedFtData,dataset.cMat,calibMatrices);
normalOffset=calculateOffset(sensorsToAnalize,dataset.inertial.ftData,dataset.inertial.estimatedFtData,dataset.cMat,dataset.cMat);
for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    for j=1:size(dataset.rawData.(ft),1)
        reCalibData2.(ft)(j,:)=calibMatrices.(ft)*(dataset.rawData.(ft)(j,:)')+inerOffset.(ft);
    end
end

for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    for j=1:size(dataset.rawData.(ft),1)
        measureNoOffset.(ft)(j,:)=dataset.filteredFtData.(ft)(j,:)'+normalOffset.(ft);
    end
end

for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    %     [filteredNoOffset.(ft),filteredOffset.(ft)]=removeOffset(dataset.filteredFtData.(ft),dataset.estimatedFtData.(ft));
    
    
    figure,
    plot3_matrix(measureNoOffset.(ft)(:,1:3)); grid on;hold on;
    plot3_matrix(dataset.estimatedFtData.(ft)(:,1:3)); grid on;hold on;
    plot3_matrix(reCalibData2.(ft)(:,1:3));
    
    legend('measuredDataNoOffset','estimatedData','reCalibratedData2','Location','west');
    title(strcat({'Wrench space '},escapeUnderscores(ft)));
    xlabel('F_{x}');
    ylabel('F_{y}');
    zlabel('F_{z}');
end

for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    for j=1:size(dataset.inertial.ftData.(ft),1)
        measureNoOffset2.(ft)(j,:)=dataset.inertial.ftData.(ft)(j,:)'+normalOffset.(ft);
         reCalibInertia2.(ft)(j,:)=calibMatrices.(ft)*(inertialRaw.(ft)(j,:)')+inerOffset.(ft);
    end
end

for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    %     [filteredNoOffset.(ft),filteredOffset.(ft)]=removeOffset(dataset.filteredFtData.(ft),dataset.estimatedFtData.(ft));
    
    
    figure,
    plot3_matrix(measureNoOffset2.(ft)(:,1:3)); grid on;hold on;
    plot3_matrix(dataset.inertial.estimatedFtData.(ft)(:,1:3)); grid on;hold on;
     plot3_matrix(reCalibInertia2.(ft)(:,1:3)); grid on;hold on;
    plot3_matrix(dataset.inertial.ftData.(ft)(:,1:3));
    
    legend('measuredDataNoOffset','estimatedData','recalibNoOffset','measuredWithOffset','Location','west');
    title(strcat({'Wrench space '},escapeUnderscores(ft)));
    xlabel('F_{x}');
    ylabel('F_{y}');
    zlabel('F_{z}');
end