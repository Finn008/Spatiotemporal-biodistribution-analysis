% Type 0: only GFPM signal
% Type 1: GFPM and VGLUT1 signal
function detectMossyBoutons()
global W;

F=W.G.T.F{W.Task}(W.File,:);
[FctSpec]=variableExtract(F.MossyBoutons{1},{'Step';'Do';'Type'});
FctSpec.Step=0;

ThresholdType='Elena';
Thresholds=table;
Thresholds{'Severin','Everything'}={struct('Smooth',0.1,'Background',3,'LowerManual',5000)};
Thresholds{'Elena','Everything'}={struct('Smooth',0.1,'Background',3,'LowerManual',8000)};
% Thresholds{'Elena','Everything'}={struct('Smooth',0.1,'Background',3,'LowerManual',1000)};
Thresholds{'Severin','Boutons'}={struct('Smooth',0.2,'Background',10,'LowerManual',6000)};
Thresholds{'Elena','Boutons'}={struct('Smooth',0.2,'Background',10,'LowerManual',27000,'SeedsDiameter',4)};
% Thresholds{'Elena','Boutons'}={struct('Smooth',0.2,'Background',10,'LowerManual',6000,'SeedsDiameter',4)};

Thresholds.FirstIn(:,1)=8;
Thresholds.FirstOut(:,1)=20;

%% Step=0; generate data for each file
if FctSpec.Step==0
    FilenameTotal=[F.Filename{1},F.Type{1}];
    [PathRaw,Report]=getPathRaw(FilenameTotal);
    Application=openImaris_2(PathRaw);
    Application.GetDataSet.SetChannelName(0,'GFPMcorr');
    
%     keyboard; % correct GFPM signal to percentile
    J=struct;
    J.FilenameTotal=FilenameTotal;
    J.TargetChannel=1;
    J.DataOutput={'Normalize2Percentile',{'90',10000},[]};
    J.CorrType='InVivoFixed';
    J.Exponent=-0.033;
    [GFPMcorr,~]=depthCorrection_6(J);
    ex2Imaris_2(GFPMcorr,Application,'GFPMcorr');
    clear GFPMcorr;
    
    if FctSpec.Type==1
        
        J=struct;
        J.FilenameTotal=FilenameTotal;
        J.TargetChannel=2;
        J.DataOutput={'Normalize2Percentile',{'99.99',65535},[]};
        J.CorrType='Immuno';
        J.Exponent=-0.020; % previously -0.029;
        [Vglut,~]=depthCorrection_6(J);
        Application.GetDataSet.SetChannelName(1,'VglutCorr');
        ex2Imaris_2(Vglut,Application,'VglutCorr');
    end
    clear VglutCorr;
    
    
    [Fileinfo,FileinfoInd,Path2file]=getFileinfo_2(FilenameTotal,Application);
    % low threshold surface
    J = struct;
    J.Smooth=Thresholds.Everything{ThresholdType}.Smooth;
    J.Application=Application;
    J.SurfaceName='Everything';
    J.Channel='GFPMcorr';
    J.Background=Thresholds.Everything{ThresholdType}.Background;
    J.LowerManual=Thresholds.Everything{ThresholdType}.LowerManual;
    generateSurface3(J);
    
    [Everything]=im2Matlab_3(Application,'Everything',1,'Surface');
    
    % remove islands
    Wave1=imclearborder(1-Everything,18);
    if max(Wave1(:))>0
        Everything=Everything+Wave1;
    end
    
    
    J=struct;
    J.OutCalc=0;
    J.InCalc=1;
    J.ZeroBin=0;
    J.Output={'DistInOut'};
    J.Um=Fileinfo.Um{1};
    J.UmBin=0.1;
    J.DistanceBitType='uint16';
    [Out]=distanceMat_2(J,Everything);
    DistInOut=Out.DistInOut;
    clear Out;
    ex2Imaris_2(DistInOut,Application,'DistInOut');
    
    DistInOut2=DistInOut; DistInOut2(:)=0;
    DistInOut2(DistInOut>=Thresholds.FirstIn(ThresholdType))=1; % rather switch to 6
    
    J=struct;
    J.OutCalc=1;
    J.InCalc=0;
    J.ZeroBin=0;
    J.Output={'DistInOut'};
    J.Um=Fileinfo.Um{1};
    J.UmBin=0.1;
    J.DistanceBitType='uint16';
    [Out]=distanceMat_2(J,DistInOut2);
    DistInOut2=Out.DistInOut;
    clear Out;
    ex2Imaris_2(DistInOut2,Application,'DistInOut2');
    
    
    [BoutonMask]=im2Matlab_3(Application,'GFPMcorr');
    BoutonMask(DistInOut2>=Thresholds.FirstOut(ThresholdType))=0;
    ex2Imaris_2(BoutonMask,Application,'BoutonMask');
    
    
    
    
    J = struct;
    J.Application=Application;
    J.SurfaceName='Boutons1';
    J.Channel='BoutonMask';
    J.Smooth=Thresholds.Boutons{ThresholdType}.Smooth;
    J.Background=Thresholds.Boutons{ThresholdType}.Background;
    J.LowerManual=Thresholds.Boutons{ThresholdType}.LowerManual;
    J.SurfaceInfo=1;
    [~,Statistics1]=generateSurface3(J);
    
    J.SurfaceName='Boutons2';
    J.SeedsDiameter=Thresholds.Boutons{ThresholdType}.SeedsDiameter;
    [~,Statistics2]=generateSurface3(J);
    
    [Boutons]=im2Matlab_3(Application,'Boutons1',1,'Surface');
    ex2Imaris_2(Boutons,Application,'Boutons1');
    
    % keyboard; % export results
    Results=struct;
    Results.Statistics1=Statistics1;
    Results.Statistics2=Statistics2;
    Path=[FilenameTotal,'_Results.mat'];
    Path=getPathRaw(Path);
    save(Path,'Results');
    
    FilenameTotal=[F.Filename{1},'.ims'];
    [PathRaw,Report]=getPathRaw(FilenameTotal);
    Application.FileSave(PathRaw,'writer="Imaris5"');
    
    [Fileinfo,FileinfoInd]=extractFileinfo(FilenameTotal,Application,1);
    clear Application;
    
    Wave1=variableSetter_2(W.G.T.F{W.Task,1}.MossyBoutons{W.File},{'Do','Fin';'Step','1'});
    iFileChanger('W.G.T.F{W.Task,1}.MossyBoutons{W.File}',Wave1);
end

%% Step=1; read out the data
if FctSpec.Step==1
    keyboard; % put everything together
    detectMossyBoutonsSub1(FctSpec);
end

evalin('caller','global W;');