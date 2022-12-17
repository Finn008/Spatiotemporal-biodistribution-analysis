function [Groups]=processTraceGroups(PlaqueList,ImageName)
global W;

% RadiusPooling=(0:100).';
% RadiusPooling=[0,5:5:100].';
% RadiusPooling=[0,10:10:100].';
RadiusPooling=[0,20:20:100].';
RadiusPooling(RadiusPooling>20,:)=[];

% exclude traces
% PlaqueList(PlaqueList.MouseId==275,:)=[];
% PlaqueList(PlaqueList.MouseId==351,:)=[];
% PlaqueList(PlaqueList.MouseId==346,:)=[];
% PlaqueList(PlaqueList.MouseId==2PlaqueList(PlaqueList.MouseId==351,:)=[];79,:)=[];
% PlaqueList(PlaqueList.MouseId==347 & ceil(PlaqueList.Radius)==12,:)=[];
% PlaqueList(PlaqueList.MouseId==351 & ceil(PlaqueList.Radius)==16,:)=[];


Colors={[0,1,1],[0,0.15,0.15];...
    [1,0,1],[0.15,0,0.15]}; % control in cyan and NB360 in magenta
% Groups2show={'NB360Vehicle';'NB360-60'};
Groups2show={'NB360Vehicle';'NB360'};
GraphLabel=1;

%% define settings
TimeGroups=[0;60;999];
Settings=struct;
if strcmp(ImageName,'Dystrophies1')
    Settings=struct('Yrange',[0;1]);
    
    Settings.DistRel.Xrange=[-2;70;0;10]; % [-10;70;0;20];[-2;70;0;20]
    Settings.DistRel.Yrange=[0;1;0;0.2];
    Settings.DistRel.MeanTrim=20;
    Settings.DistRel.Ylab='Dystrophy fraction';
    Settings.DistRel.LegendLocation='northwest';
    Settings.DistRel.SmoothingParam=0.01; % the smaller the more smoothing
    Settings.Single.Xdata='Radius';
    Settings.Single.Ydata='DystrophyFraction';
    Settings.Single.SmoothParam=0.4;
    Settings.Single.Yrange=[0;1];
    Settings.Single.Xrange=[0;15];
    Settings.Single.MeanTrim=5;
    Settings.Single.LegendLocation='northwest';
    
    
elseif strcmp(ImageName,'Boutons1')
    Settings.DistRel.Xrange=[0;30;0;5];
    Settings.DistRel.Yrange=[0;110;0;20]; % [0;5;0;2]
    Settings.DistRel.MeanTrim=0;
    Settings.DistRel.Ylab='Bouton density (norm)';
    Settings.DistRel.LegendLocation='northwest';
    Settings.DistRel.SmoothingParam=0.01;
    
    Settings.Single.Xdata='Radius';
    Settings.Single.Ydata='BoutonFactor';
    Settings.Single.SmoothParam=0.4;
    Settings.Single.Yrange=[0;0.006];
    Settings.Single.Xrange=[0;15];
    Settings.Single.MeanTrim=5;
    Settings.Single.LegendLocation='northwest';
elseif strcmp(ImageName,'Autofluo1')
    Settings.DistRel.Xrange=[-10;70;0;20];
    Settings.DistRel.Yrange=[0;0.025;0;0.01];
    Settings.DistRel.MeanTrim=20;
    Settings.DistRel.Ylab='Autofluorescence fraction';
    Settings.DistRel.LegendLocation='northwest';
    Settings.Single.Xdata='Radius';
    Settings.Single.Ydata='AutofluoFraction';
    Settings.Single.SmoothParam=0.4;
    Settings.Single.Yrange=[0;0.01;0;0.005];
    Settings.Single.Xrange=[0;15];
    Settings.Single.MeanTrim=5;
    Settings.Single.LegendLocation='northwest';
    Settings.DistRel.SmoothingParam=0.1;
elseif strcmp(ImageName,'MetBlue')
    Settings=struct('Yrange',[0.5;200]);
    Settings.DistRel.SmoothingParam=0.1;
    Settings.LogScaleY=10;
    Settings.InterpolationOff=1;
    Settings.Single.Xdata='Radius';
    Settings.Single.Ydata='RadiusMetBlue';
    Settings.Single.SmoothParam=0.4;
    
elseif strcmp(ImageName,'MetRed')
    Settings=struct('Yrange',[0.5;100]);
    Settings.DistRel.SmoothingParam=0.1;
    Settings.LogScaleY=10;
    Settings.InterpolationOff=1;
    Settings.Single.Xdata='Radius';
    Settings.Single.Ydata='RadiusMetRed';
    Settings.Single.SmoothParam=0.4;
else
    keyboard;
end

Xminmax=[min(PlaqueList{:,Settings.Single.Xdata});max(PlaqueList{:,Settings.Single.Xdata})];
SingleXaxis=linspace(Xminmax(1),Xminmax(2),1000).';

%% grouping
Groups=table;
Groups{'All','Data'}={PlaqueList(strcmp(PlaqueList.TreatmentType,'TauKO')==0,:)};
Wave1=PlaqueList(strcmp(PlaqueList.TreatmentType,'NB360Vehicle'),:);
Wave2=PlaqueList(strcmp(PlaqueList.TreatmentType,'NB360') & PlaqueList.TreatmentStart==0,:);
Groups{'NB360Vehicle','Data'}={[Wave1;Wave2]};
Groups{'TauKO','Data'}={PlaqueList(strcmp(PlaqueList.TreatmentType,'TauKO'),:)};
Groups{'NB360','Data'}={PlaqueList(strcmp(PlaqueList.TreatmentType,'NB360') & PlaqueList.TreatmentStart>0,:)};

NB360=Groups{'NB360','Data'}{1};
for m=2:size(TimeGroups,1)
    Groups{['NB360-',num2str(TimeGroups(m))],'Data'}={NB360(NB360.TreatmentStart>TimeGroups(m-1) & NB360.TreatmentStart<=TimeGroups(m),:)};
end

Wave1={'r';'w';'m';'c';'g';'y';'b'};
Groups.Color=Wave1(1:size(Groups,1));



%% combined traces
for Type=Groups.Properties.RowNames.' %{'NB360Vehicle','NB360','TauKO'}
    SelGroup=Groups{Type,'Data'}{1};
    Radii=[-1;RadiusPooling]; % Radii=(-1:ceil(max(SelGroup.Radius))).';
    Radii(Radii>max(SelGroup.Radius)+5,:)=[];
    DistRel=nan(256,size(Radii,1)-1);
    DistRelSmooth=nan(256,size(Radii,1)-1);
    SingleReadOut=nan(size(Radii,1)-1,1);
    SingleReadOutSmoothed=nan(size(Radii,1)-1,1);
    Mice=unique(SelGroup.MouseId);
    for Mouse=1:size(Mice,1)+1
%         MouseId=Mice(Mouse);
        if Mouse==size(Mice,1)+1
            SelMouse=SelGroup;
        else
            SelMouse=SelGroup(SelGroup.MouseId==Mice(Mouse),:);
        end
        
        for Rad=1:size(Radii,1)-1 % Rad represents lower radius boundary, so for Rad=1 it is -1to0, for Rad=2 it is 0to1
            SelRadius=SelMouse(SelMouse.Radius>Radii(Rad)&SelMouse.Radius<=Radii(Rad+1),:);
            try % if no traces of that radius available, also at least 2 required for fitting
                if strcmp(ImageName,'Boutons1')
                    SelRadius.DistRel(SelRadius.DistRel>0.004)=NaN;
                end
                Ydata=weightedMean(SelRadius.DistRel,SelRadius.DistRelVolume,Settings.Single.MeanTrim).';
                SingleReadOut(Rad)=trimmean(SelRadius{:,Settings.Single.Ydata},Settings.Single.MeanTrim);
                Xdata=(1:size(Ydata,1)).';
                if strcmp(ImageName,'Boutons1')
                    Wave2=find(Ydata>0);
                    Wave1=find(Ydata(1:min(Wave2(:)))==0);
                    Xdata(Wave1)=max(Wave1);
                    Ydata(Wave1(1:end-1))=NaN;
                    if Radii(Rad+1)==0; Ydata(51,1)=NaN; end;
                    [Curve]=fit(Xdata,Ydata,'smoothingspline','SmoothingParam',Settings.DistRel.SmoothingParam,'Exclude',isnan(Ydata));
                elseif strcmp(ImageName,'Dystrophies1')
                    [~,Wave1]=max(Ydata(:));
                    Ydata(1:Wave1-1)=NaN;
                    [Curve]=fit(Xdata,Ydata,'smoothingspline','SmoothingParam',Settings.DistRel.SmoothingParam,'Exclude',isnan(Ydata));
                elseif strcmp(ImageName,'Boutons1allPoints')
                    Xdata=repmat((1:size(Ydata,1)).',[size(Wave1,1),1]);
                    Ydata=reshape(Wave1.DistRel.',[size(Wave1,1)*size(Wave1.DistRel,2),1]);
                    [Curve]=fit(Xdata,Ydata,'smoothingspline','SmoothingParam',Settings.DistRel.SmoothingParam,'Exclude',isnan(Ydata));
                else
                    
                    [Curve]=fit(Xdata,Ydata,'smoothingspline','SmoothingParam',Settings.DistRel.SmoothingParam,'Exclude',isnan(DistRel(:,Rad)));
                end
                Curve=feval(Curve,Xdata);
                Curve(isnan(Ydata))=NaN;
                
                if strcmp(ImageName,'Boutons1')
                    Max=max(Curve(:));
                    Curve=Curve/Max*100;
                    Ydata=Ydata/Max*100;
                end
                DistRel(:,Rad)=Ydata;
                DistRelSmooth(:,Rad)=Curve;
            end
        end
        try
            [Curve]=fit(Radii(2:end),SingleReadOut,'smoothingspline','SmoothingParam',0.1,'Exclude',isnan(SingleReadOut));
            Curve=feval(Curve,SingleXaxis);
        catch
            Curve=nan(size(SingleXaxis,1),1);
        end
        Curve(isnan(SingleReadOut))=NaN;
        if Mouse==1
            TotalCurve=Curve;
            TotalSingleReadOut=SingleReadOut;
            TotalDistRel=DistRel;
            TotalDistRelSmooth=DistRelSmooth;
        else
            TotalCurve(:,Mouse)=Curve;
            TotalSingleReadOut(:,Mouse)=SingleReadOut;
            TotalDistRel(:,:,Mouse)=DistRel;
            TotalDistRelSmooth(:,:,Mouse)=DistRelSmooth;
            if min(isnan(DistRel(2,:)))==0
                %                 keyboard;
                try; disp(['Error',num2str(Mice(Mouse))]);end;
            end
        end
    end
    % mean the mice
    MiceMeanDistRelSmooth=nanmean(TotalDistRelSmooth(:,:,1:end-1),3);
    MiceMeanDistRelSmoothStd=nanstd(TotalDistRelSmooth(:,:,1:end-1),[],3);
    % put the data
    Groups.SingleReadOut(Type,1)={TotalSingleReadOut(:,1:end-1)};
    Groups.SingleReadOut(Type,3)={TotalSingleReadOut(:,end)};
    Groups.SingleReadOutSmoothed(Type,1)={TotalCurve(:,1:end-1)};
    Groups.SingleReadOutSmoothed(Type,3)={TotalCurve(:,end)};
    Groups.DistRel(Type,1)={TotalDistRel(:,:,1:end-1)};
    Groups.DistRel(Type,3)={TotalDistRel(:,:,end)};
    Groups.DistRelSmooth(Type,1)={TotalDistRelSmooth(:,:,1:end-1)};
    Groups.DistRelSmooth(Type,2)={MiceMeanDistRelSmooth};
    Groups.DistRelSmooth(Type,3)={TotalDistRelSmooth(:,:,end)};
    Groups.DistRelStd(Type,1)={MiceMeanDistRelSmoothStd};
    Groups.Mice(Type,1)={Mice};
end
Radii=[-1;RadiusPooling(1:size(Groups.DistRel{'All',1},2))];
DistRelXaxis=(-49:1:206).';

%% make images
SavePath=[W.G.PathOut,'\Unsorted\'];

%% show for each group one trace representing mean over mice together with std

if exist('asdf')~=1
    
    OrigYaxis=cell(0,2);
    for Group=1:size(Groups2show,1)
        GroupId=Groups2show{Group};
        Ind=size(OrigYaxis,1)+1;
        Data=Groups{GroupId,'DistRelSmooth'}{2};
        OrigYaxis(Ind,1:2)=[{Data},{struct('Color',{Colors(Group,1)},'LineStyle','-','LineWidth',1)}];
        
        Std=Groups{GroupId,'DistRelStd'}{1};
        Data=Data+Std;
        Data(:,:,:,2)=Data-2*Std;
        OrigYaxis(Ind+1,1:2)=[{Data},{struct('Color',{Colors(Group,2)},'LineStyle','-','LineWidth',1,'Area',{[]})}];
    end
    J=struct;
    J.Path2file=[SavePath,ImageName,'DistanceProfile.avi'];
    J.Tit=strcat({'Plaque radius: '},num2strArray_2(Radii(1:end-1)),' to',{' '},num2strArray_2(Radii(2:end))); %     J.Tit=strcat({'Plaque radius: '},num2strArray_2((0:100).'));
    J.OrigYaxis=OrigYaxis;
    J.OrigType=4;
    J.IntersectionColor=[0.20,0.20,0.20];
    J.X=DistRelXaxis;
    J.Xres=1;
    J.Xlab='Plaque distance [µm]';
    J.Ylab=Settings.DistRel.Ylab;
    J.Xrange=Settings.DistRel.Xrange;
    %     J.Xrange=[-2;70;0;20];
    J.Yrange=Settings.DistRel.Yrange;
    %%%     J.Legend=repmat(Groups2show,[2,1]);
    try; J.LogScale.Y=Settings.DistRel.LogScaleY; end;
    %%%     try; J.LegendLocation=Settings.DistRel.LegendLocation; end;
    J.Style=1;
    J.FidPix=[50,50,1500,750];
    movieBuilder_5(J);
    keyboard;
end


%% show all together, each trace represents the mean over plaques of all mice
if exist('asdf')~=1
    OrigYaxis=cell(0,2);
    for Group=1:size(Groups2show,1)
        GroupId=Groups2show{Group};
        Ind=size(OrigYaxis,1)+1;
        Data=Groups{GroupId,'DistRelSmooth'}{1};
        OrigYaxis(Ind,1:2)=[{Data},{struct('Color',{Colors(Group,2)},'LineWidth',1,'GraphLabel',num2strArray_2(Groups{GroupId,'Mice'}{1}))}];
        Data=Groups{GroupId,'DistRelSmooth'}{2};
        OrigYaxis(Ind+1,1:2)=[{Data},{struct('Color',{Colors(Group,1)},'LineWidth',1)}];
    end
    OrigYaxis=OrigYaxis([1;3;2;4],:);
    J=struct;
    J.Path2file=[SavePath,ImageName,'DistanceProfile.avi'];
    J.Tit=strcat({'Plaque radius: '},num2strArray_2(Radii(1:end-1)),' to',{' '},num2strArray_2(Radii(2:end))); %     J.Tit=strcat({'Plaque radius: '},num2strArray_2((0:100).'));
    J.OrigYaxis=OrigYaxis;
    J.OrigType=4;
    J.X=DistRelXaxis;
    J.Xres=1;
    J.Xlab='Plaque distance [µm]';
    J.Ylab=Settings.DistRel.Ylab;
    J.Xrange=Settings.DistRel.Xrange;
    J.Yrange=Settings.DistRel.Yrange;
    J.FidPix=[50,50,1500,750];
    J.LineWidth=3;
    %%%     J.Legend=repmat(Groups2show,[2,1]);
    try; J.LogScale.Y=Settings.DistRel.LogScaleY; end;
    %%%     try; J.LegendLocation=Settings.DistRel.LegendLocation; end;
    J.Style=1;
    movieBuilder_5(J);
end
keyboard;




%% show separate traces
Groups2show={'NB360Vehicle','TauKO','NB360'};
if exist('asdf')~=0
    for Type=Groups2show
        Y=Groups{Type,'DistRel'}{1};
        if isfield(Settings.DistRel,'InterpolationOff')~=1
            Y(:,:,2)=Groups{Type,'DistRelSmooth'}{1};
        end
        J=struct;
        J.Path2file=[SavePath,ImageName,'DistanceProfile_',Type{1},'.avi'];
        J.Tit=strcat({'Plaque radius: '},num2strArray_2((0:size(Y,2)-1).'),{' ('},Type{1},')');
        J.Y=permute(Y,[1,3,2]);
        J.X=DistRelXaxis;
        J.Xres=1;
        J.Xlab='Plaque distance [µm]';
        J.Ylab=Settings.DistRel.Ylab;
        J.Xrange=Settings.DistRel.Xrange;
        J.Yrange=Settings.DistRel.Yrange;
        J.Sp={[Groups.Color{Type},'.'];[Groups.Color{Type},'-']};
        %         try; J.LegendLocation=Settings.DistRel.LegendLocation; end;
        %         J.Sp={'w.';'w-'};
        try; J.LogScale.Y=Settings.LogScaleY; end;
        J.Style=1;
        movieBuilder_4(J);
    end
end
%% single readout
Groups2show={'NB360Vehicle';'NB360';'NB360-60';'NB360-999';'TauKO'};
Groups2show={'NB360Vehicle'};
Groups2show={'NB360Vehicle';'NB360';'TauKO'};
Groups2show={'NB360Vehicle';'NB360-60';'NB360-999'};

%% show presmoothed single readouts
if exist('asdf')~=1
    %     Wave1=Groups(Groups2show,'SingleReadOutSmoothed');
    clear Y;
    Wave1=Groups{Groups2show,'SingleReadOutSmoothed'};
    for m=1:size(Wave1,1)
        Y(:,m)=Wave1{m};
    end
    J=struct;
    J.Path2file=[SavePath,ImageName,'Single_PreSmoothed.png'];
    %     J.Tit=[ImageName,'Smoothed'];
    J.Y=Y;
    J.X=SingleXaxis;
    J.Yrange=Settings.Single.Yrange;
    J.Xrange=Settings.Single.Xrange;
    J.Xlab='Plaque radius [µm]';
    J.Ylab='Density in %';
    
    J.Sp=strcat(Groups.Color(Groups2show),'-');
    J.Legend=Groups2show;
    try; J.LegendLocation=Settings.Single.LegendLocation; end;
    J.Style=1;
    movieBuilder_4(J);
end

%% show each single readout separately
if exist('asdf')~=0
    for Type=Groups2show.'
        J=struct;
        J.Path2file=[SavePath,ImageName,'Single_Scattered.jpg'];
        J.Tit=[ImageName,'Scattered'];
        J.Y=Groups.Data{Type,1}{:,Settings.Single.Ydata};
        J.X=Groups.Data{Type,1}{:,Settings.Single.Xdata};
        J.Yrange=Settings.Single.Yrange;
        J.Xlab='Plaque radius [µm]';
        J.Ylab='Density in %';
        J.Sp=[Groups.Color{Type},'.'];
        J.Legend=Groups2show;
        movieBuilder_4(J);
    end
end

%% show all smoothing splines together
if exist('asdf')~=0
    
    Data=nan(1000,size(Groups2show,1));
    for m=1:size(Groups2show,1)
        Ind=strfind1(Groups.Properties.RowNames,Groups2show(m)).';
        Xdata=Groups.Data{Ind,1}{:,Settings.Single.Xdata};
        Ydata=Groups.Data{Ind,1}{:,Settings.Single.Ydata};
        [Curve,Goodness,Output]=fit(Xdata,Ydata,'smoothingspline','SmoothingParam',Settings.Single.SmoothParam);
        SmoothingSpline=feval(Curve,SingleXaxis);
        Groups.SmoothingSpline(m,1)={SmoothingSpline};
        Data(:,m)=SmoothingSpline;
    end
    
    J=struct;
    J.Path2file=[SavePath,ImageName,'Single_Smoothed.jpg'];
    J.Tit=[ImageName,'Smoothed'];
    J.Y=Data;
    J.X=SingleXaxis;
    J.Yrange=Settings.Single.Yrange;
    J.Xlab='Plaque radius [µm]';
    J.Ylab='Density in %';
    
    J.Sp=Groups.Color(Groups2show);
    J.Sp={'w-';'m-';'c-';'r-';'g-';'y-';'b-'};
    J.Legend=Groups2show;
    movieBuilder_4(J);
end

