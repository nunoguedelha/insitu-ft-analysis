function H=wrenchSpacePlots(namesDatasets,graphName,varargin)
H=figure,
if (length(namesDatasets) <=length(varargin))    
    for n=1:length(namesDatasets)
        if ismatrix(varargin{n})
            if(length(namesDatasets)<length(varargin))
            plot3_matrix(varargin{n}(:,1:3),varargin{length(namesDatasets)+1:end}); grid on;hold on;
            else
                 plot3_matrix(varargin{n}(:,1:3)); grid on;hold on;
            end
        else
            warning('Something is wrong, matrix was expected');
        end
    end
    legend(namesDatasets,'Location','west');
    title(strcat({'Wrench space '},escapeUnderscores(graphName)));
    xlabel('F_{x}');
    ylabel('F_{y}');
    zlabel('F_{z}');
else
    warning('Insuficient arguments');
end