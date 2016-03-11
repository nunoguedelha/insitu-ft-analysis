max_full=zeros(1,6);
min_full=zeros(1,6);
for ri=1:6
    for ci=1:6
        if (C(ri,ci)>0) 
            maxvalf=32768*C(ri,ci);
            minvalf=-32768*C(ri,ci);
        else
            maxvalf=-32768*C(ri,ci);
            minvalf=32768*C(ri,ci);
        end
        max_full(ri)=max_full(ri)+maxvalf;
        min_full(ri)=min_full(ri)+minvalf;
    end
end
format short g
%max_full
%min_full
message = 'FullScale is:';    
message = strcat(message, sprintf('    %5.1fN',max_full(1)));
message = strcat(message, sprintf('    %5.1fN',max_full(2)));
message = strcat(message, sprintf('    %5.1fN',max_full(3)));
message = strcat(message, sprintf('    %5.1fNm',max_full(4)));
message = strcat(message, sprintf('    %5.1fNm',max_full(5)));
message = strcat(message, sprintf('    %5.1fNm',max_full(6)));
disp(message)
