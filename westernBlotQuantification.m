function westernBlotQuantification()

Path2file='\\fs-mu.dzne.de\petersf\data\X0103 presentations\X0233 TauKO\BACE1\BACE1_Westernblots_2018.12.13.xlsx';
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(Path2file);

Data=xlsActxGet(Workbook,'RawData',1);
% % Data(Data.Include==0,:)=[];
Data=Data(:,{'Gel';'Column';'MouseId';'Include';'BACE1';'Calnexin';'Group'});
RefMouseId='121, VKIN';
Data.Ratio=Data.BACE1./Data.Calnexin;

MouseList=unique(Data(:,{'MouseId';'Group'}));
if size(unique(Data.MouseId),1)~=size(MouseList,1); A1=adsf; end;

Gels=unique(Data.Gel);
for Gel=Gels.'
    Ind=find(Data.Gel==Gel);
    RefInd=find(Data.Gel==Gel & strcmp(Data.MouseId,RefMouseId),1);
    Data.Norm2Ref(Ind)=Data.Ratio(Ind)./Data.Ratio(RefInd)*100;
end

MouseList.Norm2Ref=nan(size(MouseList,1),max(Gels));
MouseList.Include=nan(size(MouseList,1),max(Gels));
for Mouse=1:size(MouseList,1)
    MouseId=MouseList.MouseId{Mouse};
    Ind=find(strcmp(Data.MouseId,MouseId));
%     MouseList.N(Mouse)=size(Ind,1);
    MouseList.Norm2Ref(Mouse,Data.Gel(Ind))=Data.Norm2Ref(Ind).';
    MouseList.Include(Mouse,Data.Gel(Ind))=Data.Include(Ind).';
%     MouseList.Norm2Ref(Mouse,1:size(Ind,1))=Data.Norm2Ref(Ind).';
end

Ind=strfind1(MouseList.MouseId,RefMouseId,1);
MouseList.Norm2Ref(Ind,:)=100; % % % Wave1=find(MouseList.Norm2Ref(Ind,:)==100).'; MouseList.Norm2Ref(Ind,Wave1(2:end))=NaN;

Wave1=MouseList.Norm2Ref; Wave1(MouseList.Include==0)=NaN;
MouseList.Mean=nanmean(Wave1,2);
MouseList.Min2Max=max(Wave1,[],2)-min(Wave1,[],2);
MouseList.Min2Max(MouseList.Min2Max==0)=NaN;

MouseList.N=sum(isnan(Wave1)==0,2);

% put cohorts together
Groups=table;
Groups.Group=unique(MouseList.Group);

for Group=1:size(Groups,1)
    GroupId=Groups.Group{Group};
    Ind=find(strcmp(MouseList.Group,GroupId));
    Groups.N(Group)=size(Ind,1);
end
Groups.Data=nan(size(Groups,1),max(Groups.N));
for Group=1:size(Groups,1)
    GroupId=Groups.Group{Group};
    Ind=find(strcmp(MouseList.Group,GroupId));
    Groups.Data(Group,1:size(Ind,1))=MouseList.Mean(Ind).';
end
Groups.Data=Groups.Data/nanmean(Groups.Data(2,:))*100;
Wave1=xlsActxGet(Workbook,'Groups');
Table=table;Table.Group=Wave1(2:end,1);
for Group=1:size(Groups,1)
    GroupId=Groups.Group{Group};
    Groups.Ind(Group)=find(strcmp(Table.Group,GroupId));
end
Groups(Groups.Ind,:)=Groups;
Groups=removevars(Groups,'Ind');
xlsActxWrite(Groups,Workbook,'Groups',[],'Delete');
% excelWriteSparse(Groups,Workbook,'Groups','WholeColumns');

% gather info for each Gel
GelTable=table;
GelTable.Gel=Gels;
GelTable.Mean=nanmean(MouseList.Norm2Ref(:,Gels),1).';
GelTable.Min=min(MouseList.Norm2Ref(:,Gels),[],1).';
GelTable.Max=max(MouseList.Norm2Ref(:,Gels),[],1).';
GelTable.Range=GelTable.Max-GelTable.Min;
% xlsActxWrite(GelTable,Workbook,'Gels',[],'Delete');
excelWriteSparse(GelTable,Workbook,'Gels','WholeColumns');

%% export MouseList

% sort according to excel sheet
Table=xlsActxGet(Workbook,'MouseList',1);
for Mouse=1:size(MouseList,1)
    MouseId=MouseList.MouseId{Mouse};
    Ind=find(strcmp(Table.MouseId,MouseId));
    if isempty(Ind); Ind=0; end;
    MouseList.Ind(Mouse)=Ind;
end
Wave1=find(MouseList.Ind==0);
MouseList.Ind(Wave1,1)=(size(Table,1)+1:size(Table,1)+size(Wave1,1)).';
MouseList(MouseList.Ind,:)=MouseList;

MouseList.Include(isnan(MouseList.Include))=0;
MouseListInc=table;
for Gel=1:size(Gels,1)
    MouseList{:,['Gel',num2str(Gels(Gel))]}=MouseList.Norm2Ref(:,Gel);
    MouseListInc{:,['Gel',num2str(Gels(Gel))]}=MouseList.Include(:,Gel);
end
MouseList=removevars(MouseList,{'Include';'Norm2Ref';'Ind'});

% MouseList=removevars(MouseList,{'Ind';'Include'});
excelWriteSparse(MouseList,Workbook,'MouseList','WholeColumns');


excelWriteSparse(MouseListInc,Workbook,'MouseList','EachCell',1);







% [A1,A2,A3]=unique(MouseList.MouseId);