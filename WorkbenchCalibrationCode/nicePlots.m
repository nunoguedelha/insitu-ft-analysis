%colormap
map = [1 1 0; 1 0 0];

figure(1)
titles = {'F_{x}','F_{y}','F_{z}','\tau_{x}','\tau_{y}','\tau_{z}'};
for i = 1 : 6
    h1(i) = subplot(2,3,i);
    bar(eLS(:,i),'FaceColor','r')
    xlim([0.5 24.5]);
    limits(i,:) = get(h1(i),'YLim');
    title(titles{i})
    grid on
end
limits(1:3,1) = min(limits(1:3,1));
limits(1:3,2) = max(limits(1:3,2));
limits(4:6,1) = min(limits(4:6,1));
limits(4:6,2) = max(limits(4:6,2));
for i = 1 : 6
    set(h1(i),'YLim',limits(i,:));
    set(get(h1(i),'XLabel'),'String','load condition number')
end
for i = 1 : 3
    set(get(h1(i),'YLabel'),'String','MSE error [N]')
    set(get(h1(i+3),'YLabel'),'String','MSE error [Nm]')
end

figure(2)
for i = 1 : 6
    h2(i) = subplot(2,3,i);
    bar([B(:,i) eLS(:,i)],'stacked')
    colormap(map)
    xlim([0.5 24.5]);
    limits(i,:) = get(h2(i),'YLim');
    title(titles{i})
    grid on
end

limits(1:3,1) = min(limits(1:3,1));
limits(1:3,2) = max(limits(1:3,2));
limits(4:6,1) = min(limits(4:6,1));
limits(4:6,2) = max(limits(4:6,2));
for i = 1 : 6
    set(h2(i),'YLim',limits(i,:));
    set(get(h2(i),'XLabel'),'String','load condition number')
end
for i = 1 : 3
    set(get(h2(i),'YLabel'),'String','load [N]')
    set(get(h2(i+3),'YLabel'),'String','load [Nm]')
end