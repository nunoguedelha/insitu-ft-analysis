%% Plotting script
%assumes is run as part of main, having params and dataset already loaded.
%script options
all=false;
noOffset=true;
onlyWSpace=true;

i0=4;%start from
ie=4;%until
%numbered as the filed in input.ftData

if(noOffset)
    for i=1:size(ftNames,1)
        [ftDataNoOffset.(ftNames{i}),offset.(ftNames{i})]=removeOffset(dataset.ftData.(ftNames{i}),dataset.estimatedFtData.(ftNames{i}));
    end
    dataset.ftDataNoOffset=ftDataNoOffset;
    
    for i=1:size(ftNames,1)
        [filteredNoOffset.(ftNames{i}),filteredOffset.(ftNames{i})]=removeOffset(dataset.filteredFtData.(ftNames{i}),dataset.estimatedFtData.(ftNames{i}));
    end
    dataset.filteredNoOffset=filteredNoOffset;
    dataset.filteredOffset=filteredOffset;
end


if(~onlyWSpace || all)
    
    if(~noOffset || all)
        % Plot ftDataNoOffset and/vs estimatedFtData
        for i=i0:ie
            FTplots(struct(ftNames{i},dataset.ftData.(ftNames{i}),strcat('estimated',ftNames{i}),dataset.estimatedFtData.(ftNames{i})),dataset.time);
       
            FTplots(struct(ftNames{i},filterd.(ftNames{i}),strcat('estimated',ftNames{i}),dataset.estimatedFtData.(ftNames{i})),dataset.time);
        end
       
    end
    if(noOffset || all)
         % Plot ftDataNoOffset and/vs estimatedFtData
        for i=i0:ie
            FTplots(struct(ftNames{i},dataset.ftDataNoOffset.(ftNames{i}),strcat('estimated',ftNames{i}),dataset.estimatedFtData.(ftNames{i})),dataset.time);
            FTplots(struct(ftNames{i},dataset.filteredOffset.(ftNames{i}),strcat('estimated',ftNames{i}),dataset.estimatedFtData.(ftNames{i})),dataset.time);
        end
        
    end
    
end
if(onlyWSpace || all)
    % Plot forces in wrench space
    if(~noOffset || all)
        % %with offset
        for i=i0:ie
            %     for i=1:size(ftNames,1)
            figure,plot3_matrix(dataset.ftData.(ftNames{i})(:,1:3));hold on;
            plot3_matrix(dataset.estimatedFtData.(ftNames{i})(:,1:3)); grid on;
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
            %     for i=1:size(ftNames,1)
            figure,plot3_matrix(dataset.ftDataNoOffset.(ftNames{i})(:,1:3));hold on;
            plot3_matrix(dataset.estimatedFtData.(ftNames{i})(:,1:3)); grid on;
        end
        legend('measuredDataNoOffset','estimatedData','Location','west');
        title('Wrench space');
        xlabel('F_{x}');
        ylabel('F_{y}');
        zlabel('F_{z}');
    end
end