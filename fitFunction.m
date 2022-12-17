function [Out]=fitFunction(J)
global W;
v2struct(J);
AllPercentiles=NormPercentileProfile.Properties.RowNames;
NormPercentileProfile=double(NormPercentileProfile{1:100,:});

if exist('BaseName')~=1
    BaseName='';
end

%% determine range to be included for fit
if exist('FitMinCenterMax')~=1
    
    if strcmp(CorrType,'InVivo')
        Smooth=table;
        Smooth.Power=1;
        Smooth.Robust={[]}; 
        Smooth=repmat(Smooth,[3,1]);
        
%         Smooth=table; Smooth.Span=[20;20;20]/Zres;
        % get maximum of smoothed data
        [Abl,Out1]=ableitung_2(NormPercentileProfile(:,:).','Value',Smooth);
        UpperMaxPix=Out1.MaximaLocs(1,1,:);UpperMaxPix=permute(UpperMaxPix,[3,1,2]);
        UpperMaxUm=Xaxis(UpperMaxPix)-5;
        BottomMaxUm=repmat(5,[100,1]);
        CenterUm=(UpperMaxUm+BottomMaxUm)/2;
        MinCenterMax=[BottomMaxUm,CenterUm,UpperMaxUm];
        FitMinCenterMax=nanmean(MinCenterMax(20:60,:),1);
        if FitMinCenterMax(1,3)-FitMinCenterMax(1,1)<30
            FitMinCenterMax(1,3)=max(Xaxis)-50;
            FitMinCenterMax(1,2)=(FitMinCenterMax(1,1)+FitMinCenterMax(1,3))/2;
        end
    elseif strcmp(CorrType,'Immuno')
        Smooth=table;
        Smooth.Power=1;
        Smooth.Robust={[]}; 
        Smooth=repmat(Smooth,[3,1]);
        [Abl,Out1]=ableitung_2(NormPercentileProfile(:,:).','Value',Smooth);
        if exist('ImmunoAdjustType')==1 && max(strcmp(ImmunoAdjustType,{'Chengy3';'Chengy4'}))==1
            [~,BottomMaxPix]=max(NormPercentileProfile,[],2);
            BottomMaxUm=Xaxis(BottomMaxPix);
            for m=1:100
                UpperMaxPix(m,1)=max(Out1.MaximaLocs(:,1,m));
            end
            UpperMaxUm=Xaxis(UpperMaxPix);
            CenterUm=(UpperMaxUm+BottomMaxUm)/2;
            MinCenterMax=[BottomMaxUm,CenterUm,UpperMaxUm];
        else
            [~,BottomMaxPix]=max(NormPercentileProfile,[],2);
            BottomMaxUm=Xaxis(BottomMaxPix)+1; % previously +2
            UpperMax=table(nan(100,1),nan(100,1),'VariableNames',{'Pix','Um'});
            for m=1:100
                UpperMax.Pix(m,1)=max(Out1.MaximaLocs(:,1,m));
                try; UpperMax.Um(m,1)=Xaxis(UpperMax.Pix(m,1))-0; end; % previously -1
            end
%             UpperMax.Um=Xaxis(UpperMax.Pix)-0; % previously -1
            CenterUm=(UpperMax.Um+BottomMaxUm)/2;
            MinCenterMax=[BottomMaxUm,CenterUm,UpperMax.Um];
            
        end
        FitMinCenterMax=nanmean(MinCenterMax(20:80,:),1);
        if FitMinCenterMax(1,3)<FitMinCenterMax(1,1)+10
            keyboard;
            FitMinCenterMax=[FitMinCenterMax(1,1),0,Fileinfo.Um{1}(3)-8];
            FitMinCenterMax(1,2)=(FitMinCenterMax(1,3)+FitMinCenterMax(1,1))/2;
        end
    end
    
    %% for all
    
    J=struct;
    J.Path2file=[SavePath,',',BaseName,',Ableitung.avi'];
    J.Tit=strcat({'Percentile: '},AllPercentiles,'%');
    J.Frequency=5;
    J.Y=Abl;
    J.Xres=Zres;
    J.Xlab='depth [µm]';
    J.Ylab='Yaxis';
    try; J.Xrange=ZumRange; end;
    J.Yrange=[-1;1];
    J.Sp={'w.';'r.';'c.'};
%     J.Style=1;
    J.AddLine=[{FitMinCenterMax(1);-1;FitMinCenterMax(1);+1;{'Color','w'}},{FitMinCenterMax(3);-1;FitMinCenterMax(3);+1;{'Color','w'}}];
    movieBuilder_4(J);
end
if exist('FitMinCenterMax')==1
    [Ind]=findClosestValue(Xaxis,FitMinCenterMax.');
    FitMinCenterMaxPix=Ind.';
    ExcludedZpixBins=ones(size(Xaxis,1),1);
    ExcludedZpixBins(FitMinCenterMaxPix(1,1):FitMinCenterMaxPix(1,3))=0;
    CenterXaxis=Xaxis-FitMinCenterMax(1,2);
    [NormPercentileProfile]=normalize2Ind(NormPercentileProfile,[FitMinCenterMaxPix(1,2)-2;FitMinCenterMaxPix(1,2)+2])*100; % normalize to Center
end



%% in vivo Plaque
if strcmp(CorrType,'InVivo')
    % make the fit
    %     Lower=      [0.0,-0.1,000];
    %     Upper=      [0.1,0,200];
    %     Startpoint= [0,0,100];
    % keyboard;
    % readout laser change
    try
        LaserChange=Fileinfo.Results{1}.ZenInfo.Lasers.Transmission;
    catch
        LaserChange=8;
    end
    LaserChange=LaserChange(1,1)/LaserChange(end,1)-1;
    if LaserChange==0
    else
        keyboard;
        LaserChange=LaserChange/(max(Xaxis(:)-min(Xaxis(:))));
    end
    
    
    Lower=      [0.0,000];
    Upper=      [0.1,200];
    Startpoint= [0,100];
    s = fitoptions('Method','NonlinearLeastSquares','Lower',Lower,'Upper',Upper,'Startpoint',Startpoint);
    %     f = fittype('exp(A1*x) * (1+A2*x) * A3','independent','x','options',s);
    %     f = fittype('exp(A1*x) * (1+A2*x) * A3','independent','x','options',s);
    f = fittype('exp(A1*x) * (1+LaserChange*x) * A2','independent','x','options',s,'problem','LaserChange');
    
    for m=1:size(NormPercentileProfile,1)
        Yaxis=NormPercentileProfile(m,:).';
        [Fit,Gof] = fit(CenterXaxis,Yaxis,f,'problem',LaserChange,'Exclude', ExcludedZpixBins==1 | isnan(Yaxis)==1);
        FitCoefTotal(m,:)=coeffvalues(Fit);
        FitGofTotal(m,:)=struct2table(Gof);
        FitOptics(m,:)=YofBinFnc_2(CenterXaxis,[1;FitCoefTotal(m,1)],[],'exp1');
        %         FitLinAdjust(m,:)=1+CenterXaxis*FitCoefTotal(m,2);
    end
    
    
    % select the correct exponent
    Wave1=smooth(FitGofTotal.rsquare); Wave1(1:40)=0; Wave1(85:100)=0;
    [~,ExpPerc]=max(Wave1);
    Exponent=FitCoefTotal(ExpPerc,1);
    Out.Exponent=Exponent;
    % corrected FitOptics
    FitOpticsCorr=YofBinFnc_2(CenterXaxis,[1;Exponent],[],'exp1').';
    FitOpticsCorr=repmat(FitOpticsCorr,[100,1]);
    
    FitLinAdjust=(1+CenterXaxis*LaserChange).';
    FitLinAdjust=repmat(FitLinAdjust,[100,1]);
    FitSignal=repmat(FitCoefTotal(:,2),[1,size(NormPercentileProfile,2)]);
    FitTotal=FitOptics.*FitLinAdjust;
    FitTotalCorr=FitOpticsCorr.*FitLinAdjust;
    LinAdjustCorr=NormPercentileProfile./FitLinAdjust;
    OpticsCorr=NormPercentileProfile./FitOptics;
    CorrOpticsCorr=NormPercentileProfile./FitOpticsCorr;
    TotalCorr=NormPercentileProfile./FitTotal;
    
    %     FitSignal=FitTotal; FitSignal(:)=100;
    
    [NormFitTotal]=normalize2Ind(FitTotalCorr,[FitMinCenterMaxPix(1,3)-2;FitMinCenterMaxPix(1,3)+2]); % normalize to Startpoint
    %     OpticsCorr;;LinAdjustCorr;FitLinAdjust;TotalCorr;FitSignal;NormFitTotal};
    % Out.Sp={'c.';'c-';'m.';'r.';'r-';'w.';'w-';'y.';'y-'};
    OrigYaxis={NormPercentileProfile,'w.';...
        %         FitTotal*100,'c-';... %
        %         FitTotalCorr*100,'m-';... %
        FitOptics*100,'w-';...
        FitOpticsCorr*100,'c-';...
        OpticsCorr,'y.';...
        CorrOpticsCorr,'c.'};
    [J]=movieSettings_2(Xaxis,OrigYaxis,ZumRange,AllPercentiles,FitMinCenterMax);
    J.Path=[SavePath,',',BaseName,',FitTotalProfile.avi'];
    movieBuilder_3(J);
    
    % FitCoefOptics and error
    FitGofTotal.dfe=[];
    J=struct;
    J.Tit='Exponential exponent and error';
    Y=[FitCoefTotal(:,1),FitGofTotal{:,:}];
    for m=1:size(Y,2)
        Y(:,m)=Y(:,m)/max(Y(:,m),[],1);
    end
    J.Y=Y;
    J.Xlab='percentile';
    J.Sp={'c.';'m.';'r.';'w.';'y'};
    J.Layout='black';
    J.Path=[SavePath,',',BaseName,',FitCoefOpticsAndError','.jpg'];
    figureBuilder_2(J);
    
    J=struct;
    J.Tit='Exponential exponent and error';
    J.Y=FitCoefTotal(:,1);
    J.Y2=FitGofTotal.rsquare;
    J.Xlab='Percentile';
    J.Layout='black';
    J.Path=[SavePath,',',BaseName,',FitCoefOptics','.jpg'];
    figureBuilder_2(J);
    
end
%% most recent Immuno fit
if strcmp(CorrType,'Immuno')
    %     LaserChange=0;
    if exist('Exponent')==1
        
        Lower=      [Exponent,0.0,000];
        Upper=      [Exponent+0.00001,0.5,200];
        Startpoint= [Exponent,0.0,000];
    else
        
        Lower=      [0.0,0.0,000];
        Upper=      [0.1,0.5,200];
        Startpoint= [0.1,0.0,000];
    end
    s = fitoptions('Method','NonlinearLeastSquares','Lower',Lower,'Upper',Upper,'Startpoint',Startpoint);
    f = fittype('exp(A1*x) * (0.5*exp(A2*x)+0.5*exp(-A2*x)) * A3','independent','x','options',s);
    for m=1:size(NormPercentileProfile,1)
        Yaxis=NormPercentileProfile(m,:).';
        [Fit,Gof] = fit(CenterXaxis,Yaxis,f,'Exclude', ExcludedZpixBins==1 | isnan(Yaxis)==1);
        FitCoefTotal(m,:)=coeffvalues(Fit);
        FitOptics(m,:)=YofBinFnc_2(CenterXaxis,[1;FitCoefTotal(m,1)],[],'exp1');
        FitAntibody(m,:)=YofBinFnc_2(CenterXaxis,[0.5,FitCoefTotal(m,2),0.5,-FitCoefTotal(m,2)].',[],'exp2');
    end
    
    FitSignal=repmat(FitCoefTotal(:,3),[1,size(NormPercentileProfile,2)]);
    FitTotal=FitOptics.*FitAntibody;
    
    OpticsCorr=NormPercentileProfile./FitAntibody;
    AntibodyCorr=NormPercentileProfile./FitOptics;
    TotalCorr=NormPercentileProfile./FitTotal;
    
    [NormFitTotal]=normalize2Ind(FitTotal,[FitMinCenterMaxPix(1,1)-2;FitMinCenterMaxPix(1,1)+2]); % normalize to Startpoint
    
%     
%     J=struct;
%     J.Path2file=[SavePath,',',BaseName,',FitTotalProfile.avi'];
%     J.Tit=strcat({'Percentile: '},AllPercentiles,'%');
%     J.Frequency=5;
%     J.Y=Abl;
%     J.Xres=Zres;
%     J.Xlab='depth [µm]';
%     J.Ylab='Yaxis';
%     J.OrigYaxis=[...
%         {Histogram},{'w-'};...
%         ];
%     try; J.Xrange=ZumRange; end;
%     J.Yrange=[-1;1];
%     J.Sp={'w.';'r.';'c.'};
% %     J.Style=1;
%     J.AddLine=[{FitMinCenterMax(1);-1;FitMinCenterMax(1);+1;{'Color','w'}},{FitMinCenterMax(3);-1;FitMinCenterMax(3);+1;{'Color','w'}}];
    
    ZumRange=[];
    [J]=movieSettings1(Xaxis,NormPercentileProfile,FitTotal,OpticsCorr,FitOptics,AntibodyCorr,FitAntibody,TotalCorr,FitSignal,NormFitTotal,ZumRange,AllPercentiles,FitMinCenterMax);
    J.Path2file=[SavePath,',',BaseName,',FitTotalProfile.avi'];
    movieBuilder_4(J);
    
    %% correct FitCoefs with fitted version
    CorrectFitCoefs=1;
    if CorrectFitCoefs==1
        [CorrFitCoefAntibody,Exclusion,Outliars]=fitOutliars((1:100).',FitCoefTotal(:,2),'smoothingspline',5,0.1);
        [CorrFitCoefOptics,Exclusion,Outliars]=fitOutliars((1:100).',FitCoefTotal(:,1),'smoothingspline',5,0.1);
        for m=1:size(NormPercentileProfile,1)
            FitOptics(m,:)=YofBinFnc_2(CenterXaxis,[1;CorrFitCoefOptics(m)],[],'exp1');
            FitAntibody(m,:)=YofBinFnc_2(CenterXaxis,[0.5,CorrFitCoefAntibody(m),0.5,-CorrFitCoefAntibody(m)].',[],'exp2');
        end
        FitTotal=FitOptics.*FitAntibody;
        
        [NormFitTotal]=normalize2Ind(FitTotal,[FitMinCenterMaxPix(1,1)-2;FitMinCenterMaxPix(1,1)+2]); % normalize to Startpoint
        % FitCoefOptics
        Path=[SavePath,',',BaseName,',FitCoefOptics','.emf'];
        Yaxis=[FitCoefTotal(:,1),CorrFitCoefOptics];
        figureBuilder(Path,(1:100).',Yaxis,'Percentile [%]','exp',[],[],{'w.';'w-'},'FitCoefOptics','black');
        % FitCoefAntibody
        Path=[SavePath,',',BaseName,',FitCoefAntibody','.emf'];
        Yaxis=[FitCoefTotal(:,2),CorrFitCoefAntibody];
        figureBuilder(Path,(1:100).',Yaxis,'Percentile [%]','exp',[],[],{'w.';'w-'},'FitCoefAntibody','black');
        
        OpticsCorr=NormPercentileProfile./FitAntibody;
        AntibodyCorr=NormPercentileProfile./FitOptics;
        TotalCorr=NormPercentileProfile./FitTotal;
        
        [J]=movieSettings1(Xaxis,NormPercentileProfile,FitTotal,OpticsCorr,FitOptics,AntibodyCorr,FitAntibody,TotalCorr,FitSignal,NormFitTotal,ZumRange,AllPercentiles,FitMinCenterMax);
        J.Path2file=[SavePath,',',BaseName,',CorrFitTotalProfile.avi'];
        movieBuilder_4(J);
    end
    
    % set NormFitTotal outside MinMaxRange to zero
    RemoveOutsideFitRange=0;
    if RemoveOutsideFitRange==1
        NormFitTotal(:,1:FitMinCenterMaxPix(1,1)-1)=65535;
        NormFitTotal(:,FitMinCenterMaxPix(1,3)+1:end)=65535;
    end
    
    % MinCenterMax
    if exist('MinCenterMax')==1
        Path=[SavePath,',',BaseName,',MinCenterMax','.emf'];
        Yaxis=[MinCenterMax,repmat(FitMinCenterMax,[100,1])];
        figureBuilder(Path,(1:100).',Yaxis,'Percentile [%]','Zpix',[],[],{'w.';'r.';'y.';'w-';'r-';'b-'},'MinCenterMax','black');
    end
    
    % FitCoefSignal
    Path=[SavePath,',',BaseName,',FitCoefSignal','.emf'];
    Yaxis=FitCoefTotal(:,3);
    figureBuilder(Path,(1:100).',Yaxis,'Percentile [%]','exp',[],[],{'w.';'w-'},'FitCoefSignal','black');
    
end
%% further
Out.FitTotal=NormFitTotal;
Out.FitMinCenterMax=FitMinCenterMax;
try; DepthInfo.CorrType=CorrType; end;

evalin('caller','global W;');

function [Out]=normalize2Ind(In,Range)
if Range(1,1)<1; Range(1,1)=1; end;
if Range(2,1)>size(In,2); Range(2,1)=size(In,2); end;
for m=1:size(In,1)
    MeanIntensity=nanmean(In(m,Range(1,1):Range(2,1)));
    Out(m,:)=In(m,:)/MeanIntensity;
end


