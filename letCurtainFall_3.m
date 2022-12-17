function [Results,Container]=letCurtainFall_3(In)
v2struct(In);

MinDensityWithin5um=2e-5;
if exist('PlaneDistance')~=1
    PlaneDistance=10;
end
if exist('DepthStep')~=1
    DepthStep=5;
end
if exist('FitModel')~=1
    FitModel='Lowess';
end

if strcmp(FitModel,'Lowess')
    MaxWeight=3;
    if exist('Span')~=1
        Span=0.8;
    end
    FitFunction= fittype('lowess');
    Opts = fitoptions('Method','LowessFit');
    Opts.Normalize='on';
    Opts.Span=Span;
elseif strcmp(FitModel,'SinusBrain')
    MaxWeight=6;
    FitFunction=fittype('C+ Cx1*x+Cx2*sin((x-Xmin)*pi/Xrange) + Cy1*y+Cy2*sin((y-Ymin)*pi/Yrange)',...
        'independent',{'x','y'},...
        'dependent','z',...
        'coefficients',{'C','Cx1','Cx2','Cy1','Cy2'},...
        'problem',{'Xmin','Ymin','Xrange','Yrange'});
    Opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    Opts.Display = 'Off';
    Xflexion=[0;Um(1)/450*7]; % from +-7 for 450µm
    Yflexion=[0;Um(2)/450*7];
    if exist('FitCoefCorr')~=1 || isempty(FitCoefCorr)
        Opts.Lower = [-Inf,-0.3,Xflexion(1),-0.3,Yflexion(1)]; % C,Cx1,Cx2,Cy1,Cy2
        Opts.StartPoint = [0,0,0,0,0];
        Opts.Upper = [Inf,0.3,Xflexion(2),0.3,Yflexion(2)];
    else
        Range=0.02; % 40µm per 500µm, before 2016.07.04 always 0.08
        Xflexion=[FitCoefCorr(3)-Xflexion(2)*0.1;FitCoefCorr(3)+Xflexion(2)*0.1];
        Xflexion(Xflexion<0)=0;
        Yflexion=[FitCoefCorr(5)-Yflexion(2)*0.1;FitCoefCorr(5)+Yflexion(2)*0.1];
        Yflexion(Yflexion<0)=0;
        Opts.Lower = [-Inf,FitCoefCorr(2)-Range,Xflexion(1),FitCoefCorr(4)-Range,Yflexion(1)]; % C,Cx1,Cx2,Cy1,Cy2
        Opts.StartPoint = FitCoefCorr.';
        Opts.Upper = [Inf,FitCoefCorr(2)+Range,Xflexion(2),FitCoefCorr(4)+Range,Yflexion(2)];
    end
    Problems={0,0,Um(1),Um(2)}; %     Problems={min(Table.X),min(Table.Y),Um(1),Um(2)}; % Problems={min(X),min(Y),(max(X)-min(X)),(max(Y)-min(Y))};
end
if exist('EnhanceDenseSpots')~=1
    EnhanceDenseSpots=1;
end


if exist('XYZdata')==1
    Table=table(XYZdata(:,1),XYZdata(:,2),XYZdata(:,3),'VariableNames',{'X','Y','Z'});
end

GhostXYZdata=rand(size(Table,1),3);
Wave1=repmat(Um.',[size(Table,1),1]);
GhostXYZdata=GhostXYZdata.*Wave1;
GhostXYZdata(:,3)=GhostXYZdata(:,3)+Um(3);
GhostXYZdata=table(GhostXYZdata(:,1),GhostXYZdata(:,2),GhostXYZdata(:,3),'VariableNames',{'X','Y','Z'});
Table=[Table;GhostXYZdata];
Table.NonGhost(1:size(GhostXYZdata,1),1)=1;

Table.Order=(1:size(Table,1)).';
RefinementPhase=0;
Results=table;
tic;
%% MeshDensity

NormalMinDist=calcDistance3D([Table.X,Table.Y,Table.Z],struct('Zband',10));
NormalMinDist=nanmean(NormalMinDist.MinDist);
Container.NormalMinDist=NormalMinDist;

Table.Weight(:,1)=0;
Depth=Um(3)*0.7; % Depth=Um(3)*2/3;
Stop=0;
for Run=1:999999
    if DepthStep~=0 && Depth<=Um(3)+50
        Depth=Depth+DepthStep;
        Ind=find(Table.Z>Depth-DepthStep&Table.Z<Depth);
        SpotTopAdd=size(Ind,1);
        Table.Weight(Ind,1)=1;
    else
        SpotTopAdd=0;
    end
    if Run>100; keyboard; end;
    Table.Weight(Table.Weight>0&Table.NonGhost==0,1)=0.7; % maximal weight of ghost-points
    
    Selection=find(Table.Weight~=0);
    if DepthStep~=0 && size(Selection,1)<5 % || max(Table.Weight(Table.NonGhost==1))==0
        continue;
    end
    Opts.Weight=Table.Weight(Selection);
    X=Table.X(Selection);
    Y=Table.Y(Selection);
    Z=Table.Z(Selection);
    if strcmp(FitModel,'Lowess')
        [Fit,Gof]=fit([X,Y],Z,FitFunction,Opts);
    else
        [Fit,Gof]=fit([X,Y],Z,FitFunction,Opts,'problem',Problems);
    end
    
    ResCalc=[5;5;1];
    Wave1=(0:ResCalc(1):Um(1));
    Wave2=(0:ResCalc(2):Um(2)).';
    AreaSize=[size(Wave1,2);size(Wave2,1)];
    Wave1=repmat(Wave1,[AreaSize(2),1]);
    Wave2=repmat(Wave2,[AreaSize(1),1]);
    Wave1=reshape(Wave1,[prod(size(Wave1)),1]);
    Wave1=feval(Fit,Wave1,Wave2);
    Wave2=zeros(AreaSize(1),AreaSize(2));
    Wave2(:)=Wave1(:);
    Wave2(Wave2>Um(3)|Wave2<0)=NaN;
    
    [Area]=calcMeshArea(Wave2,ResCalc);
    
    Table.ZDist=Table.Z-feval(Fit,Table.X,Table.Y);
    Table.ZDistAbs=abs(Table.ZDist);
    Table=sortrows(Table,'ZDistAbs','ascend');
    
    IdSmaller10um=find(Table.ZDistAbs<PlaneDistance);
    if DepthStep~=0 && isempty(IdSmaller10um)
        continue;
    end
    
    MeanSpotDistance=(Area/size(IdSmaller10um,1))^0.5;
    
    
    % finish evaluation of this fit, subsequently spots will be refined
    
    Wave1=calcDistance3D([Table.X(IdSmaller10um),Table.Y(IdSmaller10um),Table.Z(IdSmaller10um)]);
    Table.MinDist=zeros(size(Table,1),1);
    Table.MinDist(IdSmaller10um)=Wave1.MinDist;
    MedianMinDist=median(Wave1.MinDist);
    
    % judge if brain surface already reached
    Range=[-(1:40).',(1:40).'];
    VolumeBoth=planeVolumeIntersection(Fit,[[0;0;0],Um],Range,0.2,'Layer');
    Range=[(-1:-1:-40).',(0:-1:-39).'];
    VolumeDown=planeVolumeIntersection(Fit,[[0;0;0],Um],Range,0.2);
    
    DensityBoth=histc(Table.ZDistAbs(Table.NonGhost==1),(0:39).');
    DensityBoth=DensityBoth./VolumeBoth;
    DensityDown=flip(histc(Table.ZDist(Table.NonGhost==1),(-39:0).'));
    DensityDown=DensityDown./VolumeDown;
    DensityWithin5um=mean(DensityBoth(1:5));
    
    SpotDistanceHistogram(1:40,size(Results,1)+1)=DensityDown;
    SpotDistanceRatio=mean(DensityBoth(1:5))/mean(DensityDown(10:40));
    SpotDistanceRatio(isnan(SpotDistanceRatio))=0;
    Results(size(Results,1)+1,{'MeanSpotDistance','SpotDistanceRatio','DensityWithin5um','Depth','Area','MedianMinDist','FitCoef','Fit','Table','SpotNumber'})={MeanSpotDistance,SpotDistanceRatio,DensityWithin5um,Depth,Area/prod(Um(1:2)),MedianMinDist,coeffvalues(Fit),{Fit},{Table},size(Selection,1)};
    Ind=find(Table.ZDistAbs>PlaneDistance & Table.Weight~=0);
    SpotRemove=round(size(Ind,1)*0.5);
    if size(Ind,1)>=10 && SpotRemove<10
        SpotRemove=10;
    end
    Ind=Ind(end-SpotRemove+1:end);
    Table.Weight(Ind,1)=0;
    
    Ind=find(Table.ZDistAbs<PlaneDistance&Table.MinDist>NormalMinDist); % reduce weight of spots without close neighbors
    Table.Weight(Ind,1)=0.3;
    SpotNoNeighbor=size(Ind,1);
    
    Ind=find(abs(Table.ZDist)<PlaneDistance&Table.MinDist<NormalMinDist&Table.Weight<1);
    Table.Weight(Ind,1)=1;
    SpotReinclude=size(Ind,1);
    
    SpotEnhance=0;
    if EnhanceDenseSpots==1 && DensityWithin5um>MinDensityWithin5um
        CurrentWeight=[1;(1:100)'];
        try
            CurrentWeight=CurrentWeight(ceil(SpotDistanceRatio+0.0001)); % +0.0001 to treat also SpotDistanceRatio
        catch
            keyboard;
        end
        CurrentWeight=min(MaxWeight,CurrentWeight);
        
        Ind=find(abs(Table.ZDist)<PlaneDistance & Table.MinDist<NormalMinDist/2); %  & Table.MinDist<60
        Table.Weight(Ind,1)=Table.Weight(Ind,1)+1;
        Table.Weight(Table.Weight>CurrentWeight)=CurrentWeight;
        SpotEnhance=size(Ind,1);
    end
    
    Results(size(Results,1),{'SpotRemove','SpotNoNeighbor','SpotReinclude','SpotEnhance','SpotTopAdd'})={SpotRemove,SpotNoNeighbor,SpotReinclude,SpotEnhance,SpotTopAdd};
    
    if size(Results,1)>3 && max(Results.SpotRemove(end-1:end))==0 && RefinementPhase==0 &&  MedianMinDist<100
        Ind=find(abs(Table.ZDist)<15);
        Table.Weight(Ind,1)=1;
        
        if DensityWithin5um<MinDensityWithin5um
            Table.Weight(:,1)=0;
            Table.Weight(Table.NonGhost==0)=1;
            Table.Z(Table.NonGhost==0)=Um(3)*2;
        end
        
        RefinementPhase=1;
    end
    for m=size(Results,1)-1:-1:size(Results,1)-6
        if m>0 && isequal(coeffvalues(Fit),Results.FitCoef(m,:))
            Stop=1;
        end
    end
    if Stop==1 % if (size(Results,1)>3 && max(Results.SpotRemove(end-2:end))==0) || 
        break;
    end
end

if strcmp(FitModel,'Lowess')
    % calculate straight plane
    Ft=fittype('a*x+b*y+c','independent',{'x','y'},'dependent','z');
    Opts=fitoptions('Method','NonlinearLeastSquares');
    Opts.Display='Off';
    [Fit,Gof]=fit([Results.Table{end,1}.X,Results.Table{end,1}.Y],Results.Table{end,1}.Z,Ft,Opts);
    Container.PlaneCoeff=coeffvalues(Fit);
    Container.Rmse=Gof.rmse;
end
Container.SpotDistanceHistogram=SpotDistanceHistogram;

Results(Results.Depth==0,:)=[];



%%
if exist('MoviePath')
    J=struct;
    J.Path2file=MoviePath;
    J.Frequency=1;
    J.Tit=strcat('Fit',cellstr(num2str((1:size(Results,1)).')));
    J.XYZT=table;
    J.XYZT.Time=repmat((1:size(Results,1)).',[2,1]);
    J.XYZT.Data=[Results.Fit;Results.Table];
    J.Xlab='X';
    J.Ylab='Y';
    J.Zlab='Z';
    J.Xrange=[0;Um(1)];
    J.Yrange=[0;Um(2)];
    J.Zrange=[0;Um(3)];
    J.View=[26.5 2]; % Hazal5b: [43.5 10]
    J.MaximizeWindow=1;
    movieBuilder3D(J);
end


if exist('Surface')==1
    Res=Um./Pix;
    Curve=feval(Results.Fit{end,1},repmat(linspace(0,Um(1),100).',[1,100]),repmat(linspace(0,Um(2),100),[100,1]));
    Curve=imresize(Curve,[Pix(1),Pix(2)],'bilinear');
    Curve=uint16(Curve/Res(3));
    
    Data3D=zeros(Pix(1),Pix(2),Pix(3),'uint8');
    Table.Pix=round([Table.X/Res(1),Table.Y/Res(2),Table.Z/Res(3)]);
    for X=1:Pix(1)
        for Y=1:Pix(2)
            Data3D(X,Y,Curve(X,Y):end)=1;
        end
    end
    if Surface==2
        for m=1:size(Table,1)
            Data3D(Table.Pix(m,1),Table.Pix(m,2),Table.Pix(m,3))=255;
        end
    end
    Container.Data3D=Data3D;
end

