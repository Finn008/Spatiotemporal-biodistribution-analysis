function vglutClusterAnalysis_ClusterDistribution4EachPlaque(VglutArray1,PlaqueListSingle,VglutArray2,MouseInfo,Groups,RelationshipIDs,Path2file)
keyboard; % not working yet

% fuse cluster bin fraction from VglutArray2 into VglutArray1
VariableNames=VglutArray2.Properties.VariableNames.';
VariableNames=strrep(VariableNames,'VolumeUm3','ClusterVolume');
VglutArray2.Properties.VariableNames=VariableNames;

Wave1=fuseTable_MatchingColums_2(VglutArray2,VglutArray1,{'MouseId';'Time2Treatment';'RoiId';'PlId';'Distance'},{'VolumeUm3'});
VglutArray2.TotalVolume=full(Wave1.VolumeUm3);

VglutArray2.Fraction=full(VglutArray2.ClusterVolume./VglutArray2.TotalVolume*100);

Pix=[1599;1603];
for MouseId=MouseInfo.MouseId.'
    clear OverviewImage;
    MouseId=336;
    disp(MouseId);
    Table=VglutArray2(find(VglutArray2.MouseId==MouseId),:);
    PlaqueIds=unique(Table.PlId);
    for PlId=PlaqueIds.'
        Table2=Table(find(Table.PlId==PlId),:);
        Times=unique(Table2.Time2Treatment);
        for Time=Times.'
            Table3=Table2(find(Table2.Time2Treatment==Time),:);
            [Image]=vglutClusterAnalysis_ClusterSizeDistributionPlotting(Table3.Fraction,Table3.Distance,Table3.Dystrophies2Radius,[]);
            if isempty(Image)
                Chunk=zeros(Pix(1),Pix(2),3,'uint8');
            else
                Chunk=Image(200:1798,562:2164,:);
            end
            OverviewImage((Time-1)*Pix(1)+1:(Time-1)*Pix(1)+Pix(1),(PlaqueRadius-1)*Pix(2)+1:(PlaqueRadius-1)*Pix(2)+Pix(2),1:3)=Chunk;
        end
    end
%     Path=[Path2file,Groups.Description{Group},'.tif'];
    Path=[Path2file,'Mouse',num2str(MouseId),'_Plaque',num2str(PlId)];
    imwrite(OverviewImage,Path);
end


%% binning
% VglutArray1(:,{'RoiId';'PlId';'VolumeUm3';'ClusterVolume'})=[];

BinInfo={'MouseId',0,0,0; % no binning
    'Time2Treatment',-2,0,[0;70]; %     'Time2Treatment',[28],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; %  % 'Time2Treatment',-2,0,[-28;70];
    'PlaqueRadius',[2],[0;999],0 %
    'Dystrophies2Radius',-2,0,[(0:1:60).';999]; % [0;5;10;15;20;999]
    'Distance',[1],[-20;51],0; % 1µm steps
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'});
BinInfo.Properties.RowNames=BinInfo.Name;

    
[Table]=accumArrayBinning(VglutArray1(:,{'MouseId';'Time2Treatment';'Distance';'Dystrophies2Radius';'Fraction';'PlaqueRadius'}),BinInfo,'Fraction');
Table=distributeColumnHorizontally_4(Table,[],'MouseId','Fraction',MouseInfo.MouseId);

PlaqueBinning=2;
PlaqueRadiiRanges=(0:PlaqueBinning:18).';PlaqueRadiiRanges=[PlaqueRadiiRanges,PlaqueRadiiRanges+PlaqueBinning];
TimeBinning=70; % TimeBinning=28; 
TimeRanges=[0,70];

Pix=[1599;1603];
for Group=[9:26] %1:size(Groups,1)
    clear OverviewImage;
    disp(Group);
    for PlaqueRadius=1:size(PlaqueRadiiRanges,1)
        for Time=1:size(TimeRanges,1)
            Wave1=[Groups.Description{Group},'_Plaque',num2str(PlaqueRadiiRanges(PlaqueRadius,1)),'-',num2str(PlaqueRadiiRanges(PlaqueRadius,2)),'_Time2Tr',num2str(TimeRanges(Time,1)),'to',num2str(TimeRanges(Time,2))];
            [Image]=vglutClusterAnalysis_PlotClusterSizeDistribution_2(Wave1,Table,MouseInfo,Groups.MouseIds{Group},PlaqueBinning,PlaqueRadiiRanges(PlaqueRadius,:).',1,[-20;51],TimeBinning,TimeRanges(Time,:).',[],Path2file);
            if isempty(Image)
                Chunk=zeros(Pix(1),Pix(2),3,'uint8');
            else
                Chunk=Image(200:1798,562:2164,:);
            end
            OverviewImage((Time-1)*Pix(1)+1:(Time-1)*Pix(1)+Pix(1),(PlaqueRadius-1)*Pix(2)+1:(PlaqueRadius-1)*Pix(2)+Pix(2),1:3)=Chunk;
        end
    end
%     Path=[Path2file,Groups.Description{Group},'.tif'];
    Path=[Path2file,Groups.Description{Group},'_PlaqueBinning',num2str(PlaqueBinning),'-',num2str(PlaqueRadiiRanges(PlaqueRadius,2)),'_Time2Tr',num2str(TimeRanges(Time,1)),'to',num2str(TimeRanges(Time,2)),'.jpg'];
    imwrite(OverviewImage,Path);
end
keyboard;

