function [filteredFtData,mask]=filterFtData(ftData)
% FILTERFTDATA Filter the FT data contained in the dataset ftData 
% A sgolay filter with N = 2 and F = 201 is run on the sensors measurement
% to smooth the sensors value
% The function returns in output a filteredFtData structure that contains 
% the filteredFata and a mask for the value of the original samples that
% are not zero in the filtered version 

ftNames=fieldnames(ftData);
N=2;
F=101;
%premask= filteredFtData.(ftNames{1})(:,1)==0;
for i=1:size(ftNames,1)
    filteredFtData.(ftNames{i})=zeros(size(ftData.(ftNames{i})));
    for channel=1:size(ftData.(ftNames{i}),2)
        y = ftData.(ftNames{i})(:,channel);
        nrOfSamples = length(ftData.(ftNames{i}));
        [b,g] = sgolay(N,F);
        HalfWin  = ((F+1)/2) -1;
        %premask=filteredFtData.(ftNames{i})(:,channel)==0 ||; TODO
        %consider the ceros already present not to be erased by mask
        for n = (F+1)/2:nrOfSamples-(F+1)/2
            % Zeroth derivative (smoothing only)
            filteredFtData.(ftNames{i})(n,channel) = dot(g(:,1),y(n - HalfWin:n + HalfWin));
        end
        
    end
end

mask= filteredFtData.(ftNames{i})(:,1)~=0;