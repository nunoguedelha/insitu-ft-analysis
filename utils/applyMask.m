function [dataset]=applyMask(dataset,mask)
if (isstruct(dataset))
    dataFieldNames=fieldnames(dataset);
    for i=1:size(dataFieldNames,1)
        if(isstruct(dataset.(dataFieldNames{i})))
            dataset.(dataFieldNames{i})= applyMask(dataset.(dataFieldNames{i}),mask);
        else
            if  (isnumeric(dataset.(dataFieldNames{i})))
                if (ismatrix(dataset.(dataFieldNames{i})))
                    
                    dataset.(dataFieldNames{i})=dataset.(dataFieldNames{i})(mask,:);
                    
                else
                    if (isvector(dataset.(dataFieldNames{i})))
                        dataset.(dataFieldNames{i})=dataset.(dataFieldNames{i})(mask);
                    end
                end
            end
        end
    end
else
    if (isnumeric(dataset))
        if (ismatrix(dataset))
            
            dataset=dataset(mask,:);
        else
            if (isvector(dataset))
                dataset=dataset(mask);
            end
        end
    end
end