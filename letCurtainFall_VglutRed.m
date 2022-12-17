function [Results,Container,Data3D]=letCurtainFall_VglutRed(In)
v2struct(In);


if exist('PlaneDistance')~=1
    PlaneDistance=10;
end
if exist('DepthStep')~=1
    DepthStep=5;
end

if exist('Span')~=1
    Span=0.8;
end
if exist('EnhanceDenseSpots')~=1
    EnhanceDenseSpots=1;
end


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
    
    Opts.Span=Span;
    Table.Weight(:,1)=1;
    Depth=Um(3)*0.5; % Depth=Um(3)*2/3;
    if DepthStep~=0
        Table.Weight(Table.Z>=Depth,1)=0;
    end
    for Run=1:999999
        if DepthStep~=0
            Table.Weight(Table.Z>Depth-DepthStep&Table.Z<Depth,1)=1;
        end
        
        Selection=find(Table.Weight~=0);
        if DepthStep~=0 && size(Selection,1)<5
            Depth=Depth+DepthStep;
            continue;
        end
        Opts.Weight=Table.Weight(Selection);
        [Fit,Gof]=fit([Table.X(Selection),Table.Y(Selection)],Table.Z(Selection),Ft,Opts);
        
        ResCalc=[5;5;1];
        Wave1=(0:ResCalc(1):Um(1));
        Wave2=(0:ResCalc(2):Um(2)).';
        AreaSize=[size(Wave1,2);size(Wave2,1)];
        Wave1=repmat(Wave1,[AreaSize(2),1]);
        Wave2=repmat(Wave2,[AreaSize(1),1]);
        Wave1=reshape(Wave1,[prod(size(Wave1)),1]);
        %         Wave1=[Wave1,Wave2];
        Wave1=feval(Fit,Wave1,Wave2);
        Wave2=zeros(AreaSize(1),AreaSize(2));
        Wave2(:)=Wave1(:);
        Wave2(Wave2>Um(3)|Wave2<0)=NaN;
        [Area]=calcMeshArea(Wave2,ResCalc);
        
        Table.ZDist=Table.Z-feval(Fit,Table.X,Table.Y);
        Table.ZDistAbs=abs(Table.ZDist);
        Table=sortrows(Table,'ZDistAbs','ascend');
        
        IdSmaller10um=find(Table.ZDistAbs<PlaneDistance);
        %         IdSmaller5um=find(Table.ZDistAbs<PlaneDistance);
        if DepthStep~=0 && isempty(IdSmaller10um)
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
        Results(size(Results,1)+1,{'MeanSpotDistance','Depth','Area','RemoveNumber','MedianMinDist','SSE','Rsquare','Adjrsquare','Rmse','Fit','Table'})={MeanSpotDistance,Depth,Area/prod(Um(1:2)),RemoveNumber,MedianMinDist,Gof.sse,Gof.rsquare,Gof.adjrsquare,Gof.rmse,{Fit},{Table(Selection,:)}};
        Remove=Remove(end-RemoveNumber+1:end);
        Table.Weight(Remove,1)=0;
        
        Wave1=find(Table.ZDistAbs<PlaneDistance&Table.MinDist>NormalMinDist*2);
        Table.Weight(Wave1,1)=0.1;
        
        if EnhanceDenseSpots==1
            Wave1=find(abs(Table.ZDist)<PlaneDistance&Table.MinDist<NormalMinDist/2);
            Table.Weight(Wave1,1)=Table.Weight(Wave1,1)+1;
            Table.Weight(Table.Weight>3)=3;
        end
        
        
        if size(Results,1)>3 && max(Results.RemoveNumber(end-2:end))==0
            break;
        end
        if DepthStep~=0
            Depth=Depth+DepthStep;
        end
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
% Curve=feval(Results.Fit{end,1},repmat(linspace(1,Um(1),100).',[1,100]),repmat(linspace(1,Um(2),100),[100,1]));
% Curve=imresize(Curve,[Um(1),Um(2)],'bilinear');
% Curve=uint16(Curve);
% keyboard;
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
    movieBuilder3D(J);
end


if exist('Surface')==1
    Res=Um./Pix;
    Curve=feval(Results.Fit{end,1},repmat(linspace(0,Um(1),100).',[1,100]),repmat(linspace(0,Um(2),100),[100,1]));
    Curve=imresize(Curve,[Pix(1),Pix(2)],'bilinear');
    Curve=uint16(Curve/Res(3));
%     Curve=Curve-round(3/Res(3));
    
    Data3D=zeros(Pix(1),Pix(2),Pix(3),'uint8');
    Table.Pix=round([Table.X/Res(1),Table.Y/Res(2),Table.Z/Res(3)]);
    for X=1:Pix(1)
        for Y=1:Pix(2)
            %             Data3D(X,Y,Curve(X,Y))=1;
            Data3D(X,Y,Curve(X,Y):end)=1;
        end
    end
    if Surface==2
        for m=1:size(Table,1)
            Data3D(Table.Pix(m,1),Table.Pix(m,2),Table.Pix(m,3))=255;
        end
    end
%     Container.Data3D=Data3D;
else
    Data3D=[];
end

% ex2Imaris_2(Data3D,Application,'Test');

