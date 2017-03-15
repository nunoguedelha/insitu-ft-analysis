function [data, time] = readMultiDataConnections(s,n)

for i=1:n
    st=strrep(s, '/data.log', strcat('_0000',num2str(i),'/data.log'));
    name=strcat('test',num2str(i));
[data.(name),time.(name)]=datareadDataDumper(st);
end