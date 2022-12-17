% 
function finalEvaluation_PlaquesQuantificationGlobal(MouseInfo,PlaqueListSingle)
global W;
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