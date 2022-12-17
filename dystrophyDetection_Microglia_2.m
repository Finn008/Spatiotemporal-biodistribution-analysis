function [Microglia,Soma,Fibers,Iba1Corr,MicrogliaInfo]=dystrophyDetection_Microglia_2(FilenameTotal,Pix,Res)

[Iba1]=im2Matlab_3(FilenameTotal,'Iba1');
[Outside]=im2Matlab_3(FilenameTotal,'Outside');

[~,Iba1Corr]=sparseFilter(Iba1,Outside,Res,10000,[200;200;1],[3;3;3],50,'Multiply3000');

Application=openImaris_2(FilenameTotal); Application.SetVisible(1);
ex2Imaris_2(Iba1Corr,Application,'Iba1Corr');


ex2Imaris_2(Iba1Corr,FilenameTotal,'Iba1Corr2');
Application=openImaris_2(FilenameTotal);
[Fileinfo,Ind,PathRaw]=getFileinfo_2(FilenameTotal);
Wave1=strfind1(Fileinfo.ChannelList,'Iba1Corr2',1);
Application.GetImageProcessing.SubtractBackgroundChannel(Application.GetDataSet,Wave1-1,1);
imarisSaveHDFlock(Application,FilenameTotal);
[Iba1Corr2]=im2Matlab_3(FilenameTotal,'Iba1Corr2');

% detect Soma
Threshold=prctile_2(Iba1Corr2,90,Outside==0);
Mask=Iba1Corr2>Threshold;
Threshold2=prctile_2(Iba1Corr,85,Outside==0);
Mask(Iba1Corr<Threshold2)=0;
clear Iba1Corr2;

% remove structures smaller than 1µm^3
BW=bwconncomp(Mask,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
Table.Volume=Table.NumPix*prod(Res);
Table=Table(Table.Volume>1,:);
Mask=zeros(Pix.','uint8');
Mask(cell2mat(Table.IdxList))=1;



Fileinfo=getFileinfo_2(FilenameTotal);
ChannelList=Fileinfo.ChannelList{1};
if strfind1(ChannelList,'Vglut1')
% % %     Mask2=Skeleton3D(Mask);
    SizeMinMax=[0.4,10;1.6,10;1.4,8.2]; % diameter 10
    [Islands]=detectIslands(1-Mask,SizeMinMax,Res,'3D','Ones10');

    [Vglut1]=im2Matlab_3(FilenameTotal,'Vglut1');
    [Outside]=im2Matlab_3(FilenameTotal,'Outside');
    [~,Vglut1Corr]=sparseFilter(Vglut1,Outside,Res,10000,[30;30;30],[5;5;5],85,'Multiply12000'); % set 85 percentile to 12000, previously 50th to 8000
    Threshold=prctile_2(Vglut1Corr,80,Outside==0); % 75=7200
    [MapVolume,MapDistInMax]=clusterAnalysis(Vglut1Corr<Threshold,Res,[0;0.025],[]);
    Mask2=Islands; Mask2(Vglut1Corr>Threshold)=0;
    Mask2=removeIslands_3(Mask2,4,[0;0.025],prod(Res(:)));
    
    J=struct;
    J.OutCalc=1;
    J.ZeroBin=0;
    J.Output={'DistInOut'};
    J.Res=Res;
    J.UmBin=0.1;
    [Out]=distanceMat_2(J,1-Mask);
    Distance=Out.DistInOut; clear Out;
    clear Mask;
    
    Watershed=uint8(10)-Distance; % previously 4
    tic;
    Watershed=single(watershed(Watershed,26));
    toc;
    Watershed(Distance==0)=0;
    BW=bwconncomp(Mask2,6);
    Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
    Table.Volume=Table.NumPix*prod(Res(1:3));
    Table=Table(Table.Volume>5,:);
    Mask2=zeros(Pix.','uint16');
    Mask2(cell2mat(Table.IdxList(:)))=1;
    
    Islands(Mask2==0)=0;
    IslandThreshold=5;
    clear Mask2;
end

if strfind1(FilenameTotal,'ExTanja')
    J=struct('DataOutput','AllPercentiles');
    Iba1Perc=percentiler(Iba1Corr,Outside,J);
    Islands(Iba1Perc<97)=0; % remove stuff outside microglia
    IslandThreshold=11;
    SizeMinMax=[0.4,10;1.6,10;1.4,8.2]; % diameter 10
    [Islands]=detectIslands(1-Mask,SizeMinMax,Res,'3D','Ones10');
end

Mask(Islands>=IslandThreshold)=1;
clear Islands;
[Mask]=removeIslands_3(Mask,4,[0;1],prod(Res(:)));

J=struct;
J.OutCalc=1;
J.ZeroBin=0;
J.Output={'DistInOut'};
J.Res=Res;
J.UmBin=0.1;
[Out]=distanceMat_2(J,1-Mask);
Distance=Out.DistInOut; clear Out;

DistanceThreshold=16;
Nuclei=Distance>DistanceThreshold;
clear Distance;

J=struct;
J.OutCalc=1;
J.ZeroBin=0;
J.Output={'DistInOut'};
J.Res=Res;
J.UmBin=0.1;
[Out]=distanceMat_2(J,Nuclei);
Distance2=Out.DistInOut; clear Out;

Soma=Mask;Soma(Distance2>DistanceThreshold+3)=0;
clear Distance2;

BW=bwconncomp(Soma,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
Table.Volume=Table.NumPix*prod(Res);
Table.Diameter=(Table.Volume*3/4/3.1415).^(1/3)*2;
Table(Table.Volume<100,:)=[];
Soma=zeros(Pix.','uint16');
for m=1:size(Table,1)
    Table.Iba1Mean(m,1)=mean(Iba1(Table.IdxList{m}));
    Table.Iba1CorrMean(m,1)=mean(Iba1Corr(Table.IdxList{m}));
    Soma(Table.IdxList{m})=m;
end

Fibers=Mask;Fibers(Soma~=0)=0;
Microglia=Fibers+uint8(Soma>0)*2;
ex2Imaris_2(Microglia,FilenameTotal,'Microglia');
Microglia=Microglia>0;

J=struct;
J.OutCalc=1;
J.ZeroBin=0;
J.Output={'DistInOut';'Membership'};
J.Res=Res;
J.UmBin=0.1;
J.DistanceBitType='uint16';
[Out]=distanceMat_2(J,Soma);
Distance3=Out.DistInOut;
Membership=Out.Membership;
clear Out;

% keyboard; % check if accumarray_8 provides same results as accumarray_2
% keyboard; % Membership m==1 is missing
[Table2]=accumarray_9({Distance3,'Distance';Membership,'Membership'},Fibers,@mean);
Table2(Table2.Distance==0,:)=[];
clear Distance3; clear Membership;
% Table2.Properties.VariableNames={'Distance';'Membership';'Fraction'};
Table.SomaCoverage(:,1:max(Table2.Distance))=NaN;
for m=1:size(Table,1)
    Table.SomaCoverage(m,Table2.Distance(Table2.Membership==m))=Table2.Value1(Table2.Membership==m);
end

Soma=logical(Soma);

Ind=find(Fibers==1);
FiberInfo=struct;
FiberInfo.MeanIba1=mean(Iba1(Ind));
FiberInfo.Iba1CumSum=prctile_2(Iba1(:),(1:100).');
FiberInfo.MeanIba1Corr=mean(Iba1Corr(Ind));
FiberInfo.Iba1CorrCumSum=prctile_2(Iba1Corr(:),(1:100).');

MicrogliaInfo=struct;
MicrogliaInfo.Somata=Table(:,{'Volume';'Diameter';'Iba1Mean';'Iba1CorrMean';'SomaCoverage'});
MicrogliaInfo.Fibers=FiberInfo;