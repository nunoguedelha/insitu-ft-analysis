%% Plotting script
%assumes is run as part of main, having params and dataset already loaded.
%script options
all=false;
noOffset=true;
onlyWSpace=true;

i0=4;%start from
ie=4;%until
%numbered as the filed in input.ftData
if(~onlyWSpace || all)
    
    if(~noOffset || all)
        % Plot ftDataNoOffset and/vs estimatedFtData
        for i=i0:ie
            %     for i=1:size(input.ftNames,1)
            FTplots(struct(input.ftNames{i},dataset.ftData.(input.ftNames{i}),strcat('estimated',input.ftNames{i}),dataset.estimatedFtData.(input.ftNames{i})),dataset.time);
        end
        
        % Plot ftDataNoOffset and/vs estimatedFtData
        for i=i0:ie
            %     for i=1:size(input.ftNames,1)
            FTplots(struct(input.ftNames{i},dataset.ftDataNoOffset.(input.ftNames{i}),strcat('estimated',input.ftNames{i}),dataset.estimatedFtData.(input.ftNames{i})),dataset.time);
        end
    end
    if(noOffset || all)
        for i=i0:ie
            %     for i=1:size(input.ftNames,1)
            FTplots(struct(input.ftNames{i},filterd.(input.ftNames{i}),strcat('estimated',input.ftNames{i}),dataset2.estimatedFtData.(input.ftNames{i})),dataset2.time);
        end
    end
    
end
if(onlyWSpace || all)
    % Plot forces in wrench space
    if(~noOffset || all)
        % %with offset
        for i=i0:ie
            %     for i=1:size(input.ftNames,1)
            figure,plot3_matrix(dataset.ftData.(input.ftNames{i})(:,1:3));hold on;
            plot3_matrix(dataset.estimatedFtData.(input.ftNames{i})(:,1:3)); grid on;
        end
        legend('measuredData','estimatedData','Location','west');
        title('Wrench space');
        xlabel('F_{x}');
        ylabel('F_{y}');
        zlabel('F_{z}');
    end
    
    if(noOffset || all)
        %without offset
        for i=i0:ie
            %     for i=1:size(input.ftNames,1)
            figure,plot3_matrix(dataset.ftDataNoOffset.(input.ftNames{i})(:,1:3));hold on;
            plot3_matrix(dataset.estimatedFtData.(input.ftNames{i})(:,1:3)); grid on;
        end
        legend('measuredDataNoOffset','estimatedData','Location','west');
        title('Wrench space');
        xlabel('F_{x}');
        ylabel('F_{y}');
        zlabel('F_{z}');
    end
end