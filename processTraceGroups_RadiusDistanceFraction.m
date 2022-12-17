function processTraceGroups_RadiusDistanceFraction(Title,Table,MouseInfo,Groups,RadiiBinning,RadiusMinMax,DistanceBinning,DistanceMinMax,TimeMinMax,Zaxis,Path2file)
keyboard; % remove

global W;
Table(strfind1(Table.Specification,'MouseId',1),:)=[];
RadiusBins=(RadiusMinMax(1):RadiiBinning:RadiusMinMax(2)-RadiiBinning).'; RadiusBins(:,2)=RadiusBins(:,1)+RadiiBinning;
RadiusBins(:,3)=RadiiBinning;RadiusBins(:,4)=mean(RadiusBins(:,1:2),2);
RadiusBins=array2table(RadiusBins,'VariableNames',{'RadMin','RadMax','RadiiBinning','RadMean'});
DistBins=(DistanceMinMax(1):DistanceBinning:DistanceMinMax(2)-DistanceBinning).'; DistBins(:,2)=DistBins(:,1)+DistanceBinning;
DistBins(:,3)=DistanceBinning;DistBins(:,4)=mean(DistBins(:,1:2),2);
DistBins=array2table(DistBins,'VariableNames',{'DistMin','DistMax','DistBinning','DistMean'});


for RadiusBin=1:size(RadiusBins,1)
    Selection=Table(Table.TimeMin==TimeMinMax(1)...
        & Table.TimeMax==TimeMinMax(2)...
        & Table.RadMin==RadiusBins.RadMin(RadiusBin)...
        & Table.RadMax==RadiusBins.RadMax(RadiusBin)...
        & Table.Distance>DistanceMinMax(1)...
        & Table.Distance<=DistanceMinMax(2),:);
    if size(Selection,1)
        Data2add=permute(Selection.Data(:,:),[1,3,2]);
    else
        Data2add=NaN;
    end
    
    Fraction(RadiusBin,(1:1:size(DistBins,1)).',1:size(MouseInfo,1))=Data2add;
    
end

% clear Selection;
for Group=1:size(Groups,1)
    MouseIds=Groups.MouseIds{Group,1};
    Mice=find(ismember(MouseInfo.MouseId,MouseIds)==1);
    Groups.Xarray(Group,1)={RadiusBins.RadMean};
    Groups.Yarray(Group,1)={DistBins.DistMean};
    Groups.Zarray(Group,1)={nanmean(Fraction(:,:,Mice),3).'};
    Groups.SeparateX(Group,1)=1;
    Groups.MarkerFaceColor(Group,1)=Groups.Color(Group,1);
    Groups.FaceColor(Group,1)=Groups.Color(Group,1);
    Groups.EdgeColor(Group,1)=Groups.Color(Group,1);
end

% Groups.Marker={'.';'.'};
Groups.Marker={'none';'none'};
% Groups.LineStyle={'none';'none'};
Groups.LineStyle={'-';'-'};

General=struct;
General.Title=Title;
General.XTick=(RadiusMinMax(1):RadiiBinning:RadiusMinMax(2)).';
General.YTick=(DistanceMinMax(1):10:DistanceMinMax(2)).';
General.ZTick=Zaxis;
General.Rotation=[147,22];
General.Xlabel='Plaque radius [µm]';
General.Ylabel='Distance to plaque [µm]';
General.Zlabel='Fraction [%]';


plotSurf(Groups,General,Path2file);


