function [MetBlueCorr,MetBlueBackground]=ratioPlaque_CorrectMetBluePerc(FilenameTotalRatioB,MetBlueRaw,Outside)
keyboard; % discontinued
FileinfoRatioB=getFileinfo_2(FilenameTotalRatioB);
% % % % MetBlueRaw=im2Matlab_3(FilenameTotalRatioB,'MetBlue');
% % % % Outside=im2Matlab_3(FilenameTotalRatioB,'Outside');

Pix=FileinfoRatioB.Pix{1};
Um=FileinfoRatioB.Um{1};
Res=FileinfoRatioB.Res{1};

% MetBlueBackground=sparseFilter(ExactMetBlue,Outside,Res,10000,[100;100;Res(3)*2],[2;2;2],90);
% MetBlueBackground=sparseFilter(ExactMetBlue,Outside,Res,10000,[100;100;Res(3)*5],[5;5;Res(3)*5],90);
[MetBlueBackground,MetBlueCorr]=sparseFilter(MetBlueRaw,Outside,Res,10000,[100;100;Res(3)*3],[10;10;Res(3)*3],90,SubtractBackground);

% MinMax=[min(MetBlueBackground(:));max(MetBlueBackground(:))];
% MetBlueCorr=uint16(single(MetBlueRaw)-single(MetBlueBackground)+single(MinMax(2)));

% ex2Imaris_2(MetBlueBackground,FilenameTotalRatioB,'MetBlueBackground');
% ex2Imaris_2(MetBlueCorr,FilenameTotalRatioB,'MetBlueCorr');

