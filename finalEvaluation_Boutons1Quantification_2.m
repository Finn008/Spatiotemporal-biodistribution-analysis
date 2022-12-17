function [PlaqueListSingle]=finalEvaluation_Boutons1Quantification_2(MouseInfo,PlaqueListSingle)
tic;


keyboard;

%% calculations on each plaque separately
SuccessCount=0;
for Row=1:size(PlaqueListSingle,1)
%     Row=3223;
    if strcmp(PlaqueListSingle.TreatmentType{Row},'TauKO'); continue; end;
    
    Data=PlaqueListSingle.Boutons1(Row,:).';
    Data(Data==Inf)=NaN;
    if nansum(Data(:))==0; continue; end;
    
    DataMinMax=find(isnan(Data)==0,1);
    Wave1=find(isnan(Data(DataMinMax:end)),1);
    if isempty(Wave1)
        DataMinMax(2,1)=256;
    else
        DataMinMax(2,1)=Wave1+DataMinMax-2;
    end
    
    if DataMinMax(1)>50 || DataMinMax(2)<60
        continue;
    end
    
    X=(-49:206).';
    Y=Data;
    Exclude=isnan(Data);
    IndZero=find(Y(1:50)==0);
    X(IndZero)=0;
    Weights=ones(size(Y,1),1);
    Weights(IndZero)=size(IndZero,1);
    clear Coefs;
    
    FitType='MonoPhasicAssociation'; % 'SigmoidalDoseResponse'
    
    %% fit Sigmoidal dose-response (variable slope)
    if strcmp(FitType,'SigmoidalDoseResponse')
        Coefficients=table;
        Coefficients.BottomMinMax=[0;prctile(Data(1:70)+0.0001,20);0];
        Coefficients.TopMinMax=[prctile(Data,90);0.1;0.03];
        Coefficients.EC50MinMax=[50;200;60];
        Coefficients.HillSlopeMinMax=[0;0.1;0];
        
        Ft= fittype('Bottom + (Top-Bottom)/(1+10^((EC50-x)*HillSlope))',...
            'dependent',{'y'},'independent',{'x'},...
            'coefficients',{'Bottom','Top','EC50','HillSlope'});
        Opts=fitoptions('Method','NonlinearLeastSquares');
        Opts.Robust='Bisquare';
        Opts.Exclude=Exclude;
        Opts.Lower=[Coefficients.BottomMinMax(1),Coefficients.TopMinMax(1),Coefficients.EC50MinMax(1),Coefficients.HillSlopeMinMax(1)];
        Opts.Upper=[Coefficients.BottomMinMax(2),Coefficients.TopMinMax(2),Coefficients.EC50MinMax(2),Coefficients.HillSlopeMinMax(2)];
        Opts.Startpoint=[Coefficients.BottomMinMax(3),Coefficients.TopMinMax(3),Coefficients.EC50MinMax(3),Coefficients.HillSlopeMinMax(3)];
        Fit=fit(X,Y,Ft,Opts);
        Coefs=coeffvalues(Fit).';
    end
    
    
    
    %% fit mono-phasic association curve
    if strcmp(FitType,'MonoPhasicAssociation')
        Coefficients=table;
        Coefficients.Y0=[0;0.1;0];
        Coefficients.Top=[prctile(Data,80);0.1;0.03];
        Coefficients.K=[0;1;1];

        
        
        Ft= fittype('Y0+(Top-Y0)*(1-exp(-K*x))',...
            'dependent',{'y'},'independent',{'x'},...
            'coefficients',{'Y0','Top','K'});
        Opts=fitoptions('Method','NonlinearLeastSquares');
        Opts.Robust='Bisquare';
        Opts.Exclude=Exclude;
        Opts.Lower=[Coefficients.Y0(1),Coefficients.Top(1),Coefficients.K(1)];
        Opts.Upper=[Coefficients.Y0(2),Coefficients.Top(2),Coefficients.K(2)];
        Opts.Startpoint=[Coefficients.Y0(3),Coefficients.Top(3),Coefficients.K(3)];
        Opts.Weights=Weights;
        Fit=fit(X,Y,Ft,Opts);
        Coefs=coeffvalues(Fit).';
    end
    
    Wave1=feval(Fit,-49:206).';
    Wave1(isnan(Y))=NaN;
    PlaqueListSingle.Boutons1Fit(Row,1:256)=Wave1;
    
    GenerateFigure=0;
    if GenerateFigure==1
        figure;
        hold on;
        title(['K: ',num2str(round(Coefs(3),2)),', Y0: ',num2str(round(Coefs(1),0)),', Row: ',num2str(Row)]);
        plot(X,Y,'.k');
        Range=[-10,100,0,0.05];
        axis(Range);
        
        plot(Fit,'-k');
        MouseId=PlaqueListSingle.MouseId(Row);
        Path=['\\GNP90N\share\Finn\Analysis\output\Boutons1\M',num2str(MouseId)];
        if exist(Path)~=7
            mkdir(Path);
        end
        saveas(gcf,[Path,'\',num2str(MouseId),'_Roi',num2str(PlaqueListSingle.RoiId(Row)),'_Pl',num2str(PlaqueListSingle.Pl(Row)),'_Tp',num2str(PlaqueListSingle.Time(Row)),'.png'])
        close Figure 1;
    end
    
    SuccessCount=SuccessCount+1;
    if SuccessCount==0
        keyboard;
    end
    
end
disp(['finalEvaluation_Boutons1Quantification_2: ',num2str(round(toc/60)),'min']);
% keyboard;
return;

processTraceGroups_2(PlaqueListSingle,'Boutons1');

% OrigPlaqueList=PlaqueList;
Input=PlaqueListSingle;
PlaqueListSingle(isnan(Input.RadiusFit1),:)=[];
Wave1=nansum(Selection.Boutons1,2);
        Selection(Wave1==0,:)=[];
% Input.BoutonFactor(PlaqueList.BoutonFactor==inf)=NaN;

Wave1=find(isnan(PlaqueList.DistRel(:,2))==0);
if isempty(Wave1)==0
    PlaqueList(Wave1,:)=[];
end




PlaqueListBoutons1=PlaqueList;


Selection=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId & PlaqueListSingle.RadiusFit1>RadBinId(1) & PlaqueListSingle.RadiusFit1<=RadBinId(2),:);
        Wave1=nansum(Selection.Boutons1,2);
        Selection(Wave1==0,:)=[];