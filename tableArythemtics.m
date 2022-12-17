function [Out]=tableArythemtics(Tables)

Out=table;
T1=Tables{1,1};
for m=2:size(Tables,1)
    T1Rows=T1.Properties.RowNames;
    T1Cols=T1.Properties.VariableNames.';
    
    T2=Tables{m,1};
    T2Rows=T2.Properties.RowNames;
    T2Cols=T2.Properties.VariableNames.';
    
    if isequal(T1Cols,T2Cols)==0 || isequal(T1Rows,T2Rows)==0
        % those Colums and Rows that are not present in T1 but in T2 just fuse into
        ColsNotInT1=T2Cols(ismember(T2Cols,T1Cols)==0);
        RowsNotInT1=T2Rows(ismember(T2Rows,T1Rows)==0);
        T2addCols=T2(:,ColsNotInT1);
        T2addCols(RowsNotInT1,:)=[];
        T2addRows=T2(RowsNotInT1,:);
        
        T1(T2addCols.Properties.RowNames,T2addCols.Properties.VariableNames)=T2addCols(T2addCols.Properties.RowNames,T2addCols.Properties.VariableNames);
%         if size(T2addRows,1)>0
%             keyboard; % check if Rows corectly integrated
%         end
        T1(T2addRows.Properties.RowNames,T2addRows.Properties.VariableNames)=T2addRows(T2addRows.Properties.RowNames,T2addRows.Properties.VariableNames);
        
        % select intersecting data
        ColsInter=T1Cols(ismember(T1Cols,T2Cols));
        RowsInter=T1Rows(ismember(T1Rows,T2Rows));
    else
        ColsInter=T1Cols;
        RowsInter=T1Rows;
    end
    
    Data1=T1{RowsInter,ColsInter};
    Data2=T2{RowsInter,ColsInter};
    Data1=Data1+Data2;
    
    T1{RowsInter,ColsInter}=Data1(:,:);
    
    % sort according to RowNames
%     T1=sortrows(T1,'RowNames');
    RowNames=T1.Properties.RowNames;
    for m2=1:size(RowNames,1)
        Wave1(m2,1)=str2num(RowNames{m2,1});
    end
    [~,Wave1]=sort(Wave1);
    T1=T1(Wave1,:);
%     T1=sortrows(T1,'RowNames');
    
    
end
Out=T1;


    
    
    
%     if isequal(T1Cols,T2Cols)==0
%         Cols=unique([T1Cols;T2Cols]);
%         Wave1=find(ismember(Cols,T1Cols)==0);
%         for m2=Wave1.'
%             T1(:,Cols{m2})=nan;
%         end
%         
%     end
%     
%     if isequal(T1Rows,T2Rows)==0
%         Rows=unique([T1Rows;T2Rows]);
%         A1=ismember(T2Rows,Rows);
%     end