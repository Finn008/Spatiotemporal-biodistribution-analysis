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

[~,Ind]=sort(Table.Z(:,1)); Table=Table(Ind,:);
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
Table(Table.Exclude==1,:)=[];

FitType= fittype('A1*x^2+A2*x+A3',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'A1','A2','A3'});
Opts=fitoptions('Method','NonlinearLeastSquares');
Opts.Robust='Bisquare'; % 'LAR';
if Loop==1
    Opts.Upper=[0.00001,0.2,Inf];
    Opts.Lower=[-0.00001,-0.2,-Inf];
    Opts.Startpoint=[0,0,0];
end

for Trials=1:10
    Opts.Exclude=Table.Exclude;
    [Xcurve,Xgof,Xoutput]=fit(Table.Z(:,1),Table.Drift(:,1),FitType,Opts);
    [Ycurve,Ygof,Youtput]=fit(Table.Z(:,1),Table.Drift(:,2),FitType,Opts);
    [Zcurve,Zgof,Zoutput]=fit(Table.Z(:,1),Table.Drift(:,3),FitType,Opts);
    Table.DriftFit(:,1)=feval(Xcurve,Table.Z(:,1));
    Table.DriftFit(:,2)=feval(Ycurve,Table.Z(:,1));
    Table.DriftFit(:,3)=feval(Zcurve,Table.Z(:,1));
    Table.DriftDelta=abs(Table.Drift-Table.DriftFit);
    Table.DriftDeltaXYZ=sum(Table.DriftDelta,2);
    Table=sortrows(Table,'DriftDeltaXYZ','descend');
    Number=round(Trials*5/100*size(Table,1));
    Table.Exclude(1:Number)=1;
end

FitCoefB2A=[coeffvalues(Xcurve);coeffvalues(Ycurve);coeffvalues(Zcurve)];
Rmse=[Xgof.rmse;Ygof.rmse;Zgof.rmse];

[~,Ind]=sort(Table.Z(:,1)); Table=Table(Ind,:);
Startpoints=[Xcurve(MinMaxB(3,1));Ycurve(MinMaxB(3,1));Zcurve(MinMaxB(3,1))];
X=Table.Z(:,1);
figure; hold on;
plot(X,Table.Drift(:,1)-Startpoints(1),'k.');
plot(X,Table.Drift(:,2)-Startpoints(2),'c.');
plot(X,Table.Drift(:,3)-Startpoints(3),'r.');
plot(X,Xcurve(Table.Z(:,1))-Startpoints(1),'k-');
plot(X,Ycurve(Table.Z(:,1))-Startpoints(2),'c-');
plot(X,Zcurve(Table.Z(:,1))-Startpoints(3),'r-');
% line([Start(1)*Res(3),Start(1)*Res(3)],[-1,1],'Color','k');
% set(gca,'ylim',[-1;1]);
% Startpoints=round(Startpoints*100)/100;
Wave1=[Startpoints,FitCoefB2A];
Wave1=Wave1.*repmat([1,1000,100,1],[3,1]);
Wave1=round(Wave1)./repmat([1,1000,100,1],[3,1]);
Wave2=num2str(Wave1);
% strcat(
legend(['X: ',Wave2(1,:)],['Y: ',Wave2(2,:)],['Z: ',Wave2(3,:)]);
legend('boxoff')
% legend(['X: ',num2str(Startpoints(1))],['Y: ',num2str(Startpoints(2))],['Z: ',num2str(Startpoints(3))]);
% Wave1=[round(Startpoints*100)/100,FitCoefB2A];
% Wave1=round(Wave1*100)/100;
% legend(['X: ',num2str(Startpoints(1))],['Y: ',num2str(Startpoints(2))],['Z: ',num2str(Startpoints(3))]);
% pause(2);

Path2file=[W.G.PathOut,'\IntrDrift\',FilenameTotalB,'_vs_',FilenameTotalA,'.jpg'];
if Loop>1
    Wave1=strrep(Path2file,'.ims.jpg',['.ims_',num2str(Loop-1),'.jpg']);
    Path=['copy "',Path2file,'" "',Wave1,'"'];
    [Status,Cmdout]=dos(Path);
end
saveas(gcf,Path2file);
close Figure 1;
[~,~,~,FitCoefA2B]=intrDrift_invertFitCoef(FitCoefB2A,Xcenter(:,2),Ycenter(:,2),Zcenter(:,2),MinMaxB(3,:).');
Out=struct;
Out.FitCoefB2A=FitCoefB2A;
Out.MinMaxA=MinMaxA;
Out.MinMaxB=MinMaxB;
Out.Table=Table;
Out.Rmse=Rmse;
Out.FitCoefA2B=FitCoefA2B;

evalin('caller','global W;');