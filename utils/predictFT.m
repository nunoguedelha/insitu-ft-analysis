function [ ft ] = predictFT( params, acc, vel )
%predictFT Predict the output of FT using a new set of inertial parameters 
    inertialParams = iDynTree.Vector10();
    inertialParams.fromMatlab(params);
    I = iDynTree.SpatialInertia();
    I.fromVector(inertialParams);
    
    a = iDynTree.SpatialAcc();
    v = iDynTree.Twist();
    ftPredicted1 = iDynTree.Wrench();
    ftPredicted2 = iDynTree.Wrench();

    nrOfSamples = size(acc,1);
    
    ft = zeros(nrOfSamples,6);
    
    for i = 1:nrOfSamples
        a.fromMatlab(acc(i,:));
        v.fromMatlab(vel(i,:));
        ftPredicted1 = (I*a);
        ftPredicted2 = v.cross(I*v);
        ft(i,:) = ftPredicted1.toMatlab() + ftPredicted2.toMatlab(); 
    end
    
end

