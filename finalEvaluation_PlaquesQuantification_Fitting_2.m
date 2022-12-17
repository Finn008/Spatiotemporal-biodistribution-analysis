% include BorderTouching plaques with low power
function [Table,Coefs,Fit,PlBirth]=finalEvaluation_PlaquesQuantification_Fitting_2(Loop,Table,CaseOutliars)
SaveFigure=5; % set 0 to produce images, set to 5 if not

StartNum=Loop.StartTreatmentNum;
Table.Out(Table.Radius==0|isnan(Table.Radius)|Table.BorderTouch~=0,1)=1;


try % remove manually defined outliars
    Weights=ones(size(Table,1),1);
    Wave1=CaseOutliars.TimepointsPlaque{num2str(Loop.MouseId)};
    Table.Out(ismember(Table.Time,Wave1(:,1)))=1;
end

Appearance=find(isnan(Table.Radius)==0 & Table.Out==0,1); % first appearance, exclude border timepoints because then too large
Coefs={NaN;NaN};
if isempty(Appearance)
    Fit=[]; PlBirth=NaN;
    return;
end

X=Table.Age;
Y=Table.Radius;


Ft= fittype('Y0+Span*(1-exp(-K*x))',... % previously 'Y0+(Plateau-Y0)*(1-exp(-K*x))'
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'Y0','Span','K'});
Opts=fitoptions('Method','NonlinearLeastSquares');
Opts.Robust='Bisquare';
Opts.Upper=[+100,+Inf,0.13];
Opts.Lower=[-Inf,0,0];
Opts.Startpoint=[0,20,0];
Opts.MaxIter=70; % default 400
Opts.Weights=Weights;

if strfind1({'Control';'TauKO';'TauKD';'NB360Vehicle'},Loop.TreatmentType,1)
    Opts.Exclude=Table.Out;
    if sum(Table.Out(:)==0)>=4 % 4 or more accepted
        FitExp1=fit(X,Y,Ft,Opts);
        Coefs{1}=coeffvalues(FitExp1).';
        Table.RadiusFit1=feval(FitExp1,X);
        Table.Growth=differentiate(FitExp1,X);
        FitX1=(min(X):max(X)).';
        FitY1=feval(FitExp1,FitX1);
        SaveFigure=SaveFigure+1;
    end
elseif strcmp(Loop.TreatmentType,'NB360')
    
    Table.Include1=Table.Time2Treatment<=0 & Table.Age>=Table.Age(Appearance); % included to calculate radius fit for initial phase
    Table.Exclude1=Table.Time2Treatment>0 | Table.Out==1; % excluded to calculate initial phase
    Table.Include2=Table.Time2Treatment>=-1 & Table.Age>=Table.Age(Appearance); % included to calculate radius fit for initial phase
    Table.Exclude2=Table.Time2Treatment<-1 | Table.Out==1; % try to include first value from before
    
    if min(Table.Age(Table.Exclude2==0))-StartNum>8 % if no point close to treatmentstart then include last from before
        Wave1=Table.Exclude1==0 & Table.Time2Treatment>=-15 & Table.Time2Treatment<-1;
        Table.Exclude2(size(Wave1,1)-find(flip(Wave1)==1,1)+1)=0;
        
    end
    
    FtLinear=fittype('a+b*x',...
        'dependent',{'y'},'independent',{'x'},...
        'coefficients',{'a','b'});
    OptsLinear=fitoptions('Method','LinearLeastSquares');
    OptsLinear.Robust='Bisquare';
    OptsLinear.Weights=Weights;
    % find transition point
    if exist('TransitionPoint')==1
        TransitionPoint=nan(2,1);
        if sum(Table.Exclude1(:)==0)>=3 % 3 or more accepted
            OptsLinear.Exclude=Table.Exclude1;
            [FitLin1,GoodnessLin1,OutputLin1]=fit(X,Y,FtLinear,OptsLinear);
            TransitionPoint(1,1)=feval(FitLin1,StartNum);
        end
        if sum(Table.Exclude2(:)==0)>=3 % include TransitionPoint already here
            if min(Table.Age(Table.Exclude2==0))-StartNum>8 % if no point close to treatmentstart then include last from before
                Wave1=Table.Exclude2;
                Wave2=Table.Exclude1==0 & Table.Time2Treatment>=-15 & Table.Time2Treatment<-1;
                Wave1(size(Wave1,1)-find(flip(Wave2)==1,1)+1)=0;
                OptsLinear.Exclude=Wave1;
            else
                OptsLinear.Exclude=Table.Exclude2;
            end
            FitLin2=fit(X,Y,FtLinear,OptsLinear);
            TransitionPoint(2,1)=feval(FitLin2,StartNum);
        end
        if isnan(TransitionPoint(1,1))==0
            if abs(TransitionPoint(1,1)-TransitionPoint(2,1))>4
                TransitionPoint=nanmean(TransitionPoint);
                keyboard;
                X=[X;StartNum];
                Y=[Y;TransitionPoint];
                Exclude1=[Exclude1;0];
                Exclude2=[Exclude2;0];
                Opts.Weights=[Weights;5];
                OptsLinear.Weights=[Weights;5];
            end
        end
    end
    % Before treatment
    if sum(Table.Exclude1(:)==0)>=3
        if sum(Table.Exclude1(:)==0)>=4
            Opts.Exclude=Table.Exclude1;
            [FitExp1,GoodnessExp1,OutputExp1]=fit(X,Y,Ft,Opts);
        else
            OptsLinear.Exclude=Table.Exclude1;
            [FitExp1,GoodnessExp1,OutputExp1]=fit(X,Y,FtLinear,OptsLinear);
        end
        Coefs{1}=coeffvalues(FitExp1).';
        Table.RadiusFit1(Table.Include1)=feval(FitExp1,X(Table.Include1));
        Table.Growth(Table.Include1)=differentiate(FitExp1,X(Table.Include1));
        FitX1=(min(Table.Age):StartNum).';
        FitY1=feval(FitExp1,FitX1);
        SaveFigure=SaveFigure+1;
    end
    
    % After treatment
    if sum(Table.Exclude2(:)==0)>=3
        if sum(Table.Exclude2(:)==0)>=4
            Opts.Exclude=Table.Exclude2;
            FitExp2=fit(X,Y,Ft,Opts);
        else
            OptsLinear.Exclude=Table.Exclude2;
            FitExp2=fit(X,Y,FtLinear,OptsLinear);
        end
        Coefs{2,1}=coeffvalues(FitExp2).';
        Table.RadiusFit1(Table.Exclude1)=feval(FitExp2,X(Table.Exclude1));
        Table.Growth(Table.Time2Treatment>0)=differentiate(FitExp2,X(Table.Time2Treatment>0));
        FitX2=(StartNum:max(Table.Age)).';
        FitY2=feval(FitExp2,FitX2);
        SaveFigure=SaveFigure+1;
    end
else
    keyboard;
end

Fit=zeros(0,2);
try; Fit=[Fit;FitX1,FitY1]; end;
try; Fit=[Fit;FitX2,FitY2]; end;
Fit(Fit(:,1)<Table.Age(Appearance),:)=[];
Fit(:,1)=Fit(:,1)-StartNum;


% determine if newborn
PlBirth=NaN;
PlBirthProblem=0;
Table.RadiusFit1(1:Appearance-1,1)=NaN;
if sum(isnan(Table.RadiusFit1)==0)>=4 && Appearance>1 % minimally 4 timepoints
    BorderTouchBefore=Table.BorderTouch(1:Appearance-1);
    if Table.RadiusFit1(Appearance)<=5
        PlBirth=Table.Age(Appearance);
        Table.RadiusFit1(1:Appearance-1,1)=0;
    elseif Table.RadiusFit1(Appearance)>3.5 & min(BorderTouchBefore)==0
        PlBirthProblem=1;
    end
end

if SaveFigure<5 && SaveFigure~=0
    figure;
    hold on;
    plot(Table.Time2Treatment(Table.Out==0),Table.Radius(Table.Out==0),'xk');
    plot(Table.Time2Treatment(Table.Out==1),Table.Radius(Table.Out==1),'.k');
    
    plot(Table.Time2Treatment,Table.RadiusFit1,'.r')
    plot(Fit(:,1),Fit(:,2),'-r');
    
    Wave1=round(min(Table.Radius));
    Range=[min(Table.Time2Treatment),max(Table.Time2Treatment),Wave1-2,Wave1+18];
    axis(Range);
    line([0,0],[Range(1),Range(2)]);
    if isnan(PlBirth)==0 || PlBirthProblem==1
        line([PlBirth-StartNum,PlBirth-StartNum],[Range(1),Range(2)],'Color','r');
    end
    
    Path=['\\GNP90N\share\Finn\Analysis\Output\PlaqueGrowth\M',num2str(Loop.MouseId)];
    if exist(Path)~=7
        mkdir(Path);
    end
    Filename=['M',num2str(Loop.MouseId),'_Roi',num2str(Loop.RoiId),'_Pl',num2str(Loop.Pl)];
    if isnan(PlBirth)==0
        Filename=[Filename,'_Birth'];
    end
    if PlBirthProblem==1
        Filename=[Filename,'_Problem'];
    end
    saveas(gcf,[Path,'\',Filename,'.png'])
    close Figure 1;
end