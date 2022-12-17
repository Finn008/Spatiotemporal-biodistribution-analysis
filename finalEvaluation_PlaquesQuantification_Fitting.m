function [Table]=finalEvaluation_PlaquesQuantification_Fitting(Loop,Table)
SaveFigure=0; % set 0 to produce images, set to 5 if not
X=Table.Age;
Y=Table.Radius;
Exclude=Table.Out;

Ft= fittype('Y0+Span*(1-exp(-K*x))',... % previously 'Y0+(Plateau-Y0)*(1-exp(-K*x))'
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'Y0','Span','K'});
Opts=fitoptions('Method','NonlinearLeastSquares');
Opts.Robust='Bisquare';
Opts.Exclude=Exclude;
Opts.Upper=[+100,+100,0.13]; % 0.780
Opts.Lower=[-Inf,0,0];
Opts.MaxIter=70; % default 400

if strcmp(Loop.TreatmentType,'Control') || strcmp(Loop.TreatmentType,'TauKO')
    if sum(Exclude(:)==0)>3
        Fit=fit(X,Y,Ft,Opts);
        Coefs=coeffvalues(Fit);
        Table.RadiusFit1=feval(Fit,X);
        Table.Growth=differentiate(Fit,X);
        FitX=(min(X):max(X)).';
        FitY=feval(Fit,FitX);
        SaveFigure=SaveFigure+1;
    end
elseif strcmp(Loop.TreatmentType,'NB360')
    if sum(Exclude(:)==0)<=3
        return;
    end
    Fit=fit(X,Y,'smoothingspline','Exclude',Exclude,'SmoothingParam',0.001);
    TransitionPoint=feval(Fit,Loop.StartTreatmentNum);
    Wave1=find(X==Loop.StartTreatmentNum);
    Exclude(Wave1,:)=1;
    X=[X;Loop.StartTreatmentNum];
    Y=[Y;TransitionPoint];
    Exclude=[Exclude;0];
    Opts.Weight=[ones(size(Table,1),1);1000];
    % before treatment
    IndExclude=find(Table.Time2Treatment>0);
    IndInclude=find(Table.Time2Treatment<=0);
    Exclude2=Exclude; Exclude2(IndExclude,1)=1;
    FitX=zeros(0,1);
    FitY=zeros(0,1);
    if sum(Exclude2(:)==0)>3
        Opts.Exclude=Exclude2;
        Fit=fit(X,Y,Ft,Opts);
        Coefs=coeffvalues(Fit);
        Table.RadiusFit1(IndInclude)=feval(Fit,X(IndInclude));
        Table.Growth(IndInclude)=differentiate(Fit,X(IndInclude));
        FitX=(min(X(IndInclude)):Loop.StartTreatmentNum).';
        FitY=feval(Fit,FitX);
        SaveFigure=SaveFigure+1;
    end


    % after treatment
    IndExclude=find(Table.Time2Treatment<=0);
    IndInclude=find(Table.Time2Treatment>0);
    Exclude2=Exclude; Exclude2(IndExclude,1)=1;
    if sum(Exclude2(:)==0)>3
        Opts.Exclude=Exclude2;
        Fit=fit(X,Y,Ft,Opts);
        Coefs=coeffvalues(Fit);
        Table.RadiusFit1(IndInclude)=feval(Fit,X(IndInclude));
        Table.Growth(IndInclude)=differentiate(Fit,X(IndInclude));
        FitX2add=(Loop.StartTreatmentNum+1:max(X(IndInclude))).';
        FitX=[FitX;FitX2add];
        FitY=[FitY;feval(Fit,FitX2add)];
        SaveFigure=SaveFigure+1;
    end
    
    
else
    keyboard;
end

if SaveFigure<5 && SaveFigure~=0
    figure;
    hold on;
%     SaveFigure=1;
    plot(Table.Age,Table.Radius);
    plot(FitX,FitY);
    saveas(gcf,['\\GNP90N\share\Finn\Analysis\output\Unsorted\PlaqueGrowth\',num2str(Loop.MouseId),'_Roi',num2str(Loop.RoiId),'_Pl',num2str(Loop.Pl),'.png'])
    close Figure 1;
%     SaveFigure=0;
end