function [dataset]=applyMask(dataset,mask)
sizeRef=length(mask);
if (isstruct(dataset))
    dataFieldNames=fieldnames(dataset);
    for i=1:size(dataFieldNames,1)
        if(isstruct(dataset.(dataFieldNames{i})))
            dataset.(dataFieldNames{i})= applyMask(dataset.(dataFieldNames{i}),mask);
        else
            if  (isnumeric(dataset.(dataFieldNames{i})))
                if (ismatrix(dataset.(dataFieldNames{i})))
                    if(size(dataset.(dataFieldNames{i}),1)==sizeRef)
                    dataset.(dataFieldNames{i})=dataset.(dataFieldNames{i})(mask,:);
                    end
                else
                    if (isvector(dataset.(dataFieldNames{i})))
                        if(size(dataset.(dataFieldNames{i}),1)==sizeRef)
                        dataset.(dataFieldNames{i})=dataset.(dataFieldNames{i})(mask);
                        end
                    end
                end
            else
                if (iscell(dataset.(dataFieldNames{i})))
                    if(size(dataset.(dataFieldNames{i}),1)==sizeRef)
                        dataset.(dataFieldNames{i})=dataset.(dataFieldNames{i})(mask);
                    end
                end
            end
        end
    end
else
    if (isnumeric(dataset))
        if (ismatrix(dataset))
            if(size(dataset,1)==sizeRef)
            dataset=dataset(mask,:);
            end
        else
            if (isvector(dataset))
                if(size(dataset,1)==sizeRef)
                dataset=dataset(mask);
                end
            end
        end
    else
        if (iscell(dataset))
            if(size(dataset,1)==sizeRef)
                 dataset=dataset(mask);
            end
        end
    end
end