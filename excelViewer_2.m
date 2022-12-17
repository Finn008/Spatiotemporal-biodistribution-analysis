function excelViewer_2()
global W;
% PathTaskXls=[W.PathExp,'\default\Excel\',W.TaskListID,W.ComputerInfo.ExcelVersion];
% PathTaskXls=[W.PathSlaveDriver,'\TaskLists\',W.CurrentTaskList,'.xlsx'];
% if exist(PathTaskXls,'file')==0;
%     Path=[W.PathProgs,'\blueprint',W.ComputerInfo.ExcelVersion]; % blueprint is empty excel sheet
%     copyfile(Path,PathTaskXls);
% end
% get handle to Excel file
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel([W.PathSlaveDriver,'\Excel\',W.CurrentTaskList,'.xlsx']);

Sheets=regexprep(Sheets,'!!',':');
W.ExcludedCells=cell(0,1);
for m=1:SheetNumber
    Path=['Proxy=',Sheets{m}(1:end-1),';']; eval(Path);
    
    if istable(Proxy) % to remove Properties
        AllColumnNames=Proxy.Properties.VariableNames.';
    elseif isstruct(Proxy)
        AllColumnNames=fieldnames(Proxy);
    end
    
    % get sheet data
    Raw=xlsActxGet(Workbook,m);
    
    ActiveRange=cell(size(Raw,1),size(Raw,2));
    if isempty(Raw) || size(Raw,1)<=1% get all fields and all indices
        if strfind1(AllColumnNames,'RowSpecifier')==0
            AllColumnNames=[AllColumnNames;'RowSpecifier'];
        end
        Raw=AllColumnNames.';
        
        Raw(2:W.ExcelViewerHeadLines,:)={[]};
    end
    % remove columns to be removed
    RemovedCols=strcmp(Raw(3,:),'remove'); RemovedCols=find(RemovedCols==1).';
    Raw(:,RemovedCols)=[];
    
    ColumnNames=Raw(1:W.ExcelViewerHeadLines,:);
    ColumnNames(cellfun(@(x) any(isnan(x)),ColumnNames)) = {''};
    ColumnNumber=size(ColumnNames,2);
    
    Wave1=cell(ColumnNumber,1); Wave1(:)=Sheets(m);
    Wave1=[Wave1,ColumnNames(1:2,:).'];
    [ColumnProxys]=joinCell2string(Wave1);
    
    RowNumber=size(Proxy,1);
    DataIn=ColumnNames; DataIn(RowNumber+W.ExcelViewerHeadLines,:)={[]};
    
    if istable(Proxy)
        for n=1:ColumnNumber
            try
                Path=['Wave2=',ColumnProxys{n},';']; eval(Path);
            catch % if name not yet present or doN not yet present
                Wave2=cell(size(Proxy,1),1);
            end
            if isempty(ColumnNames{3,n})==0
                Wave2=cc(Wave2,ColumnNames{3,n});
            end
            if isnumeric(Wave2) || islogical(Wave2)
                Wave2=num2cell(Wave2);
            elseif ischar(Wave2)
                Wave2={Wave2};
            elseif isstruct(Wave2)
                Wave3=cell(1,1);
                for m3=1:size(Wave2)
                    Wave3{m3,1}=Wave2(m3,1);
                end
                Wave2=Wave3;
            end
            DataIn(W.ExcelViewerHeadLines+1:end,n)=Wave2(:,1);
        end
    end
    
    if isstruct(Proxy);
        for n=1:ColumnNumber-1;
            try
                Path=['Wave2=',ColumnProxys{n},';']; eval(Path);
            catch % if name not yet present or doN not yet present
                Wave2=cell(size(Proxy,1),1);
            end
            if isempty(ColumnNames{3,n})==0
                Wave2=cc(Wave2,ColumnNames{3,n});
            end
            DataIn{W.ExcelViewerHeadLines+1:end,n}=Wave2;
        end
    end
    
    % delete RowSpecifier and add it at the end
    Ind=strfind1(ColumnNames(1,:).','RowSpecifier',1);
    DataIn(:,end+1)=DataIn(:,Ind(end));
    DataIn(W.ExcelViewerHeadLines+1:end,end)=num2cell((1:RowNumber).');
    DataIn(:,Ind)=[];
    
    
    [Xdim,Ydim,Zdim] = cellfun(@size, DataIn); % get size in XYZ of each entry
    IsAstring=cellfun(@ischar, DataIn); % entries with Ydim < 1 can be visualized in excel, only chars are larger but still should be included
    IsAnumber = cellfun(@isnumeric, DataIn); % to exclude 1x1 struct cells
    IsAstructure = cellfun(@isstruct, DataIn); % to exclude 1x1 struct cells
    IsAcell = cellfun(@iscell, DataIn); % to exclude cells
    IsAtable = cellfun(@istable, DataIn); % to exclude 1x1 struct cells
    IncludedCells=zeros(size(DataIn,1),size(DataIn,2));
    IncludedCells(IsAstring | IsAnumber)=1; % not ==1 because otherwise empty cells would be excluded
    IncludedCells(Xdim>1)=0;
    
    % export excluded cells
    [Ind,Ind(:,2)]=find(IncludedCells==0);
    Ind(Ind==0,:)=[];
    for m2=1:size(Ind)
        W.ExcludedCells(end+1,1)=DataIn(Ind(m2,1),Ind(m2,2));
        DataIn{Ind(m2,1),Ind(m2,2)}=['qqzwr',num2str(size(W.ExcludedCells,1))];
    end
    xlsActxWrite(DataIn,Workbook,m,[],'DeleteOnlyContent');
end
Workbook.Save; % save changes
Excel.Visible = 1;
release(Excel.Workbooks);
delete(Excel);