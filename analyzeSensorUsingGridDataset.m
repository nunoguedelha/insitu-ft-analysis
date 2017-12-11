%% Comparing the eccentrity of a "grid" dataset measured on the iCub Robot
% This script take dataset in the "grid" format (generated by
% sensorSelfCalibrator [1] module and copied to green datasets 
% with the according params.m file [2] ) on the iCub robot and compare
% the eccentrity of the force measurement. In theory the "grid" movement
% is slowly (so the only thing that matters is gravity) moving the legs,
% while the robot is fixed on the pole (so the only external force are
% on the root_link). In theory then the measured force should be equal
% to m*g , where g \in R^3 is the gravity expressed in the sensor frame.
% Hence the measured force should lie on a sphere (eccentrities 0,0) in
% theory. However imperfect sensor can have a different eccentricities (
% but in general they remain linear, so the sphere become an ellipsoid).
% For more on the theory behind this script, check [3,4].
% [1] : https://github.com/robotology-playground/sensors-calib-inertial/tree/feature/integrateFTSensors
% [2] : https://gitlab.com/dynamic-interaction-control/green-iCub-Insitu-Datasets
% [3] : Traversaro, Silvio, Daniele Pucci, and Francesco Nori.
%       "In situ calibration of six-axis force-torque sensors using accelerometer measurements."
%       Robotics and Automation (ICRA), 2015 IEEE International Conference on. IEEE, 2015.
% [4] : F. J. A. Chavez, S. Traversaro, D. Pucci and F. Nori, 
%       "Model based in situ calibration of six axis force torque sensors," 
%       2016 IEEE-RAS 16th International Conference on Humanoid Robots (Humanoids), Cancun, 2016


%%
%add required folders for use of functions
addpath external/quadfit
addpath utils
% name and paths of the data files
experimentName='/green-iCub-Insitu-Datasets/2017_12_5_TestGrid';% first sample with cable corrected ;

% Script options, meant to control the behavior of this script
scriptOptions = {};
scriptOptions.forceCalculation=true;%false;
scriptOptions.printPlots=true;%true
scriptOptions.raw=false;
scriptOptions.saveData=false;
scriptOptions.testDir=false;% to calculate the raw data, for recalibration always true
scriptOptions.filterData=true;
scriptOptions.estimateWrenches=true;
scriptOptions.useInertial=false;    
% Script of the mat file used for save the intermediate results
%scriptOptions.matFileName='dataEllipsoidAnalysis'; %newName
scriptOptions.matFileName='ftDataset';
%[dataset,~,~]=read_estimate_experimentData(experimentName,scriptOptions);
[dataset,~,~]=readExperiment (experimentName,scriptOptions);
% Sample to use less data
dataset=dataSampling(dataset,5);

% We carry the analysis just for a subset of the sensors
%{'left_leg','right_leg','right_foot','left_foot'};
sensorsToAnalize = {'right_leg'};

%% Check ellipsoid
for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    
    % We don't have a direct measure of the gravity acceleration in the
    % sensor, so we use the estimate FT as a undirected measure
    fittedEllipsoid_im.(ft) = ellipsoidfit_smart(dataset.filteredFtData.(ft)(:,1:3),dataset.estimatedFtData.(ft)(:,1:3));
    
    % If the measure was perfect, the radius of the force measurements
    % would be exactly m*|g| ~ m*9.81
    % We then can print the "mass" as seen by the sensor axis, by
    % computing the intersection of the ellipsoid with the x,y,z sensor
    % axis (if the x,y,z axis of the sensor are also the principal axis
    % of the ellipsoid, this are the radii of the ellipsoid in explicit form)
    intersections.(ft) = ellipsoid_intersectionWithAxis(fittedEllipsoid_im.(ft));
    g = 9.81;
    masses = intersections.(ft)/g;
    std_masses= std(masses);
    fprintf('The apparent mass attached (using gravity from kinematics) at the sensor %s for axis x,y,z are (%f,%f,%f)\n',ft,masses(1),masses(2),masses(3));
    
    
    
    % We do the same computation, but using the best fitt that does not
    % use the data on gravity (to avoid relyng on anything)
    fittedEllipsoid_noGravity.(ft) = ellipsoidfit_leastsquares(dataset.filteredFtData.(ft)(:,1),dataset.filteredFtData.(ft)(:,2),dataset.filteredFtData.(ft)(:,3));
    
    intersections_noGravity.(ft) = ellipsoid_intersectionWithAxis(fittedEllipsoid_noGravity.(ft));
    g = 9.81;
    masses_noGravity = intersections_noGravity.(ft)/g;
    std_noGravity= std(masses_noGravity);
    fprintf('The apparent mass attached (without using the model) at the sensor %s for axis x,y,z are (%f,%f,%f)\n',ft,masses_noGravity(1),masses_noGravity(2),masses_noGravity(3));
    
    
    
    %% We do exactly the same computation on the estimted FT data to get information on
    % the assume attached mass in the model
    % We don't have a direct measure of the gravity acceleration in the
    % sensor, so we use the estimate FT as a undirected measure
    fittedEllipsoid_im_circular.(ft) = ellipsoidfit_smart(dataset.estimatedFtData.(ft)(:,1:3),dataset.estimatedFtData.(ft)(:,1:3));
    
    % If the measure was perfect, the radius of the force measurements
    % would be exactly m*|g| ~ m*9.81
    % We then can print the "mass" as seen by the sensor axis, by
    % computing the intersection of the ellipsoid with the x,y,z sensor
    % axis (if the x,y,z axis of the sensor are also the principal axis
    % of the ellipsoid, this are the radii of the ellipsoid in explicit form)
    intersections_circular.(ft) = ellipsoid_intersectionWithAxis(fittedEllipsoid_im_circular.(ft));
    g = 9.81;
    masses_estimated = intersections_circular.(ft)/g;
    fprintf('The mass attached to the sensor %s (from the model) is (%f)\n',ft,masses_estimated(1));
    
    
    fprintf('The standard deviation among the axis of %s sensor  is %f\n',ft,std_masses);
    fprintf('The standard deviation among the axis (without using the model) of %s sensor  is %f\n',ft,std_noGravity);
    
    error=masses-masses_estimated;
    error_noGravity=masses_noGravity-masses_estimated;
    errorForces=error*9.81;
    error_noGravity_forces=error_noGravity*9.81;
    
    fprintf('The error at the sensor %s for axis x,y,z are (%f N ,%f N ,%f N)\n',ft,errorForces(1),errorForces(2),errorForces(3));
    
    fprintf('The error (without using the model) at the sensor %s for axis x,y,z are (%f N ,%f N ,%f N)\n',ft,error_noGravity_forces(1),error_noGravity_forces(2),error_noGravity_forces(3));
    
end


%% Remove offset (to check similarity by visual inspection)

% compute the offset that minimizes the difference with
% the estimated F/T (so if the estimates are wrong, the offset
% estimated in this way is wrong, its just for visualization purpose)

for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    %TODO: should find also the offset for the torques, using the
    %mean difference for now (this is wrong)
    [~,offsetTau]=removeOffset(dataset.filteredFtData.(ft)(:,4:6),dataset.estimatedFtData.(ft)(:,4:6));
    
    [offset,radii_m,~,R_m]=ellipsoid_im2ex(fittedEllipsoid_im.(ft));
    model.ftDataNoOffset.(ft)= dataset.filteredFtData.(ft)-repmat([offset',offsetTau],size( dataset.filteredFtData.(ft),1),1);
    center=zeros(size(offset));
    model.ellipsoid_im.(ft)=ellipsoid_ex2im(center,radii_m,R_m);
    
    [offset_noG,radii_noG,~,R_noG]=ellipsoid_im2ex(fittedEllipsoid_noGravity.(ft));
    no_model.ftDataNoOffset.(ft)= dataset.filteredFtData.(ft)-repmat([offset_noG',offsetTau],size( dataset.filteredFtData.(ft),1),1);
    no_model.ellipsoid_im.(ft)=ellipsoid_ex2im(center,radii_noG,R_noG);
    
end

%% Some visual inspection
if(scriptOptions.printPlots)
    %% plot comparison using gravity (model)
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        figure,
        plot3_matrix(model.ftDataNoOffset.(ft)(:,1:3),'b.'); hold on;
        plot3_matrix(dataset.estimatedFtData.(ft)(:,1:3),'g.'); hold on;
        plot_ellipsoid_im(model.ellipsoid_im.(ft),'EdgeColor','k');
        plot_ellipsoid_im(fittedEllipsoid_im_circular.(ft));
        legend('measuredData','estimatedData','Location','west');
        title(strcat({'Wrench space '},escapeUnderscores(ft)));
        xlabel('F_{x}');
        ylabel('F_{y}');
        zlabel('F_{z}');
        axis equal;
        
    end
    
    %% Plot sensor vs estimated (with offset computed the minimum distance
    % from estimated)
    figure;
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        subplot(1,2,ftIdx);
        plot3_matrix(model.ftDataNoOffset.(ft)(:,1:3));%5951:6208
        hold on;
        axis equal;
        plot3_matrix(dataset.estimatedFtData.(ft)(:,1:3));
        legend('measuredData','estimatedData','Location','west');
        title(strcat({'Wrench space '},escapeUnderscores(ft)));
        xlabel('F_{x}');
        ylabel('F_{y}');
        zlabel('F_{z}');
        axis equal;
        grid on;
    end
    % subtitle('Force estimated from the model and force measured (with offset removed)');
    
    
    %% Plot sensor vs estimated (with offset computed the minimum distance
    % from estimated)
    figure;
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        subplot(2,1,ftIdx);
        plot(model.ftDataNoOffset.(ft)(:,1:3));
        hold on;
        plot(dataset.estimatedFtData.(ft)(:,1:3));
        title(strcat({'Data no Offset vs estimated data '},escapeUnderscores(ft)));
        legend('F_{x}','F_{y}','F_{z}','F_{x2}','F_{y2}','F_{z2}','Location','west');
        xlabel('Samples');
        ylabel('N');
    end
    % subtitle('Force estimated from the model and force measured (with offset removed)');
    ax=[];
    lim=zeros(1,4);
    figure;
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        tax=  subplot(2,1,ftIdx);
        normOfError = normOfRows(model.ftDataNoOffset.(ft)(:,1:3)-dataset.estimatedFtData.(ft)(:,1:3));
        plot(normOfError);
        ax=[ax tax];
        title(strcat({'norm (NoOffset - estimated data) '},escapeUnderscores(ft)));
        legend('Norm','Location','west');
        xlabel('Samples');
        ylabel('N');
        limt=axis;
        if limt(4)>lim(4)
            lim=limt;
        end
    end
    
    axis(ax,lim);
    % subtitle('Error in norm between the force estimated from the model and the one measured (with offset removed)');
    
    %% plot not using gravity (model)
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        figure,
        plot3_matrix(no_model.ftDataNoOffset.(ft)(:,1:3),'b.'); hold on;
        %plot3_matrix(dataset.estimatedFtData.(ft)(:,1:3),'g.'); hold on;
        plot_ellipsoid_im(no_model.ellipsoid_im.(ft),'EdgeColor','m');
        [~,radii,~,R]=ellipsoid_im2ex(no_model.ellipsoid_im.(ft));
        [newSphere]=ellipsoid_ex2im([0,0,0],[min(radii),min(radii),min(radii)],R);
        plot_ellipsoid_im(newSphere,'EdgeColor','k');
        legend('measuredData','Location','west');
        title(strcat({'Wrench space no gravity '},escapeUnderscores(ft)));
        xlabel('F_{x}');
        ylabel('F_{y}');
        zlabel('F_{z}');
        axis equal;
    end
    
    %% Plot sensor vs estimated (with offset computed the minimum distance
    % from estimated)
    figure;
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        subplot(1,2,ftIdx);
        plot3_matrix(no_model.ftDataNoOffset.(ft)(:,1:3));%5951:6208
        hold on;
        axis equal;
        plot3_matrix(dataset.estimatedFtData.(ft)(:,1:3));
        legend('measuredData','estimatedData','Location','west');
        title(strcat({'Wrench space no gravity '},escapeUnderscores(ft)));
        xlabel('F_{x}');
        ylabel('F_{y}');
        zlabel('F_{z}');
        axis equal;
        grid on;
    end
    % subtitle('Force estimated from the model and force measured (with offset removed)');
    
    
    %% Plot sensor vs estimated (with offset computed the minimum distance
    % from estimated)
    figure;
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        subplot(2,1,ftIdx);
        plot(no_model.ftDataNoOffset.(ft)(:,1:3));
        hold on;
        plot(dataset.estimatedFtData.(ft)(:,1:3));
        title(strcat({'Data no Offset vs estimated data no gravity '},escapeUnderscores(ft)));
        legend('F_{x}','F_{y}','F_{z}','F_{x2}','F_{y2}','F_{z2}','Location','west');
        xlabel('Samples');
        ylabel('N');
    end
    % subtitle('Force estimated from the model and force measured (with offset removed)');
    ax=[];
    lim=zeros(1,4);
    figure;
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        tax=  subplot(2,1,ftIdx);
        normOfError = normOfRows(no_model.ftDataNoOffset.(ft)(:,1:3)-dataset.estimatedFtData.(ft)(:,1:3));
        plot(normOfError);
        ax=[ax tax];
        title(strcat({'norm (NoOffset - estimated data) no gravity '},escapeUnderscores(ft)));
        legend('Norm','Location','west');
        xlabel('Samples');
        ylabel('N');
        limt=axis;
        if limt(4)>lim(4)
            lim=limt;
        end
    end
    
    axis(ax,lim);
    % subtitle('Error in norm between the force estimated from the model and the one measured (with offset removed)');
    
end

