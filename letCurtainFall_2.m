function [Results,Container]=letCurtainFall_2(In)
v2struct(In);


if exist('XYZdata')==1
    Table=table(XYZdata(:,1),XYZdata(:,2),XYZdata(:,3),'VariableNames',{'X','Y','Z'});
end
Table.Order=(1:size(Table,1)).';

Results=table;
%%
if strcmp(Type,'MeshDensity')
    
    NormalMinDist=calcDistance3D([Table.X,Table.Y,Table.Z],struct('Zband',10));
    NormalMinDist=nanmean(NormalMinDist.MinDist);
    Container.NormalMinDist=NormalMinDist;
    
    Ft = fittype('lowess');
    Opts = fitoptions('Method','LowessFit');
    Opts.Normalize='on';
    
    Opts.Span=0.8; % previously 0.8
    DepthStep=5;
    Depth=XYZsize(3)*0.5; % Depth=XYZsize(3)*2/3;
    PlaneDistance=10;
    Table.Weight(Table.Z<Depth,1)=1;
    for Run=1:999999
        Table.Weight(Table.Z>Depth-DepthStep&Table.Z<Depth,1)=1;
        
        Selection=find(Table.Weight~=0);
        if size(Selection,1)<5
            Depth=Depth+DepthStep;
            continue;
        end
        Opts.Weight=Table.Weight(Selection);
        [Fit,Gof]=fit([Table.X(Selection),Table.Y(Selection)],Table.Z(Selection),Ft,Opts);
        
        Res=[5;5;1];
        Wave1=(0:Res(1):XYZsize(1));
        Wave2=(0:Res(2):XYZsize(2)).';
        AreaSize=[size(Wave1,2);size(Wave2,1)];
        Wave1=repmat(Wave1,[AreaSize(2),1]);
        Wave2=repmat(Wave2,[AreaSize(1),1]);
        Wave1=reshape(Wave1,[prod(size(Wave1)),1]);
%         Wave1=[Wave1,Wave2];
        Wave1=feval(Fit,Wave1,Wave2);
        Wave2=zeros(AreaSize(1),AreaSize(2));
        Wave2(:)=Wave1(:);
        Wave2(Wave2>XYZsize(3)|Wave2<0)=NaN;
        [Area]=calcMeshArea(Wave2,Res);
        
        Table.ZDist=Table.Z-feval(Fit,Table.X,Table.Y);
        Table.ZDistAbs=abs(Table.ZDist);
        Table=sortrows(Table,'ZDistAbs','ascend');
        
        IdSmaller10um=find(Table.ZDistAbs<PlaneDistance);
%         IdSmaller5um=find(Table.ZDistAbs<PlaneDistance);
        if isempty(IdSmaller10um)
            Depth=Depth+DepthStep;
            continue;
        end
        SpotNumber=size(IdSmaller10um,1);
        MeanSpotDistance=(Area/SpotNumber)^0.5;
        
        Wave1=calcDistance3D([Table.X(IdSmaller10um),Table.Y(IdSmaller10um),Table.Z(IdSmaller10um)]);
        Table.MinDist=zeros(size(Table,1),1);
        Table.MinDist(IdSmaller10um)=Wave1.MinDist;
        MedianMinDist=median(Wave1.MinDist);
        
        Remove=find(Table.ZDistAbs>PlaneDistance&Table.Weight~=0);
        if MeanSpotDistance<NormalMinDist*2/3
            Remove=find(abs(Table.ZDist)>PlaneDistance&Table.Weight~=0);
        end
        RemoveNumber=round(size(Remove,1)*0.5);
%         Results(Run,{'Fit','Table','SSE','Rsquare','Dfe','Adjrsquare','Rmse','RemoveNumber','MedianMinDist'})={{Fit},{Table(Selection,:)},Gof.sse,Gof.rsquare,Gof.dfe,Gof.adjrsquare,Gof.rmse,RemoveNumber,MedianMinDist};
        Results(size(Results,1)+1,{'MeanSpotDistance','Depth','Area','RemoveNumber','MedianMinDist','SSE','Rsquare','Adjrsquare','Rmse','Fit','Table'})={MeanSpotDistance,Depth,Area/prod(XYZsize(1:2)),RemoveNumber,MedianMinDist,Gof.sse,Gof.rsquare,Gof.adjrsquare,Gof.rmse,{Fit},{Table(Selection,:)}};
%         Results(Run,{'Fit','Table','SSE','Rsquare','Dfe','Adjrsquare','Rmse','SpotNumber','RemoveNumber','SpotDensity','MedianMinDist'})={{Fit},{Table(Selection,:)},Gof.sse,Gof.rsquare,Gof.dfe,Gof.adjrsquare,Gof.rmse,SpotNumber,RemoveNumber,SpotDensity,MedianMinDist};
        Remove=Remove(end-RemoveNumber+1:end);
        Table.Weight(Remove,1)=0;
        
        Wave1=find(Table.ZDistAbs<PlaneDistance&Table.MinDist>NormalMinDist*2);
        Table.Weight(Wave1,1)=0.1;
        
%         if MedianMinDist<NormalMinDist*2/3
        Wave1=find(abs(Table.ZDist)<PlaneDistance&Table.MinDist<NormalMinDist/2);
        Table.Weight(Wave1,1)=Table.Weight(Wave1,1)+1;
        Table.Weight(Table.Weight>3)=3;
%         end
        
        
        if size(Results,1)>3 && max(Results.RemoveNumber(end-2:end))==0
            break;
        end
        
        Depth=Depth+DepthStep;
    end
    
    % calculate straight plane
    Ft=fittype('a*x+b*y+c','independent',{'x','y'},'dependent','z');
    Opts=fitoptions('Method','NonlinearLeastSquares');
    Opts.Display='Off';
%     Opts.Robust='Bisquare';
    [Fit,Gof]=fit([Results.Table{end,1}.X,Results.Table{end,1}.Y],Results.Table{end,1}.Z,Ft,Opts);
    
%     keyboard; % also add error
    Container.PlaneCoeff=coeffvalues(Fit);
    Container.Rmse=Gof.rmse;
    
end
%%
if strcmp(Type,'Maxima')
    if size(Span,1)==1
        Span=repmat(Span,[9999,1]);
    end
    Ft = fittype('lowess');
    Opts = fitoptions('Method','LowessFit');
    Opts.Normalize='on';
    for Run=1:999999
        
        Opts.Span=Span(Run);
        try; Opts.Weights=Table.Weight; end;
        
        [Fit,Gof]=fit([Table.X,Table.Y],Table.Z,Ft,Opts);
        Table.ZDist=feval(Fit,Table.X,Table.Y);
        Table.ZDist=Table.Z-Table.ZDist;
        
        Results(Run,{'Fit','Gof','Table'})={{Fit},{Gof},{Table}};
        
        Table=sortrows(Table,'ZDist','ascend');
        Remove=find(Table.ZDist>-2); Remove=Remove(1);
        Remove=round(Remove*0.7);
        Table(1:Remove,:)=[];
        if size(Table,1)<30 || Run>10
            break;
        end
        
    end
end
Results(Results.Rmse==0,:)=[];

%%
% Curve=feval(Results.Fit{end,1},repmat(linspace(1,XYZsize(1),100).',[1,100]),repmat(linspace(1,XYZsize(2),100),[100,1]));
% Curve=imresize(Curve,[XYZsize(1),XYZsize(2)],'bilinear');
% Curve=uint16(Curve);

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
    J.Xrange=[0;XYZsize(1)];
    J.Yrange=[0;XYZsize(2)];
    J.Zrange=[0;XYZsize(3)];
    J.View=[26.5 2]; % Hazal5b: [43.5 10]
    movieBuilder3D(J);
end

