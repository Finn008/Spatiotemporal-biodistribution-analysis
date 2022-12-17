function vglutClusterAnalysis_ClusterDistribution4AllPlaqueSizes(VglutArray1,PlaqueListSingle,VglutArray2,MouseInfo,Groups,Path2file)
global W;

% make a framework such that each single volume bin has all existing cluster bins set to zero
ClusterBins=unique(VglutArray2.Dystrophies2Radius);
Wave1=repmat(ClusterBins.',[size(VglutArray1,1),1]);
VglutArray1=[repmat(VglutArray1,[size(ClusterBins,1),1])];
VglutArray1.Dystrophies2Radius(:,1)=Wave1(:);

% fuse cluster bin fraction from VglutArray2 into VglutArray1
% VglutArray2=exchangeVariableName(VglutArray2,'VolumeUm3','ClusterVolume');
VglutArray2.Properties.VariableNames{'VolumeUm3'}='ClusterVolume';

Wave1=fuseTable_MatchingColums_4(VglutArray1,VglutArray2,{'MouseId';'Time2Treatment';'RoiId';'PlId';'Distance';'Dystrophies2Radius'},{'ClusterVolume'});
% Table1=fuseTable_MatchingColums_4(Table1,Table2,MatchingColumns,Colums2Integrate,NewColumnNames)
VglutArray1.ClusterVolume=full(Wave1.ClusterVolume);

VglutArray1.Fraction=full(VglutArray1.ClusterVolume./VglutArray1.VolumeUm3*100);
% % % PlaqueListSingle.RadiusFit1(PlaqueListSingle.RadiusFit1==0 & ismember(PlaqueListSingle.MouseId,[275;279;280;318;331;346;347;349;251;371]),:)=0.001; % otherwise bin 0-2µm remains empty

VglutArray1=fuseTable_MatchingColums_4(VglutArray1,PlaqueListSingle,{'MouseId';'Time2Treatment';'RoiId';'PlId'},{'RadiusFit1'},{'PlaqueRadius'});
% remove bins smaller than 1µm^3
% % % % VglutArray1(VglutArray1.VolumeUm3<1,:)=[];

%% binning
VglutArray1(isnan(VglutArray1.PlaqueRadius),:)=[];
% % % VglutArray1(VglutArray1.Dystrophies2Radius>30,:)=[];
keyboard;
OrigVglutArray1=VglutArray1; % VglutArray1=OrigVglutArray1;
% keyboard;

% % % VglutArray1(VglutArray1.MouseId==279 & VglutArray1.RoiId==1 & VglutArray1.PlId==4,:)=[]; %M2
% % % VglutArray1(VglutArray1.MouseId==318 & VglutArray1.PlId==36,:)=[]; %M5
% % % VglutArray1(VglutArray1.MouseId==331 & VglutArray1.PlId==17 & ismember(VglutArray1.Time2Treatment,[-27;-20;-14;-6]),:)=[]; %M5
% % % VglutArray1(VglutArray1.MouseId==331 & VglutArray1.PlId==19 & ismember(VglutArray1.Time2Treatment,[-27;-20;-14]),:)=[]; %M5
% % % VglutArray1(VglutArray1.MouseId==331 & VglutArray1.PlId==22 & ismember(VglutArray1.Time2Treatment,[-34;-27;-20;-14;-6]),:)=[]; %M5
% % % VglutArray1(VglutArray1.MouseId==331 & VglutArray1.PlId==28 & ismember(VglutArray1.Time2Treatment,[-20;-14;-6;0;6]),:)=[]; %M5
% % % VglutArray1(VglutArray1.MouseId==331 & VglutArray1.PlId==34,:)=[]; %M5
% % % VglutArray1(VglutArray1.MouseId==331 & VglutArray1.PlId==42,:)=[]; %M5

VglutArray1(VglutArray1.MouseId==336 & ismember(VglutArray1.PlId,[32;34]),:)=[]; %M3
VglutArray1(VglutArray1.MouseId==341 & ismember(VglutArray1.PlId,[20;34;35;37;75]),:)=[]; %M5  previously: 30;29;47;31;
VglutArray1(VglutArray1.MouseId==375 & ismember(VglutArray1.PlId,[24;33]),:)=[]; %M8 previously: 10;16;
% Wave1=unique(VglutArray1.Time2Treatment(VglutArray1.MouseId==331 & VglutArray1.PlId==17));

%% calculate dystrophic fraction for different plaque sizes
Selection=VglutArray1(VglutArray1.Dystrophies2Radius>9,:);
Selection=accumarray_8(Selection(:,{'MouseId';W.XaxisType;'RoiId';'PlId';'Distance';'PlaqueRadius'}),Selection(:,{'Fraction'}),@nansum,[]);
Selection=Selection(Selection.Distance>=-2 & Selection.Distance<=2,:);
% Selection=Selection(Selection.Distance>=0 & Selection.Distance<=1,:);
Selection=accumarray_8(Selection(:,{'MouseId';W.XaxisType;'RoiId';'PlId';'PlaqueRadius'}),Selection(:,{'Fraction'}),@nanmean,[]);
% 'Time2Treatment',[7],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; %  % 'Time2Treatment',-2,0,[-28;70];
BinInfo={'MouseId',0,0,0;
    'Age',[30.42;999],30.42*[3;6],0;    % 70;244   'Time2Treatment',-2,0,[0;70];
    'PlaqueRadius',[2],[0;999],0
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;

[Table]=accumArrayBinning(Selection,BinInfo,'Fraction',[],@nanmean);

% Wave1=Selection;Wave1.Fraction(:,1)=1;
% [CountInstances]=accumArrayBinning(Wave1,BinInfo,'Fraction',[],@nansum,1);

% Table(CountInstances.Fraction<2,:)=[];
Table=distributeColumnHorizontally_4(Table,[],'MouseId','Fraction',MouseInfo.MouseId);

% Table.Fraction=Table.Fraction*100;
TableExport=Table;
[TableExport]=table2cell_2(TableExport);
TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
TableExport=[TableExport(1,:);TableExport];
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;

PathExcelExport=getPathRaw('VGLUT1.xlsx');
% PathExcelExport=['\\GNP90N\share\Finn\Raw data\VGLUT1.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(TableExport,Workbook,'DystrophicFractionPerPlaque',[],'Delete');

keyboard;
%% generate profiles from mean of the means of each mouse
% VglutArray1=OrigVglutArray1;
% VglutArray1(VglutArray1.MouseId==336 & ismember(VglutArray1.PlId,[32;34]),:)=[]; %M3
% VglutArray1(VglutArray1.MouseId==341 & ismember(VglutArray1.PlId,[20;34;35;37;75;30;29;47;31]),:)=[]; %M5  previously: 
% VglutArray1(VglutArray1.MouseId==375 & ismember(VglutArray1.PlId,[24;33;10;16;]),:)=[]; %M8 previously: 
VglutArray1(VglutArray1.MouseId==341 & ismember(VglutArray1.PlId,[47;31]),:)=[]; %M5  previously: 30;29;47;31;
VglutArray1(VglutArray1.MouseId==353 & ismember(VglutArray1.PlId,[23]),:)=[];
VglutArray1(VglutArray1.MouseId==336 & ismember(VglutArray1.PlId,[64]),:)=[];

VglutArray1(VglutArray1.MouseId==279& ismember(VglutArray1.PlId,[7]),:)=[];
VglutArray1(VglutArray1.MouseId==331& ismember(VglutArray1.PlId,[20;18]),:)=[];
VglutArray1(VglutArray1.MouseId==347 & ismember(VglutArray1.PlId,[25]),:)=[];
VglutArray1(VglutArray1.MouseId==349 & ismember(VglutArray1.PlId,[55]),:)=[];
VglutArray1(VglutArray1.MouseId==371 & ismember(VglutArray1.PlId,[8]),:)=[];


ReplicateType='Plaques'; % ReplicateType='mice';
if strcmp(ReplicateType,'Plaques')
    BinInfo={'Time2Treatment',-2,0,[0;70]; %     'Time2Treatment',[28],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; %  % 'Time2Treatment',-2,0,[-28;70];
        'PlaqueRadius',[2],[0;999],0 %
        'Dystrophies2Radius',-2,0,[(0:1:60).';999]; % [0;5;10;15;20;999]
        'Distance',[1],[-20;51],0; % 1µm steps
        };
    BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'});
    BinInfo.Properties.RowNames=BinInfo.Name;
    PlaqueBinning=2;
    PlaqueRadiiRanges=(0:PlaqueBinning:18).';PlaqueRadiiRanges=[PlaqueRadiiRanges,PlaqueRadiiRanges+PlaqueBinning];
    TimeBinning=70; % TimeBinning=28;
    TimeRanges=[0,70];
    Pix=[1599;1603];
    
    for Group=1%[1,6,8,9]
        Selection=VglutArray1(ismember(VglutArray1.MouseId,Groups.MouseIds{Group}),:);
        [Table]=accumArrayBinning(Selection,BinInfo,'Fraction',[],@nanmean);
        clear OverviewImage;
        disp(Group);
        for PlaqueRadius=1:size(PlaqueRadiiRanges,1)
            for Time=1:size(TimeRanges,1)
                Wave1=['Nplaques_',Groups.Description{Group},'_Plaque',num2str(PlaqueRadiiRanges(PlaqueRadius,1)),'-',num2str(PlaqueRadiiRanges(PlaqueRadius,2)),'_Time2Tr',num2str(TimeRanges(Time,1)),'to',num2str(TimeRanges(Time,2))];
                [Image]=vglutClusterAnalysis_PlotClusterSizeDistribution_2(Wave1,Table,MouseInfo,MouseInfo.MouseId(1),PlaqueBinning,PlaqueRadiiRanges(PlaqueRadius,:).',1,[-20;51],TimeBinning,TimeRanges(Time,:).',[],Path2file);
                if isempty(Image)
                    Chunk=zeros(Pix(1),Pix(2),3,'uint8');
                else
                    Chunk=Image(200:1798,562:2164,:);
                end
                OverviewImage((Time-1)*Pix(1)+1:(Time-1)*Pix(1)+Pix(1),(PlaqueRadius-1)*Pix(2)+1:(PlaqueRadius-1)*Pix(2)+Pix(2),1:3)=Chunk;
            end
        end
        Path=[Path2file,Groups.Description{Group},'_PlaqueBinning',num2str(PlaqueBinning),'_Time2Tr',num2str(TimeRanges(Time,1)),'to',num2str(TimeRanges(Time,2)),'.jpg'];
        imwrite(OverviewImage,Path);
    end
end

%% generate profiles from mean of the means of each mouse

% VglutArray1(:,{'RoiId';'PlId';'VolumeUm3';'ClusterVolume'})=[];
% VglutArray1(VglutArray1.PlaqueRadius==0,:)=[];
% VglutArray1=OrigVglutArray1;
% VglutArray1(VglutArray1.MouseId==336 & ismember(VglutArray1.PlId,[32;34]),:)=[]; %M3
% VglutArray1(VglutArray1.MouseId==341 & ismember(VglutArray1.PlId,[20;34;35;37;75;30;29;47;31]),:)=[]; %M5  previously: 
% VglutArray1(VglutArray1.MouseId==375 & ismember(VglutArray1.PlId,[24;33;10;16;]),:)=[]; %M8 previously: 
% 
% VglutArray1(isnan(VglutArray1.PlaqueRadius),:)=[];
if strcmp(ReplicateType,'Mice')
    BinInfo={'MouseId',0,0,0; % no binning
        'Time2Treatment',-2,0,[0;70]; %     'Time2Treatment',[28],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; %  % 'Time2Treatment',-2,0,[-28;70];
        'PlaqueRadius',[2],[0;999],0 %
        'Dystrophies2Radius',-2,0,[(0:1:60).';999]; % [0;5;10;15;20;999]
        'Distance',[1],[-20;51],0; % 1µm steps
        };
    BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'});
    BinInfo.Properties.RowNames=BinInfo.Name;
    
    [Table]=accumArrayBinning(VglutArray1,BinInfo,'Fraction',[],@nanmean);
    Table=distributeColumnHorizontally_4(Table,[],'MouseId','Fraction',MouseInfo.MouseId);
    
    PlaqueBinning=2;
    PlaqueRadiiRanges=(0:PlaqueBinning:18).';PlaqueRadiiRanges=[PlaqueRadiiRanges,PlaqueRadiiRanges+PlaqueBinning];
    TimeBinning=70; % TimeBinning=28;
    TimeRanges=[0,70];
    
    Pix=[1599;1603];
    % for Group=[8] % 1
    for Group=9%[1,6,8,9] %[9:26]
        % for Group=[1,13]
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
        Path=[Path2file,Groups.Description{Group},'_PlaqueBinning',num2str(PlaqueBinning),'_Time2Tr',num2str(TimeRanges(Time,1)),'to',num2str(TimeRanges(Time,2)),'.jpg'];
        imwrite(OverviewImage,Path);
    end
end



%% plot cluster distribution at plaque border over time for each plaque separately for each mouse