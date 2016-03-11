fid = fopen('report_input.txt', 'w+');
fprintf(fid, '  #              S1              S2              S3              S4              S5              S6           Fx(N)           Fy(N)           Fz(N)          Tx(Nm)          Ty(Nm)          Tz(Nm)\r\n') 

for iy=1:24
    fprintf(fid, '%3d ', iy);
    for ix=1:6
        fprintf(fid, '%+15.6f ', A(iy,ix));
    end
    for ix=1:6
        fprintf(fid, '%+15.6f ', B(iy,ix));
    end    
    fprintf(fid, '\r\n');
end


status = fclose(fid)