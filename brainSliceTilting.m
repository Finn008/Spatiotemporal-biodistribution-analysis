function [Data3D]=brainSliceTilting(Data3D,XYZpix,Res,FitType)

Pix=size(Data3D).';

if strcmp(FitType,'Plane')
    Ft = fittype( 'poly11' );
    Opts = fitoptions( 'Method', 'LinearLeastSquares' );
    Opts.Robust = 'Bisquare';
    [Fit,Gof]=fit([XYZpix(:,1),XYZpix(:,2)],XYZpix(:,3),Ft,Opts );
    SpotNumber=[];
elseif strcmp(FitType,'Loess')
    Ft = fittype( 'loess' );
    Opts = fitoptions( 'Method', 'LowessFit' );
    Opts.Normalize = 'on';
    Opts.Robust = 'LAR';
    Opts.Span = 1;
    [Fit,Gof]=fit([XYZpix(:,1),XYZpix(:,2)],XYZpix(:,3),Ft,Opts );
    SpotNumber=50000;
    
else
    keyboard;
end

DiffNumbersInside=unique(round(Fit(XYZpix(:,1:2))));

[Area]=feval_Area(Fit,Pix,SpotNumber);
Diff=reshape(uint16(Area),[prod(Pix(1:2)),1]);

Data3D=reshape(Data3D(:),[Pix(1)*Pix(2),Pix(3)]);
Change=table;
Change.DiffNumbers=double(unique(Diff));
RotationPoint=round(mean(DiffNumbersInside));
Change.Cut=RotationPoint-Change.DiffNumbers+1;
Change.Cut(:,2)=RotationPoint-Change.DiffNumbers+Pix(3);

Change.Leapover=-Change.Cut(:,1)+1; Change.Leapover(Change.Cut(:,1)>0)=0;
Wave1=Change.Cut(:,2)-Pix(3); Wave1(Change.Cut(:,2)<=Pix(3))=0;
Change.Leapover(:,2)=Wave1;

Change.Paste=Change.Leapover(:,1)+1;
Change.Paste(:,2)=Pix(3)-Change.Leapover(:,2);

Change.Cut(:,1)=Change.Cut(:,1)+Change.Leapover(:,1);
Change.Cut(:,2)=Change.Cut(:,2)-Change.Leapover(:,2);

Change.Cut(:,3)=Change.Cut(:,2)-Change.Cut(:,1)+1;
Change.Paste(:,3)=Change.Paste(:,2)-Change.Paste(:,1)+1;

for DiffNu=1:size(Change,1)
    Wave1=Data3D(Diff==Change.DiffNumbers(DiffNu),:);
    Wave2=zeros(size(Wave1),'uint16');
    Wave2(:,Change.Paste(DiffNu,1):Change.Paste(DiffNu,2))=Wave1(:,Change.Cut(DiffNu,1):Change.Cut(DiffNu,2));
    Data3D(Diff==Change.DiffNumbers(DiffNu),:)=Wave2;
end

Data3D=reshape(Data3D(:),[Pix(1),Pix(2),Pix(3)]);


