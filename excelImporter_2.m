function excelImporter_2()
global W;
% PathTaskXls=[W.PathExp,'\default\Excel\',W.TaskListID,W.ComputerInfo.ExcelVersion];

[Excel,Workbook,Sheets,SheetNumber]=connect2Excel([W.PathSlaveDriver,'\Excel\',W.CurrentTaskList,'.xlsx']);

for Sheet=1:SheetNumber
    try
        Path=['Proxy=',Sheets{Sheet}(1:end-1),';']; eval(Path); % get previous version
    end
    if exist('Proxy','Var')==0 || isempty(Proxy)
        Proxy=table; Proxy.RowSpecifier=1;
    end
    Raw=xlsActxGet(Workbook,Sheet);
    
    % remove columns to be removed
    Wave1=strfind1(Raw(3,:).','remove',1);
    if Wave1~=0
%         keyboard; % test whether it works
        Proxy(:,Raw(1,Wave1))=[];
        Raw(:,Wave1)=[];
%         RemovedColNames=Raw(1,RemovedColNumbers).';
%         for m2=1:size(RemovedColNumbers,1);
%             % if only one column is left then donot use (:,w.doN) because otherwise whole table is emptied
%             try; Proxy(:,RemovedColNames{m2})=[]; end; % try catch because otherwise error if variable not present
%         end
    end
    ColumnNames=Raw(1:W.ExcelViewerHeadLines,:);
    ColumnNames(cellfun(@(x) any(isnan(x)),ColumnNames)) = {[]};
    DataIn=Raw(W.ExcelViewerHeadLines+1:end,:); % extract data values from new version
    if strfind1(ColumnNames(1,:),'RowSpecifier')==0 % if Rowspecifier not present add one
        ColumnNames{1,end+1}='RowSpecifier';
        DataIn(:,end+1)=num2cell(1:size(DataIn,1).');
    end
    
    ColumnNumber=size(ColumnNames,2);
    RowNumber=size(DataIn,1);
    
    % sort original dataset according to new one
    IndSpec=strfind1(ColumnNames(1,:).','RowSpecifier',1);
    RowSpecifier=cell2mat(DataIn(:,IndSpec));
    
    NewProxy=Proxy(1:min(size(RowSpecifier,1),size(Proxy,1)),:);
    % go through each line of datain (if proxy is larger than datain then also go through these lines)
    for m2=1:size(RowSpecifier,1)
        if isnan(RowSpecifier(m2,1)) % if no RowSpecifier present then replace that row in newProxy with an empty one
            NewProxy(m2,:)=emptyRow(NewProxy(1,:));
        elseif RowSpecifier(m2,1)~=m2
            NewProxy(m2,:)=Proxy(RowSpecifier(m2,1),:);
        end
    end
    % replace excluded cells
    Ind=strfind1(DataIn,'qqzwr');
    Ind(Ind==0,:)=[];
    for m2=1:size(Ind,1)
        Wave1=str2num(DataIn{Ind(m2,1),Ind(m2,2)}(6:end));
        DataIn(Ind(m2,1),Ind(m2,2))=W.ExcludedCells(Wave1);
    end
    
    % generate proxys
    Wave1=cell(ColumnNumber,1); Wave1(:)={'NewProxy.'};
    Wave1=[Wave1,ColumnNames(1:2,:).'];
    [ColumnProxys]=joinCell2string(Wave1);
    
    if istable(NewProxy);
        if isempty(NewProxy)
            NewProxy.RowSpecifier=1;
        end
        for m2=1:ColumnNumber; % -1 to exclude RowSpecifierA1
            try
                Path=['Wave1=',ColumnProxys{m2},';'];
                eval(Path);
            catch
                Wave1=DataIn(:,m2);
            end
            
            Wave2=DataIn(:,m2);
            if isnumeric(Wave1) % test if input was numeric
                try % if imported column now char instead of numeric then leave it as cellarray
                    Wave2=cell2mat(DataIn(:,m2));
                end
            end
            if isempty(ColumnNames{3,m2})==0
                Wave2=ccBack(Wave1,Wave2,ColumnNames{3,m2});
            end
            
            if size(Wave2,1)>size(NewProxy,1)
                NewProxy(size(Wave2,1),1)=NewProxy(1,1);
            end
            
            Path=[ColumnProxys{m2},'=Wave2;'];
            eval(Path);
            clear Wave2;
            clear Wave1;
        end
        % try to convert to numeric array
        for m2 = 1: size(NewProxy,2)
            try
                Wave1=cell2mat(NewProxy.(m2));
                if ischar(Wave1)
                else
                    NewProxy.(m2)=Wave1;
                end
            end
        end
    end
    
    if isstruct(NewProxy);
        for m2=1:ColumnNumber-1; % -1 to exclude RowSpecifier
            try
                Path=['wave1=',ColumnProxys{m2},';'];
                eval(Path);
            end
            if isnumeric(Wave1)
                Wave2=cell2mat(DataIn(:,m2));
            else
                Wave2=DataIn{:,m2};
            end
            if isempty(ColumnNames{3,m2})==0
                Wave2=ccBack(Wave1,Wave2,ColumnNames{3,m2});
            end
            Path=[ColumnProxys{m2},'=Wave2;'];
            eval(Path);
        end
    end
    %% finish
    Path=[Sheets{Sheet}(1:end-1),'=NewProxy;'];
    eval(Path);
end


excelViewer_2()

