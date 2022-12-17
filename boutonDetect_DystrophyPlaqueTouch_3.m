function [Dystrophies1,DystrophiesPl]=boutonDetect_DystrophyPlaqueTouch_3(FilenameTotalRatio,FilenameTotalTrace,Timepoint,D2DRatio)

FileinfoTrace=getFileinfo_2(FilenameTotalTrace);
FileinfoRatio=getFileinfo_2(FilenameTotalRatio);
% FileinfoDeFin=getFileinfo_2(FilenameTotalDeFin);

% FilenameTotalRatio=FileinfoRatio.FilenameTotal{1};
% FilenameTotalTrace=FileinfoTrace.FilenameTotal{1};
Pix=FileinfoRatio.Pix{1};
Res=FileinfoRatio.Res{1};

if strfind1(FilenameTotalRatio,'b_Ratio.ims')
    DystrophiesName='Dystrophies1';
    FitCoefs=zeros(3,3);
elseif strfind1(FilenameTotalRatio,'a_Ratio.ims')
    keyboard;
    DystrophiesName='Dystrophies2';
    FitCoefs=FitCoefB2A+FitCoefTrace2B;
else
    keyboard;
end

[Dystrophies]=im2Matlab_3(FilenameTotalRatio,DystrophiesName);

if FileinfoRatio.Datenum<FileinfoTrace.Datenum
    
    D2DTrace=struct('FilenameTotal',FilenameTotalTrace,...
        'SourceTimepoint',Timepoint,...
        'TumMinMax',[FileinfoRatio.UmStart{1},FileinfoRatio.UmEnd{1}],...
        'FitCoefs',FitCoefs,...
        'Tpix',Pix,...
        'Rotate',D2DRatio.Rotate);
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

DystrophiesPl=Dystrophies==2;
Dystrophies1=Dystrophies>0;
