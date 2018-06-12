function [sensors] = readMultiSens(filename)
% This function is meant to read the ports using the MultipleAnalogSensors
% device

fid    = fopen(filename);
temporal=textscan(fid,'%s','delimiter','\n');
text=temporal{1};
sensorType={'gyroscope', 'accelerometer', 'magnetometer', 'orientation', 'temperature', 'ft', 'loadCell', 'encoderArray', 'skinPatch'};
timestamp=false;
for line=1:length(text)
    separated=regexp(text{line},') ','split');
    nrOfSensors=length(separated)-9;
    sensorNumber=1;
    lineInit=textscan(separated{1},'%f %f(');
    sensors.time(line)=lineInit{2};
    for j=1:length(separated)
        if j==1
            lineInit=textscan(separated{1},'%f %f(');
            sensors.time(line)=lineInit{2};
            bottleStart=regexp(separated{1},'(','once');
            separated{j}=separated{j}(bottleStart:end);
            if line==1
               sensors.time(length(text))=0; 
               sensors.time=sensors.time';
            end
        end
        if ~timestamp
            if (strcmp('(',separated(j)) || strcmp('()',separated(j)))
                if (line==1)
                    disp(strcat(sensorType{sensorNumber},' not active '))
                end
            else
                timestamp=true;
                noParenthesis=(separated{j});
                noParenthesis=noParenthesis(4:end);
                sensors.(sensorType{sensorNumber}).measures(line,:)=cell2mat(textscan(noParenthesis, '%f'));
                noParenthesis=(separated{j+1});
                noParenthesis=noParenthesis(1:end-1);
                sensors.(sensorType{sensorNumber}).time(line)=cell2mat(textscan(noParenthesis, '%f'));
                if (line==1) % if is the first time generating the structure, preallocate size
                    sensors.(sensorType{sensorNumber}).measures(length(text),:)=zeros(size(sensors.(sensorType{sensorNumber}).measures(:,line)));
                    sensors.(sensorType{sensorNumber}).time(length(text))=0;                    
                    % make the row values the actual position of the value
                    % instead of the column
                    sensors.(sensorType{sensorNumber}).time=sensors.(sensorType{sensorNumber}).time';
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