function [Table]=processTraceGroups_2(MouseInfo,PlaqueListSingle,ImageName,RadiiBinning,TimeBinning)
global W;


if strfind1({'Boutons1';'Bace1';'Lamp1'},ImageName,1)
    DistanceBins=30:80;
elseif strfind1({'Dystrophies1';'Bace1Corona';'Lamp1Corona';'Microglia';'MicrogliaSoma';'MicrogliaFibers';'Iba1'},ImageName,1)
    DistanceBins=40:70;
elseif strfind1({'MetBlue'},ImageName,1)
    DistanceBins=30:70;
else
    keyboard;
end

MouseIds=strcat('M',num2strArray_2(MouseInfo.MouseId));

%% Binning
if exist('RadiiBinning')~=1 || isempty(RadiiBinning)
    RadiiBinning=[999;10;4;2];
end
if exist('TimeBinning')~=1 || isempty(TimeBinning)
    TimeBinning=[999];
end
% keyboard;
RadiusMinMax=[0;ceil(max(PlaqueListSingle.RadiusFit1))];
TimeMinMax=[min(PlaqueListSingle.Time2Treatment);max(PlaqueListSingle.Time2Treatment)];
[BinTable]=generateBinTable(RadiiBinning,TimeBinning,RadiusMinMax,TimeMinMax,MouseInfo);

Table=table;
Table.Specification(1)={'MouseId'};Table.Data=MouseInfo.MouseId.';
for Bin=1:size(BinTable,1)
    OrigRowId=BinTable(Bin,{'TimeMin','TimeMax','TimeBin','RadMin','RadMax','RadBin'});
    
    Selection=PlaqueListSingle(PlaqueListSingle.MouseId==BinTable.MouseId(Bin)...
        & PlaqueListSingle.Time2Treatment>BinTable.TimeMin(Bin)...
        & PlaqueListSingle.Time2Treatment<=BinTable.TimeMax(Bin)...
        & PlaqueListSingle.RadiusFit1>BinTable.RadMin(Bin)...
        & PlaqueListSingle.RadiusFit1<=BinTable.RadMax(Bin)...
        & PlaqueListSingle.BorderTouch==0,:);
    
    if size(Selection,1)==0
        continue;
    end
    
    Container=struct;
    if strcmp(ImageName,'Boutons1')
        Container=processTraceGroups_Boutons1(Selection,BinTable(Bin,:));
    elseif strfind1({'Dystrophy';'Bace1Corona'},ImageName,1) % fraction, ;'Microglia';'MicrogliaSoma';'MicrogliaFibers'
        Container=processTraceGroups_Fraction(Selection,BinTable(Bin,:),ImageName);
    elseif strfind1({'Bace1';'Iba1'},ImageName,1) % intensity normalized to 100%
        Container=processTraceGroups_Intensity(Selection,BinTable(Bin,:),ImageName);
    else
        
    end
    
    if strfind1(Selection.Properties.VariableNames,'Volume',1)
        % from density of datatype and volume per distance ring recalculate the overall mean density
        Volume=Selection.Volume;
        Wave1=Selection{:,ImageName};
        Mean=nansum(Wave1.*Volume,2)./nansum(Volume,2);
        RowId=table; RowId.Roi=(1:size(Mean,1)).'; RowId.Specification(:,1)={'RoiMeans'}; RowId=[RowId,repmat(OrigRowId,[size(RowId,1),1])];
        Table=addData2OutputTable(Table,Mean,RowId,BinTable.Mouse(Bin));
        
        % export mean over all Rois
        Mean=nanmean(Mean);
        RowId=OrigRowId; RowId.Specification={'MouseMean'};
        Table=addData2OutputTable(Table,Mean,RowId,BinTable.Mouse(Bin));
    end
    
    % export mean for each distance bin
    Wave1=nanmean(Selection{:,ImageName},1).';
    RowId=table; RowId.Distance=(-49:206).'; RowId.Specification(:,1)={'MouseMeanPerDistance'}; RowId=[RowId,repmat(OrigRowId,[size(RowId,1),1])];
    Table=addData2OutputTable(Table,Wave1,RowId,BinTable.Mouse(Bin));
    
    
    if isempty(fieldnames(Container))
        continue;
    end
    
    % put EC50
    if strfind1(fieldnames(Container),'EC50')
        RowId=OrigRowId; RowId.Specification={'EC50'};
        Table=addData2OutputTable(Table,Container.EC50,RowId,BinTable.Mouse(Bin));
    end
    
    % determine DistRel trace
    RowId=table; RowId.Distance=(-49:206).'; RowId.Specification(:,1)={'FitPerDistance'}; RowId=[RowId,repmat(OrigRowId,[size(RowId,1),1])];
    Table=addData2OutputTable(Table,Container.FitData,RowId,BinTable.Mouse(Bin));
    
    % add max fraction
    RowId=OrigRowId; RowId.Specification={'MaxFraction'};
    Table=addData2OutputTable(Table,max(Container.FitData),RowId,BinTable.Mouse(Bin));
end

% show slice thickness

OutputFilename=[W.G.T.TaskName{W.Task},'_',ImageName];
PathExcelExport=['\\GNP90N\share\Finn\Raw data\',OutputFilename,'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);

% write to excel
Wave1=findIntersection_2({'Specification';'TimeMin';'TimeMax';'TimeBin';'RadMin';'RadMax';'RadBin';'Roi';'Distance';'Data'},Table.Properties.VariableNames.');
TableExport=addData2OutputTable(Table,struct(),MouseInfo);
xlsActxWrite(TableExport,Workbook,ImageName,[],'Delete');
Workbook.Save;
Workbook.Close;


if BinTable.RadBin(Bin)==999999999999
    % correlate plaque size with MaxFraction
    PlaqueListSingle.MaxFraction=nanmax(PlaqueListSingle.Bace1Corona,[],2);
    Selection=PlaqueListSingle(strfind1(PlaqueListSingle.TreatmentType,{'Control';'NB360';'NB360Vehicle'},1),:);
    Selection=Selection(Selection.BorderTouch==0,:);
    Selection=Selection(Selection.MouseId~=280,:);
    Selection=Selection(Selection.MaxFraction<0.8,:);
    Selection(:,{'Volume';'MetBlue';'Bace1';'Bace1Corona';'DistRelation'})=[];
    xlsActxWrite(Selection,Workbook,[ImageName,'Correlation'],[],'Delete');
end
if BinTable.RadBin(Bin)==999999999999 % make 3D plot Fraction(Radius,Distance)
    Groups={[314;336;341;353;375],{'Vehicle'},[0.5;0.5;0.5];...
        [318;331;346;347;371],{'NB-360_5Sel'},[0;0;0];...
        [275;279;280;318;331;346;347;349;351;371],{'NB-360_All'},[0;0;0];...
        };
    Groups=array2table(Groups,'VariableNames',{'MouseIds';'Description';'Color'});
    Path2file=[W.G.PathOut,'\SurfacePlots\',OutputFilename];
    
    if strcmp(ImageName,'MetBlue')
        Zaxis=(0:100:300).';
    elseif strcmp(ImageName,'Dystrophies1')
        Zaxis=(0:0.2:1).';
    end
    
    
    processTraceGroups_RadiusDistanceFraction('Vehicle_Vs_NB360sel',Table,MouseInfo,Groups([1:2],:),RadiiBinning,[0;30],1,[-10;20],[63;70],Zaxis,Path2file);
%     processTraceGroups_RadiusDistanceFraction('Vehicle_Vs_NB360all',Table,MouseInfo,Groups([1;3],:),RadiiBinning,[0;30],1,[-10;20],[63;70],Path2file);
    
    Times=(-21:7:63).';Times=[Times,Times+7];
    for Time=1:size(Times,1)
        Week=num2str(Times(Time,1)/7);
        processTraceGroups_RadiusDistanceFraction(['Vehicle_Vs_NB360sel_',Week],Table,MouseInfo,Groups([1:2],:),RadiiBinning,[0;30],1,[-10;20],Times(Time,:).',Zaxis,Path2file);
    end

    
end
