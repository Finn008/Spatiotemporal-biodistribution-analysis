function [MouseInfo,PlaqueListAutofluo1]=finalEvaluation_Autofluo1Quantification(TimeDistTable,MouseInfo)
global W;
PlaqueList=table;

Loop=struct('Ind',0,'Selection',[]);
while Loop.Ind>=0
    Loop=struct('Type','TimeDistTable','TimeDistTable',TimeDistTable,'MouseInfo',MouseInfo,'Ind',Loop.Ind,'Selection',Loop.Selection,'Restriction',{{'Mod','Autofluo1';'Sub',1}});
    [Loop]=looper(Loop);
    if Loop.Ind<0; break; end
    % calculate density between 0 and 10µm from plaque border compared to 20-40
    BaselineFraction=nanmean(Loop.Data(71:91,:));
    AutofluoFraction=nanmean(Loop.Data(50:65,:));
    AutofluoFraction=AutofluoFraction-BaselineFraction;
    Factor=AutofluoFraction./BaselineFraction;
    AutofluoVol=Loop.VolumeData(50:65,:).*Loop.Data(50:65,:);
    AutofluoVol=nansum(AutofluoVol);
    Wave1=table(AutofluoFraction.',BaselineFraction.',Factor.',AutofluoVol.','VariableNames',{'AutofluoFraction','AutofluoBaselineFraction','AutofluoFactor','AutofluoVol'});
    Loop.PlaqueData(Loop.NanCols,{'AutofluoFraction','AutofluoBaselineFraction','AutofluoFactor','AutofluoVol'})=Wave1(Loop.NanCols,:);
    Loop.PlaqueData.Radius(cellfun(@isempty,Loop.PlaqueData.XYZCenter))=NaN;
    MouseInfo.RoiInfo{Loop.Mouse,1}.TraceData{Loop.RoiData,1}.Data{Loop.Pl,1}=Loop.PlaqueData;
    [PlaqueList]=generatePlaqueList(PlaqueList,Loop.PlaqueData,Loop,MouseInfo,{'AutofluoFraction'});
end

keyboard;

PlaqueList(PlaqueList.BorderTouch==1 |...
    isnan(PlaqueList.Radius) |...
    isnan(PlaqueList.AutofluoFraction),:)=[];

processTraceGroups(PlaqueList,'Autofluo1');

PlaqueListAutofluo1=PlaqueList;


%%
return;

PlaqueList(PlaqueList.BorderTouch==1 | isnan(PlaqueList.Radius) | isnan(PlaqueList.AutofluoFraction),:)=[];

keyboard; % process via processTraceGroups
Groups=table;

Groups{'All','Data'}={PlaqueList(strcmp(PlaqueList.TreatmentType,'TauKO')==0,:)};

Wave1=PlaqueList(strcmp(PlaqueList.TreatmentType,'NB360Vehicle'),:);
Wave2=PlaqueList(strcmp(PlaqueList.TreatmentType,'NB360') & PlaqueList.TreatmentStart==0,:);
Groups{'NB360Vehicle','Data'}={[Wave1;Wave2]};

Groups{'TauKO','Data'}={PlaqueList(strcmp(PlaqueList.TreatmentType,'TauKO'),:)};
Groups{'NB360','Data'}={PlaqueList(strcmp(PlaqueList.TreatmentType,'NB360') & PlaqueList.TreatmentStart>0,:)};

TimeGroups=[0;30;60;90;999];
NB360=Groups{'NB360','Data'}{1};
for m=2:size(TimeGroups,1)
    Groups{['NB360-',num2str(TimeGroups(m))],'Data'}={NB360(NB360.TreatmentStart>TimeGroups(m-1) & NB360.TreatmentStart<=TimeGroups(m),:)};
end
RadiusVsAutofluo=nan(60,size(Groups,1));
for m=1:size(Groups,1)
    Xdata=Groups.Data{m,1}.Radius;
    Ydata=Groups.Data{m,1}.AutofluoFraction;
    [Curve,Goodness,Output]=fit(Xdata,Ydata,'smoothingspline','SmoothingParam',0.4);
    Wave1=feval(Curve,0:0.5:max(Xdata(:)));
    Groups.RadiusVsAutofluo(m,1)={Wave1};
    RadiusVsAutofluo(1:size(Wave1,1),m)=Wave1;
end

for Type={'All','TauKO','NB360'}
    clear DistRel;
    clear DistRelSmooth;
    %     clear DistRelSmooth;
    Data=Groups{Type,'Data'}{1};
    Radii=(0:ceil(max(Data.Radius))).';
    for m=2:size(Radii,1)
        Wave1=Data(Data.Radius>Radii(m-1)&Data.Radius<Radii(m),:);
        DistRel(:,m-1)=nanmean(Wave1.DistRel).';
        Xdata=(1:size(DistRel,1)).';
        [Curve]=fit(Xdata,DistRel(:,m-1),'smoothingspline','SmoothingParam',0.1,'Exclude',isnan(DistRel(:,m-1)));
        Curve=feval(Curve,Xdata);
        Curve(isnan(DistRel(:,m-1)))=NaN;
        DistRelSmooth(:,m-1)=Curve;
    end
    Groups{Type,'DistRel'}={DistRel};
    Groups{Type,'DistRelSmooth'}={DistRelSmooth};
end

SavePath=[W.G.PathOut,'\Unsorted\'];

for Type={'All','TauKO','NB360'}
    Y=Groups{Type,'DistRel'}{1};
    Y(:,:,2)=Groups{Type,'DistRelSmooth'}{1};
    
    J=struct;
    J.Path2file=[SavePath,'Autofluo1DistanceProfile_',Type{1},'.avi'];
    J.Tit=strcat(Type{1},' Autofluo1DistanceProfile Radius: ',num2strArray_2((1:size(Y,2)).'));
    J.Frequency=3;
    J.Y=permute(Y*100,[1,3,2]);
    J.X=(-50:1:205).';
    J.Xres=1;
    J.Xlab='Distance2Plaque [µm]';
    J.Ylab='Autofluorescence density in %';
    J.Xrange=[-10;100];
    J.Yrange=[0;2.5];
    J.Sp={'w.';'w-'};
    movieBuilder_4(J);
end

J=struct;
J.Path2file=[SavePath,'Autofluo1Smoothed.jpg'];
J.Tit='Autofluo1Smoothed';
J.Y=RadiusVsAutofluo*100;
J.Xres=0.5;
J.Xlab='Plaque radius [µm]';
J.Ylab='Autofluorescence density in %';
J.Sp={'w-';'r-';'w-';'g-';'c-';'m-';'y-';'b-'};
J.Legend=Groups.Properties.RowNames;
movieBuilder_4(J);


