function detectSpineSize_2()
global W;
FilenameTotal='Kaichuan_s1.CA1.1.so1.lsm';
[Fileinfo,IndFileinfo,PathRaw]=getFileinfo_2(FilenameTotal);
Pix=Fileinfo.Pix{1};
Application=openImaris_2(PathRaw);
Application.SetVisible(1);

Application.GetDataSet.SetChannelName(0,'GFPMraw');
[GFPMcorr]=im2Matlab_3(Application,'GFPMraw');
ex2Imaris_2(GFPMcorr,Application,'GFPMcorr');

imarisSubtractBackground(Application,'GFPMcorr',0.7);


% % % ThresholdType='Kaichuan';
% % % Thresholds=table;
% % % Thresholds{'Kaichuan','Everything'}={struct('Smooth',0.1,'LowerManual',1)};
% % % Thresholds{'Elena','Everything'}={struct('Smooth',0.1,'Background',3,'LowerManual',8000)};
% % % Thresholds{'Kaichuan','Boutons'}={struct('Smooth',0.2,'Background',10,'LowerManual',6000)};
% % % Thresholds{'Elena','Boutons'}={struct('Smooth',0.2,'Background',10,'LowerManual',27000,'SeedsDiameter',4)};
% % % Thresholds.FirstIn(:,1)=8;
% % % Thresholds.FirstOut(:,1)=20;

% generate "Everything" surface
J = struct;
J.Application=Application;
J.SurfaceName='Everything';
J.Channel='GFPMcorr';
J.LowerManual=5;
J.SurfaceFilter=['"Volume" above 0.1 um^3'];
generateSurface3(J);

[Results]=getObjectInfo_2('Everything',[],Application);
J=struct;J.Application=Application;J.Channels='Everything';J.Feature='Id'; J.ObjectInfo=Results;
[Everything]=im2Matlab_3(J);

[~,Wave1]=max(Results.ObjInfo.Volume);
Dendrite=Everything; Dendrite(Everything~=Wave1)=0;
% clear Everything;

J=struct;
J.InCalc=1;
J.OutCalc=1;
J.Output={'DistInOut'};
J.Um=Fileinfo.Um{1};
J.ZeroBin=150;
J.UmBin=0.1;
[Out]=distanceMat_2(J,1-Dendrite);
Distance=Out.DistInOut;
clear Out;
ex2Imaris_2(Distance,Application,'Distance');


% generate DendriteCenter surface
J = struct;
J.Application=Application;
J.SurfaceName='DendriteCenter';
J.Channel='Distance';
J.Smooth=0.1;
J.LowerManual=153;
J.SurfaceFilter=['"Volume" above 0.1 um^3'];
generateSurface3(J);

[DendriteCenter]=im2Matlab_3(Application,'DendriteCenter',1,'Surface');
RadiusOut=round(0.21/Fileinfo.Res{1}(1));
RadiusOut=2*RadiusOut-1;
% DendriteCenter=imdilate(DendriteCenter,ones(7,7,7));
DendriteCenter=imdilate(DendriteCenter,ones(RadiusOut,RadiusOut));

DendriteCenter=max(DendriteCenter,[],3);
DendriteCenter=repmat(DendriteCenter,[1,1,Pix(3)]);
ex2Imaris_2(DendriteCenter,Application,'Dendrite');

ex2Imaris_2(GFPMcorr.*(1-DendriteCenter),Application,'GFPMcorr');

[Fileinfo]=getImarisFileinfo(Application);
ChannelList=varName2Col(Fileinfo.ChannelList{1});
% Wave1=strfind1(Fileinfo.ChannelList{1},'Distance');
% Wave2=Results.ObjInfo.IntensityMin(:,Wave1);
% Wave3=find(Wave2>140);


J = struct;
J.Application=Application;
J.SurfaceName='Spines';
J.Channel='GFPMcorr';
J.LowerManual=50;
J.SeedsDiameter=0.3;
J.SeedsFilter='"Quality" above 12.0';
J.SurfaceFilter=['"Intensity Min Ch=',num2str(ChannelList.Distance),'" above 140','"Volume" above 0.01 um^3','"Sphericity" above 0.37 um^3'];
generateSurface3(J);

[Results]=getObjectInfo_2('Spines',[],Application);
keybord;

Spines=Everything; Spine(Everything~=Wave1)=0;


keyboard; % calculate RadiusOut from res
Wave1=Dendrite-DendriteCenter;
RadiusOut=1;
[xx,yy,zz] = ndgrid(-RadiusOut(1):RadiusOut(1));
Circle=sqrt(xx.^2 + yy.^2 + zz.^2) <= RadiusOut(1);
Wave1=imerode(Wave1,Circle);

RadiusOut=2;
[xx,yy,zz] = ndgrid(-RadiusOut(1):RadiusOut(1));
Circle=sqrt(xx.^2 + yy.^2 + zz.^2) <= RadiusOut(1);
Wave1=imdilate(Wave1,Circle);

ex2Imaris_2(Wave1,Application,'SpineData2');

% SpineData=im2Matlab_3(Application,1);
ex2Imaris_2(GFPMcorr.*(1-DendriteCenter),Application,'GFPMcorr');



SpineData2=Distance;
SpineData2=SpineData2.*(1-DendriteCenter);
ex2Imaris_2(SpineData2,Application,'SpineData2');


% [Test]=im2Matlab_3(Application,'Filaments 1',1,'Surface');



[Everything]=im2Matlab_3(Application,'Everything',1,'Surface');