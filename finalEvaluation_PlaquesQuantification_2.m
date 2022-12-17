% quantification of single plaques
function [PlaqueList,PlaqueListSingle]=finalEvaluation_PlaquesQuantification_2(MouseInfo)
FitType='MonoPhasicAssociation';
SaveFigure=5; % zero to produce images, 5 if not
PlaqueList=table;
PlaqueListSingle=table;
tic
Loop=struct('Ind',0,'Selection',[]);
while Loop.Ind>=0
    Loop=struct('Type','MouseInfo','MouseInfo',MouseInfo,'Ind',Loop.Ind,'Selection',Loop.Selection);
    [Loop]=looper(Loop);
    if Loop.Ind<0; break; end
    
    % calculate Radii linear growth
    
    Table=table;
    Table.BorderTouch=Loop.PlaqueData.BorderTouch;
    Table.Age=Loop.Age(1:size(Table,1));
    Table.Radius=Loop.PlaqueData.Radius;
    Table.XYZCenter=Loop.PlaqueData.UmCenter;
    Table.Time2Treatment=Table.Age-Loop.StartTreatmentNum;
    Table.TreatmentType(:,1)={Loop.TreatmentType};
    if strcmp(Loop.TreatmentType,'NB360')
        Table.TreatmentType(Table.Age<Loop.StartTreatmentNum,1)={'NB360Vehicle'};
    end
    
    for m=1:size(Table,1)
        if isequal(Table.XYZCenter{m},[1;1;1]) || isempty(Table.XYZCenter{m})
            Table.Radius(m,1)=NaN;
        end
    end
    
    % % %     [DataOut]=fit2TimeSections_2(Loop.TimeSections,Table.Age,Table.Radius,Table.Out);
    DataOut=table;
    
    % determine if newborn
    Wave1=find(isnan(Table.Radius));
    DataOut.PlBirth=NaN;
    if isempty(Wave1)==0 | min(Wave1)==1
        for m=1:size(Table,1)
            if isnan(Table.Radius(m))==0
                Appearance=m;
                break;
            end
        end
        if min(Table.BorderTouch(1:Appearance-1))==0
            % find next three not Bordertouching Plaques
            
            Wave2=Table(Table.Age<Table.Age(Appearance)+18&Table.Age>=Table.Age(Appearance)&Table.BorderTouch==0,:);
            Wave2.ApproxRadius=Wave2.Radius-(Wave2.Age-Table.Age(Appearance-1))*0.3/7;
            
            if isempty(Wave2)==0 && mean(Wave2.ApproxRadius)<3
                DataOut.PlBirth=Table.Age(Appearance);
                Table.Radius(1:Appearance-1,1)=0;
            end
        end
    end
    
    % interpolate radius
    Table.Out(Table.Radius==0|isnan(Table.Radius)|Table.BorderTouch~=0,1)=1;
    Table.Out(1)=1;
    
    Table.RadiusFit1(:,1)=NaN;
    Table.Growth(:,1)=NaN;
    for Treatment=unique(Table.TreatmentType).'
        if strcmp(Loop.TreatmentType,'NB360') && strcmp(Treatment,'NB360Vehicle')
            Ind=find(Table.Time2Treatment<=0);
        elseif strcmp(Loop.TreatmentType,'NB360') && strcmp(Treatment,'NB360')
            Ind=find(Table.Time2Treatment>=-1);
        else
            Ind=(1:size(Table,1)).';
        end
        X=Table.Age(Ind);
%         X(Table.Out(Ind)==1)=NaN;
        Y=Table.Radius(Ind);
        Exclude=Table.Out(Ind);
        if sum(Exclude(:)==0)>3
            if strcmp(FitType,'MonoPhasicAssociation')
%                 Ft= fittype('Y0+(Plateau-Y0)*(1-exp(-K*x))',... % previously 
                Ft= fittype('Y0+Span*(1-exp(-K*x))',... % previously 'Y0+(Plateau-Y0)*(1-exp(-K*x))'
                    'dependent',{'y'},'independent',{'x'},...
                    'coefficients',{'Y0','Span','K'});
                Opts=fitoptions('Method','NonlinearLeastSquares');
                Opts.Robust='Bisquare';
                Opts.Exclude=Exclude;
%                 Opts.Upper=[+Inf,+Inf,0.13]; % 0.754
%                 Opts.Upper=[+100,+Inf,0.13]; % 0.746
                Opts.Upper=[+100,+100,0.13]; % 0.780
                Opts.Lower=[-Inf,0,0];
                Opts.MaxIter=70; % default 400
                Fit=fit(X,Y,Ft,Opts);
                Coefs=coeffvalues(Fit);
            elseif strcmp(FitType,'quadratic')
                Ft= fittype('a+x^b',...
                    'dependent',{'y'},'independent',{'x'},...
                    'coefficients',{'a','b'});
                Opts=fitoptions('Method','LinearLeastSquares');
                %                 Opts.Robust='Bisquare';
                Opts.Exclude=Exclude;
                Fit=fit(X,Y,Ft,Opts);
            elseif strcmp(FitType,'poly2')
                Ft=fittype('poly2');
                Opts=fitoptions('Method','LinearLeastSquares');
                Opts.Robust='Bisquare';
                Opts.Exclude=Exclude;
                [Fit,Gof]=fit(X,Y,Ft,Opts);
            elseif strcmp(FitType,'smoothingspline')
                Fit=fit(X,Y,'smoothingspline','Exclude',Exclude,'SmoothingParam',0.001);
            end
            Table.RadiusFit1(Ind)=feval(Fit,X);
            Table.Growth(Ind)=differentiate(Fit,X);
            FitX=(min(X):max(X)).';
            Fit=feval(Fit,FitX);
            if SaveFigure==0
                figure;
                hold on;
                SaveFigure=1;
            end
            if SaveFigure==1
                plot(X,Y);
                plot(FitX,Fit);
            end
        end
    end
    if SaveFigure==1
        saveas(gcf,['\\GNP90N\share\Finn\Analysis\output\Unsorted\PlaqueGrowth\',num2str(Loop.MouseId),'_Roi',num2str(Loop.RoiId),'_Pl',num2str(Loop.Pl),'.png'])
        close Figure 1;
        SaveFigure=0;
    end
    %     if Loop.MouseId==375
    
    %     end
    
    PlaqueData=[Loop.PlaqueData,Table(:,{'Age','RadiusFit1','Growth','TreatmentType','Time2Treatment'})];
    PlaqueData.MouseId(:,1)=Loop.MouseId;
    PlaqueData.Mouse(:,1)=Loop.Mouse;
    PlaqueData.RoiId(:,1)=Loop.RoiId;
    PlaqueData.Pl(:,1)=Loop.Pl;
    Wave1=cell(size(PlaqueData,1),2); Wave1(:,1:size(Loop.Filenames,2))=Loop.Filenames(1:size(Wave1,1),:);
    PlaqueData.Filenames=Wave1;
    PlaqueData.Time(:,1)=(1:size(PlaqueData,1)).';
    
    PlaqueData=PlaqueData(:,{'MouseId','RoiId','Pl','Time','Radius','RadiusFit1','BorderTouch','UmCenter','Age','Growth','TreatmentType','Time2Treatment','Mouse','Filenames'});
    
    PlaqueListSingle=[PlaqueListSingle;PlaqueData];
    
    PlaqueList(end+1,{'MouseId','RoiId','Pl','PlaqueListSingle','Mouse','TreatmentType','StartTreatmentNum'})={Loop.MouseId,Loop.RoiId,Loop.Pl,{PlaqueData},Loop.Mouse,{Loop.TreatmentType},Loop.StartTreatmentNum};
    PlaqueList(end,{'PlBirth'})=DataOut(1,{'PlBirth'});
    % % % %     PlaqueList.Timepoints(size(PlaqueList,1),1:size(DataOut.Timepoints,2))=DataOut.Timepoints;
    % % % %     PlaqueList.PlRadPerWeek(size(PlaqueList,1),1:size(DataOut.Growth,2))=DataOut.Growth;
    % % % %     PlaqueList.PlFitLines(size(PlaqueList,1),1:size(DataOut.FitLines,2))=DataOut.FitLines;
    
end

disp(['finalEvaluation_PlaquesQuantification: ',num2str(round(toc/60)),'min']);
