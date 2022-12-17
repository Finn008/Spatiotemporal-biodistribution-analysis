function [MouseInfo,PlaqueListDystrophies1]=finalEvaluation_Dystrophies1Quantification_2(TimeDistTable,MouseInfo)
tic;
global W;
PlaqueList=table;

Loop=struct('Ind',0,'Selection',[]);
while Loop.Ind>=0
    Loop=struct('Type','TimeDistTable','TimeDistTable',TimeDistTable,'MouseInfo',MouseInfo,'Ind',Loop.Ind,'Selection',Loop.Selection,'Restriction',{{'Mod','Dystrophies1';'Sub',2}});
    [Loop]=looper(Loop);
    if Loop.Ind<0; break; end
    Data=Loop.Data(:,Loop.NanCols);
    Data(Data==0)=NaN;
    Loop.Data(:,Loop.NanCols)=Data;
    VolumeData=Loop.VolumeData(:,Loop.NanCols);
    Xaxis=(1:256).';
    Table=table; Table(size(Data,2),{'DystrophyReach','DystrophyReach50','DystrophyRadius','DystrophyExclude'})={0,0,0,{[]}};
%     Table.DystrophyExclude(1)={[]};
    for Time=1:size(Data,2)
        
        Deviation1=smooth(Data(1:end-1,Time),5)-Data(2:end,Time);
        if find(isnan(Data(:,Time))==0,1)>51 % first non-NaN index
            Table.DystrophyExclude(Time,1)={'TrailingNaNs'}; % plaque might be below another plaque
            continue;
        end
        TurningPoint=find(Deviation1<-0.001 & Data(1:end-1,Time)<0.3,2); TurningPoint=TurningPoint(end);
        if TurningPoint<50
            Table.DystrophyExclude(Time,1)={'TurningPoint<50'};
        end
%         if TurningPoint<50 || isempty(TurningPoint)
        Yaxis=Data(:,Time);
        Yaxis(1:TurningPoint)=NaN;
        F = fittype('A1*x+A2','independent','x');
        [Fit,Gof]=fit(Xaxis,Yaxis,F,'Exclude',isnan(Yaxis)==1,'Weight',VolumeData(:,Time));
        BaselineFit=feval(Fit,Xaxis);
        MeanBaselineFit=nanmean(BaselineFit(isnan(Data(:,Time))==0));
        if MeanBaselineFit>0.3
            Table.DystrophyExclude(Time,1)={'MeanBaselineFit>0.3'};
        end
        DystrophyReach=find(Data(:,Time)<BaselineFit*1.5,1);
        DystrophyReach50=find(Data(:,Time)<0.5,1); %         DystrophyReach50=find(Data(:,Time)<1/2+BaselineFit/2,1);
        Wave1=Data(:,Time)-BaselineFit;
        Wave1=Wave1/max(Wave1);
        Table.DystrophyReach(Time,1)=DystrophyReach-50;
        Table.DystrophyReach50(Time,1)=DystrophyReach50-50;
        Table.Volume(Time,1)=nansum(Wave1(1:DystrophyReach).*VolumeData(1:DystrophyReach,Time));
        Table.DystrophyRadius(Time,1)=(Table.Volume(Time,1)/3*4/3.1415)^(1/3);
        Table.DystrophyBaseline(Time,1)=MeanBaselineFit;
    end
    Loop.PlaqueData(Loop.NanCols,{'DystrophyReach','DystrophyReach50','DystrophyRadius','DystrophyExclude'})=Table(:,{'DystrophyReach','DystrophyReach50','DystrophyRadius','DystrophyExclude'});
    Loop.PlaqueData.Radius(cellfun(@isempty,Loop.PlaqueData.UmCenter))=NaN;
    MouseInfo.RoiInfo{Loop.Mouse,1}.TraceData{Loop.RoiData,1}.Data{Loop.Pl,1}=Loop.PlaqueData;
    [PlaqueList]=generatePlaqueList(PlaqueList,Loop.PlaqueData,Loop,MouseInfo,{'DystrophyRadius'});
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




return;
OrigPlaqueList=PlaqueList;
PlaqueList=PlaqueList(PlaqueList.Mouse>2,:);
% PlaqueList=PlaqueList(PlaqueList.Mouse~=1|PlaqueList.Mouse~=2,:);

keyboard;
PlaqueList(PlaqueList.BorderTouch==1 |...
    isnan(PlaqueList.Radius) |...
    isnan(PlaqueList.Dystrophy1Distance),:)=[];
[Groups]=processTraceGroups(PlaqueList,'Dystrophies1');


