fid = fopen('matrix_out.txt', 'w+');
for iy=1:6
    for ix=1:6
        temp=convert_onedotfifteen(Cs(iy,ix));
        fprintf(fid, '%s\r\n', temp);
    end
end
fprintf(fid, '%d\r\n', 1);
fprintf(fid, '%d\r\n', max_Fx);
fprintf(fid, '%d\r\n', max_Fy);
fprintf(fid, '%d\r\n', max_Fz);
fprintf(fid, '%d\r\n', max_Tx);
fprintf(fid, '%d\r\n', max_Ty);
fprintf(fid, '%d\r\n', max_Tz);

status = fclose(fid)