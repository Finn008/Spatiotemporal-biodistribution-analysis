function [Table,BinTable,Template]=accumArrayBinning(Data,BinInfo,DataVar2Bin,HorizontalVar,Function,CountInstances)

Data=Data(:,[BinInfo.Name;{DataVar2Bin}]);
if exist('Function')~=1 || isempty(Function)
    Function=@nanmean;
end
if exist('CountInstances')~=1
    CountInstances=[];
end
BinInfo.BinningNumber(:,1)=1;
for Row=1:size(BinInfo,1)
    BinTable=zeros(0,3);
    Var=BinInfo.Name{Row};
    Binning=BinInfo.Binning{Row};
    BinInfo.RealMinMax(Row,1)={[min(Data{:,Var});max(Data{:,Var})]};
    if Binning==0 % donot bin at all
        Wave1=unique(Data{:,Var});
        Wave1=[Wave1;max(Wave1)+1];
        BinInfo.Edges(Row,1)={Wave1};
    end
    
    if Binning==-1 % bin everything
        BinInfo.Edges(Row,1)={BinInfo.RealMinMax{Row,1}+[-0.1;0.1]};
    end
    if Binning==-2 % use defined ranges
        Wave1=BinInfo.Edges{Row,1};
        for m=1:size(Wave1,2)
            BinInfo.Edges(Row,m)={Wave1(:,m)};
        end
        BinInfo.BinningNumber(Row,1)=size(Wave1,2);
        BinInfo.Binning(Row,1)={Wave1(2,:).'-Wave1(1,:).'};
    end
    
    if Binning>0 % binning
        MinMax=BinInfo.MinMax{Row};
        RealMinMax=BinInfo.RealMinMax{Row};
        MinMax=[max([MinMax(1);RealMinMax(1)]);min([MinMax(2);RealMinMax(2)])];
        for Bin=1:size(Binning,1)
            Max=ceil(MinMax(2)/Binning(Bin))*Binning(Bin);
            Min=floor(MinMax(1)/Binning(Bin))*Binning(Bin);
            if Min==Max
                Edges=[Min-0.001;Max+0.001];
            else
                Edges=(Min:Binning(Bin):Max).';
            end
            BinTable=[BinTable;[Edges(1:end-1),Edges(2:end),repmat(Binning(Bin),[size(Edges,1)-1,1])]];
            BinInfo.Edges(Row,Bin)={Edges};
        end
        BinInfo.BinningNumber(Row,1)=size(Binning,1);
    end
    BinTable=array2table(BinTable,'VariableNames',{[BinInfo.Name{Row},'Min'],[BinInfo.Name{Row},'Max'],[BinInfo.Name{Row},'Bin']});
    BinInfo.BinTable(Row,1)={BinTable};
end

Table=table;
BinInfo.Combi=generateAllCombinations(BinInfo.BinningNumber);
OrigData=Data;
for Loop=1:size(BinInfo.Combi,2)
    Data=OrigData;
    for Row=1:size(BinInfo,1)
        Var=BinInfo.Name{Row};
        if Binning==-1 % bin everything, donot integrate into OutputTable
            keyboard;
            Data(:,Var)=[];
        end
        Edges=BinInfo.Edges{Row,BinInfo.Combi(Row,Loop)};
%         [Data{:,Var}]=discretize_2(Data{:,Var},Edges);
        [~,~,Wave1]=histcounts(Data{:,Var},Edges);
        Data{:,Var}=Wave1;
    end
    % remove all nan rows
    Wave1=find(min(Data{:,BinInfo.Name},[],2)==0);
    Data(Wave1,:)=[];
%     Wave1=Data(:,BinInfo.Name);
%     Wave1.MouseId=repmat(Wave1.MouseId,[1,size(Data{:,DataVar2Bin},2)]);
%     Wave1.PlaqueRadius=repmat(Wave1.PlaqueRadius,[1,size(Data{:,DataVar2Bin},2)]);
%     AccumArray=accumarray_9(Wave1,Data(:,DataVar2Bin),Function,[],'NonSparse',CountInstances);
    AccumArray=accumarray_9(Data(:,BinInfo.Name),Data(:,DataVar2Bin),Function,[],'NonSparse',CountInstances);
    
    if exist('HorizontalVar')==1 && isempty(HorizontalVar)==0
        AccumArray=distributeColumnHorizontally_3(AccumArray,[],HorizontalVar,DataVar2Bin);
        AccumArray.Properties.VariableNames{end}=DataVar2Bin;
    end
    % generate OutputTable
    for Row=1:size(BinInfo,1)
        Var=BinInfo.Name{Row};
        if exist('HorizontalVar')==1 && strcmp(Var,HorizontalVar)
            continue;
        end
        Binning=BinInfo.Binning{Row};
        Binning=Binning(BinInfo.Combi(Row,Loop));
        Edges=BinInfo.Edges{Row,BinInfo.Combi(Row,Loop)};
        if Binning==0 % just leave it as it is
            Wave1=AccumArray{:,Var};
            AccumArray(:,Var)=table(Edges(Wave1(:)));
        end
        if Binning==-1 % bin everything, donot integrate into OutputTable
        end
        
        if Binning>0 || Binning==-2 % binning
            Wave1=AccumArray{:,Var};
            AccumArray(:,[Var,'_Min'])=table(Edges(Wave1(:)));
            EdgesSel=Edges(2:end);
            AccumArray(:,[Var,'_Max'])=table(EdgesSel(Wave1(:)));
            AccumArray(:,[Var,'_Bin'])=table(Binning);
            AccumArray(:,Var)=[];
        end
    end
    Wave1=AccumArray(:,DataVar2Bin);
    AccumArray(:,DataVar2Bin)=[];
    AccumArray(:,DataVar2Bin)=Wave1;
    Table=[Table;AccumArray];
end

ProvideBinTable=0;
if ProvideBinTable==1
    BinTable=BinInfo.BinTable{1,1};
    for Row=2:size(BinInfo,1)
        BinTable2add=BinInfo.BinTable{Row,1};
        Wave1=table2cell(BinTable); Wave1=Wave1(:).';
        Wave1=repmat(Wave1,[size(BinTable2add,1),1]);
        Wave1=reshape(Wave1(:),[size(BinTable,1)*size(BinTable2add,1),size(BinTable,2)]);
        Wave2=table2cell(BinTable2add);
        Wave2=repmat(Wave2,[size(BinTable,1),1]);
        BinTable(1:size(Wave1,1),1:size(Wave1,2))=Wave1;
        BinTable2add(1:size(Wave2,1),1:size(Wave2,2))=Wave2;
        BinTable=[BinTable,BinTable2add];
    end
    
    
    Template=table;
    VariableNames=[{'Specification'};BinTable.Properties.VariableNames.';{'Data'}];
    Wave1=[{'MouseId'},repmat({NaN},[1,size(VariableNames,1)-2]),MouseInfo.MouseId.'];
    Template('MouseId',VariableNames)=Wave1;
else
    BinTable=[];
    Template=[];
end

