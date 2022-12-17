function processSingleGroups(MouseInfo,MouseInfoTime,DataType,XaxisType,TimeBinning,RadiiBinning)
global W;


Table=table;
% MouseIds=strcat('M',num2strArray_2(MouseInfo.Mouse));
if exist('XaxisType')~=1 || isempty(XaxisType); XaxisType='TimeTo'; end;

if strcmp(XaxisType,'Age')
    MinMax=[min(MouseInfoTime.Age);max(MouseInfoTime.Age)];
    TimeZero=30.42*4;
elseif strcmp(XaxisType,'TimeTo')
    MinMax=[min(MouseInfoTime.Time2Treatment);max(MouseInfoTime.Time2Treatment)];
    TimeZero=0;
end

%% Binning
if exist('RadiiBinning')~=1 || isempty(RadiiBinning)
    RadiiBinning=[999;10];
end
if exist('TimeBinning')~=1 || isempty(TimeBinning)
    TimeBinning=[999;30.42;7];
end
[BinTable]=generateBinTable(RadiiBinning,TimeBinning);

% TimeBins=table;
% for TimeBin=1:size(TimeBinning,1)
%     TimeBinId=TimeBinning(TimeBin);
%     MinMaxBinRange=[floor((MinMax(1)-TimeZero)/TimeBinId);ceil((MinMax(2)-TimeZero)/TimeBinId)];
%     MinMaxBinRange=MinMaxBinRange*TimeBinId+TimeZero;
%     Wave1=(MinMaxBinRange(1):TimeBinId:MinMaxBinRange(2)).';
%     Data2Add=table(Wave1(1:end-1),Wave1(2:end),repmat(TimeBinning(TimeBin),[size(Wave1,1)-1,1]),'VariableNames',{'TimeMin','TimeMax','TimeBin'});
%     TimeBins=[TimeBins;Data2Add];
% end

Xaxis1d=(MinMax(1):1:MinMax(2)).';


% Table=table;
% Table.Specification(1)={'MouseId'};Table.Data=MouseInfo.Mouse.';

for Mouse=1:size(MouseInfo,1)
    MouseId=MouseInfo.MouseId(Mouse);
    Selection=MouseInfoTime(MouseInfoTime.MouseId==MouseId,:);
    if strcmp(XaxisType,'Age')
        TimeData=Selection.Age;
    elseif strcmp(XaxisType,'TimeTo')
        TimeData=Selection.Time2Treatment;
    end
    
    Ind=uint16(TimeData-MinMax(1)+1);
    Data1d=nan(size(Xaxis1d,1),1);
    Data1d(min(Ind):max(Ind))=0;
    
    Sparse=0;
    if Sparse==1
        Data1d(Ind,1)=Selection{:,DataType};
    else
        Ind=[Ind(1);Ind;Ind(end)];
        for m=1:size(Selection,1)
            Data1d(round(mean(Ind(m:m+1))):round(mean(Ind(m+1:m+2))))=Selection{m,DataType};
        end
        % normalize first datapoint to zero
% % %         Data1d=Data1d-min(Data1d);
    end
    
    for TimeBin=1:size(TimeBins,1)
        Wave1=Data1d(Xaxis1d>TimeBins.TimeMin(TimeBin)&Xaxis1d<=TimeBins.TimeMax(TimeBin));
        Days=size(find(isnan(Wave1)==0),1);
        Share=Days/size(Wave1,1);
        if Share>0.5 || Days>7
            DataBin=nanmean(Wave1);
        else
            DataBin=NaN;
        end
        RowId=['Time',num2str(TimeBin)];
        Table(RowId,{'TimeBinning','TimeRange','TimeMean'})={TimeBins.TimeBin(TimeBin),[TimeBins.TimeMin(TimeBin),TimeBins.TimeMax(TimeBin)],mean([TimeBins.TimeMin(TimeBin),TimeBins.TimeMax(TimeBin)])};
        Table.Data(RowId,Mouse)=DataBin;
    end
end

[Table]=table2cell_2(Table);
Table(1,5:end)={DataType};
Table=[Table(1,:);[NaN,NaN,NaN,NaN,MouseInfo.TreatmentType.'];num2cell([NaN,NaN,NaN,NaN,MouseInfo.MouseId.']);Table(2:end,:)];

PathExcelExport=['\\GNP90N\share\Finn\Raw data\',DataType,'_',XaxisType,'.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);

xlsActxWrite(Table,Workbook,['Data'],[],1);
% keyboard;
Workbook.Save;
Workbook.Close;
