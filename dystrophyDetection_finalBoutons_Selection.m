function [TableExport]=dystrophyDetection_finalBoutons_Selection(BoutonList,MouseInfo,SingleStacks,ChannelNames,BoutonVersion,DiameterRange,DistancetoImageBorderXYZ,Outside,PositionZ)

if strfind1(BoutonList.Properties.VariableNames.','MinRadius',1)
    BoutonList.DiameterX=BoutonList.MinRadius*2;
    try; BoutonList(:,'MinRadius')=[]; end;
    BoutonList.PositionZ=BoutonList.Position(:,3);
    try; BoutonList(:,'Position')=[]; end;
else
    BoutonList.Outside=BoutonList.IntensityCenter(:,2);
end
    

Table=table;
Table.Specification(1)={'MouseId'};Table.Data=MouseInfo.MouseId.';

BoutonList=BoutonList(BoutonList.Version==BoutonVersion,:);
if isempty(DiameterRange)==0
    BoutonList=BoutonList(BoutonList.DiameterX>=DiameterRange(1)&BoutonList.DiameterX<=DiameterRange(2),:);
end
if isempty(DistancetoImageBorderXYZ)==0
    BoutonList=BoutonList(BoutonList.DistancetoImageBorderXYZ>=DistancetoImageBorderXYZ,:);
end
if exist('PositionZ')
    BoutonList=BoutonList(BoutonList.PositionZ>=PositionZ(1)&BoutonList.PositionZ<=PositionZ(2),:);
end
if strcmp(Outside,'Include')
    
elseif strcmp(Outside,'Exclude')
    BoutonList=BoutonList(BoutonList.Outside==0,:);
else
    keyboard;
end



Settings={'Volume';'DiameterX';'IntensityMean';'IntensityMedian'}; % Area
% % % CumSumEdges=table;
% % % CumSumEdges.Area={(0:0.1:15).'};
% % % CumSumEdges.Volume={(0:0.05:1).'};
% % % CumSumEdges.DiameterX={(0:0.01:1.5).'};
% % % CumSumEdges.IntensityMean_Vglut1={(0:500:60000).'};
% % % CumSumEdges.IntensityMean_Outside={(3000:200:50000).'};
% % % CumSumEdges.IntensityMean_Vglut1Corr={(0:500:50000).'};
% % % CumSumEdges.IntensityMean_Vglut1Corr2={(0:10:1600).'};
% % % CumSumEdges.IntensityMedian_Vglut1={(0:500:60000).'};
% % % CumSumEdges.IntensityMedian_Outside={(3000:200:50000).'};
% % % CumSumEdges.IntensityMedian_Vglut1Corr={(0:500:50000).'};
% % % CumSumEdges.IntensityMedian_Vglut1Corr2={(0:10:1600).'};

HistogramEdges=table;
HistogramEdges.Area={(0:0.1:5).'};
HistogramEdges.Volume={(0:0.02:1).'};
HistogramEdges.DiameterX={(0:0.01:1.5).'};
HistogramEdges.IntensityMean={(0:5:800).'};
HistogramEdges.IntensityMean_Vglut1={(0:1000:60000).'};
HistogramEdges.IntensityMean_Outside={(3000:200:50000).'};
HistogramEdges.IntensityMean_Vglut1Corr={(0:500:50000).'};
HistogramEdges.IntensityMean_Vglut1Corr2={(0:5:800).'};
HistogramEdges.IntensityMedian={(0:20:1600).'};
HistogramEdges.IntensityMedian_Vglut1={(0:1000:60000).'};
HistogramEdges.IntensityMedian_Outside={(3000:200:50000).'};
HistogramEdges.IntensityMedian_Vglut1Corr={(0:500:50000).'};
HistogramEdges.IntensityMedian_Vglut1Corr2={(0:20:1600).'};
CumSumEdges=HistogramEdges;
% MouseIds=unique(MicrogliaList.MouseId);
for Mouse=1:size(MouseInfo,1)
    MouseId=MouseInfo.MouseId(Mouse);
    Selection=BoutonList(BoutonList.MouseId==MouseId,:);
    if size(Selection,1)==0; continue; end;
    
    for Setting=Settings.'
        DataSub=Selection{:,Setting};
        OrigDataSub=DataSub;
        OrigSetting=Setting;
%         ColumnNumber=size(DataSub,2);
        for n=1:size(OrigDataSub,2)
%             DataSub=Selection{:,Setting};
            if size(OrigDataSub,2)>1
                DataSub=OrigDataSub(:,n);
                Setting={[OrigSetting{1},'_',ChannelNames{n}]};
            end
            Percentiles=prctile_2(DataSub,1:100);
            RowId=table; RowId.Percentile=(1:100).'; RowId.Specification(:,1)={[Setting{1},'Percentiles']};
            Table=addData2OutputTable(Table,Percentiles,RowId,Mouse);
            
            [CumSum,~,Ranges]=cumSumGenerator(DataSub,CumSumEdges{1,Setting}{1});
            RowId=table; RowId.Value=Ranges(:,2); RowId.Specification(:,1)={[Setting{1},'CumSum']};
            Table=addData2OutputTable(Table,CumSum,RowId,Mouse);
            
            [~,Histogram,Ranges]=cumSumGenerator(DataSub,HistogramEdges{1,Setting}{1});
            RowId=table; RowId.Value=Ranges(:,2); RowId.Specification(:,1)={[Setting{1},'Histogram']};
            Table=addData2OutputTable(Table,Histogram,RowId,Mouse);
            
            Mean=mean(DataSub);
            RowId=table; RowId.Specification={[Setting{1},'Mean']};
            Table=addData2OutputTable(Table,Mean,RowId,Mouse);
            
            Median=median(DataSub);
            RowId=table; RowId.Specification={[Setting{1},'Median']};
            Table=addData2OutputTable(Table,Median,RowId,Mouse);
            
            Min=min(DataSub);
            RowId=table; RowId.Specification={[Setting{1},'Min']};
            Table=addData2OutputTable(Table,Min,RowId,Mouse);
            
            Max=max(DataSub);
            RowId=table; RowId.Specification={[Setting{1},'Max']};
            Table=addData2OutputTable(Table,Max,RowId,Mouse);
        end
    end
    
    % Density
    InsideVolume=sum(SingleStacks.InsideVolume(SingleStacks.MouseId==MouseId));
    OutsideVolume=sum(SingleStacks.OutsideVolume(SingleStacks.MouseId==MouseId));
    TotalVolume=InsideVolume+OutsideVolume;
    if exist('PositionZ')
        Outside='Include';
        TotalVolume=TotalVolume*(PositionZ(2)-PositionZ(1))/10;
    end
    if strcmp(Outside,'Include')
        Density=size(Selection,1)/TotalVolume;
    elseif strcmp(Outside,'Exclude')
        Density=size(Selection,1)/InsideVolume;
    end
%     Density=size(Selection,1)/Volume;
    RowId=table; RowId.Specification={'Density'};
    Table=addData2OutputTable(Table,Density,RowId,Mouse);
    
%     VolumeSphereRadius=(3/4/3.1415*(Volume/size(Selection,1)))^(1/3);   
%     RowId=table; RowId.Specification={'VolumeSphereRadius'};
%     Table=addData2OutputTable(Table,VolumeSphereRadius,RowId,Mouse);
    disp(Mouse);
end



% OrigTable=Table;
% Table(:,{'MouseId','Id'})=[];
TableExport=Table(:,{'Specification','Percentile','Value','Data'});
for m=size(TableExport,2)-1:-1:1
    TableExport=sortrows(TableExport,m);
end
Ind=strfind1(TableExport.Specification,'MouseId',1);
TableExport=[TableExport(Ind,:);TableExport(1:Ind-1,:);TableExport(Ind+1:end,:)];
[TableExport]=table2cell_2(TableExport);
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType.';
% % % TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.Mouse.');



