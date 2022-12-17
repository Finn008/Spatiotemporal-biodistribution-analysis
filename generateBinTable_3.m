function [BinTable,Template,BinInfo]=generateBinTable_3(BinInfo,MouseInfo)

for Row=1:size(BinInfo,1)
    clear BinTable;
    Binning=BinInfo.Binning{Row};
    if Binning==0
        BinTable=BinInfo.MinMax{Row};
        BinTable(:,3)=1;
    else
        MinMax=BinInfo.MinMax{Row};
        
        BinTable=zeros(0,3);
        for Bin=1:size(Binning,1)
            Max=ceil(MinMax(2)/Binning(Bin))*Binning(Bin);
            Min=floor(MinMax(1)/Binning(Bin))*Binning(Bin);
            Wave1=(Min:Binning(Bin):Max).';
            BinTable=[BinTable;[Wave1(1:end-1),Wave1(2:end),repmat(Binning(Bin),[size(Wave1,1)-1,1])]];
        end
    end
    
    BinTable=array2table(BinTable,'VariableNames',{[BinInfo.Name{Row},'Min'],[BinInfo.Name{Row},'Max'],[BinInfo.Name{Row},'Bin']});
    BinInfo.BinTable(Row,1)={BinTable};
    
end

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

