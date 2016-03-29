function [filteredFtData,mask]=filterFtData(ftData)
ftNames=fieldnames(ftData);
N=2;
F=201;
for i=1:size(ftNames,1)
    filteredFtData.(ftNames{i})=zeros(size(ftData.(ftNames{i})));
    for channel=1:size(ftData.(ftNames{i}),2)
        y = ftData.(ftNames{i})(:,channel);
        nrOfSamples = length(ftData.(ftNames{i}));
        [b,g] = sgolay(N,F);
        HalfWin  = ((F+1)/2) -1;
        
        for n = (F+1)/2:nrOfSamples-(F+1)/2,
            % Zeroth derivative (smoothing only)
            filteredFtData.(ftNames{i})(n,channel) = dot(g(:,1),y(n - HalfWin:n + HalfWin));
            
        end
    end
end

mask= filteredFtData.(ftNames{i})(:,channel)~=0;