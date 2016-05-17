function [ outputString ] = escapeUnderscores( inputString )
%ESCAPEUNDERSCORE Substitute underscores (_) with \_
    outputString = strrep(inputString, '_', '\_');
end

