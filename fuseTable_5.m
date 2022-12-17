function [T1,TargetSubColNames]=fuseTable_5(T1,T2,SourceTarget,SubColNames)

if iscell(T1)
    for m=1:size(T1,1)-1
        [T1{1,1}]=fuseTable_5(T1{1,1},T1{m+1,1});
    end
    T1=T1{1,1};
    return;
end

%% Rows
if exist('SourceTarget')==1 && isempty(SourceTarget)==0
    SourceRows=SourceTarget(:,1);
    TargetRows=SourceTarget(:,2);
else
    TargetRows=T2.Properties.RowNames;
    SourceRows=TargetRows;
    if isempty(TargetRows)
        %         keyboard; % if no RowNames are present
        SourceRows=(1:size(T2,1)).';
        TargetRows=SourceRows+size(T1,1);
    end
end

%% subColumns
if exist('SubColNames')==1
%     EnhanceMultiCol=0;
    TargetSubColNames=SubColNames{1,1};
    SourceSubColNames=SubColNames{1,2};
    SubCol=(1:size(SourceSubColNames,1)).';
    for m=1:size(SourceSubColNames,1)
        Wave1=strfind1(TargetSubColNames,SourceSubColNames{m,1},1);
        if Wave1==0
            TargetSubColNames(end+1,1)=SourceSubColNames(m,1);
            Wave1=strfind1(TargetSubColNames,SourceSubColNames{m,1},1);
        end
        SubCol(m,2)=Wave1;
    end
    
    %% Aufspreizen subcolumns of T1
    TotalSubColumns=size(TargetSubColNames,1);
    if TotalSubColumns>size(SubColNames{1,1},1)
        VariableNames=T1.Properties.VariableNames.';
        for m=VariableNames.'
            SubColNumber=size(T1{:,m},2);
            if SubColNumber>1
                Wave1=T1{:,m};
                Wave1(:,end+1:TotalSubColumns)=nan;
                T1(:,m)=[];
                T1(:,m)=table(Wave1);
            end
        end
        T1=T1(:,VariableNames);
    end
    
    %% Aufspreizen subcolumns of T2
%     TotalSubColumns=size(TargetSubColNames,1);
    if TotalSubColumns>size(SubColNames{1,2},1)
        VariableNames=T2.Properties.VariableNames.';
        for m=VariableNames.'
            SubColNumber=size(T2{:,m},2);
            if SubColNumber>1
                Wave1=T2{:,m};
                Wave1(:,end+1:TotalSubColumns)=nan;
                T2(:,m)=[];
                T2(:,m)=table(Wave1);
            end
        end
        T2=T2(:,VariableNames);
    end
    
    Wave1=SubCol(:,1)-SubCol(:,2);
    if sum(abs(Wave1))~=0
        for m=T2.Properties.VariableNames
            SubColNumber=size(T2{:,m},2);
            if SubColNumber>1
                Wave1=nan(size(T2,1),size(SubCol,1));
                Wave2=T2{:,m};
                Wave1(:,SubCol(:,2))=Wave2(:,SubCol(:,1));
                T2{:,m}=Wave1;
            end
        end
    end
end

% MainColumns


EnhanceCol=0;
TargetColNames=T1.Properties.VariableNames.';
SourceColNames=T2.Properties.VariableNames.';
Col=(1:size(TargetColNames,1)).';
% Col=(1:size(SourceColNames,1)).';
for m=1:size(SourceColNames,1)
    Wave1=strfind1(TargetColNames,SourceColNames{m,1},1);
    if Wave1==0 % T1 does not contain that column
%         keyboard; 
        TargetColNames(end+1,1)=SourceColNames(m,1);
        Wave1=strfind1(TargetColNames,SourceColNames{m,1},1);
        Col(end+1,1)=0;
    end
    Col(m,2)=Wave1;
end

Wave1=Col(:,1)-Col(:,2);
if sum(abs(Wave1))~=0
%     keyboard;
    
%     T2a=table2cell(T2);
%     T2b=cell(size(T2a,1),size(Col,1));
%     T2b(Col(:,1))=T2a(Col(:,2));
    
    % first generate T1
    for m=find(Col(:,1)==0).'
%         keyboard;
        T1(:,TargetColNames{m})=emptyRow(T2(:,TargetColNames{m}));
        Col(m,1)=m;
    end
    
    T2a=repmat(emptyRow(T1),[size(T2,1),1]);
    for m=T2.Properties.VariableNames
        T2a(:,m)=T2(:,m);
    end
    T2=T2a;
    
end


%% Place new rows from T2 into T1
T1(TargetRows,:)=T2(SourceRows,:);

