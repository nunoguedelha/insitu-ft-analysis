FTplots(dataset.rawData,dataset.time, 'raw' )

rawsubset.rightleg=dataset.rawData.right_leg;
rawsubset.leftleg=dataset.rawData.left_leg;

subset.rightleg=dataset.ftData.right_leg;
subset.leftleg=dataset.ftData.left_leg;
FTplots(subset,dataset.time )
FTplots(rawsubset,dataset.time, 'raw' )

extrasub.rightleg=extraSample.right.rawData.right_leg;
extrasub.leftleg=extraSample.right.rawData.left_leg;

FTplots(extrasub,extraSample.right.time, 'raw' )

extrasub2.rightleg=extraSample.right.ftData.right_leg;
extrasub2.leftleg=extraSample.right.ftData.left_leg;

figure,
FTplots(extrasub2,extraSample.right.time )