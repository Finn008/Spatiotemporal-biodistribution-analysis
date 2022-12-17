function [PlaqueListSingle]=finalEvaluation_Dystrophies1Quantification_5(MouseInfo,PlaqueListSingle)

keyboard; % put everything to processTraceGroups_2
keyboard; % include that NB-360 mice were not treated from beginning on, include age

% determine radius of dystrophies
Volume=PlaqueListSingle.Volume1.*PlaqueListSingle.DystrophiesPl;
Volume=nansum(Volume,2);
PlaqueListSingle.DystrophyRadius=(Volume*3/4/3.1415).^(1/3);


% define RadiiBins
MaxRadius=ceil(max(PlaqueListSingle.Radius));
RadiiBinning=[MaxRadius;10;5;1];
RadiiBins=zeros(0,3);
for RadBin=1:size(RadiiBinning,1)
    Wave1=ceil(MaxRadius/RadiiBinning(RadBin))*RadiiBinning(RadBin);
    Wave1=(0:RadiiBinning(RadBin):Wave1).';
    RadiiBins=[RadiiBins;[Wave1(1:end-1),Wave1(2:end),repmat(RadiiBinning(RadBin),[size(Wave1,1)-1,1])]];
end

Table=table;
MouseIds=strcat('M',num2strArray_2(MouseInfo.MouseId));
% read out the means of PlaqueGrowth
for Mouse=1:size(MouseInfo,1)
    MouseId=MouseInfo.MouseId(Mouse);
    
    for RadBin=1:size(RadiiBins,1)
        RadBinId=RadiiBins(RadBin,:).';
        Selection=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId & PlaqueListSingle.RadiusFit1>RadBinId(1) & PlaqueListSingle.RadiusFit1<=RadBinId(2),:);
                
        % determine integrated radius of dystrophies over amyloid fibril radius
        DystrophyRadiusDelta=Selection.RadiusFit1-Selection.DystrophyRadius;
        DystrophyRadiusDelta=nanmedian(DystrophyRadiusDelta);
        
        RowId=['Rad',num2str(RadBin),'Delta'];
        Table(RowId,{'RadiiBinning','RadiiRange','Distance'})={RadBinId(3),RadBinId(1:2).',{'RadiusDelta'}};
        Table(RowId,MouseIds(Mouse))={DystrophyRadiusDelta};
        
        % determine EC50
        Data=Selection.DystrophiesPl;
        Data=nanmedian(Data,1).'*100;
        
        MinMax=find(isnan(Data)==0,1);
        if size(find(isnan(Data)==0),1)>0
            MinMax(2,1)=find(isnan(Data(MinMax(1):end)),1)+MinMax(1)-2;
            Fit=fit((1:256).',Data,'smoothingspline','Exclude',isnan(Data),'SmoothingParam',0.7);
%         figure; plot(Fit,(1:256).',Data);
%         Range=[40,80,0,110];
%         axis(Range);
            Xaxis=(MinMax(1):0.1:MinMax(2)).';
            Wave1=feval(Fit,Xaxis);
            EC50=Xaxis(find(Wave1<50,1))-50;
        else
            EC50=NaN;
        end
        RowId=['Rad',num2str(RadBin),'EC50'];
        Table(RowId,{'RadiiBinning','RadiiRange','Distance'})={RadBinId(3),RadBinId(1:2).',{'EC50'}};
        Table(RowId,MouseIds(Mouse))={EC50};
        
        % determine DistRel trace
        for Distance=30:70
            RowId=['Rad',num2str(RadBin),'Dist',num2str(Distance)];
            if Mouse==1
                Table(RowId,{'RadiiBinning','RadiiRange','Distance'})={RadBinId(3),RadBinId(1:2).',{Distance-50}};
            end
            Table(RowId,MouseIds(Mouse))={Data(Distance)};
            
        end
    end
end

[Table]=table2cell_2(Table);
Table=[[NaN,NaN,NaN,NaN,MouseInfo.TreatmentType.'];Table(1,:);Table(2:end,:)];

PathExcelExport='\\GNP90N\share\Finn\Raw data\Dystrophies.xlsx';
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
% keyboard;
xlsActxWrite(Table,Workbook,['Dystrophies'],[],1);
Workbook.Save;
Workbook.Close;

%% calculations on each plaque separately

tic;
for Row=1:size(PlaqueListSingle,1)
    try
        if strcmp(PlaqueListSingle.TreatmentType{Row},'TauKO'); continue; end;
        VolumeData=PlaqueListSingle.Volume1(Row,:).';
        VolumeMinMax=find(VolumeData>0,1);
        VolumeMinMax=[VolumeMinMax;find(VolumeData(VolumeMinMax:end)==0,1)+VolumeMinMax-2];
        if isempty(VolumeMinMax)||VolumeMinMax(1)>50
            PlaqueListSingle.DystrophyReach(Row,1)=-101;
            continue;
        end
        % only plaque dystrophies
        Data=PlaqueListSingle.DystrophiesPl(Row,:).';
        if nansum(Data(:))==0
            PlaqueListSingle.DystrophyReach(Row,1)=-100;
            continue;
        end
        DysMinMax=find(Data>0,1);
        Wave1=find(Data(DysMinMax:end)==0,1);
        if isempty(Wave1)
            PlaqueListSingle.DystrophyReach(Row,1)=-102;
            continue;
        end
        DysMinMax(2,1)=Wave1+DysMinMax-2;
        RangeMinMax=find(isnan(Data)==0,1);
        RangeMinMax(2,1)=find(isnan(Data(RangeMinMax:end)),1)+RangeMinMax-2;
        
        if RangeMinMax(2)==DysMinMax(2); keyboard; end;
        PlaqueListSingle.DystrophyReach(Row,1)=DysMinMax(2)-50;
        Wave1=find(Data(DysMinMax(1):DysMinMax(2))<0.5,1)+DysMinMax(1)-2;
        PlaqueListSingle.DystrophyReach50(Row,1)=Wave1-50;
    end
end








disp(['finalEvaluation_Dystrophies1Quantification_2: ',num2str(round(toc/60)),'min']);


return;
OrigPlaqueList=PlaqueList;

PlaqueList(PlaqueList.BorderTouch==1 |...
    isnan(PlaqueList.Radius) |...
    isnan(PlaqueList.DystrophyFraction),:)=[];
Wave1=find(isnan(PlaqueList.DistRel(:,2))==0);
if isempty(Wave1)==0
    PlaqueList(Wave1,:)=[];
end
processTraceGroups(PlaqueList,'Dystrophies1');

PlaqueListDystrophy1=PlaqueList;

