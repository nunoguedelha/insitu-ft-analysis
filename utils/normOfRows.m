function [ norm ] = normOfRows( matrix )
%NORMOFROWS Given a N * M matrix, return the N * 1 vector of norms of rows
norm = sqrt(sum(abs(matrix).^2,2));

end

