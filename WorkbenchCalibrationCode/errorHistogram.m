%sensNumList = {'SN229', 'SN217', 'SN153', 'SN151', 'SN230', 'SN026', 'SN106571'}; %% 163,269,270,271 have different names
banList=[4,5,10,11,31,51,61,64,71,90,91,93,122,125,137,148,152,155,163,166,200,201,269,270,271,282,283]; % 31 51 and 61 have huge errors 172 and 240 too
%banList=[banList,15,27,32,44,80,83,100,112,113,116,117,119,128,129,131,132,135,136,139,144,154,165,172,173,178,179,180,186,187,191,203,207,208,209,218,219,230,240,256,257,258,287];%sensors with errors above 10N in atleast 1 test
banList=[banList,172,218,230,240,287]; %errors above 15
ii=1;
for i=3:289%289
    if (~sum(banList==i))
        if i<10
            snNum=strcat('SN00',num2str(i));
        else
            if i<100
                snNum=strcat('SN0',num2str(i));
                
            else
                snNum=strcat('SN',num2str(i));
            end
        end
        sensNumList(ii)={snNum};
        ii=ii+1;
    end
end

j=1;
for sensNum = sensNumList 
    sensNum
    calibrateWithWorkbanchData
    histArray(:,:,j)=B-B_pred;
    j=j+1;
  %  observeTest;
end
tocheck=[];
axisName={'Fx';'Fy';'Fz';'Tx';'Ty';'Tz'};
% for t=1:16
%     for ax=1:3
%     figure,
% histogram(histArray(t,ax,:))
% title(strcat('test ',num2str(t),'  ',axisName(ax)));
%     end
% end

[r,c,v] = ind2sub(size(histArray),find(abs(histArray)>10));
sensNumList(unique(v))
histArrayfiltered=histArray(:,:,setdiff(1:size(histArray,3),unique(v)));
for t=6:16
    for ax=1:2
    figure,
histogram(histArrayfiltered(t,ax,:))
title(strcat('test ',num2str(t),'  ',axisName(ax)));
xlabel('error in N');
ylabel('mode')
    end
end
