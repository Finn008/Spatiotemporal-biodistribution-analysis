function [DistInOut,Membership,Dist2Border]=distanceMat_3(Data3D,Output,Res,UmBin,OutCalc,InCalc,ZeroBin)
keyboard; % remove
% v2struct(In);
if exist('ZeroBin','var')==0
    ZeroBin=50;
end
if exist('DistanceBitType','var')==0
    DistanceBitType='uint8';
end
if exist('OutCalc')~=1
    OutCalc=0;
end
if exist('InCalc')~=1
    InCalc=0;
end
if exist('Output')~=1
    Output={'DistInOut';'Membership';'Dist2Border';};
end
if ischar(Output)
    Output={Output};
end

if exist('UmBin','var')~=1
    UmBin=1;
end
Pix=[size(Data3D,1);size(Data3D,2);size(Data3D,3)];
if exist('Res')~=1
    Res=Um./Pix;
end
if exist('ResCalc')~=1
    ResCalc=min(Res(:));
end
PixCalc=round(Pix.*Res/ResCalc);

Xi=round(linspace(1,Pix(1),PixCalc(1)));
Yi=round(linspace(1,Pix(2),PixCalc(2)));
Zi=round(linspace(1,Pix(3),PixCalc(3)));
Xt=round(linspace(1,PixCalc(1),Pix(1)));
Yt=round(linspace(1,PixCalc(2),Pix(2)));
Zt=round(linspace(1,PixCalc(3),Pix(3)));

Dist2Border=[];
DistInOut=[];
Membership=[];

if strfind1(Output,'DistInOut',1)
    DistInOut=zeros(Pix(1),Pix(2),Pix(3),DistanceBitType);
end
if strfind1(Output,'Membership',1)
    Membership=zeros(Pix(1),Pix(2),Pix(3),DistanceBitType);
end

cprintf('text','DistanceTransform: ');
Data3D=Data3D(Xi,Yi,Zi);
if OutCalc==1
    if isempty(Membership)
        tic;
        Wave1=bwdist(Data3D,'quasi-euclidean');
        toc;
    else
        tic;
        [Wave1,Wave2]=bwdist(Data3D,'quasi-euclidean');
        toc;
    end
    DistOut=cast(ceil(Wave1*ResCalc/UmBin),'uint16'); % convert pixel based distance into µm based distance
    clear Wave1;
    
    if isempty(Membership)==0
        Wave2(:)=Data3D(Wave2(:));
        Membership(:,:,:)=cast(Wave2(Xt,Yt,Zt),DistanceBitType);
        clear Wave2;
    end
end
if InCalc==1 && isempty(DistInOut)==0 % inside
    Wave1=logical(Data3D)==0; % invert so that everything outside plaque is set to 1
    [Wave1]=bwdist(Wave1,'quasi-euclidean'); % make distance transform for inside and store in Stack
    DistIn=cast(ceil(Wave1*ResCalc/UmBin),'uint16');
    clear Wave1;
end

if OutCalc==1 && InCalc==1
    Data3D=DistOut+ZeroBin-(DistIn-UmBin);
elseif OutCalc==1 && InCalc==0
    Data3D=DistOut+ZeroBin;
elseif OutCalc==0 && InCalc==1
    Data3D=DistIn+ZeroBin;
end
clear DistOut; clear DistIn;
DistInOut(:,:,:)=cast(Data3D(Xt,Yt,Zt),DistanceBitType);

if strfind1(Output,'Dist2Border')
    Dist2Border=zeros(PixCalc(1),PixCalc(2),PixCalc(3),DistanceBitType);
    Dist2Border(1,:,:)=1; Dist2Border(end,:,:)=1; Dist2Border(:,1,:)=1; Dist2Border(:,end,:)=1; Dist2Border(:,:,1)=1; Dist2Border(:,:,end)=1;
    Dist2Border=bwdist(Dist2Border,'quasi-euclidean'); % make distance transform for inside and store in Stack
    Dist2Border=(cast((Dist2Border-1)*ResCalc/UmBin,DistanceBitType));
    Dist2Border=Dist2Border(Xt,Yt,Zt,:);
end

cprintf('text','\n');
