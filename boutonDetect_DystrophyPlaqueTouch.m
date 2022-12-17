function [Dystrophies1,DystrophiesPl]=boutonDetect_DystrophyPlaqueTouch(FilenameTotalRatio,FilenameTotalTrace,Timepoint,FitCoefB2A,FitCoefTrace2B,RotateTrace2A)
FileinfoTrace=getFileinfo_2(FilenameTotalTrace);
FileinfoRatio=getFileinfo_2(FilenameTotalRatio);
% FileinfoDeFin=getFileinfo_2(FilenameTotalDeFin);

% FilenameTotalRatio=FileinfoRatio.FilenameTotal{1};
% FilenameTotalTrace=FileinfoTrace.FilenameTotal{1};
Pix=FileinfoRatio.Pix{1};
Res=FileinfoRatio.Res{1};

if FileinfoRatio.Datenum<FileinfoTrace.Datenum
    if strfind1(FilenameTotalRatio,'b_Ratio.ims')
        DystrophiesName='Dystrophies1';
    elseif strfind1(FilenameTotalRatio,'a_Ratio.ims')
        DystrophiesName='Dystrophies2';
    else
        keyboard;
    end
    [Dystrophies]=im2Matlab_3(FilenameTotalRatio,DystrophiesName);
    
    D2DTrace=struct('FilenameTotal',FilenameTotalTrace,...
        'SourceTimepoint',Timepoint,...
        'TumMinMax',[FileinfoRatio.UmStart{1},FileinfoRatio.UmEnd{1}],...
        'FitCoefs',FitCoefB2A+FitCoefTrace2B,...
        'Tpix',Pix,...
        'Rotate',RotateTrace2A);
    DistInOut=applyDrift2Data_4(D2DTrace,'DistInOut');
    BW=bwconncomp(Dystrophies,6);
    Table=table;
    Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
    Table.IdxList=BW.PixelIdxList.';
    clear BW;
    
    Table.Volume=Table.NumPix*prod(Res(:));
    for m=1:size(Table,1)
        Table.PlaqueTouch(m,1)=min(DistInOut(Table.IdxList{m}));
    end
    Table(Table.PlaqueTouch>50,:)=[];
    
    Dystrophies(Dystrophies>1)=1;
    
    for m=1:size(Table,1)
        Dystrophies(Table.IdxList{m})=2;
    end
    ex2Imaris_2(Dystrophies,FilenameTotalRatio,DystrophiesName);
end
