%% Plotting script
%assumes is run as part of main, having params and dataset already loaded.
%script options
all=false;
noOffset=true;
onlyWSpace=true;
filtered=true;

%numbered as the filed in input.ftData

if(noOffset || all)
       % compute the offset that minimizes the difference with 
    % the estimated F/T (so if the estimates are wrong, the offset
    % estimated in this way will be totally wrong) 
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        [ftDataNoOffset.(ft),offset.(ft)]=removeOffset(dataset.ftData.(ft),dataset.estimatedFtData.(ft));
        
        [filteredNoOffset.(ft),filteredOffset.(ft)]=removeOffset(dataset.filteredFtData.(ft),dataset.estimatedFtData.(ft));
    end
    dataset.ftDataNoOffset=ftDataNoOffset;
    dataset.filteredNoOffset=filteredNoOffset;
    
end


if(~onlyWSpace || all)
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        if(~noOffset || all)
            % Plot ftDataNoOffset and/vs estimatedFtData
            if(~filtered ||all)
                FTplots(struct(ft,dataset.ftData.(ft),strcat('estimated',ft),dataset.estimatedFtData.(ft)),dataset.time);
            else
                FTplots(struct(ft,dataset.filteredFtData.(ft),strcat('estimated',ft),dataset.estimatedFtData.(ft)),dataset.time);
            end
        end
        if(noOffset || all)
            % Plot ftDataNoOffset and/vs estimatedFtData
            if(~filtered ||all)
                FTplots(struct(ft,dataset.ftDataNoOffset.(ft),strcat('estimated',ft),dataset.estimatedFtData.(ft)),dataset.time);
            else
                FTplots(struct(ft,dataset.filteredNoOffset.(ft),strcat('estimated',ft),dataset.estimatedFtData.(ft)),dataset.time);
            end
        end
    end
end
if(onlyWSpace || all)
    % Plot forces in wrench space
    if(~noOffset || all)
        % %with offset
       for ftIdx =1:length(sensorsToAnalize)
           ft = sensorsToAnalize{ftIdx};

            figure,plot3_matrix(dataset.ftData.(ft)(:,1:3));hold on;
            plot3_matrix(dataset.estimatedFtData.(ft)(:,1:3)); grid on;
        end
        legend('measuredData','estimatedData','Location','west');
        title(strcat({'Wrench space '},escapeUnderscores(ft)));
        xlabel('F_{x}');
        ylabel('F_{y}');
        zlabel('F_{z}');
        axis equal;
    end
    
    if(noOffset || all)
        %without offset
       for ftIdx =1:length(sensorsToAnalize)
           ft = sensorsToAnalize{ftIdx};

            figure,plot3_matrix(dataset.ftDataNoOffset.(ft)(:,1:3));hold on;
            plot3_matrix(dataset.estimatedFtData.(ft)(:,1:3)); grid on;
        end
        legend('measuredDataNoOffset','estimatedData','Location','west');
        title(strcat({'Wrench space '},escapeUnderscores(ft)));
        xlabel('F_{x}');
        ylabel('F_{y}');
        zlabel('F_{z}');
        axis equal;
    end
end