function somaSize()
global W;

F=W.G.T.F{W.Task}(W.File,:);
[FctSpec]=variableExtract(F.SomaSize{1},{'Do';'Step'});
% keyboard;
FilenameTotal=[F.Filename{1},F.Type{1}];
[PathRaw,Report]=getPathRaw(FilenameTotal);
Fileinfo=getFileinfo_2(FilenameTotal);
Res=Fileinfo.Res{1};
Pix=Fileinfo.Pix{1};
Application=openImaris_2(PathRaw);
Application.SetVisible(1);
Application.GetDataSet.SetChannelName(0,'Hoechst');
Application.GetDataSet.SetChannelName(1,'Neurotrace');

% get percentile data
J=struct;
J.FilenameTotal=FilenameTotal;
J.TargetChannel=2;
J.DataOutput={'IntensityBinning2D',{'AllPercentiles'},['uint8']};
[NTperc,~]=depthCorrection_6(J);
ex2Imaris_2(NTperc,Application,'NTperc');

J.TargetChannel=1;
[HoePerc,~]=depthCorrection_6(J);
ex2Imaris_2(HoePerc,Application,'HoePerc');


%% determine nuclei
Nuclei=uint8(HoePerc>65); % previously 80

% remove holes in nuclei
Wave1=uint8(imclearborder(1-Nuclei,4));
Nuclei=Nuclei+Wave1;

Nuclei=imerode(Nuclei,ones(3,3,3));

BW=bwconncomp(Nuclei,6);
NucleiTable=table;
NucleiTable.NumPix=cellfun(@numel,BW.PixelIdxList).';
NucleiTable.IdxList=BW.PixelIdxList.';
NucleiTable.Volume=NucleiTable.NumPix*prod(Res(1:3));
NucleiTable=NucleiTable(NucleiTable.Volume>50,:);
Nuclei=zeros(Pix(1),Pix(2),Pix(3),'uint16');
for m=1:size(NucleiTable,1)
    Nuclei(NucleiTable.IdxList{m})=1;
end



% from nuclei determine cell regions

J=struct;
J.InCalc=0;
J.OutCalc=1;
J.ZeroBin=0;
J.Output={'DistInOut'};
J.Res=Res;
J.UmBin=0.1;
[Out]=distanceMat_2(J,1-Nuclei);

ex2Imaris_2(Out.DistInOut,Application,'Calculation');

% select 'good' nuclei

[Fileinfo]=getImarisFileinfo(Application);
ChannelList=varName2Col(Fileinfo.ChannelList{1});
J = struct;
J.Application=Application;
J.SurfaceName='Nuclei';
J.Channel='Calculation';
J.Smooth=0.4;
J.LowerManual=1;
J.SeedsFilter=['"Intensity Max Ch=',num2str(ChannelList.Calculation),'" above 25'];
J.SurfaceFilter=['"Volume" between 100 um^3 and 1500 um^3','"Distance to Image Border XYZ" above 5.00 um','"Sphericity" above 0.7 um^3'];
J.SeedsDiameter=8;
generateSurface3(J);
ObjectInfo=getObjectInfo_2('Nuclei',[],Application,1);
J=struct;J.Application=Application;J.Channels='Nuclei';J.Feature='Id';J.ObjectInfo=ObjectInfo;
[NucleiMapSel]=im2Matlab_3(J);


NucleiMap=uint16(Nuclei)*65535;
NucleiMap(NucleiMapSel~=0)=NucleiMapSel(NucleiMapSel~=0);

% remove little parts outside NucleiSel due to smoothing
Wave1=NucleiMap==65535;

BW=bwconncomp(Wave1,6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
Table.Volume=Table.NumPix*prod(Res(1:3));
Table=Table(Table.Volume<50,:);

Wave1=ones(Pix(1),Pix(2),Pix(3),'uint16');
for m=1:size(Table,1)
    Wave1(Table.IdxList{m})=0;
end

NucleiMap=NucleiMap.*Wave1;

Nuclei=uint8(logical(NucleiMap));
ex2Imaris_2(Nuclei,Application,'Nuclei');

% from nuclei make Distance transformation
J=struct;
J.InCalc=0;
J.OutCalc=1;
J.ZeroBin=0;
J.Output={'Membership';'DistInOut'};
J.Res=Res;
J.UmBin=0.1;
J.DistanceBitType='uint16';
[Out]=distanceMat_2(J,NucleiMap);
Distance3D=Out.DistInOut;
Membership=Out.Membership;

%% determine soma

Soma=NTperc>60;

% remove holes in soma
Wave1=imclearborder(1-Soma,4);
Soma=Soma+Wave1;

Soma=imerode(Soma,ones(3,3));

clear BW;
BW=bwconncomp(Soma,6);

SomaTable=table;
SomaTable.NumPix=cellfun(@numel,BW.PixelIdxList).';
SomaTable.IdxList=BW.PixelIdxList.';
SomaTable.Volume=SomaTable.NumPix*prod(Res(1:3));
SomaTable=sortrows(SomaTable,'Volume','descend');
SomaTable=SomaTable(SomaTable.Volume>500,:);

Soma=zeros(Pix(1),Pix(2),Pix(3),'uint8');
for m=1:size(SomaTable,1)
    Soma(SomaTable.IdxList{m})=1;
end

% keyboard;
% cells are combined Soma and Nuclei masks
Cells=uint8(logical(Soma+Nuclei));

CellsMapSel=uint16(Cells).*Membership;
CellsMapSel(Membership==65535)=0;

Wave1=imclearborder(1-CellsMapSel,4);
CellsMapSel=CellsMapSel+Wave1;

J=struct;
J.InCalc=1;
J.OutCalc=0;
J.ZeroBin=0;
J.Output={'Membership';'DistInOut'};
J.Res=Res;
J.UmBin=0.1;
J.DistanceBitType='uint16';
[Out]=distanceMat_2(J,CellsMapSel);
Distance3D=Out.DistInOut;


ex2Imaris_2(Distance3D,Application,'Calculation');

[Fileinfo]=getImarisFileinfo(Application);
ChannelList=varName2Col(Fileinfo.ChannelList{1});
J = struct;
J.Application=Application;
J.SurfaceName='Cells';
J.Channel='Calculation';
J.Smooth=1;
J.LowerManual=1;
J.SeedsFilter=['"Intensity Max Ch=',num2str(ChannelList.Calculation),'" above 25'];
J.SurfaceFilter=['"Volume" above 500 um^3','"Distance to Image Border XYZ" above 1.00 um'];
J.SeedsDiameter=8;
generateSurface3(J);


ObjectInfo=getObjectInfo_2('Cells',[],Application);

ChannelList=varName2Col(ObjectInfo.ChannelNames);
ObjectInfo=ObjectInfo.ObjInfo;

OutputTable=table;
OutputTable.Id=(1:size(ObjectInfo,1)).';
OutputTable.Volume=ObjectInfo.Volume;
OutputTable.VolumeNucleus=ObjectInfo.IntensitySum(:,ChannelList.Nuclei)*prod(Res(1:3));
OutputTable.VolumeCytosol=OutputTable.Volume-OutputTable.VolumeNucleus;
OutputTable.Width=ObjectInfo.BoundingBoxOOLengthA;
OutputTable.Length=ObjectInfo.BoundingBoxOOLengthC;
OutputTable.BoundingBoxX=ObjectInfo.BoundingBoxAALengthX;
OutputTable.BoundingBoxY=ObjectInfo.BoundingBoxAALengthY;
OutputTable.BoundingBoxZ=ObjectInfo.BoundingBoxAALengthZ;
OutputTable.Sphericity=ObjectInfo.Sphericity;
OutputTable.PositionX=ObjectInfo.PositionX;
OutputTable.PositionY=ObjectInfo.PositionY;
OutputTable.PositionZ=ObjectInfo.PositionZ;


Path2file=[F.Filename{1},'_Analysis.xlsx'];
Path2file=getPathRaw(Path2file);
OutputTable2=[OutputTable.Properties.VariableNames;table2cell(OutputTable)];
xlswrite(Path2file,OutputTable2);

Path2file=[F.Filename{1},'_Analysis.ims'];
Path2file=getPathRaw(Path2file);
Application.FileSave(Path2file,'writer="Imaris5"');
quitImaris(Application);
clear Application;

Wave1=variableSetter_2(W.G.T.F{W.Task,1}.SomaSize{W.File},{'Do','Fin';'Step','1'});
iFileChanger('W.G.T.F{W.Task,1}.SomaSize{W.File}',Wave1);

