% analyse plaque radius, birth growth on a general scale pooling all plaques per mouse and per treatmenttype
function [MouseInfoTime,MouseInfo]=finalEvaluation_PlaquesQuantificationGlobal_2(MouseInfo,PlaqueList,PlaqueListSingle,MouseInfoTime,PathExcelExport)
keyboard; % 2016.07.25
global W;

for Mouse=1:size(MouseInfo,1)
    MouseId=MouseInfo.MouseId(Mouse);
    Selection=PlaqueList(PlaqueList.MouseId==MouseId,:);
    %  compare growth before with during treatment
    Wave1=nanmean(Selection.PlRadPerWeek,1);
    MouseInfo.MeanPlGrowth(Mouse,1:size(Wave1,2))=Wave1;
    
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

Table=MouseInfo(:,{'Mouse','TreatmentType'});
TimeBinning=[7;30.42;999];
for XaxisType={'Age','TimeTo'}
    if strcmp(XaxisType,'Age')
        MinMax=[min(MouseInfoTime.Age);max(MouseInfoTime.Age)];
        TimeZero=30.42*4;
    elseif strcmp(XaxisType,'TimeTo')
        MinMax=[min(MouseInfoTime.Time2Treatment);max(MouseInfoTime.Time2Treatment)];
        TimeZero=0;
    end
    
    Xaxis1d=(MinMax(1):1:MinMax(2)).';
    
    for Mouse=1:size(MouseInfo,1)
        MouseId=MouseInfo.MouseId(Mouse);
        Selection=MouseInfoTime(MouseInfoTime.MouseId==MouseId,:);
        if strcmp(XaxisType,'Age')
            TimeData=Selection.Age;
        elseif strcmp(XaxisType,'TimeTo')
            TimeData=Selection.Time2Treatment;
        end
%         PlBirth=Selection.PlBirth;
                
        
        Ind=TimeData-MinMax(1)+1;
        
        Data1d=nan(size(Xaxis1d,1),1);
        Data1d(min(Ind):max(Ind))=0;
        Data1d(Ind,1)=Selection.PlBirth;
        
        for TimeBin=1:size(TimeBinning,1)
            TimeBinId=TimeBinning(TimeBin);
            MinMaxBinRange=[floor((MinMax(1)-TimeZero)/TimeBinId);ceil((MinMax(2)-TimeZero)/TimeBinId)];
            BinAxis=[MinMaxBinRange(1):1:-1,1:1:MinMaxBinRange(2)].';
            MinMaxBinRange=MinMaxBinRange*TimeBinId+TimeZero;
            BinRanges=(MinMaxBinRange(1):TimeBinId:MinMaxBinRange(2)).';
            DataBin=nan(size(BinAxis,1),1);
            
            for m=2:size(BinRanges,1)
                Wave1=Data1d(Xaxis1d>BinRanges(m-1)&Xaxis1d<=BinRanges(m));
                Days=size(find(isnan(Wave1)==0),1);
                Share=Days/size(Wave1,1);
                if Share>0.5 || Days>7
                    DataBin(m-1,1)=nanmean(Wave1);
                else
                    DataBin(m-1,1)=NaN;
                end
            end
            VariableName=[XaxisType{1},num2str(round(TimeBinId))];
            Table(Mouse,{VariableName})={DataBin.'};
            if Mouse==1
                Table(size(MouseInfo,1)+1,{VariableName})={BinAxis.'};
            end
        end
    end
end






[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(Table,Workbook,['PlaqueFormationSparse'],[],1);
% xlsActxWrite(Table(:,{'Mouse','AgeAxis'}),Workbook,['PlaqueFormationSparseAge'],[],1);
% xlsActxWrite(Table(:,{'Mouse','Time2Axis'}),Workbook,['PlaqueFormationSparseTime2Treatment'],[],1);
% xlsActxWrite(FileData,Workbook,['PlaqueFormationSparseTime2Treatment'],[],1);
Workbook.Save;
Workbook.Close;


return;
keyboard;
% AgeAxis=(min(MouseInfoTime.Age):1:max(MouseInfoTime.Age)).';
AgeAxis=(min(MouseInfoTime.Age):1:max(MouseInfoTime.Age)).';
% Time2Axis=(0:-TimeResolution:min(MouseInfoTime.Time2Treatment)).';
% Time2Axis=(min(MouseInfoTime.Time2Treatment):TimeResolution:0).';
Time2Axis=(min(MouseInfoTime.Time2Treatment):1:max(MouseInfoTime.Time2Treatment)).';
Table=MouseInfo(:,'Mouse');
% % Table.AgeAxis(size(Table,1)+1,1:size(AgeAxis,1))=AgeAxis;
Table.Time2Axis(size(Table,1),1:size(Time2Axis,1))=Time2Axis;
for Mouse=1:size(MouseInfo,1)
    MouseId=MouseInfo.MouseId(Mouse);
    Selection=MouseInfoTime(MouseInfoTime.MouseId==MouseId,:);
    Ind=Selection.Age-min(AgeAxis)+1;
    Wave1=nan(size(AgeAxis,1),1);
    Wave1(min(Ind):max(Ind))=0;
    Wave1(Ind,1)=Selection.PlBirth;
    Table.AgeAxis(Mouse,:)=Wave1.';
    Ind=Selection.Time2Treatment-min(Time2Axis)+1;
    Wave1=nan(size(Time2Axis,1),1);
    Wave1(min(Ind):max(Ind))=0;
    Wave1(Ind,1)=Selection.PlBirth;
    Table.Time2Axis(Mouse,:)=Wave1.';
    %     Table.Time2Axis(Mouse,Ind)=Selection.PlBirth;
end
TimeBinning=[7;30.42;999999];
for BinTime=TimeBinning.'
    Bins=(floor(min(Time2Axis)/BinTime):1:ceil(max(Time2Axis)/BinTime)).';
    for Bin=1:size(Bins,1)
        
    end
end

% compare BabyPlaques before and after treatment
StartTreatmentNum=MouseInfo.StartTreatmentNum(Mouse);
Selection=PlaqueList(PlaqueList.MouseId==MouseId,:);
%     for m=1:2
Wave1=find(Selection.PlBirth<=StartTreatmentNum);
Wave2=find(Selection.PlBirth>StartTreatmentNum);

MouseInfo.BabyPlaques(Mouse,1:2)=Wave1;


Wave1=nanmean(MouseInfo.RoiInfo{Mouse}.BabyPlaques,1);

%     MouseInfo.TotalVolume(Mouse,1)=TotalVolume;
%     try
Wave1=nanmean(MouseInfo.RoiInfo{Mouse}.BabyPlaques,1);
MouseInfo.BabyPlaques(Mouse,1:size(Wave1,2))=Wave1;
%     end








% Dystrophies: exclude DystrophyBaseline>0.3
AllPlaqueSizes=zeros(0,1);
AllAges=zeros(0,1);

PlaqueDataTotal=table;
for Mouse=1:size(MouseInfo,1)
    %     MouseInfo.PlaqueContainer(Mouse,1)={struct('PlaqueGrowth',Table)};
    MouseId=MouseInfo.MouseId(Mouse);
    PlaqueData=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId,:);
    PlaqueData=PlaqueData(isnan(PlaqueData.Radius)|isnan(PlaqueData.Growth),:);
    %     PlaqueData=[];
    %     PlaqueData=MouseInfo.PlaqueContainer{Mouse}.PlaqueGrowth;
    %     PlaqueData(isnan(PlaqueData.Radius)|isnan(PlaqueData.Growth),:)=[];
    
    % group definition
    SizeGroups=table;
    SizeGroups.PlaqueSize=[(-1:2:69).',(1:2:71).'];
    SizeGroups.Name(:,1)={'SizeBin2'};
    SizeGroups(end+1,{'PlaqueSize','Name'})={[1,999],{'All'}};
    Wave1=[(0:15:60).',(15:15:75).']; Wave1(1)=1;
    Wave1=table(Wave1,repmat({'SizeBin15'},[size(Wave1,1),1]),'VariableNames',{'PlaqueSize','Name'});
    SizeGroups=[SizeGroups;Wave1];
    SizeGroups.AgeRange(:,2)=999;
    
    Wave1=SizeGroups(strfind1(SizeGroups.Name,'SizeBin15'),:);
    Wave1=SizeGroups(strfind1(SizeGroups.Name,{'SizeBin15';'All'}),:);
    AgeGroups=[(65:10:255).',(75:10:265).'];
    for m=1:size(AgeGroups,1)
        Wave1.AgeRange=repmat(AgeGroups(m,:),[size(Wave1,1),1]);
        SizeGroups=[SizeGroups;Wave1];
    end
    
    Groups=table;
    for m=1:size(SizeGroups,1)
        TreatmentType=MouseInfo.TreatmentType(Mouse);
        Ind=find(PlaqueData.Radius>=SizeGroups.PlaqueSize(m,1)&...
            PlaqueData.Radius<=SizeGroups.PlaqueSize(m,2)&...
            PlaqueData.Age>=SizeGroups.AgeRange(m,1)&...
            PlaqueData.Age<=SizeGroups.AgeRange(m,2));
        Data=PlaqueData(Ind,:); % just select according to plaque size
        if strcmp(MouseInfo.TreatmentType(Mouse),'NB360')
            Data1=Data(Data.Age<MouseInfo.StartTreatmentNum(Mouse),:);
            Data=Data(Data.Age>=MouseInfo.StartTreatmentNum(Mouse),:);
            Groups(end+1,{'Name','Data','PlaqueSize','AgeRange','TreatmentType'})={SizeGroups.Name(m,1),{Data1},SizeGroups.PlaqueSize(m,:),SizeGroups.AgeRange(m,:),{'NB360Vehicle'}};
        end
        Groups(end+1,{'Name','Data','PlaqueSize','AgeRange','TreatmentType'})={SizeGroups.Name(m,1),{Data},SizeGroups.PlaqueSize(m,:),SizeGroups.AgeRange(m,:),TreatmentType};
    end
    
    % calculate groups mean median etc
    Groups(isempty_2(Groups.Data),:)=[];
    
    
    AllPlaqueSizes=unique([(AllPlaqueSizes);ceil(PlaqueData.Radius)]);
    AllAges=unique([AllAges;PlaqueData.Age]);
    
    for Group=1:size(Groups,1)
        Data=Groups.Data{Group}.Growth;
        Groups.N(Group,1)=size(Data,1);
        Groups.Mean(Group,1)=mean(Data);
        Groups.Median(Group,1)=median(Data);
        Groups.Std(Group,1)=std(Data);
        AgeGroups=unique(Groups.Data{Group}.Age);
        Table=table;
        for iAge=1:size(AgeGroups,1)
            Age=AgeGroups(iAge);
            Data=Groups.Data{Group};
            Data=Data.Growth(Data.Age==Age);
            
            Table.Age(iAge,1)=Age;
            Table.Mean(iAge,1)=mean(Data);
            Table.Median(iAge,1)=median(Data);
            Table.Std(iAge,1)=std(Data);
            Table.N(iAge,1)=size(Data,1);
            
        end
        Groups.Profile(Group,1)={Table};
    end
    MouseInfo.PlaqueContainer{Mouse,1}.Groups=Groups;
    
    PlaqueData.MouseId(:,1)=MouseInfo.MouseId(Mouse);
    PlaqueDataTotal=[PlaqueDataTotal;PlaqueData];
end

%% pool into treatment groups

TreatmentGroups=table;
Wave1=unique(MouseInfo.TreatmentType);
TreatmentGroups(Wave1,'TreatmentType')=Wave1;
for TreatmentType=TreatmentGroups.TreatmentType.'
    Wave1=MouseInfo.MouseId(strfind1(MouseInfo.TreatmentType,TreatmentType));
    if strcmp(TreatmentType,'NB360Vehicle')
        Wave1=[Wave1;MouseInfo.MouseId(strfind1(MouseInfo.TreatmentType,'NB360'))];
    end
    TreatmentGroups.Data2D(TreatmentType,1)={table(Wave1,'VariableNames',{'Mouse'})};
end

for Mouse=1:size(MouseInfo,1)
    TreatmentType=MouseInfo.TreatmentType(Mouse);
    if strcmp(TreatmentType,'NB360')
        TreatmentType={'NB360';'NB360Vehicle'};
    end
    for Treat=TreatmentType.'
        % PlaqueSizeVsGrowth
        MouseId=MouseInfo.MouseId(Mouse);
        MouseId2=find(TreatmentGroups.Data2D{Treat}.Mouse==MouseId);
        Data=MouseInfo.PlaqueContainer{Mouse,1}.Groups;
        Data=Data(strcmp(Data.TreatmentType,Treat),:);
        
        Wave1=Data(strcmp(Data.Name,'SizeBin2') & Data.N>=3,:);
        Xaxis=mean(Wave1.PlaqueSize,2)/2+1;
        
        try
            TreatmentGroups.Data2D{Treat}{:,'SizeVsGrowth'};
        catch
            Rows=size(TreatmentGroups.Data2D{Treat},1);
            TreatmentGroups.Data2D{Treat}{:,'SizeVsGrowth'}=repmat(NaN,[Rows,ceil(max(AllPlaqueSizes)/10)]);
        end
        TreatmentGroups.Data2D{Treat}.SizeVsGrowth(MouseId2,Xaxis)=Wave1.Median;
        
        % AgeVsGrowth
        Data(Data.AgeRange(:,1)==0,:)=[];
        for SizeBin=unique(Data.PlaqueSize(:,2)).'
            Wave1=Data(Data.PlaqueSize(:,2)==SizeBin & Data.N>=3,:);
            Xaxis=mean(Wave1.AgeRange,2)/10;
            ColName=['AgeVsGrowth',num2str(SizeBin)];
            try
                TreatmentGroups.Data2D{Treat}{:,ColName};
            catch
                Rows=size(TreatmentGroups.Data2D{Treat},1);
                TreatmentGroups.Data2D{Treat}{:,ColName}=repmat(NaN,[Rows,ceil(max(AllAges)/10)]);
            end
            TreatmentGroups.Data2D{Treat}{MouseId2,ColName}(1,Xaxis.')=Wave1.Median.';
            
        end
    end
end

%% produce images
SavePath=[W.G.PathOut,'\Unsorted\'];

% median over each 2µm bin for all mice

J=struct;
J.Path2file=[SavePath,'PlaqueSizeToGrowth_AllMice.jpg'];

J.OrigYaxis=[   {TreatmentGroups.Data2D{'NB360Vehicle'}.SizeVsGrowth},{struct('Color','w','LineStyle','-')};...
    {TreatmentGroups.Data2D{'NB360'}.SizeVsGrowth},{struct('Color','c','LineStyle','-')}];
J.OrigType=0;
J.X=(0:2:200).';
J.Xlab='Plaque size [µm]';
J.Ylab='Plaque growth [µm/week]';
J.Xrange=[0;20];
J.Style=1;
J.GenerateExcelFile=1;
movieBuilder_5(J);


% scatter plot of all plaques for each mouse
for Mouse=1:size(MouseInfo,1)
    MouseId=MouseInfo.MouseId(Mouse);
    J=struct;
    J.Path2file=[SavePath,'PlaqueSizeToGrowth_M',num2str(MouseId),'.jpg'];
    Data=PlaqueDataTotal(PlaqueDataTotal.Mouse==MouseId,:);
    J.OrigYaxis=[{Data.Growth},{struct('Color','w')}];
    J.OrigType=1;
    J.X=Data.Radius;
    J.Xlab='Plaque size [µm]';
    J.Ylab='Plaque growth [µm/week]';
    J.Style=1;
    movieBuilder_5(J);
end



keyboard;
A1=1;