function synaptosomes()
global W;

F=W.G.T.F{W.Task}(W.File,:);
[FctSpec]=variableExtract(F.Synaptosomes{1},{'Do';'Step'});
FctSpec.Step=0;
if FctSpec.Step==1
    keyboard;
        synaptosomes_FinalEvaluation();
    return;
end

FilenameTotal=[F.Filename{1}(1:strfind(F.Filename{1},'.')-1),'.ims'];
FilenameTotalOrig=F.Filename{1};

Fileinfo=getFileinfo_2(FilenameTotalOrig);
Res=Fileinfo.Res{1};
Pix=Fileinfo.Pix{1};
Out=filenameExtract(FilenameTotal);
Immunolabeling=Out.Ihc;
[PathRaw,Report]=getPathRaw(FilenameTotal);

Application=openImaris_2(FilenameTotalOrig);
ChannelNames={'VglutGreen';'VglutRed';Immunolabeling};
for m=1:size(ChannelNames,1)
    Application.GetDataSet.SetChannelName(m-1,ChannelNames{m});
end
Application.FileSave(PathRaw,'writer="Imaris5"');
quitImaris(Application);


VglutGreen=im2Matlab_3(FilenameTotal,'VglutGreen');
VglutRed=im2Matlab_3(FilenameTotal,'VglutRed');
Data3DImmuno=im2Matlab_3(FilenameTotal,Immunolabeling);

[Boutons,TableBoutons]=synaptosomes_spotDetection(VglutGreen,Res,0.15);

[ImmunoSpots,TableImmunoSpots]=synaptosomes_spotDetection(Data3DImmuno,Res,0);

RoiData=zeros(Pix.','uint16');

for Bouton=1:size(TableBoutons,1)
    VoxelTable=table;
    VoxelTable.LinInd=TableBoutons.IdxList{Bouton};
    VoxelTable.VglutGreen=VglutGreen(VoxelTable.LinInd);
    VoxelTable.VglutRed=VglutRed(VoxelTable.LinInd);
    VoxelTable.Immuno=Data3DImmuno(VoxelTable.LinInd);
    [VoxelTable.XYZpos(:,1),VoxelTable.XYZpos(:,2),VoxelTable.XYZpos(:,3)]=ind2sub(Pix.',VoxelTable.LinInd);
    VoxelTable=sortrows(VoxelTable,'VglutGreen','descend');
    TableBoutons.CenterPix(Bouton,1:3)=round(mean(VoxelTable.XYZpos(1:15,:),1)); % round(size(VoxelTable,1)*0.01)
    TableBoutons.CenterUm(Bouton,1:3)=TableBoutons.CenterPix(Bouton,1:3).*Res.';
    VoxelTable=VoxelTable(VoxelTable.XYZpos(:,3)==TableBoutons.CenterPix(Bouton,3),:);
    TableBoutons.CenterPlaneVoxels(Bouton,1)={VoxelTable};
    Radius=size(VoxelTable,1)*prod(Res(1:2));
    Radius=(Radius/3.1415)^0.5;
    TableBoutons.Radius(Bouton,1)=Radius;
    TableBoutons.VglutGreen(Bouton,1)=mean(VoxelTable.VglutGreen);
    TableBoutons.VglutRed(Bouton,1)=mean(VoxelTable.VglutRed);
    TableBoutons.Immunolabeling(Bouton,1)=mean(VoxelTable.Immuno);
    
    TableBoutons.VglutGreenSum(Bouton,1)=sum(VoxelTable.VglutGreen);
    TableBoutons.VglutRedSum(Bouton,1)=sum(VoxelTable.VglutRed);
    TableBoutons.ImmunolabelingSum(Bouton,1)=sum(VoxelTable.Immuno);
    
    RoiData(VoxelTable.LinInd)=1;
    
    % ImmunoSpots
    ImmunoInd=ImmunoSpots(TableBoutons.IdxList{Bouton});
    ImmunoInd=unique(ImmunoInd(:));ImmunoInd(ImmunoInd==0)=[];
    if isempty(ImmunoInd)
        continue;
    elseif size(ImmunoInd,1)>1
        [~,Wave1]=max(TableImmunoSpots.Volume(ImmunoInd));
        ImmunoInd=ImmunoInd(Wave1);
%         keyboard;
    end
    TableBoutons.ImmunoId(Bouton,1)=ImmunoInd;
    VoxelTable=table;
    VoxelTable.LinInd=TableImmunoSpots.IdxList{ImmunoInd};
    VoxelTable.VglutGreen=VglutGreen(VoxelTable.LinInd);
    VoxelTable.VglutRed=VglutRed(VoxelTable.LinInd);
    VoxelTable.Immuno=Data3DImmuno(VoxelTable.LinInd);
    [VoxelTable.XYZpos(:,1),VoxelTable.XYZpos(:,2),VoxelTable.XYZpos(:,3)]=ind2sub(Pix.',VoxelTable.LinInd);
    VoxelTable=sortrows(VoxelTable,'Immuno','descend');
    
    TableBoutons.CenterPixImmuno(Bouton,1:3)=round(mean(VoxelTable.XYZpos(1:15,:),1)); % round(size(VoxelTable,1)*0.01)
    TableBoutons.CenterUmImmuno(Bouton,1:3)=TableBoutons.CenterPixImmuno(Bouton,1:3).*Res.';
    
    TableBoutons.ImmunoSpotDistance(Bouton,1)=xyzDistance(TableBoutons.CenterUm(Bouton,1:3).',TableBoutons.CenterUmImmuno(Bouton,1:3).');
    
    VoxelTable=VoxelTable(VoxelTable.XYZpos(:,3)==TableBoutons.CenterPixImmuno(Bouton,3),:);
    TableBoutons.CenterPlaneVoxelsImmuno(Bouton,1)={VoxelTable};
    
    RoiData(VoxelTable.LinInd)=2;
end
% keyboard; % remove TableBoutons.IdxList
TableBoutons(:,'IdxList') = [];

ex2Imaris_2(Boutons,FilenameTotal,'Boutons');
ex2Imaris_2(ImmunoSpots,FilenameTotal,'ImmunoSpots');
ex2Imaris_2(RoiData,FilenameTotal,'RoiData');


GenerateSortedVersion=0;
if GenerateSortedVersion==1
    OrigTableBoutons=TableBoutons;
    TableBoutons=OrigTableBoutons;
    
    SquBoutonUm=2; % µm
    SquBoutonPix=round2odd(SquBoutonUm/Res(1)); SquBoutonPix=[SquBoutonPix;SquBoutonPix;Pix(3)];
    TableBoutons(TableBoutons.CenterPixImmuno(:,1)<SquBoutonPix(1) | TableBoutons.CenterPixImmuno(:,1)>Pix(1)-SquBoutonPix(1),:)=[];
    TableBoutons(TableBoutons.CenterPixImmuno(:,2)<SquBoutonPix(2) | TableBoutons.CenterPixImmuno(:,2)>Pix(2)-SquBoutonPix(2),:)=[];
    [A1,UniqueImmunoId,A2]=unique(TableBoutons.ImmunoId);
    UniqueImmunoId=[UniqueImmunoId;find(TableBoutons.ImmunoId==0)];
    
    TableBoutons=TableBoutons(UniqueImmunoId,:);
    TableBoutons.Sorter=round(rand(size(TableBoutons,1),1));
    TableBoutons=sortrows(TableBoutons,'Sorter','descend');
    
    ColumnNumber=6;
    clear VglutGreen2; clear Data3DImmuno2;
    for Bouton=1:size(TableBoutons,1)
        Row=floor(Bouton/(ColumnNumber+0.001))+1;
        Col=Bouton-(Row-1)*ColumnNumber;
        CenterPixPaste=[Row;Col;1].*SquBoutonPix-(SquBoutonPix-1)/2;
        CenterPix=TableBoutons.CenterPixImmuno(Bouton,:).';
        [Cut,Paste]=pixelOverhang(CenterPix,SquBoutonPix,CenterPixPaste,Pix);
        
        VglutGreen2(Paste(1,1):Paste(1,2),Paste(2,1):Paste(2,2),Paste(3,1):Paste(3,2))=VglutGreen(Cut(1,1):Cut(1,2),Cut(2,1):Cut(2,2),Cut(3,1):Cut(3,2));
        Data3DImmuno2(Paste(1,1):Paste(1,2),Paste(2,1):Paste(2,2),Paste(3,1):Paste(3,2))=Data3DImmuno(Cut(1,1):Cut(1,2),Cut(2,1):Cut(2,2),Cut(3,1):Cut(3,2));
    end
    FilenameTotalSorted=regexprep(FilenameTotal,'.ims','_Sorted.ims');
    [Application]=dataInspector3D({VglutGreen2;Data3DImmuno2},Res,{'VglutGreen';ChannelNames{3}},0,FilenameTotalSorted,1);
end


imarisSaveHDFlock(FilenameTotal);

PathTotalResults=[FilenameTotal,'_Results.mat'];
[PathTotalResults,Report]=getPathRaw(PathTotalResults);

TotalResults=struct;
TotalResults.BoutonTable=TableBoutons;
TotalResults.MetaData=Out;
TotalResults.Fileinfo=Fileinfo;



save(PathTotalResults,'TotalResults');

Wave1=variableSetter_2(F.Synaptosomes{1},{'Do','Fin';'Step','1'});
iFileChanger('W.G.T.F{W.Task,1}.Synaptosomes{W.File}',Wave1);
