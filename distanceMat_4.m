function [DistInOut,Membership,Dist2Border]=distanceMat_4(Data3D,Output,Res,UmBin,OutCalc,InCalc,ZeroBin,DistanceBitType,ResCalc,Dimensionality,TilingSettings)

if exist('ZeroBin','var')==0; ZeroBin=50; end;
if exist('DistanceBitType','var')==0; DistanceBitType='uint8'; end;
if exist('OutCalc')~=1; OutCalc=0; end;
if exist('InCalc')~=1; InCalc=0; end;
if exist('Output')~=1; Output={'DistInOut';'Membership';'Dist2Border'}; end;

if exist('TilingSettings','Var')==1
    CalcSettings=struct('Output',Output,'UmBin',UmBin,'OutCalc',OutCalc,'InCalc',InCalc,'ZeroBin',ZeroBin,'DistanceBitType',DistanceBitType,'ResCalc',ResCalc,'Dimensionality',Dimensionality);
    [DistInOut]=tiledProcessing_2(Data3D,[],Res,TilingSettings,mfilename(),CalcSettings);
    DistInOut=DistInOut{1};
    Membership=[];
    Dist2Border=[];
    return;
%     DataOut=tiledProcessing_2(Data3D,Outside,Res,ResLevels,Calculation,CS) % CS for CalcSettings
end

if ischar(Output)
    Output={Output};
end

if exist('UmBin')~=1 || isempty(UmBin)
    UmBin=1;
end
if max(Data3D(:))>65535; keyboard; end;
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

if exist('Dimensionality','Var')==0 || isempty(Dimensionality)
    Dimensionality='3D';
end
% if strfind1(Output,'Membership',1)
% end

% % % cprintf('text','DistanceTransform: ');
Data3D=Data3D(Xi,Yi,Zi);
if OutCalc==1
    if strcmp(Dimensionality,'3D')
        if strfind1(Output,'DistInOut',1) && strfind1(Output,'Membership',1)
            [DistInOut,Membership]=bwdist(Data3D,'quasi-euclidean');
        elseif strfind1(Output,'DistInOut',1)
            [DistInOut]=bwdist(Data3D,'quasi-euclidean');
        elseif strfind1(Output,'Membership',1)
            keyboard; % check if Membership is working correctly
            [~,Membership]=bwdist(Data3D,'quasi-euclidean');
        end
    elseif strcmp(Dimensionality,'XY')
        for m=1:size(Data3D,3)
            DistInOut(:,:,m)=bwdist(Data3D(:,:,m),'quasi-euclidean');
        end
    end
    
    if strfind1(Output,'DistInOut',1)
        DistInOut=cast(ceil(DistInOut(Xt,Yt,Zt)*ResCalc/UmBin),DistanceBitType); % convert pixel based distance into µm based distance
    end
    if strfind1(Output,'Membership',1)
        Membership(:)=Data3D(Membership(:));
        Membership=cast(Membership(Xt,Yt,Zt),DistanceBitType);
    end
end
if InCalc==1 && strfind1(Output,'DistInOut',1) % inside
    Data3D=logical(Data3D)==0; % invert so that everything outside plaque is set to 1
    [DistIn]=bwdist(Data3D,'quasi-euclidean'); % make distance transform for inside and store in Stack
    DistIn=cast(ceil(DistIn(Xt,Yt,Zt)*ResCalc/UmBin),DistanceBitType);
end
clear Data3D;
if strfind1(Output,'DistInOut',1)
    if OutCalc==1 && InCalc==1
        DistInOut=DistInOut+ZeroBin-(DistIn-UmBin);
    elseif OutCalc==1 && InCalc==0
        DistInOut=DistInOut+ZeroBin;
    elseif OutCalc==0 && InCalc==1
        DistInOut=DistIn+ZeroBin;
    end
    clear DistIn;
end
if strfind1(Output,'Dist2Border')
    Dist2Border=zeros(PixCalc(1),PixCalc(2),PixCalc(3),DistanceBitType);
    Dist2Border(1,:,:)=1; Dist2Border(end,:,:)=1; Dist2Border(:,1,:)=1; Dist2Border(:,end,:)=1; Dist2Border(:,:,1)=1; Dist2Border(:,:,end)=1;
    Dist2Border=bwdist(Dist2Border,'quasi-euclidean'); % make distance transform for inside and store in Stack
    Dist2Border=(cast((Dist2Border-1)*ResCalc/UmBin,DistanceBitType));
    Dist2Border=Dist2Border(Xt,Yt,Zt,:);
end
% % % cprintf('text','\n');
