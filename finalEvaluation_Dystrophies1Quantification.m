function finalEvaluation_Dystrophies1Quantification(TimeDistTable,MouseInfo)
global W;
PlaqueList=table;


Loop=struct('Ind',0,'Selection',[]);
while Loop.Ind>=0
    Loop=struct('Type','TimeDistTable','TimeDistTable',TimeDistTable,'MouseInfo',MouseInfo,'Ind',Loop.Ind,'Selection',Loop.Selection,'Restriction',{{'Mod','Dystrophies1';'Sub',2}});
    [Loop]=looper(Loop);
% Loop=struct('Ind',0);
% while Loop.Ind>=0
%     [Loop]=looper(struct('Type','TimeDistTable','TimeDistTable',TimeDistTable,'MouseInfo',MouseInfo,'Ind',Loop.Ind,'Restriction',{{'Mod','Dystrophies1';'Sub',2}}));
    if Loop.Ind<0; break; end
    
    Smooth=table([1;1;1],{[];[];[]},'VariableNames',{'Power','Robust'});
    Data=Loop.Data(:,Loop.NanCols);
    [Abl,Out1]=ableitung_2(Data,[],Smooth);
    Distance=nan(size(Data,2),1);
    Baseline=nan(size(Data,2),1);
    Volume=nan(size(Data,2),1);
    Version=4;
    
    VolumeData=Loop.VolumeData(:,Loop.NanCols);
    
    
    for Time=1:size(Data,2)
        Baseline(Time,1)=weightedMean(Data(65:end,Time),VolumeData(65:end,Time));
        
        Yaxis=Data(:,Time);
        [Wave1]=sort(Yaxis(isnan(Yaxis)==0));
        Wave1=Wave1(round(size(Wave1,1)*4/5));
        Yaxis(Yaxis>Wave1)=nan;
        Xaxis=(1:256).';
        f = fittype('A1*x+A2','independent','x');
        [Fit,Gof]=fit((1:256).',Yaxis,f,'Exclude',isnan(Yaxis)==1);
        FitCoef=coeffvalues(Fit);
        % % % % %         plot(Fit,Xaxis,Yaxis);
        BaselineFit=Xaxis*FitCoef(1)+FitCoef(2);
        
        if Version==1 % find first Wendepunkt below Baseline and use Wendepunkt before that
            Wave1=Out1.MaximaLocs(1:7,3,Time);
            Wave1(:,2)=Data(Wave1(:,1),Time);
            Wave2=find(Wave1(:,2)<=Baseline(Time,1));
            Distance(Time,1)=Wave1(min(Wave2(:))-1,1);
        end
        if Version==2 % find last Wendepunkt within falling region
            Wave1=Out1.MaximaLocs(:,3,Time);
            Falling=find(Abl(50:end,2,Time)>-0.1)+50;
            Wave2=find(Wave1<=min(Falling(:))); Wave2=max(Wave2(:));
            Distance(Time,1)=Wave1(Wave2,1);
        end
        if Version==3
            % large 2.Abl value, 1.Abl is negative for at least 3µm, raw value above Baseline
            Wave1=table;
            Wave1.Abl2Maxima=Out1.MaximaLocs(:,3,Time);
            Wave1.Abl2Value=Out1.MaximaValues(:,3,Time);
            Wave1(isnan(Wave1.Abl2Maxima),:)=[];
            [~,Wave2]=sort(Wave1.Abl2Value);
            Wave1.Abl2Order(Wave2,1)=(size(Wave2,1):-1:1).';
            for m2=1:size(Wave1,1)
                Wave1.RawValue(m2,1)=Data(Wave1.Abl2Maxima(m2,1),Time);
                Wave1.FallingFor3um(m2,1)=max(Abl(Wave1.Abl2Maxima(m2,1)-2:Wave1.Abl2Maxima(m2,1),2,Time))<0;
            end
            Wave2=find(Wave1.Abl2Order<4&...
                Wave1.FallingFor3um==1&...
                Wave1.RawValue>Baseline(Time,1)&...
                Wave1.Abl2Value>0.3);
            if isempty(Wave2) || size(Wave2,1)>1
                keyboard;
            end
            Distance(Time,1)=Wave1.Abl2Maxima(Wave2,1);
        end
        if Version==4
            %             Distance(Time,1)=min(find(Data(:,Time)<Baseline(Time,1)*1.5));
            Distance(Time,1)=min(find(Data(:,Time)<BaselineFit*1.5));
        end
        Wave1=Data(:,Time)-BaselineFit;
        Wave1(Wave1<0)=0;
        Wave1=VolumeData(:,Time).*Wave1;
        Volume(Time,1)=nansum(Wave1(1:Distance(Time,1)));
    end
    Distance=Distance-50;
    Wave1=table(Distance,Volume,Baseline,'VariableNames',{'Dystrophy1Distance','Dystrophy1Volume','Dystrophy1Baseline'});
    Loop.PlaqueData(Loop.NanCols,{'Dystrophy1Distance','Dystrophy1Volume','Dystrophy1Baseline'})=Wave1;
    Loop.PlaqueData.Radius(cellfun(@isempty,Loop.PlaqueData.XYZCenter))=NaN;
    MouseInfo.RoiInfo{Loop.Mouse,1}.TraceData{Loop.RoiData,1}.Data{Loop.Pl,1}=Loop.PlaqueData;
    
    Wave1=Loop.PlaqueData(:,{'Radius','BorderTouch','Dystrophy1Distance'});
    Wave1.TreatmentStart=Loop.Age-Loop.TimeSections(1,2);
    Wave1.TreatmentStart(Wave1.TreatmentStart<0)=0;
    Wave1.TreatmentType(:,1)=MouseInfo.TreatmentType(Loop.Mouse,1);
    Wave1.DistRel=Loop.Data(:,1:size(Wave1,1)).';
    PlaqueList=[PlaqueList;Wave1];
end

keyboard;
PlaqueList(PlaqueList.BorderTouch==1 |...
    isnan(PlaqueList.Radius) |...
    isnan(PlaqueList.Dystrophy1Distance),:)=[];
[Groups]=processTraceGroups(PlaqueList,'Dystrophies1');


