function [PlaqueListSingle]=vglutClusterAnalysis_4(PlaqueListSingle,MouseInfo,DataArray,SingleStacks,Readout,Settings)
global W;
if exist('Settings','Var')~=1
    Settings=struct('PlaqueRadiusBin',5,'Plot_ClusterSizeEdges',[(0:1:60).';999],'Plot_DistanceMinMax',[-20;51],'Plot_PercentMax',10);
end
ThresholdDystrophic=30;
% % % Groups{end+1:end+size(MouseInfo,1),{'MouseIds';'Description'}}=[num2cell(MouseInfo.MouseId),MouseInfo.TreatmentType];
DataArray.Properties.VariableNames{Readout}='ClusterSize';

% make a framework such that each single volume bin has all existing cluster bins set to zero
ClusterBins=unique(DataArray.ClusterSize);
Framework=accumarray_9(DataArray(:,{'MouseId';'Filename';'Membership';'Distance'}),DataArray(:,{'VolumeUm3'}),@nansum,[]);
Wave2=repmat(ClusterBins.',[size(Framework,1),1]);

Framework=[repmat(Framework,[size(ClusterBins,1),1])];
Framework.ClusterSize(:,1)=Wave2(:);

% fuse cluster bin fraction from DataArray into Framework
DataArray.Properties.VariableNames{'VolumeUm3'}='ClusterVolume';

Framework=fuseTable_MatchingColums_4(Framework,DataArray,{'MouseId';'Filename';'Membership';'Distance';'ClusterSize'},{'ClusterVolume'});
Framework.ClusterVolume(isnan(Framework.ClusterVolume))=0;

Framework.Fraction=Framework.ClusterVolume./Framework.VolumeUm3*100;
PlaqueListSingle2=PlaqueListSingle;
PlaqueListSingle2.PlaqueRadius(PlaqueListSingle2.BorderTouch==1)=NaN;
PlaqueListSingle2.Properties.VariableNames('PlId')={'Membership'};
Framework=fuseTable_MatchingColums_4(Framework,PlaqueListSingle2,{'MouseId';'Filename';'Membership'},{'PlaqueRadius'});

% get age from SingleStacks
Framework=fuseTable_MatchingColums_4(Framework,SingleStacks,{'MouseId';'Filename'},{W.XaxisType});

%% exclude
RemoveCertainBins=0;
if RemoveCertainBins==1
    % remove distance rings with less than 10µm3 in volume
    Framework(Framework.VolumeUm3<=10,:)=[];
    % remove distance rings in which the fraction of detected structures (no matter which size) is larger than 30%
    Selection=Framework(Framework.ClusterSize==0&Framework.Fraction<70,:);
    Selection.Remove(:,1)=1;
    Framework=fuseTable_MatchingColums_4(Framework,Selection,{'MouseId';W.XaxisType;'Filename';'Membership';'Distance'},{'Remove'});
    Framework(Framework.Remove==1,:)=[];
    
    % Framework(strcmp(Framework.Filename,'ExHazal_TrTauKO_IhcBace1_Ihd170403_M429_HemLeft_Roi7.lsm')&Framework.Membership==4,:)=[];
end

%% for each plaque calculate the volume of dystrophic tissue within 5µm

Selection=Framework;
Selection=Selection(Selection.Distance<=5 & Selection.ClusterSize>=ThresholdDystrophic(1) & Selection.Fraction>0,:);
Wave1=accumarray_9(Selection(:,{'Filename';'Membership'}),Selection(:,{'ClusterVolume'}),@nansum,[]);
Wave1.Properties.VariableNames{'Membership'}='PlId';
PlaqueListSingle=fuseTable_MatchingColums_4(PlaqueListSingle,Wave1,{'Filename';'PlId'},{'ClusterVolume'},{'DystrophicVolume'});

%% calculate dystrophic fraction for different plaque sizes
Framework(isnan(Framework.PlaqueRadius),:)=[];
Table2=table;

for iCl=ThresholdDystrophic
    DistanceRanges= [-1,0;-1,-1]; % [-10,-10;-9,-9;-8,-8;-7,-7;-6,-6;-5,-5;-4,-4;-3,-3;-2,-2;-1,-1;0,0;1,1];
    for iDist=1:size(DistanceRanges,1)
        Selection=Framework(Framework.Distance>=DistanceRanges(iDist,1) & Framework.Distance<=DistanceRanges(iDist,2) & Framework.ClusterSize>=iCl,:);
        Wave1=unique(Selection(:,{'MouseId';W.XaxisType;'Filename';'Membership';'Distance';'VolumeUm3'}));
        Wave1=accumarray_9(Wave1(:,{'MouseId';W.XaxisType;'Filename';'Membership'}),Wave1(:,{'VolumeUm3'}),@nansum,[]);
        Selection=accumarray_9(Selection(:,{'MouseId';W.XaxisType;'Filename';'Membership';'PlaqueRadius'}),Selection(:,{'ClusterVolume'}),@nansum,[]);
        Selection=fuseTable_MatchingColums_4(Selection,Wave1,{'MouseId';W.XaxisType;'Filename';'Membership'},{'VolumeUm3'});
        Selection.Fraction=Selection.ClusterVolume./Selection.VolumeUm3*100;
        BinInfo={'MouseId',0,0,0;
            %     'Age',[30.42],30.42*[3;6],0;    % 70;244   'Time2Treatment',-2,0,[0;70];
            'PlaqueRadius',Settings.PlaqueRadiusBin,[0;999],0
            };
        BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
        
        [Table]=accumArrayBinning(Selection,BinInfo,'Fraction',[],@nanmean);
        Table.ClusterSize_Min(:,1)=iCl;
        Table.DistanceRange_Min(:,1)=DistanceRanges(iDist,1);
        Table.DistanceRange_Max(:,1)=DistanceRanges(iDist,2);
        Table.Specification(:,1)={'DystrophicFraction'};
        % count plaques
        Selection.Fraction(:,1)=1;
        [Wave1]=accumArrayBinning(Selection,BinInfo,'Fraction',[],@nansum);
        Wave1.Specification(:,1)={'DystrophicFraction_Count'};
        Table(end+1:end+size(Wave1,1),Wave1.Properties.VariableNames)=Wave1;
        Table2=[Table2;Table];
    end
end
Table2=distributeColumnHorizontally_4(Table2,[],'MouseId','Fraction',MouseInfo.MouseId);

[TableExport]=table2cell_2(Table2);
TableExport=[repmat(TableExport(1,:),[2,1]);TableExport];
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;
TableExport(2,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
TableExport(3,end-size(MouseInfo,1)+1:end)=num2cell(round(MouseInfo.Age*10)/10);

OutputFilename=[W.G.T.TaskName{W.Task},'_',Readout,'.xlsx'];
[PathExcelExport,Report]=getPathRaw(OutputFilename);
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);

xlsActxWrite(TableExport,Workbook,'DystrophicFractionPerPlaque',[],'Delete');

%% cumulative distribution close to 10-20µm plaques
Selection=Framework;
Selection=Selection(Selection.Distance>=-1 & Selection.Distance<=0 & Selection.PlaqueRadius>=10 & Selection.PlaqueRadius<=22,:);
Wave1=unique(Selection(:,{'MouseId';W.XaxisType;'Filename';'Membership';'Distance';'VolumeUm3'}));
Wave1=accumarray_9(Wave1(:,{'MouseId';W.XaxisType;'Filename';'Membership'}),Wave1(:,{'VolumeUm3'}),@nansum,[]);
Selection=accumarray_9(Selection(:,{'MouseId';W.XaxisType;'Filename';'Membership';'ClusterSize'}),Selection(:,{'ClusterVolume'}),@nansum,[]);
Selection=fuseTable_MatchingColums_4(Selection,Wave1,{'MouseId';W.XaxisType;'Filename';'Membership'},{'VolumeUm3'});
Selection.Fraction=Selection.ClusterVolume./Selection.VolumeUm3*100;
BinInfo={'MouseId',0,0,0;
    'ClusterSize',[1],[0;100],0
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
[Table]=accumArrayBinning(Selection,BinInfo,'Fraction',[],@nanmean);
Table=distributeColumnHorizontally_4(Table,[],'MouseId','Fraction',MouseInfo.MouseId);

[TableExport]=table2cell_2(Table);
TableExport=[repmat(TableExport(1,:),[2,1]);TableExport];
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;
TableExport(2,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
TableExport(3,end-size(MouseInfo,1)+1:end)=num2cell(round(MouseInfo.Age*10)/10);

xlsActxWrite(TableExport,Workbook,'DystrophicFractionCumSumPlaqueBorder',[],'Delete');

%% cumulative distribution distant to plaques
Selection=Framework;
Selection=Selection(Selection.Distance>=20 & Selection.Distance<=999,:);
Wave1=unique(Selection(:,{'MouseId';W.XaxisType;'Filename';'Membership';'Distance';'VolumeUm3'}));
Wave1=accumarray_9(Wave1(:,{'MouseId';W.XaxisType;'Filename';'Membership'}),Wave1(:,{'VolumeUm3'}),@nansum,[]);
Selection=accumarray_9(Selection(:,{'MouseId';W.XaxisType;'Filename';'Membership';'ClusterSize'}),Selection(:,{'ClusterVolume'}),@nansum,[]);
Selection=fuseTable_MatchingColums_4(Selection,Wave1,{'MouseId';W.XaxisType;'Filename';'Membership'},{'VolumeUm3'});
Selection.Fraction=Selection.ClusterVolume./Selection.VolumeUm3*100;
BinInfo={'MouseId',0,0,0;
    'ClusterSize',[1],[0;100],0
    };
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'}); BinInfo.Properties.RowNames=BinInfo.Name;
[Table]=accumArrayBinning(Selection,BinInfo,'Fraction',[],@nanmean);
Table=distributeColumnHorizontally_4(Table,[],'MouseId','Fraction',MouseInfo.MouseId);

[TableExport]=table2cell_2(Table);
TableExport=[repmat(TableExport(1,:),[2,1]);TableExport];
TableExport(1,end-size(MouseInfo,1)+1:end)=MouseInfo.TreatmentType;
TableExport(2,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
TableExport(3,end-size(MouseInfo,1)+1:end)=num2cell(round(MouseInfo.Age*10)/10);

xlsActxWrite(TableExport,Workbook,'DystrophicFractionCumSumDistant',[],'Delete');
Workbook.Save;
Workbook.Close;

%% plot profiles from mean of the means of each mouse
PlotProfiles=1;
if PlotProfiles==1
    % % % Selection=Framework(Framework.VolumeUm3>10,:);
    % mice groups
%     DataArray.Properties.VariableNames(Readout)={'ClusterSize'};
    Groups={MouseInfo.MouseId,'All_';...
        %     [381;384;393;396;429],'TauKOOld_';...
        %     [381;384;393;396;429],'TauKOOld_';...
        %     [579;581;582;5792;725],'VehicleYoung_';...
        %     [318;331;346;641;280;349],'NB360_';...
        %     [13;16],'TauKD_';...
        %     [397;402;464;451],'TauKOYoung_';...
        };
    Groups=array2table(Groups,'VariableNames',{'MouseIds';'Description'});
    Groups{end+1:end+size(MouseInfo,1),{'MouseIds','Description'}}=[num2cell(MouseInfo.MouseId),num2strArray_3(MouseInfo.MouseId)];
%     keyboard;
    vglutClusterAnalysis_PlotCumulativeDistributions_2(Framework,Settings,Readout,Groups);
end