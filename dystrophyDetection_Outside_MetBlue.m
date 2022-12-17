function [Outside]=dystrophyDetection_Outside_MetBlue(MetBlue,Res)


MetBlue=depthIntensityFitting(MetBlue,Res,50,1000);
Outside=MetBlue<1000;
[Outside]=dystrophyDetection_Outside(Outside,Res);

% optimize MetBlue
[~,MetBlue]=sparseFilter(MetBlue,Outside,Res,10000,[100;100;1],[10;10;Res(3)],70,'Multiply1000');

% refine outside
Outside=MetBlue<500;
[Outside]=dystrophyDetection_Outside(Outside,Res);