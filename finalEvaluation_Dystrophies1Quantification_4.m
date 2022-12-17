function [MouseInfo,PlaqueListSingle]=finalEvaluation_Dystrophies1Quantification_4(MouseInfo,PlaqueListSingle)
tic;
global W;
for Row=1:size(PlaqueListSingle,1)
    VolumeData=PlaqueListSingle.Volume1(Row,:).';
    % only plaque dystrophies
    Data=PlaqueListSingle.DystrophiesPl(Row,:).';
    
    
    
    % all dystrophies
    Data=PlaqueListSingle.Dystrophies1(Row,:).';
    
    Xaxis=(1:256).';
    Table=table; Table(size(Data,2),{'DystrophyReach','DystrophyReach50','DystrophyRadius','DystrophyExclude'})={0,0,0,{[]}};
    Deviation1=smooth(Data(1:end-1),5)-Data(2:end);
    if find(isnan(Data(:))==0,1)>51 % first non-NaN index
        Table.DystrophyExclude(1,1)={'TrailingNaNs'}; % plaque might be below another plaque
    end
    TurningPoint=find(Deviation1<-0.001 & Data(1:end-1)<0.3,2); TurningPoint=TurningPoint(end);
    if TurningPoint<50
        Table.DystrophyExclude(1,1)={'TurningPoint<50'};
    end
    Yaxis=Data;
    Yaxis(1:TurningPoint)=NaN;
    F = fittype('A1*x+A2','independent','x');
    [Fit,Gof]=fit(Xaxis,Yaxis,F,'Exclude',isnan(Yaxis)==1,'Weight',VolumeData);
    BaselineFit=feval(Fit,Xaxis);
    MeanBaselineFit=nanmean(BaselineFit(isnan(Data)==0));
    if MeanBaselineFit>0.3
        Table.DystrophyExclude(1,1)={'MeanBaselineFit>0.3'};
    end
    DystrophyReach=find(Data<BaselineFit*1.5,1);
    DystrophyReach50=find(Data<0.5,1); %         DystrophyReach50=find(Data(:,Time)<1/2+BaselineFit/2,1);
    Wave1=Data-BaselineFit;
    Wave1=Wave1/max(Wave1);
    Table.DystrophyReach(1,1)=DystrophyReach-50;
    Table.DystrophyReach50(1,1)=DystrophyReach50-50;
    Table.Volume(1,1)=nansum(Wave1(1:DystrophyReach).*VolumeData(1:DystrophyReach));
    Table.DystrophyRadius(1,1)=(Table.Volume(1,1)/3*4/3.1415)^(1/3);
    Table.DystrophyBaseline(1,1)=MeanBaselineFit;
    PlaqueListSingle(Row,{'DystrophyReach','DystrophyReach50','DystrophyRadius','DystrophyExclude'})=Table(:,{'DystrophyReach','DystrophyReach50','DystrophyRadius','DystrophyExclude'});
    
    keyboard; % go on here
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

