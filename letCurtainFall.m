function [Results,Container]=letCurtainFall(In)
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
    Depth=XYZsize(3)*2/3;
    PlaneDistance=5;
    Table.Weight(Table.Z<Depth,1)=1;
    for Run=1:999999
        Table.Weight(Table.Z>Depth-DepthStep&Table.Z<Depth,1)=1;
        
        Selection=find(Table.Weight~=0);
        if size(Selection,1)<5
            break;
        end
        Opts.Weight=Table.Weight(Selection);
        [Fit,Gof]=fit([Table.X(Selection),Table.Y(Selection)],Table.Z(Selection),Ft,Opts);
        
        Table.ZDist=Table.Z-feval(Fit,Table.X,Table.Y);
        Table=sortrows(Table,'ZDist','ascend');
        
        IdSmaller5um=find(abs(Table.ZDist)<PlaneDistance);
        if isempty(IdSmaller5um)
            Depth=Depth+DepthStep;
            continue;
        end
        SpotNumber=size(IdSmaller5um,1);
        SpotDensity=SpotNumber/prod(XYZsize(1:2))*1000; % per 10µm^2
        
        Wave1=calcDistance3D([Table.X(IdSmaller5um),Table.Y(IdSmaller5um),Table.Z(IdSmaller5um)]);
        Table.MinDist=zeros(size(Table,1),1);
        Table.MinDist(IdSmaller5um)=Wave1.MinDist;
        MedianMinDist=median(Wave1.MinDist);
        
        Remove=find(Table.ZDist<-PlaneDistance&Table.Weight~=0);
        if MedianMinDist<NormalMinDist*2/3
            Remove=find(abs(Table.ZDist)>PlaneDistance&Table.Weight~=0);
        end
        RemoveNumber=size(Remove,1);
        Results(Run,{'Fit','Table','SSE','Rsquare','Dfe','Adjrsquare','Rmse','SpotNumber','RemoveNumber','SpotDensity','MedianMinDist'})={{Fit},{Table(Selection,:)},Gof.sse,Gof.rsquare,Gof.dfe,Gof.adjrsquare,Gof.rmse,SpotNumber,RemoveNumber,SpotDensity,MedianMinDist};
        Remove=Remove(1:round(size(Remove,1)*0.5));
        Table.Weight(Remove,1)=0;
        
        if MedianMinDist<NormalMinDist*2/3
            Wave1=find(abs(Table.ZDist)<PlaneDistance&Table.MinDist<NormalMinDist);
            Table.Weight(Wave1,1)=Table.Weight(Wave1,1)+1;
        end
        
        Wave1=find(abs(Table.ZDist)<PlaneDistance&Table.MinDist>NormalMinDist*2);
        Table.Weight(Wave1,1)=0;
        
        if size(Results,1)>3 && max(Results.RemoveNumber(end-2:end))==0
            break;
        end
        
        Depth=Depth+DepthStep;
    end
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
Results(Results.SpotNumber==0,:)=[];

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

