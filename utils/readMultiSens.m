function [gyroscope, accelerometer, magnetometer, orientation, temperature, ft, loadCell, encoderArray, skinPatch] = readMultiSens(filename)


fid    = fopen('test.txt');
temporal=textscan(fid,'%s','delimiter','\n')
text=temporal{1};
sensorType={'gyroscope', 'accelerometer', 'magnetometer', 'orientation', 'temperature', 'ft', 'loadCell', 'encoderArray', 'skinPatch'};
timestamp=false;
for line=1:length(text)
    separated=regexp(text{line},') ','split');
    nrOfSensors=length(separated)-9;
    sensorNumber=1;
    for j=1:length(separated)
        if ~timestamp
            if (strcmp('(',separated(j)) || strcmp('()',separated(j)))
                disp(strcat(sensorType{sensorNumber},' not active '))
                
            else
                timestamp=true;
                noParenthesis=(separated{j})
                noParenthesis=noParenthesis(4:end);
                sensors.(sensorType{sensorNumber}).measures(line,:)=cell2mat(textscan(noParenthesis, '%f'));
                noParenthesis=(separated{j+1})
                noParenthesis=noParenthesis(1:end-1);
                sensors.(sensorType{sensorNumber}).time(line)=cell2mat(textscan(noParenthesis, '%f'));
                if (line==1) % if is the first time generating the structure
                    sensors.(sensorType{sensorNumber}).measures(length(text),:)=zeros(size(sensors.(sensorType{sensorNumber}).measures(:,line)));
                    sensors.(sensorType{sensorNumber}).time(length(text))=0;
                end
            end
            sensorNumber=sensorNumber+1;
        else
            timestamp=false;
        end
    end
end

 if fclose(fid) == -1
    error('[ERROR] there was a problem in closing the file')
 end