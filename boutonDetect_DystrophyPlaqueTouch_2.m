function [Dystrophies1,DystrophiesPl]=boutonDetect_DystrophyPlaqueTouch_2(DistInOut,Dystrophies1,Timepoint,FileinfoTrace,FileinfoRatio,Rotate)
keyboard; % delete
% FilenameTotalRatio=FileinfoRatio.FilenameTotal{1};
% FilenameTotalTrace=FileinfoTrace.FilenameTotal{1};
Pix=FileinfoRatio.Pix{1};
Res=FileinfoRatio.Res{1};

if FileinfoRatio.Datenum<FileinfoTrace.Datenum
    
    [Dystrophies]=im2Matlab_3(FilenameTotalRatio,'Dystrophies2');
    
    D2DTrace=struct('FilenameTotal',FilenameTotalTrace,...
        'SourceTimepoint',Timepoint,...
        'TumMinMax',[FileinfoDeFin.UmStart{1},FileinfoDeFin.UmEnd{1}],...
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
    ex2Imaris_2(Dystrophies,FilenameTotalRatio,'Dystrophies2');
end


DystrophiesPl=Dystrophies1==2;
    Dystrophies1=Dystrophies1>0;