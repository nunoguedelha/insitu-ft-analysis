function [skinSample]=findSkinSample(time,sample,skinTime,timeDisplacement)
skinSample=-1;
desiredTime=time(sample)+timeDisplacement;
for t=2:length(skinTime)
   if (skinTime(t-1) <=desiredTime && desiredTime< skinTime(t))
      skinSample=t; 
   end
    
end

if skinSample==-1
    skinSample=length(skinTime);
end