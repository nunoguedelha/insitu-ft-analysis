function [ dataset ] = smoothAndEstimateVelAcc( dataset, N, F  )
%smoothAndEstimateVelAcc smooth joint position and estimate vel and acc
%   
dataset.qRaw = dataset.q;
dataset.dq = zeros(size(dataset.q));
dataset.d2q = zeros(size(dataset.q)); 

for channel = 1:size(dataset.q,2);
    % compute timestamp from dataset 
    y = dataset.q(:,channel);
    ds = mean(diff(dataset.time));
    nrOfSamples = length(dataset.time);
    [b,g] = sgolay(N,F);
    HalfWin  = ((F+1)/2) -1;

    for n = (F+1)/2:nrOfSamples-(F+1)/2,
        % Zeroth derivative (smoothing only)
        dataset.q(n,channel) = dot(g(:,1),y(n - HalfWin:n + HalfWin));

        % 1st differential
        dataset.dq(n,channel) = dot(g(:,2),y(n - HalfWin:n + HalfWin));

        % 2nd differential
        dataset.d2q(n,channel) = 2*dot(g(:,3)',y(n - HalfWin:n + HalfWin))';
    end

    dataset.dq(:,channel) = dataset.dq(:,channel)/ds;         % Turn differential into derivative
    dataset.d2q(:,channel) = dataset.d2q(:,channel)/(ds*ds);    % and into 2nd derivative
    
    % trim the dataset

end

% smooth also FT measurements 
% for channel = 1:size(dataset.ft,2);
%     % compute timestamp from dataset 
%     y = dataset.ft(:,channel);
%     nrOfSamples = length(dataset.time);
%     [b,g] = sgolay(N,F);
%     HalfWin  = ((F+1)/2) -1;
% 
%     for n = (F+1)/2:nrOfSamples-(F+1)/2,
%         % Zeroth derivative (smoothing only)
%         dataset.ft(n,channel) = dot(g(:,1),y(n - HalfWin:n + HalfWin));
%     end
%     % trim the dataset
% 
% end

end
