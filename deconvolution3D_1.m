function Out=deconvolution3D_1(In)

[Fileinfo,IndFileinfo,~]=getFileinfo_2(NameTable{'Ratio','FilenameTotal'});

Plaque=im2Matlab_2(Application,'Plaque');
Mask=im2Matlab_2(Application,'Surfaces 3 Selection',[],'Surface');

% Data=Plaque.*Mask;

% find border
Wave1=sum(Mask,2);
Wave2=sum(Wave1,3);
[First,Last]=firstLastNonzero_3(Wave2);
PixMinMax(1,1:2)=[First,Last];
Wave2=permute(sum(Wave1,1),[3,2,1]);
[First,Last]=firstLastNonzero_3(Wave2);
PixMinMax(3,1:2)=[First,Last];
Wave2=permute(sum(sum(Mask,1),3),[2,1]);
[First,Last]=firstLastNonzero_3(Wave2);
PixMinMax(2,1:2)=[First,Last];

% cut that part out
Data=Mask(PixMinMax(1,1):PixMinMax(1,2),PixMinMax(2,1):PixMinMax(2,2),PixMinMax(3,1):PixMinMax(3,2));

Res=Fileinfo.Res{1};
Pix=size(Data).';

IntensityProfile=permute(sum(sum(Data,1),2),[3,2,1]);
IntensityProfile=smooth(IntensityProfile);
[Wave1,Wave2]=sort(IntensityProfile);
MaxIntensity=round(mean(Wave2(end-4:end)));

XYmaxProjection=max(Data,[],3);
XYArea=sum(XYmaxProjection(:));
XYRadius=(XYArea/pi)^0.5*Res(1);
ZfinalPix=round(XYRadius/Res(3));

Zup=linspace(MaxIntensity,Pix(3),Pix(3)-MaxIntensity+1).';
Zup(:,2)=round(linspace(MaxIntensity,MaxIntensity+ZfinalPix,Pix(3)-MaxIntensity+1).');
Zdown=linspace(1,MaxIntensity-1,MaxIntensity-1).';
Zdown(:,2)=round(linspace(MaxIntensity-ZfinalPix,MaxIntensity-1,MaxIntensity-1).');
Zt=[Zdown;Zup];

Data2=zeros(Pix(:).','uint8');
Data2(:,:,Zt(:,2))=Data(:,:,Zt(:,1));

Mask(PixMinMax(1,1):PixMinMax(1,2),PixMinMax(2,1):PixMinMax(2,2),PixMinMax(3,1):PixMinMax(3,2))=Data2;

ex2Imaris_2(Mask,Application,'Mask');


% % % % 
% % % % Zup=(MaxIntensity:Pix(3)).';
% % % % Zup(:2)=(MaxIntensity:Pix(3)).';
% % % % 
% % % % Zup=round(linspace(1,PixCalc(3),Pix(3)-MaxIntensity));
% % % % 
% % % % 
% % % % Xt=round(linspace(1,PixCalc(1),Pix(1)));
% % % % Yt=round(linspace(1,PixCalc(2),Pix(2)));
% % % % 
% % % % 
% % % % 
% % % % DistInOut(:,:,:,m1)=cast(CurrentStack(Xt,Yt,Zt),DistanceBitType);
% % % % 
% % % % 
% % % % 
% % % % 
% % % % 
% % % % 
% % % % 
% % % % 
% % % % 
% % % % 
% % % % 
% % % % % Data3=false(PixCalc(:).'); Data3(Data2>=1)=1;
% % % % XYmaxProjection=max(Data3,[],3);
% % % % ZYmaxProjection=max(Data3,[],2);
% % % % ZXmaxProjection=max(Data3,[],1);
% % % % Area=[sum(XYmaxProjection(:));(sum(ZYmaxProjection(:))+sum(ZXmaxProjection(:)))/2];
% % % % Area=Area/Area(1);
% % % % 
% % % % 
% % % % 
% % % % 
% % % % 
% % % % 
% % % % ResCalc=min(Res(:));
% % % % PixCalc=round(Pix.*Res/ResCalc);
% % % % 
% % % % Xi=round(linspace(1,Pix(1),PixCalc(1)));
% % % % Yi=round(linspace(1,Pix(2),PixCalc(2)));
% % % % Zi=round(linspace(1,Pix(3),PixCalc(3)));
% % % % 
% % % % 
% % % % 
% % % % Data2=cast(Data(Xi,Yi,Zi),'double');
% % % % 
% % % % for m=1:1000
% % % %     % measure elongation
% % % %     
% % % %     
% % % % end
% % % % 
% % % % 
% % % % 
% % % % % I = checkerboard(8);
% % % % PSF = fspecial('gaussian',7,10);
% % % % % V = .0001;
% % % % % BlurredNoisy = imnoise(imfilter(I,PSF),'gaussian',0,V);
% % % % 
% % % % % Create a weight array to specify which pixels are included in processing.
% % % % 
% % % % % WT = zeros(Pix.');
% % % % % WT(5:end-4,5:end-4) = 1;
% % % % INITPSF = ones(size(PSF));
% % % % 
% % % % % Perform blind deconvolution.
% % % % 
% % % % [J P] = deconvblind(Data2,INITPSF,1);
% % % % 
% % % % 
% % % % 
% % % % Data4=deconvblind
% % % % 
% % % % 
% % % % 
% % % % ex2Imaris(Data,Application,'Data');