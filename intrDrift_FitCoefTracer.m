function [Out]=intrDrift_FitCoefTracer_2(FitCoef,Xcenter,Ycenter,Zcenter,FilenameTotalA,FilenameTotalB,BorderDistance,Loop,DriftZcutoff)
global W;

Table=table;
Table.X=Xcenter;
Table.Y=Ycenter;
Table.Z=Zcenter;

MinMaxA=[min(Table.X(:,2)),max(Table.X(:,2));...
    min(Table.Y(:,2)),max(Table.Y(:,2));...
    min(Table.Z(:,2)),max(Table.Z(:,2))];

% correct XYZcenter with FitCoef
[Table.X(:,1),Table.Y(:,1),Table.Z(:,1),]=intrDrift_invertFitCoef(FitCoef,Table.X(:,1),Table.Y(:,1),Table.Z(:,1),[-100;+100]);

[~,Ind]=sort(Table.Z(:,1));
Table=Table(Ind,:);
Table.Drift=[Table.X(:,2)-Table.X(:,1),Table.Y(:,2)-Table.Y(:,1),Table.Z(:,2)-Table.Z(:,1)];

MinMaxB=[min(Table.X(:,1)),max(Table.X(:,1));...
    min(Table.Y(:,1)),max(Table.Y(:,1));...
    min(Table.Z(:,1)),max(Table.Z(:,1))];

% BorderDistance=5;
Ind=find(Table.X(:,2)<MinMaxA(1,1)+BorderDistance|...
    Table.X(:,2)>MinMaxA(1,2)-BorderDistance|...
    Table.Y(:,2)<MinMaxA(2,1)+BorderDistance|...
    Table.Y(:,2)>MinMaxA(2,2)-BorderDistance|...
    Table.Z(:,2)<MinMaxA(3,1)+BorderDistance|...
    Table.Z(:,2)>MinMaxA(3,2)-BorderDistance);
Table.Exclude(Ind,1)=1;
if isempty(DriftZcutoff)==0
    Table.Exclude(Table.Z(:,1)>DriftZcutoff)=1;
end

[Xcurve,Xgof,Xoutput]=fit(Table.Z(:,1),Table.Drift(:,1),'poly2','Robust','Bisquare','Exclude',Table.Exclude);
[Ycurve,Ygof,Youtput]=fit(Table.Z(:,1),Table.Drift(:,2),'poly2','Robust','Bisquare','Exclude',Table.Exclude);
[Zcurve,Zgof,Zoutput]=fit(Table.Z(:,1),Table.Drift(:,3),'poly2','Robust','Bisquare','Exclude',Table.Exclude);

FitCoefB2A=[coeffvalues(Xcurve);coeffvalues(Ycurve);coeffvalues(Zcurve)];

[~,~,~,FitCoefA2B]=intrDrift_invertFitCoef(FitCoefB2A,Xcenter(:,2),Ycenter(:,2),Zcenter(:,2),MinMaxB(3,:).');

Rmse=[Xgof.rmse;Ygof.rmse;Zgof.rmse];

Path2file=[W.G.PathOut,'\IntrDrift\',FilenameTotalB,'_vs_',FilenameTotalA,'.jpg'];
if Loop>1
    Wave1=strrep(Path2file,'.ims.jpg',['.ims_',num2str(Loop-1),'.jpg']);
    Path=['copy "',Path2file,'" "',Wave1,'"'];
    [Status,Cmdout]=dos(Path);
end

J=struct;
J.Path2file=Path2file;
J.Tit=['IntrDrift3: ',FilenameTotalB,' ',FilenameTotalA];

Startpoints=[Xcurve(MinMaxB(3,1));Ycurve(MinMaxB(3,1));Zcurve(MinMaxB(3,1))];
J.X=Table.Z(:,1);
J.OrigYaxis=[   {Table.Drift(:,1)-Startpoints(1)},{'w.'};...
    {Xcurve(Table.Z(:,1))-Startpoints(1)},{'w-'};...
    {Table.Drift(:,2)-Startpoints(2)},{'c.'};...
    {Ycurve(Table.Z(:,1))-Startpoints(2)},{'c-'};...
    {Table.Drift(:,3)-Startpoints(3)},{'r.'};...
    {Zcurve(Table.Z(:,1))-Startpoints(3)},{'r-'};...
    ];
J.OrigType=1;
J.Xlab='Depth [µm]';
J.Ylab='Drift [µm]';
J.Style=1; J.MarkerSize=10;

movieBuilder_4(J);

Out=struct;
Out.FitCoefB2A=FitCoefB2A;
Out.MinMaxA=MinMaxA;
Out.MinMaxB=MinMaxB;
Out.Table=Table;
Out.Rmse=Rmse;
Out.FitCoefA2B=FitCoefA2B;

evalin('caller','global W;');

% % % % % % % % retrieve StdDev in 10 point bins
% % % % % % % Table(Table.Exclude==1,:)=[];
% % % % % % % Table.AbsError=abs(Table.Drift(:,1)-Xcurve(Table.Z(:,1)));
% % % % % % % Table.AbsError(:,2)=abs(Table.Drift(:,2)-Ycurve(Table.Z(:,1)));
% % % % % % % Table.AbsError(:,3)=abs(Table.Drift(:,3)-Zcurve(Table.Z(:,1)));
% % % % % % % 
% % % % % % % 
% % % % % % % Wave1=floor(linspace(1,floor(size(Table,1)/5)-0.001,size(Table,1)).');
% % % % % % % Wave2=accumarray(Wave1,Table.Z(:,1),[],@mean,NaN);
% % % % % % % Wave3=accumarray(Wave1,sum(Table.AbsError,2),[],@median,NaN);
% % % % % % % 
% % % % % % % Ft= fittype('Y0+K*x^2',... % previously 'Y0+(Plateau-Y0)*(1-exp(-K*x))'
% % % % % % %     'dependent',{'y'},'independent',{'x'},...
% % % % % % %     'coefficients',{'Y0','K'});
% % % % % % % Opts=fitoptions('Method','NonlinearLeastSquares');
% % % % % % % Opts.Robust='Bisquare';
% % % % % % % % Opts.Exclude=Exclude;
% % % % % % % Opts.Lower=[0,0];
% % % % % % % Opts.Upper=[+Inf,+Inf];
% % % % % % % Opts.Startpoint=[0,0];
% % % % % % % % Opts.MaxIter=70; % default 400
% % % % % % % Curve=fit(Wave2,Wave3,Ft,Opts);
% % % % % % % Weight=1./Curve(Table.Z(:,1));
% % % % % % % Weight=Weight.^2;
% % % % % % % % % % figure; plot(Curve,Wave2,Wave3,'.');
% % % % % % % 
% % % % % % % Weight=ones(size(Table,1),1);
% % % % % % % Weight(Table.Z(:,1)>55)=0.01;
% % % % % % % Table.Exclude(Table.Z(:,1)>75)=1;
% % % % % % % [Xcurve2,Xgof,Xoutput]=fit(Table.Z(:,1),Table.Drift(:,1),'poly2','Robust','Bisquare','Exclude',Table.Exclude);
% % % % % % % [Ycurve2,Ygof,Youtput]=fit(Table.Z(:,1),Table.Drift(:,2),'poly2','Robust','Bisquare','Exclude',Table.Exclude);
% % % % % % % [Zcurve2,Zgof,Zoutput]=fit(Table.Z(:,1),Table.Drift(:,3),'poly2','Robust','Bisquare','Exclude',Table.Exclude);
% % % % % % % 
% % % % % % % figure; 
% % % % % % % hold on;
% % % % % % % plot(Xcurve,Table.Z(:,1),Table.Drift(:,1));
% % % % % % % plot(Xcurve2,'w');
% % % % % % % 
% % % % % % % figure;
% % % % % % % plot(Table.Z(:,1),Weight);
% % % % % % % 
% % % % % % % 
% % % % % % % % [Curve,Goodness,Output]=fit(Table.Z(:,1),sum(Table.AbsError,2),'smoothingspline','SmoothingParam',0.001);
% % % % % % % % plot(Curve,Table.Z(:,1),sum(Table.AbsError,2));