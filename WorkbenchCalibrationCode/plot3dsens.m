%% START DATA CALC
clear
close all
clc
sens_list = [26];
sens_num=length(sens_list)
load('boundary_colormap_2500','mycmap')

    
sensErrText = 'SNerr';
sensErrText = 'SN141';  % 107+35-1
SENSOR_NUM=107+35-1;
sensErrText = 'SN119';  % 85+35-1
SENSOR_NUM=85+35-1;     % sensore di riferimento

for i=1:1:sens_num
sensNum = sprintf ('SN%03d', sens_list(i));
sensNumDataPath = getSensorWorkBenchCalibrationDataFolder(sensNum);
    if (exist([sensNumDataPath '/output1.dat'], 'file') == 0 | i < 35) 
        sensErrTextDataPath = getSensorWorkBenchCalibrationDataFolder(sensNum);
        
        o01(:,:,i) = load([sensErrTextDataPath 'output1.dat']);  o01m(:,i)=mean(o01(1:1000,1:7,i)); [m,n,p] = size(o01); o01r(:,:,i)=o01(:,:,i)-repmat(o01m(:,i),1,m)'; 
        o03(:,:,i) = load([sensErrTextDataPath 'output3.dat']);  o03m(:,i)=mean(o03(1:1000,1:7,i)); [m,n,p] = size(o03); o03r(:,:,i)=o03(:,:,i)-repmat(o03m(:,i),1,m)'; 
        o04(:,:,i) = load([sensErrTextDataPath 'output4.dat']);  o04m(:,i)=mean(o04(1:1000,1:7,i)); [m,n,p] = size(o04); o04r(:,:,i)=o04(:,:,i)-repmat(o04m(:,i),1,m)'; 
        o05(:,:,i) = load([sensErrTextDataPath 'output5.dat']);  o05m(:,i)=mean(o05(1:1000,1:7,i)); [m,n,p] = size(o05); o05r(:,:,i)=o05(:,:,i)-repmat(o05m(:,i),1,m)';
        o06(:,:,i) = load([sensErrTextDataPath 'output6.dat']);  o06m(:,i)=mean(o06(1:1000,1:7,i)); [m,n,p] = size(o06); o06r(:,:,i)=o06(:,:,i)-repmat(o06m(:,i),1,m)'; 
        o81(:,:,i) = load([sensErrTextDataPath 'output81.dat']); o81m(:,i)=mean(o81(1:1000,1:7,i)); [m,n,p] = size(o81); o81r(:,:,i)=o81(:,:,i)-repmat(o81m(:,i),1,m)'; 
        o82(:,:,i) = load([sensErrTextDataPath 'output82.dat']); o82m(:,i)=mean(o82(1:1000,1:7,i)); [m,n,p] = size(o82); o82r(:,:,i)=o82(:,:,i)-repmat(o82m(:,i),1,m)'; 
        o83(:,:,i) = load([sensErrTextDataPath 'output83.dat']); o83m(:,i)=mean(o83(1:1000,1:7,i)); [m,n,p] = size(o83); o83r(:,:,i)=o83(:,:,i)-repmat(o83m(:,i),1,m)'; 
        o84(:,:,i) = load([sensErrTextDataPath 'output84.dat']); o84m(:,i)=mean(o84(1:1000,1:7,i)); [m,n,p] = size(o84); o84r(:,:,i)=o84(:,:,i)-repmat(o84m(:,i),1,m)'; 
        o85(:,:,i) = load([sensErrTextDataPath 'output85.dat']); o85m(:,i)=mean(o85(1:1000,1:7,i)); [m,n,p] = size(o85); o85r(:,:,i)=o85(:,:,i)-repmat(o85m(:,i),1,m)';
        o86(:,:,i) = load([sensErrTextDataPath 'output86.dat']); o86m(:,i)=mean(o86(1:1000,1:7,i)); [m,n,p] = size(o86); o86r(:,:,i)=o86(:,:,i)-repmat(o86m(:,i),1,m)';
        o87(:,:,i) = load([sensErrTextDataPath 'output87.dat']); o87m(:,i)=mean(o87(1:1000,1:7,i)); [m,n,p] = size(o87); o87r(:,:,i)=o87(:,:,i)-repmat(o87m(:,i),1,m)';
        o88(:,:,i) = load([sensErrTextDataPath 'output88.dat']); o88m(:,i)=mean(o88(1:1000,1:7,i)); [m,n,p] = size(o88); o88r(:,:,i)=o88(:,:,i)-repmat(o88m(:,i),1,m)';   
        continue
    end;

    o01(:,:,i) = load([sensNumDataPath 'output1.dat']);  o01m(:,i)=mean(o01(1:1000,1:7,i)); [m,n,p] = size(o01); o01r(:,:,i)=o01(:,:,i)-repmat(o01m(:,i),1,m)'; 
    o03(:,:,i) = load([sensNumDataPath 'output3.dat']);  o03m(:,i)=mean(o03(1:1000,1:7,i)); [m,n,p] = size(o03); o03r(:,:,i)=o03(:,:,i)-repmat(o03m(:,i),1,m)'; 
    o04(:,:,i) = load([sensNumDataPath 'output4.dat']);  o04m(:,i)=mean(o04(1:1000,1:7,i)); [m,n,p] = size(o04); o04r(:,:,i)=o04(:,:,i)-repmat(o04m(:,i),1,m)'; 
    o05(:,:,i) = load([sensNumDataPath 'output5.dat']);  o05m(:,i)=mean(o05(1:1000,1:7,i)); [m,n,p] = size(o05); o05r(:,:,i)=o05(:,:,i)-repmat(o05m(:,i),1,m)';
    o06(:,:,i) = load([sensNumDataPath 'output6.dat']);  o06m(:,i)=mean(o06(1:1000,1:7,i)); [m,n,p] = size(o06); o06r(:,:,i)=o06(:,:,i)-repmat(o06m(:,i),1,m)'; 
    o81(:,:,i) = load([sensNumDataPath 'output81.dat']); o81m(:,i)=mean(o81(1:1000,1:7,i)); [m,n,p] = size(o81); o81r(:,:,i)=o81(:,:,i)-repmat(o81m(:,i),1,m)'; 
    o82(:,:,i) = load([sensNumDataPath 'output82.dat']); o82m(:,i)=mean(o82(1:1000,1:7,i)); [m,n,p] = size(o82); o82r(:,:,i)=o82(:,:,i)-repmat(o82m(:,i),1,m)'; 
    o83(:,:,i) = load([sensNumDataPath 'output83.dat']); o83m(:,i)=mean(o83(1:1000,1:7,i)); [m,n,p] = size(o83); o83r(:,:,i)=o83(:,:,i)-repmat(o83m(:,i),1,m)'; 
    o84(:,:,i) = load([sensNumDataPath 'output84.dat']); o84m(:,i)=mean(o84(1:1000,1:7,i)); [m,n,p] = size(o84); o84r(:,:,i)=o84(:,:,i)-repmat(o84m(:,i),1,m)'; 
    o85(:,:,i) = load([sensNumDataPath 'output85.dat']); o85m(:,i)=mean(o85(1:1000,1:7,i)); [m,n,p] = size(o85); o85r(:,:,i)=o85(:,:,i)-repmat(o85m(:,i),1,m)';
    o86(:,:,i) = load([sensNumDataPath 'output86.dat']); o86m(:,i)=mean(o86(1:1000,1:7,i)); [m,n,p] = size(o86); o86r(:,:,i)=o86(:,:,i)-repmat(o86m(:,i),1,m)';
    o87(:,:,i) = load([sensNumDataPath 'output87.dat']); o87m(:,i)=mean(o87(1:1000,1:7,i)); [m,n,p] = size(o87); o87r(:,:,i)=o87(:,:,i)-repmat(o87m(:,i),1,m)';
    o88(:,:,i) = load([sensNumDataPath 'output88.dat']); o88m(:,i)=mean(o88(1:1000,1:7,i)); [m,n,p] = size(o88); o88r(:,:,i)=o88(:,:,i)-repmat(o88m(:,i),1,m)'; 
end
%test=reshape (o83(:,2,:),2000,2)%debug
%test2=reshape (o83r(:,2,:),2000,2)%debug
o01r2 =reshape(o01r,1000,5,7,sens_num); 
o01r2m=reshape(mean(o01r2,1),5,7,sens_num);
o03r2 =reshape(o03r,1000,4,7,sens_num); 
o03r2m=reshape(mean(o03r2,1),4,7,sens_num);
o04r2 =reshape(o04r,1000,4,7,sens_num); 
o04r2m=reshape(mean(o04r2,1),4,7,sens_num);
o05r2 =reshape(o05r,1000,4,7,sens_num); 
o05r2m=reshape(mean(o05r2,1),4,7,sens_num);
o06r2 =reshape(o06r,1000,4,7,sens_num); 
o06r2m=reshape(mean(o06r2,1),4,7,sens_num);

o81r2 =reshape(o81r,1000,2,7,sens_num); 
o81r2m=reshape(mean(o81r2,1),2,7,sens_num);
o82r2 =reshape(o82r,1000,2,7,sens_num); 
o82r2m=reshape(mean(o82r2,1),2,7,sens_num);
o83r2 =reshape(o83r,1000,2,7,sens_num); 
o83r2m=reshape(mean(o83r2,1),2,7,sens_num);
o84r2 =reshape(o84r,1000,2,7,sens_num); 
o84r2m=reshape(mean(o84r2,1),2,7,sens_num);
o85r2 =reshape(o85r,1000,2,7,sens_num); 
o85r2m=reshape(mean(o85r2,1),2,7,sens_num);
o86r2 =reshape(o86r,1000,2,7,sens_num); 
o86r2m=reshape(mean(o86r2,1),2,7,sens_num);
o87r2 =reshape(o87r,1000,2,7,sens_num); 
o87r2m=reshape(mean(o87r2,1),2,7,sens_num);
o88r2 =reshape(o88r,1000,2,7,sens_num); 
o88r2m=reshape(mean(o88r2,1),2,7,sens_num);

big_o_absolute=[
o01r2m(1,:,:); %1
o01r2m(2,:,:); %2
o01r2m(3,:,:); %3
o01r2m(4,:,:); %4
o01r2m(5,:,:); %5
o03r2m(1,:,:); %6
o03r2m(2,:,:); %7
o03r2m(3,:,:); %8
o03r2m(4,:,:); %9
o04r2m(1,:,:); %10
o04r2m(2,:,:); %11
o04r2m(3,:,:); %12
o04r2m(4,:,:); %13
o05r2m(1,:,:); %14
o05r2m(2,:,:); %15
o05r2m(3,:,:); %16
o05r2m(4,:,:); %17
o06r2m(1,:,:); %18
o06r2m(2,:,:); %19
o06r2m(3,:,:); %20
o06r2m(4,:,:); %21
o81r2m(2,:,:); %21
o82r2m(2,:,:); %22
o83r2m(2,:,:); %23
o84r2m(2,:,:); %24
o85r2m(2,:,:); %25
o86r2m(2,:,:); %26
o87r2m(2,:,:); %27
o88r2m(2,:,:)]; %28

big_o_mean=mean(big_o_absolute,3)

good_values =repmat(big_o_absolute(:,:,SENSOR_NUM),[1 1 sens_num]);
good_values2=repmat(big_o_mean,[1 1 sens_num]);

% good values selects the first sensor of the list as 'reference sensor'
% good values2 select the mean of the list as 'reference sensor'
big_o_relative=big_o_absolute-good_values; 

good_output=round(big_o_absolute(:,2:7,SENSOR_NUM));

fid = fopen('good_vals.txt', 'w+');
fprintf(fid, 'SN%3d\r\n',SENSOR_NUM );
for ix=1:1:size(good_output,1)
    if (good_output(ix,0) == 0) 
        continue;
    end;
    for iy=1:1:size(good_output,2)   
        fprintf(fid, '%d \t',good_output(ix,iy));
    end
    fprintf(fid, '\r\n');
end
fprintf(fid, '2000\r\n');
fprintf(fid, '4000\r\n');
status = fclose(fid)

%% GRAPHIC PART

xl=[];
yl=[];
zl=[];
for k=2:1:7
    figure(k-1)    
    x_ax  =repmat ([1:1:29],sens_num,1);
    y_ax  =repmat ([1:1:start_sens start_sens+1:1:start_sens+14],29,1)';
    z_ax  =big_o_absolute  (:,k,:); 
%     z_ax  =big_o_relative  (:,k,:); 
    z_ax2 =reshape (z_ax,29,sens_num)';
    Col=reshape (big_o_relative(:,k,:),29,sens_num)'; 
    surf(z_ax2,Col,'FaceColor','interp');
                    %     h= bar3(z_ax2);
                    %     for i = 1:length(h)
                    %         zdata = get(h(i),'Zdata');
                    %         set(h(i),'Cdata',zdata)
                    %         %set(h,'EdgeColor','k')
                    %     end
    caxis([-10000 10000]); set(gcf,'Colormap',mycmap); colorbar;

    for kk=1:1:start_sens
        yl=[yl; sprintf('SN%03d', kk)];
    end
    for kk=start_sens+1:1:sens_num+start_sens
        yl=[yl; sprintf('SN%03d', sens_list(kk-start_sens))];
    end
    for kk=1:1:29
        xl=[xl; sprintf(' %2d', kk)];
    end
    set(gca,'YTick',1:1:sens_num);
    set(gca,'YTickLabel',yl);
    set(gca,'XTick',1:1:29);
    set(gca,'XTickLabel',xl);

    zlim([-24000 24000]);
    set(gca,'ZTick',-24000:2000:24000);
    for kk=-24000:2000:24000
       zl=[zl; sprintf(' %7d', kk)];
    end
    set(gca,'ZTickLabel',zl);
    xlabel('Trial');
    ylabel('Serial #');
    zlabel('Voltage');
    title(sprintf('Channel %d',k-1));
end

%% 

for k=2:1:7
    figure(k-1+10)    
    x_ax  =repmat ([1:1:29],sens_num,1);
    y_ax  =repmat ([1:1:sens_num],29,1)';
    z_ax  =big_o_relative  (:,k,:); 
    z_ax2 =reshape (z_ax,29,sens_num)';
    Col=reshape (big_o_relative(:,k,:),29,sens_num)'; 
    surf(z_ax2,Col,'FaceColor','interp');
                    %     h= bar3(z_ax2);
                    %     for i = 1:length(h)
                    %         zdata = get(h(i),'Zdata');
                    %         set(h(i),'Cdata',zdata)
                    %         %set(h,'EdgeColor','k')
                    %     end
    caxis([-10000 10000]); set(gcf,'Colormap',mycmap); colorbar;

    for kk=1:1:sens_num
        yl=[yl; sprintf('SN%03d', sens_list(kk))];
    end
    for kk=1:1:29
        xl=[xl; sprintf(' %2d', kk)];
    end
    set(gca,'YTick',1:1:sens_num);
    set(gca,'YTickLabel',yl);
    set(gca,'XTick',1:1:29);
    set(gca,'XTickLabel',xl);

    zlim([-24000 24000]);
    set(gca,'ZTick',-24000:2000:24000);
    for kk=-24000:2000:24000
       zl=[zl; sprintf(' %7d', kk)];
    end
    set(gca,'ZTickLabel',zl);
    xlabel('Trial');
    ylabel('Serial #');
    zlabel('Voltage');
    title(sprintf('Channel %d',k-1));
end