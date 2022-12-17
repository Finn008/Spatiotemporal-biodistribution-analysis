function [BinTable]=generateBinTable(RadiiBinning,TimeBinning,RadiusMinMax,TimeMinMax,MouseInfo)
% RadiiBinning
% RadiusMinMax=[0;ceil(max(PlaqueListSingle.RadiusFit1))];
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

% BinTable

BinTable=table;
BinTable.Mouse=(1:size(MouseInfo,1)).';
BinTable.MouseId=MouseInfo.MouseId;

if isempty(TimeBins)==0
    Wave1=table2cell(BinTable); Wave1=Wave1(:).';
    Wave1=repmat(Wave1,[size(TimeBins,1),1]);
    Wave1=reshape(Wave1(:),[size(BinTable,1)*size(TimeBins,1),size(BinTable,2)]);
    Wave2=table2cell(TimeBins);
    Wave2=repmat(Wave2,[size(BinTable,1),1]);
    BinTable(1:size(Wave1,1),1:size(Wave1,2))=Wave1;
    TimeBins(1:size(Wave2,1),1:size(Wave2,2))=Wave2;
    BinTable=[BinTable,TimeBins];
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


