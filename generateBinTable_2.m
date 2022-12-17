function [BinTable,TimeBins,RadBins,DistBins]=generateBinTable_2(TimeBinning,RadiiBinning,DistBinning,TimeMinMax,RadiusMinMax,DistMinMax,MouseInfo)
% RadiiBinning
RadBins=zeros(0,3);
for RadBin=1:size(RadiiBinning,1)
    Max=ceil(RadiusMinMax(2)/RadiiBinning(RadBin))*RadiiBinning(RadBin);
    Min=floor(RadiusMinMax(1)/RadiiBinning(RadBin))*RadiiBinning(RadBin);
    Wave1=(Min:RadiiBinning(RadBin):Max).';
    RadBins=[RadBins;[Wave1(1:end-1),Wave1(2:end),repmat(RadiiBinning(RadBin),[size(Wave1,1)-1,1])]];
end
RadBins=array2table(RadBins,'VariableNames',{'RadMin','RadMax','RadBin'});

% TimeBinning
TimeBins=zeros(0,3);
for TimeBin=1:size(TimeBinning,1)
    BinId=TimeBinning(TimeBin);
    Wave1=floor(TimeMinMax(1)/BinId);
    Wave2=ceil(TimeMinMax(2)/BinId);
    Data2add=(Wave1*BinId:BinId:Wave2*BinId).';
    Data2add=[Data2add(1:end-1),Data2add(2:end)];
    Data2add(:,3)=TimeBinning(TimeBin);
    TimeBins=[TimeBins;Data2add];
end
TimeBins=array2table(TimeBins,'VariableNames',{'TimeMin','TimeMax','TimeBin'});

% DistanceBinning
DistBins=zeros(0,3);
for DistBin=1:size(DistBinning,1)
    BinId=DistBinning(DistBin);
    Wave1=floor(DistMinMax(1)/BinId);
    Wave2=ceil(DistMinMax(2)/BinId);
    Data2add=(Wave1*BinId:BinId:Wave2*BinId).';
    Data2add=[Data2add(1:end-1),Data2add(2:end)];
    Data2add(:,3)=DistBinning(DistBin);
    DistBins=[DistBins;Data2add];
end
DistBins=array2table(DistBins,'VariableNames',{'DistMin','DistMax','DistBin'});

% BinTable
BinTable=table;
if exist('MouseInfo')==1 && isempty(MouseInfo)==0
    BinTable.Mouse=(1:size(MouseInfo,1)).';
    BinTable.MouseId=MouseInfo.MouseId;
end

if isempty(TimeBins)==0
    if isempty(BinTable)
        BinTable=TimeBins;
    else
        
        Wave1=table2cell(BinTable); Wave1=Wave1(:).';
        Wave1=repmat(Wave1,[size(TimeBins,1),1]);
        Wave1=reshape(Wave1(:),[size(BinTable,1)*size(TimeBins,1),size(BinTable,2)]);
        Wave2=table2cell(TimeBins);
        Wave2=repmat(Wave2,[size(BinTable,1),1]);
        BinTable(1:size(Wave1,1),1:size(Wave1,2))=Wave1;
        TimeBins(1:size(Wave2,1),1:size(Wave2,2))=Wave2;
        BinTable=[BinTable,TimeBins];
    end
end

if isempty(RadBins)==0
    Wave1=table2cell(BinTable); Wave1=Wave1(:).';
    Wave1=repmat(Wave1,[size(RadBins,1),1]);
    Wave1=reshape(Wave1(:),[size(BinTable,1)*size(RadBins,1),size(BinTable,2)]);
    Wave2=table2cell(RadBins);
    Wave2=repmat(Wave2,[size(BinTable,1),1]);
    BinTable(1:size(Wave1,1),1:size(Wave1,2))=Wave1;
    RadBins(1:size(Wave2,1),1:size(Wave2,2))=Wave2;
    BinTable=[BinTable,RadBins];
end

if isempty(DistBins)==0
    Wave1=table2cell(BinTable); Wave1=Wave1(:).';
    Wave1=repmat(Wave1,[size(DistBins,1),1]);
    Wave1=reshape(Wave1(:),[size(BinTable,1)*size(DistBins,1),size(BinTable,2)]);
    Wave2=table2cell(DistBins);
    Wave2=repmat(Wave2,[size(BinTable,1),1]);
    BinTable(1:size(Wave1,1),1:size(Wave1,2))=Wave1;
    DistBins(1:size(Wave2,1),1:size(Wave2,2))=Wave2;
    BinTable=[BinTable,DistBins];
end

BinTable.Id=(1:size(BinTable,1)).';

% % % for Mouse=1:size(MouseInfo,1)
% % %     MouseId=MouseInfo.Mouse(Mouse);
% % %     for TimeBin=1:size(TimeBins,1)
% % %         for RadBin=1:size(RadBins,1)
% % %             Ind=size(BinTable,1)+1;
% % %             Bin2add=[TimeBins(TimeBin,:),RadBins(RadBin,:)];
% % %             BinTable.MouseId(Ind,1)=MouseId;
% % %             BinTable.Mouse(Ind,1)=Mouse;
% % %             BinTable(Ind,Bin2add.Properties.VariableNames)=Bin2add(1,Bin2add.Properties.VariableNames);
% % %         end
% % %     end
% % % end


