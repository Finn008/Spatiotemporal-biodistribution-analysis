function [Nuclei,Data3D,NucleiData]=dystrophyDetection_Nuclei_2()
timeTable('Start');
NucleiChannelName='DAPI';
global ChannelTable;
global ShowIntermediateSteps;
% ShowIntermediateSteps=1;

% [Fileinfo,Ind,PathRaw]=getFileinfo_2(FilenameTotal);
Fileinfo=getFileinfo_2(ChannelTable{NucleiChannelName,'SourceFilename'});
Res=Fileinfo.Res{1};

Settings={  '','SpFiPrctile','SpFiSubtrBackgr','PrctileCondensedChromatin','Nuclei';...
    'DAPI',80,2500,99,80;... % 'Multiply2500'
    };
Settings=array2table(Settings(2:end,2:end),'VariableNames',Settings(1,2:end),'RowNames',Settings(2:end,1));

[Data3D]=im2Matlab_3(ChannelTable{NucleiChannelName,'SourceFilename'},ChannelTable{NucleiChannelName,'SourceChannelName'});
% [Data3D]=im2Matlab_3(FilenameTotalOrig,strfind1(ChannelListOrig,NucleiChannelName,1));
if ShowIntermediateSteps==1
    Application=ChannelTable.TargetFilename{'ShowIntermediate'};
    if ShowIntermediateSteps==1; ex2Imaris_2(Data3D,Application,NucleiChannelName,1,Res); end
end

Pix=size(Data3D).';
try % if strfind1(Fileinfo.ChannelList{1},'Outside',1)
    [Outside]=uint8(im2Matlab_3(ChannelTable{'Outside','TargetFilename'},'Outside'));
%     [Outside]=im2Matlab_3(FilenameTotal,'Outside');
catch
    Outside=zeros(size(Data3D),'uint8');
end

[~,Data3D]=percentileFilter3D_3(Data3D,Settings{NucleiChannelName,'SpFiPrctile'}{1},Res,[10;10;Res(3)],Outside,Settings{NucleiChannelName,'SpFiSubtrBackgr'}{1},[200;200;1]);
if ShowIntermediateSteps==1; ex2Imaris_2(Data3D,Application,'Nuclei_Data3DAfterpercentileFilter3D'); end
timeTable('Data3DAfterpercentileFilter3D');

%% determine dense chromatin
Threshold=prctile(Data3D(Outside==0),Settings{NucleiChannelName,'PrctileCondensedChromatin'}{1}); % 80:2496, 85:2751, 90:3176, 95:4386, 98:7917, 99:11902
DenseChromatin=Data3D>Threshold;

% 3D connected component analysis
BW=bwconncomp(DenseChromatin,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'});
Table.Volume=Table.NumPix*prod(Res);

DistanceFromDenseChromatin=zeros(Pix.','uint16');
DistanceFromDenseChromatin(cell2mat(Table.IdxList(Table.Volume<2.5^3)))=1;
DistanceFromDenseChromatin(cell2mat(Table.IdxList(Table.Volume>=2.5^3)))=2;
[DistanceFromDenseChromatin,Wave1]=distanceMat_4(DistanceFromDenseChromatin,{'DistInOut';'Membership'},Res,0.1,1,0,0,'uint16',0.4);
Wave1(Wave1==1)=60;
Wave1(Wave1==2)=15;

if ShowIntermediateSteps==1; ex2Imaris_2(DistanceFromDenseChromatin,Application,'Nuclei_DistanceFromDenseChromatin'); end
timeTable('DistanceFromDenseChromatin');

Threshold=prctile(Data3D(Outside==0),Settings{NucleiChannelName,'Nuclei'}{1}); % 80:2496, 85:2751, 90:3176, 95:4386, 98:7917, 99:11902

Nuclei=Data3D>=Threshold & DistanceFromDenseChromatin<=Wave1 & Outside==0;

% 50th within 2*2µm
[LocalPerc]=percentileFilter3D_3(Data3D,50,Res,Res,Outside,0,[2;2;Res(3)]);
Nuclei(Data3D<LocalPerc)=0;
if ShowIntermediateSteps==1; ex2Imaris_2(LocalPerc,Application,'Nuclei_Data3DAfterLocalFilter1'); end
if ShowIntermediateSteps==1; ex2Imaris_2(Nuclei,Application,'Nuclei_NucleiAfterThreshold1'); end
timeTable('Data3DAfterLocalFilter1');
% 70th within 8*8*8µm
[LocalPerc]=percentileFilter3D_3(Data3D,70,Res,[0.3;0.3;Res(3)],Outside,0,[8;8;8]);
Nuclei(Data3D<LocalPerc)=0;
timeTable('Data3DAfterLocalFilter2');
if ShowIntermediateSteps==1; ex2Imaris_2(LocalPerc,Application,'Nuclei_Data3DAfterLocalFilter2'); end
if ShowIntermediateSteps==1; ex2Imaris_2(Nuclei,Application,'Nuclei_NucleiAfterThreshold2'); end

% 2D connected component analysis
BW=bwconncomp(Nuclei,4);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); Table.Area=Table.NumPix*prod(Res(1:2));
Table(Table.Area<1,:)=[];
Nuclei=zeros(Pix.','uint16');
Nuclei(cell2mat(Table.IdxList))=1;

if ShowIntermediateSteps==1; ex2Imaris_2(Nuclei,Application,'Nuclei_NucleiAfter2DConnComp'); end
timeTable('NucleiAfter2DConnComp');
% fill holes in 2D
BW=bwconncomp(~Nuclei,4);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); Table.Area=Table.NumPix*prod(Res(1:2));
Table(Table.Area>0.4^2,:)=[];
Nuclei(cell2mat(Table.IdxList))=1;

if ShowIntermediateSteps==1; ex2Imaris_2(Nuclei,Application,'Nuclei_NucleiAfter2DHoleFilling'); end
timeTable('NucleiAfter2DHoleFilling');
%% Basins
[DistanceFromNuclei]=distanceMat_4(Nuclei,{'DistInOut'},Res,0.1,1,0,0,'uint16',0.2);
if ShowIntermediateSteps==1; ex2Imaris_2(DistanceFromNuclei,Application,'Nuclei_DistanceFromNuclei'); end
timeTable('DistanceFromNuclei');
BasinThreshold=15; % previously 13, 60, 20
DistanceFromNuclei(Outside==1)=0;
Basins=uint16(watershed(BasinThreshold-uint8(DistanceFromNuclei),6));
Basins(Nuclei==1)=0;
Basins(Outside==1)=0;

BW=bwconncomp(logical(Basins),6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); 
Table.ID=(1:size(Table,1)).';
Table.Volume=Table.NumPix*prod(Res(1:3));

Basins=labelmatrix(BW);
Wave1=accumarray_9(Basins,DistanceFromNuclei,@max,[],[],[],{1,0});
Table.DistanceMax(Wave1.Roi1,1)=Wave1.Value1;

Wave1=accumarray_9(Basins,DistanceFromNuclei,@mean,[],[],[],{1,0});
Table.DistanceMean(Wave1.Roi1,1)=Wave1.Value1;

Wave1=accumarray_9({Basins;repmat(permute(1:Pix(3),[1,3,2]),[Pix(1),Pix(2),1])},ones(Pix.','uint8'),@sum,'2D');
Table.AreaXY=max(double(Wave1),[],2)*prod(Res(1:2));

if ShowIntermediateSteps==1
    Wave1=uint16(ceil(Table.DistanceMean));
    Wave1=Wave1(Basins(Basins>0));
    Wave2=Basins;
    Wave2(Basins>0)=Wave1;
    ex2Imaris_2(uint16(Wave2),Application,'Nuclei_Basins_DistanceMean');
end
%% improve with determine3Dthreshold()
TableSelection=Table(Table.DistanceMean<=16,:); % 62,20,24 56,23,13 30,18,10  20,13,7  4,10,4
Basins=zeros(Pix.','uint16');
Basins(cell2mat(TableSelection.IdxList))=1;
Basins(Nuclei==1)=2;

if ShowIntermediateSteps==1; ex2Imaris_2(Basins,Application,'Nuclei_Basins'); end
timeTable('Basins');

% fill watershed ridge lines
Nuclei=imdilate(Basins>0,strel('sphere',1));
Nuclei=imerode(Nuclei,strel('sphere',1));
% fill holes toward top and bottom of the image
BW=bwconncomp(~Nuclei,4);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); Table.Area=Table.NumPix*prod(Res(1:2));
Table(Table.Area>9^2,:)=[];
Nuclei(cell2mat(Table.IdxList))=1;

BW=bwconncomp(Nuclei,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); Table.Volume=Table.NumPix*prod(Res(1:3));
Nuclei=labelmatrix(BW);

if ShowIntermediateSteps==1; ex2Imaris_2(Nuclei,Application,'Nuclei_FillRidgeLines'); end
timeTable('AfterFillingRidgeLines');

%% Island detection
IslandDetection=0;
if IslandDetection==1
    IslandThreshold=5; % include everything above this
    SizeMinMax=[0.4,6;1.5,6;1.5,6];
    [Islands]=detectIslands_2(1-Nuclei,SizeMinMax,Res,'3D','Ones10');
    if ShowIntermediateSteps==1; ex2Imaris_2(Islands,Application,'Nuclei_Islands'); end
    timeTable('Islands');
end
timeTable('IslandDetection');
%% separate individual nuclei
Version=struct('SeedImpact','Radius','Thresholds','Nuclei','Imdilation',1,'IdentifyLocalMaximaExtent',6,'WatershedUmBin',0.1,'ResCalc',0.2,'WatershedType','Morphology','DistanceDimensionality','XY');
[Nuclei,LocalMaxima,WatershedDistance,Seeds]=watershedSegmentation_2(Nuclei,Version,Res);
Seeds.Membership2=Nuclei(Seeds.Ind);
% %     ex2Imaris_2(Nuclei,Application,'Nuclei_AfterSegmentation');
% %     ex2Imaris_2(WatershedDistance,Application,'Nuclei_WatershedDistance');
% %     ex2Imaris_2(LocalMaxima,Application,'Nuclei_LocalMaxima');
timeTable('NucleiSegmentation');

if ShowIntermediateSteps==1
    ex2Imaris_2(Nuclei,Application,'Nuclei_AfterSegmentation');
    ex2Imaris_2(WatershedDistance,Application,'Nuclei_WatershedDistance');
    ex2Imaris_2(LocalMaxima,Application,'Nuclei_LocalMaxima');
end
OrigNuclei=Nuclei;
% % Wave1=logical(Nuclei);
% % Wave1=imerode(Wave1,imdilateWindow_2([2;2;2],Res,1,'ellipsoid'));
% % Wave1=imdilate(Wave1,imdilateWindow_2([3;3;3],Res,1,'ellipsoid'));
% % Nuclei(Wave1==0)=0;


%% quantify NucleiData
% Nuclei=im2Matlab_3(Application2,'Nuclei_AfterSegmentation');
NucleiData=table;
NucleiData.PixelIdxList=label2idx(Nuclei).';
NucleiData.NumPix=cellfun(@numel,NucleiData.PixelIdxList);
NucleiData.Volume=NucleiData.NumPix*prod(Res(1:3));

Wave1=accumarray_9(Nuclei,WatershedDistance,@max,[],[],[],{1,0});
NucleiData.WatershedDistanceMax(Wave1.Roi1,1)=double(Wave1.Value1)/10;
NucleiData(NucleiData.Volume<=4/3*3.1415*2^3,:)=[];
NucleiData(NucleiData.WatershedDistanceMax<=1.2,:)=[];
BW.PixelIdxList=NucleiData.PixelIdxList.';
BW.NumObjects=size(BW.PixelIdxList,2);
Nuclei=labelmatrix(BW); % separation lines between plaques have to be removed using Membership and PlaqueMap

Seeds.Membership3=Nuclei(Seeds.Ind);
if ShowIntermediateSteps==1; ex2Imaris_2(Nuclei,Application,'Nuclei_NucleiFinal'); end
timeTable('QuantifyNucleiData');

if ShowIntermediateSteps==1
    timeTable([],1);
    imarisSaveHDFlock(Application);
%     Application2=openImaris_4(Application,[],1,1);
%     keyboard;
end
% identify individual chromatin structures

timeTable('End');