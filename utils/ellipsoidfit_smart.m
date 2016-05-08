function [ p_implicit, output_data_refitted ] = ellipsoidfit_smart( output_elliptic_data, input_circular_data )
%% ELLIPSOIDFIT_SMART Fit a series of 3D data assuming that they are the affine function of a series of circular data 
% This functions has the format of the ellipsoidfit_* function find in
% quadfit (it also output the fitted ellipsoid in the same implicit format 
% used by quadfit) functions. The main difference is that in this case we 
% assume that the ellipsoid data to fit is obtained as an affine function
% of an input (circular) data:
% output = A*circular+b 
% where output \in R^3 , \circular^3 \in R^3 , A \in R^{3\times3}, b \in R^3
% 
% This format fits the problem of fitting the force measurement obtained 
% with a slowly movement of the FT sensor (i.e. only gravity matters)
% at which a constant mass is attached. In the case of correct calibration
% matrix, the ellipsoid fitted should be a circle, otherwise a different 
% ellipsoid is fitted 
% 
% To do this, we estimate the A and b elements of the affine function,
% and then we compute the ellipsoid parameters using A and b . 
% In the past we observer that exploiting the known information 
% about the "circular" data can improve the robustness of the ellipsoid 
% fitting, with respect to method (as the one contained in quadfit) that 
% ignore the circular data. 
% 
%ellipsoidfit_smart fit an 
    assert( size(output_elliptic_data,1) == size(input_circular_data,1) );
    n_samples = size(input_circular_data,1);
    assert( size(output_elliptic_data,2) == size(input_circular_data,2) );
    assert( size(output_elliptic_data,2) == 3 );
    
% This is how it works in theory, but it takes to much memory
%     known_terms = output_elliptic_data';
%     known_terms = known_terms(:);
%     regressor = [kron(input_circular_data,eye(3)),repmat(eye(3),n_samples)];
% In the next few lines we exploit the format of the data to compute 
    cov = zeros(12,12);
    acc = zeros(12,1);
    
    for i=1:n_samples
        input = input_circular_data(i,:);
        output = output_elliptic_data(i,:);
        regr = [kron(input,eye(3)),eye(3)];
        cov = cov + transpose(regr)*regr;
        acc = acc + transpose(regr)*(output');
    end
    
    x = pinv(cov)*acc;
        
    a = mean(sqrt(sum(input_circular_data.^2,2)));
    C = a*reshape(x(1:9),3,3);
    o = x(10:12);
    
%     figure
%     plot3(input_circular_data(:,1),input_circular_data(:,2),input_circular_data(:,3),'green');
%     hold on
%     plot3(output_elliptic_data(:,1),output_elliptic_data(:,2),output_elliptic_data(:,3),'red');
% 
     output_data_refitted = (C./a*input_circular_data'+o*ones(1,n_samples))';
%     hold on
%     plot3(output_from_input(:,1),output_from_input(:,2),output_from_input(:,3),'blue');
   
    %check ellipsoid_im2ex for the scheme used for implicit expression of
    %ellipsoid

    S = inv(C);
    Q = S'*S;
    v = -o'*Q;
    p_implicit = zeros(10,1);
    p_implicit(1) = Q(1,1);
    p_implicit(2) = Q(2,2);
    p_implicit(3) = Q(3,3);
    p_implicit(4) = 2*Q(1,2);
    p_implicit(5) = 2*Q(1,3);
    p_implicit(6) = 2*Q(2,3);
    p_implicit(7) = 2*v(1);
    p_implicit(8) = 2*v(2);
    p_implicit(9) = 2*v(3);
    p_implicit(10) = o'*Q*o-1;
   
    % figure
    % plot3_matrix_aspoints(input_circular_data./a);
    % plot3(output_elliptic_data(:,1),output_elliptic_data(:,2),output_elliptic_data(:,3),'b*');
    % plot_ellipsoid_im(p_implicit);
    % axis equal;

end

