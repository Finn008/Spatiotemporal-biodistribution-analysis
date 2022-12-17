% analyse plaque radius, birth growth on a general scale pooling all plaques per mouse and per treatmenttype
function [MouseInfoTime,MouseInfo]=finalEvaluation_BabyPlaques(MouseInfo,PlaqueList,MouseInfoTime)
global W;

for Mouse=1:size(MouseInfo,1)
    MouseId=MouseInfo.MouseId(Mouse);
    Selection=PlaqueList(PlaqueList.MouseId==MouseId,:);
    % define TotalVolume
    Selection=MouseInfoTime(MouseInfoTime.MouseId==MouseId,:);
    TotalVolume=mean(Selection.TotalVolume);
end

% count BabyPlaques for each timepoint

Selection=PlaqueList(isnan(PlaqueList.PlBirth)==0,:);
for m=1:size(MouseInfoTime,1)
    MouseId=MouseInfoTime.MouseId(m);
    Wave1=find(Selection.MouseId==MouseId&Selection.PlBirth==MouseInfoTime.Age(m));
    MouseInfoTime.PlBirth(m,1)=size(Wave1,1)/MouseInfoTime.TotalVolume(m)*1000000000;
end
Table=table;
MouseIds=strcat('M',num2strArray_2(MouseInfo.MouseId));
XaxisType='TimeTo'; %'Age'
if strcmp(XaxisType,'Age')
    MinMax=[min(MouseInfoTime.Age);max(MouseInfoTime.Age)];
    TimeZero=30.42*4;
elseif strcmp(XaxisType,'TimeTo')
    MinMax=[min(MouseInfoTime.Time2Treatment);max(MouseInfoTime.Time2Treatment)];
    TimeZero=0;
end

TimeBinning=[1;7;30.42;999];
TimeBins=zeros(0,3);
for TimeBin=1:size(TimeBinning,1)
    TimeBinId=TimeBinning(TimeBin);
    MinMaxBinRange=[floor((MinMax(1)-TimeZero)/TimeBinId);ceil((MinMax(2)-TimeZero)/TimeBinId)];
    MinMaxBinRange=MinMaxBinRange*TimeBinId+TimeZero;
    Wave1=(MinMaxBinRange(1):TimeBinId:MinMaxBinRange(2)).';
    TimeBins=[TimeBins;[Wave1(1:end-1),Wave1(2:end),repmat(TimeBinning(TimeBin),[size(Wave1,1)-1,1])]];
end

Xaxis1d=(MinMax(1):1:MinMax(2)).';

for Mouse=1:size(MouseInfo,1)
    MouseId=MouseInfo.MouseId(Mouse);
    Selection=MouseInfoTime(MouseInfoTime.MouseId==MouseId,:);
    Selection.PlBirth(isnan(Selection.PlBirth))=0;
    if strcmp(XaxisType,'Age')
        TimeData=Selection.Age;
    elseif strcmp(XaxisType,'TimeTo')
        TimeData=Selection.Time2Treatment;
    end
    
    Ind=uint16(TimeData-MinMax(1)+1);
    
    Data1d=nan(size(Xaxis1d,1),1);
    Data1d(min(Ind):max(Ind))=0;
    Data1d(Ind,1)=Selection.PlBirth;
    
    for TimeBin=1:size(TimeBins,1)
        TimeBinId=TimeBins(TimeBin,:).';
        Wave1=Data1d(Xaxis1d>TimeBinId(1)&Xaxis1d<=TimeBinId(2));
        Days=size(find(isnan(Wave1)==0),1);
        Share=Days/size(Wave1,1);
        if Share>0.5 || Days>7
            DataBin=nanmean(Wave1);
        else
            DataBin=NaN;
        end
        RowId=['Time',num2str(TimeBin)];
        Table(RowId,{'TimeBinning','TimeRange'})={TimeBinId(3),TimeBinId(1:2).'};
        Table.PlaqueFormation(RowId,Mouse)=DataBin;
    end
end

Wave1=Table.PlaqueFormation(Table.TimeBinning==1,:);
Nans=isnan(Wave1);
Wave1(Nans)=0;
Wave1=cumsum(Wave1);
Wave1(Nans)=NaN;
Table.PlaqueFormation(Table.TimeBinning==1,:)=Wave1;

[Table]=table2cell_2(Table);
Table=[Table(1,:);[NaN,NaN,NaN,MouseInfo.TreatmentType.'];num2cell([NaN,NaN,NaN,MouseInfo.MouseId.']);Table(2:end,:)];

PathExcelExport='\\GNP90N\share\Finn\Raw data\PlaqueFormation.xlsx';
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(Table,Workbook,['PlaqueFormation'],[],1);
% keyboard;
Workbook.Save;
Workbook.Close;