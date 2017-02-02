function indx=findForceIndex(forceMatrix,forces)
 indx=find(ismember(forceMatrix(:,1:length(forces)),forces,'rows'));


% indx=find(forceMatrix(:,1)==forces(1) & forceMatrix(:,2)==forces(2) & forceMatrix(:,3)==forces(3));
%    if(isempty(indx) %if there is no exact match look for the closer match available
%       temp=forceMatrix(:,1:length(forces))-repmat(forces, size(forceMatrix,1),1);
%       [~,indx]=min(abs(temp));
%    end
%        
       
 