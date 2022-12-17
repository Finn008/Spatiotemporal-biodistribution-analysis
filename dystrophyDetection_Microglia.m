function [Microglia,Soma,Fibers,Iba1Corr,MicrogliaInfo]=dystrophyDetection_Microglia(FilenameTotal,Pix,Res)

[Iba1]=im2Matlab_3(FilenameTotal,'Iba1');
[Outside]=im2Matlab_3(FilenameTotal,'Outside');
% [Iba1Perc]=im2Matlab_3(FilenameTotal,'Iba1Perc');

[~,Iba1Corr]=sparseFilter(Iba1,Outside,Res,10000,[200;200;1],[10;10;Res(3)],50,'Multiply30');

J=struct('DataOutput','AllPercentiles');
Iba1Perc=percentiler(Iba1Corr,Outside,J);


[Microglia,Soma,Fibers,MicrogliaInfo]=dystrophyDetection_Microglia_Soma_2(Iba1Perc,Iba1Corr,Iba1,Pix,Res,FilenameTotal);
% [Soma,Fibers,MicrogliaInfo]=dystrophyDetection_Microglia_Soma_2(Iba1Perc,Iba1Corr,Pix,Res,FilenameTotal),



return;
% % % ex2Imaris_2(Iba1Perc,FilenameTotal,'Iba1Perc');
% % % ex2Imaris_2(Iba1Corr,FilenameTotal,'Iba1Corr');
Application=openImaris_2(FilenameTotal); Application.SetVisible(1);
Application.SetVisible(1);


%% previously start
BW=bwconncomp(Iba1Perc>95,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
Table.Volume=Table.NumPix*prod(Res);
Table=Table(Table.Volume>1,:);
Mask=zeros(Pix.','uint8');
Mask(cell2mat(Table.IdxList))=1;

Mask=Mask+imclearborder(1-Mask,4); % close islands in Mask
% % % ex2Imaris_2(Mask,FilenameTotal,'Mask'); disp('Mask');
J=struct;
J.OutCalc=1;
J.ZeroBin=0;
J.Output={'DistInOut'};
J.Res=Res;
J.UmBin=0.1;
[Out]=distanceMat_2(J,1-Mask);
Distance=Out.DistInOut; clear Out;
% % % ex2Imaris_2(Distance,FilenameTotal,'Distance'); disp('Distance');
Nuclei=Distance>10;

J=struct;
J.OutCalc=1;
J.ZeroBin=0;
J.Output={'DistInOut'};
J.Res=Res;
J.UmBin=0.1;
[Out]=distanceMat_2(J,Nuclei);
Distance2=Out.DistInOut; clear Out;

DistanceThreshold=10;
Soma=Mask;Soma(Distance2>DistanceThreshold)=0;
Fibers=Mask;Fibers(Distance2<=DistanceThreshold)=0;

Microglia=Mask+uint8(Soma);
ex2Imaris_2(Microglia,FilenameTotal,'Microglia'); disp('Microglia');
% Application=openImaris_2(FilenameTotal); Application.SetVisible(1);
% Application.SetVisible(1);

Microglia=Microglia>0;
%% previously end

return;
ex2Imaris_2(Iba1,FilenameTotal,'Iba1Corr');

[Fileinfo]=getFileinfo_2(FilenameTotal);



Wave1=strfind1(Fileinfo.ChannelList,'Iba1Corr',1);
Application=openImaris_2(FilenameTotal); Application.SetVisible(1);
Application.GetImageProcessing.SubtractBackgroundChannel(Application.GetDataSet,Wave1-1,1);
imarisSaveHDFlock(Application,FilenameTotal);

[Iba1Corr]=im2Matlab_3(FilenameTotal,'Iba1Corr');
[~,Iba1Corr2]=sparseFilter(Iba1Corr,Outside,Res,10000,[2;2;1],[1;1;Res(3)],50,'Multiply500');
ex2Imaris_2(Iba1Corr2,FilenameTotal,'Iba1Corr2');
% define the somata
% [Mask]=dystrophyDetection_Microglia_Soma(Iba1Perc,Iba1Corr,Pix,Res,FilenameTotal);
[Soma,Fibers]=dystrophyDetection_Microglia_Soma(Iba1Perc,Iba1Corr,Pix,Res,FilenameTotal);

% define the fibers
[Mask]=dystrophyDetection_Microglia_Fibers(Fibers,Iba1Corr,Soma,Pix,Res,Application);




return;








[Mask]=dystrophyDetection_Microglia_TotalMap(Iba1Perc,Pix,Res);
ex2Imaris_2(Mask,Application,'Everything');
% now find a more close mask to identify microglia soma















% Mask=zeros(Pix(1),Pix(2),Pix(3),'uint16');
% for m=1:size(Table,1)
% %     Mask(Table.IdxList{m})=1;
%     Mask(Table.IdxList{m})=Table.Volume(m);
% end

% Mask=imdilate(Mask,ones(Window,Window));
% Wave1=Iba1Perc>Threshold;
% Mask(Wave1==0)=0;

% % % Wave1=imclearborder(1-Mask,4);
% % % Mask=Mask+Wave1;

ex2Imaris_2(Mask,Application,'Test');
Application=openImaris_2(FilenameTotal);
Application.SetVisible(1);
% 
% imarisSaveHDFlock(Application,FilenameTotal);
% imarisSaveHDFlock(FilenameTotal);






J=struct;
J.InCalc=0;
J.OutCalc=1;
J.ZeroBin=0;
J.Output={'DistInOut'};
J.Res=Fileinfo.Res{1};
% J.ResCalc=0.4;
J.UmBin=0.1;
[DistInOut]=distanceMat_2(J,1-Mask);
% Membership=Out.Membership;
DistInOut=DistInOut.DistInOut;
% clear Out;
ex2Imaris_2(DistInOut,FilenameTotal,'Microglia');



Application=openImaris_2(FilenameTotal);
[Fileinfo]=getImarisFileinfo(Application);
ChannelList=varName2Col(Fileinfo.ChannelList{1});
SomaThreshold=0.8;
J = struct;
J.Application=Application;
J.SurfaceName='MicrogliaSoma';
J.Channel='Microglia';
J.Smooth=0.8;
% J.Background=10;
J.LowerManual=SomaThreshold*10;
J.SeedsFilter=['"Intensity Min Ch=',num2str(ChannelList.Microglia),'" above 15'];
generateSurface3(J);
[MicrogliaSoma]=im2Matlab_3(Application,'MicrogliaSoma',1,'Surface');

imarisSaveHDFlock(Application,FilenameTotal);

Window=round((SomaThreshold+0.2)/Res(1));
MicrogliaSoma=imdilate(MicrogliaSoma,ones(Window,Window,Window));
MicrogliaSoma(Mask==0)=0;

ex2Imaris_2(MicrogliaSoma,FilenameTotal,'MicrogliaSoma');
DetermineSkeleton=0;
if DetermineSkeleton==1
    Skeleton=Mask;
    Skeleton(MicrogliaSoma==1)=0;
    Skeleton=Skeleton3D(Skeleton);
    % % % [~,Node,Link]=Skel2Graph3D(Skeleton,1);
    % % % Skeleton=Graph2Skel3D(Node,Link,Pix(1),Pix(2),Pix(3));
    ex2Imaris_2(Skeleton,FilenameTotal,'MicrogliaFibers');
end



return;
Application=openImaris_2(FilenameTotal);
Application.SetVisible(1);

imarisSaveHDFlock(Application,FilenameTotal);
ex2Imaris_2(DistInOut,FilenameTotal,'Microglia');
imarisSaveHDFlock(FilenameTotal);
Application=openImaris_2(FilenameTotal);
Application.SetVisible(1);


% GFPcorr(Outside==1)=0;
% GFPcorr(AxonMask==0)=0;

ex2Imaris_2(GFPcorr,FilenameTotal,'GFPcorr');

Application=openImaris_2(FilenameTotal);
J = struct;
J.Application=Application;
J.SurfaceName='AxonsStart';
J.Channel='GFPcorr';
J.Smooth=0.2;
J.Background=10;
J.LowerManual=200;
J.SurfaceFilter=['"Volume" above 100 um^3'];
generateSurface3(J);
[AxonMask]=im2Matlab_3(Application,'AxonsStart',1,'Surface');

%     Skeleton=Skeleton3D(AxonMask);
%     OrigW=W;
[~,Node,Link]=Skel2Graph3D(AxonMask,1);
Skeleton2=Graph2Skel3D(Node,Link,size(AxonMask,1),size(AxonMask,2),size(AxonMask,3));
%     W=OrigW; global W;
%     evalin('caller','global W;');

ex2Imaris_2(Skeleton2,FilenameTotal,'Skeleton2');
Application=openImaris_2(FilenameTotal);
Application.SetVisible(1);