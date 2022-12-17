function [MouseInfo,PlaqueListMetBlue]=finalEvaluation_MetBlueQuantification(TimeDistTable,MouseInfo)

PlaqueList=table;
Loop=struct('Ind',0,'Selection',[]);
while Loop.Ind>=0
    Loop=struct('Type','TimeDistTable','TimeDistTable',TimeDistTable,'MouseInfo',MouseInfo,'Ind',Loop.Ind,'Selection',Loop.Selection,'Restriction',{{'Mod','MetBlue';'Sub',2}});
    [Loop]=looper(Loop);
    if Loop.Ind<0; break; end
    
    Data=Loop.Data(:,Loop.NanCols);
    Distance=nan(size(Data,2),1);
    Radius=nan(size(Data,2),1);
    VolumeData=Loop.VolumeData(:,Loop.NanCols);
    Table=table;
    for Time=1:size(Data,2)
        
        F = fittype('A1*x+A2','independent','x');
        Xaxis=(1:256).'; Yaxis=Data(:,Time); Yaxis(1:60)=NaN;
        try
            [Fit,Gof]=fit(Xaxis,Yaxis,F,'Exclude',isnan(Yaxis)==1,'Weight',VolumeData(:,Time));
        catch
            Table.Distance(Time,1)=NaN;
            Table.Radius(Time,1)=NaN;
            continue;
        end
        FitCoef=coeffvalues(Fit);
        BaselineFit=Xaxis*FitCoef(1)+FitCoef(2);
        Table.Distance(Time,1)=min(find(Data(:,Time)<BaselineFit*1.5));
        Table.Radius(Time,1)=Table.Distance(Time,1)-sum(isnan(Data(1:Table.Distance(Time,1),Time)));
        Baseline(Time,1)=weightedMean(Data(60:80,Time),VolumeData(60:80,Time));
        Data(:,Time)=Data(:,Time)/Baseline(Time,1);
    end
    Distance=Distance-50;
%     Loop.PlaqueData{Loop.NanCols,{'RadiusMetBlue','MetBlue2Baseline'}}=[Radius,Distance];
    Loop.PlaqueData(Loop.NanCols,{'RadiusMetBlue','MetBlue2Baseline'})=Table(:,{'Radius','Distance'});
    Loop.PlaqueData.Radius(cellfun(@isempty,Loop.PlaqueData.XYZCenter))=NaN;
    MouseInfo.RoiInfo{Loop.Mouse,1}.TraceData{Loop.RoiData,1}.Data{Loop.Pl,1}=Loop.PlaqueData;
    
    [PlaqueList]=generatePlaqueList(PlaqueList,Loop.PlaqueData,Loop,MouseInfo,{'RadiusMetBlue';'MetBlue2Baseline'});
    
%     Wave1=Loop.PlaqueData(:,{'Radius','RadiusMetBlue','MetBlue2Baseline','BorderTouch'});
%     Wave1.TreatmentStart=Loop.Age-Loop.TimeSections(1,2);
%     Wave1.TreatmentStart(Wave1.TreatmentStart<0)=0;
%     Wave1.TreatmentType(:,1)=MouseInfo.TreatmentType(Loop.Mouse,1);
%     Wave1.DistRel=Loop.Data(:,1:size(Wave1,1)).';
%     PlaqueList=[PlaqueList;Wave1];
    
%     Loop.PlaqueData(Loop.NanCols,{'DystrophyReach','DystrophyReach50','DystrophyRadius'})=Table(:,{'DystrophyReach','DystrophyReach50','DystrophyRadius'});
%     Loop.PlaqueData.Radius(cellfun(@isempty,Loop.PlaqueData.XYZCenter))=NaN;
%     MouseInfo.RoiInfo{Loop.Mouse,1}.TraceData{Loop.RoiData,1}.Data{Loop.Pl,1}=Loop.PlaqueData;
%     [PlaqueList]=generatePlaqueList(PlaqueList,Loop.PlaqueData,Loop,MouseInfo,{'DystrophyRadius'});
end

keyboard;


PlaqueList(PlaqueList.BorderTouch==1 |...
    isnan(PlaqueList.Radius) |...
    isnan(PlaqueList.RadiusMetBlue),:)=[];

RadiusType='OriginalRadius';
if strcmp(RadiusType,'RadiusMetBlue')
    Wave1=nan(size(PlaqueList,1),256);
    for m=1:size(Wave1,1)
        try
            Wave2=find(isnan(PlaqueList.DistRel(m,:))==0); Wave2=[Wave2(1);Wave2(end)];
            Start=51-PlaqueList.RadiusMetBlue(m,1);
            End=Start+Wave2(2)-Wave2(1);
            Wave1(m,Start:End)=PlaqueList.DistRel(m,Wave2(1):Wave2(2));
        end
    end
    PlaqueList.DistRel=Wave1;
    PlaqueList.Radius=PlaqueList.RadiusMetBlue;
end

[Groups]=processTraceGroups(PlaqueList,'MetBlue');