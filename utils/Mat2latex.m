function [str]=Mat2latex(Mat,names2useCol,names2useRow)
% output example
% \begin{tabular}{|c|c|c|c|c|c|c|c| \\ 
%  \hline  
%  & Workbench & Yoga & gridMin30 & gridMin45 & Yogapp1st & Yogapp2nd & fastYogapp & fastYogapp2 \\ 
%  \hline  
%  Workbench & 1.0000 & 0.1729 & 1.1038 & 1.0337 & 0.5509 & 0.5753 & 0.4977 & 0.5813 \\ 
%  \hline  
%  Yoga & 1.0000 & 4.6482 & 0.1319 & 0.1829 & 0.2513 & 0.2369 & 0.3311 & 0.2426 \\ 
%  \hline  
%  gridMin30 & 1.0000 & 5.3259 & 0.1294 & 0.1099 & 0.2247 & 0.2542 & 0.2968 & 0.2561 \\ 
%  \hline  
%  gridMin45 & 1.0000 & 1.0250 & 0.3984 & 0.3020 & 0.2588 & 0.2348 & 0.3470 & 0.2581 \\ 
%  \hline  
%  Yogapp1st & 1.0000 & 1.2864 & 0.3303 & 0.2802 & 0.2825 & 0.2683 & 0.3526 & 0.2576 \\ 
%  \hline  
%  Yogapp2nd & 1.0000 & 1.0744 & 0.4351 & 0.3165 & 0.2800 & 0.2614 & 0.3657 & 0.2655 \\ 
%  \hline  
%  fastYogapp & 1.0000 & 1.1852 & 0.3318 & 0.2980 & 0.2787 & 0.2445 & 0.3494 & 0.2734 \\ 
%  \hline  
%  \end{tabular}

%cMat=cMat';%to easily print in the right order
[r,c]=size(Mat);
str=' \\begin{tabular}{|';
for columns=1:c+1
    str=strcat(str,'c|');
    
end
str=strcat(str,sprintf('} \\n \\\\hline  \\n '));
for columns=1:c
    str=strcat(str,sprintf(' & %s',names2useCol{columns}));
    
end
str=strcat(str,sprintf(' \\\\\\\\ \\n \\\\hline  \\n '));
for i=1:r
    str=strcat(str,sprintf(' %s',names2useRow{i}));
    for j=1:c
        
            str=strcat(str,sprintf(' & %0.4f',Mat(i,j)));
    end
    
        str=strcat(str,sprintf(' \\\\\\\\ \\n \\\\hline  \\n '));
    
end
str=strcat(str,sprintf(' \\\\end{tabular}'));
