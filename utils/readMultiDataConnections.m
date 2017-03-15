function [data, time] = readMultiDataConnections(s,n)

[data.data0,time.data0]=readDataDumper(s);

for i=1:min(n,9)
    st=strrep(s, '/data.log', strcat('_0000',num2str(i),'/data.log'));
    name=strcat('data',num2str(i));
[data.(name),time.(name)]=readDataDumper(st);
end

if(n>9 && n<100)
    for i=10:n
        st=strrep(s, '/data.log', strcat('_000',num2str(i),'/data.log'));
        name=strcat('data',num2str(i));
        [data.(name),time.(name)]=readDataDumper(st);
    end
    
end