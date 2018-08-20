function [ offset_ft, svdRank ] = estimateOffsetUsingInSitu( ft_raw, acc)
%estimateOffsetUsingInSitu Estimate FT offset using the techniques
%described in the paper
% In situ calibration of six-axis force-torque sensors using accelerometer measurements
plotOption=false;

%% Subspace estimation
ft_raw_no_mean = ft_raw-ones(size(ft_raw,1),1)*mean(ft_raw);
ft_raw_mean = mean(ft_raw);
    
[U_raw,S_ft_raw,V_raw] = svd(ft_raw_no_mean,'econ');

ft_raw_projector = V_raw(:,1:3)';
ft_raw_projected = (V_raw(:,1:3)'*ft_raw_no_mean')';

if plotOption
figure,bar((S_ft_raw));
title('Raw sensor data singular values')
end

%max(diag(S_ft_raw))
%min(diag(S_ft_raw))
%rank(S_ft_raw)

normalize = @(x) (x-ones(size(x,1),1)*mean(x))./(ones(size(x,1),1)*std(x));
normalize_isotropically = @(x) (x-ones(size(x,1),1)*mean(x))/mean(std(x));

% normalize data
ft_raw_projected_norm = normalize(ft_raw_projected);


%% 
%Plotting ellipsoid fitted in raw space
%fprintf(['Fitting ft ellipsoid\n']);
[p_ft_norm,ft_proj_norm_refitted]   = ellipsoidfit_smart(ft_raw_projected_norm,acc);
%fprintf(['Fitting acc ellipsoid\n']);
% p_acc  = ellipsoidfit(acc(1:end,1),acc(1:end,2),acc(1:end,3));
if plotOption
figure
plot_ellipsoid_im(p_ft_norm);
plot3_matrix(ft_raw_projected_norm(1:end,:));
axis equal
title('Ellipsoid fitted in FT raw space');
end
% Offset estimation
[centers,ax] = ellipsoid_im2ex(p_ft_norm);
center_ft_proj = denormalize2(centers',mean(ft_raw_projected),std(ft_raw_projected));
offset_ft = ((ft_raw_projector')*center_ft_proj')'+ft_raw_mean;
offset_ft=-offset_ft;

end

