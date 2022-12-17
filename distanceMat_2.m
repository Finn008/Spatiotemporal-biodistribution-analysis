% uint8: PlaqueMapTotal, plaqueMap, Membership, 3x 1.5GB = 4.5GB
% uint16: stack1, 3GB
% int16: 2x DistInOut, 2x 3GB = 6GB
% total: 13.5GB
% PlaqueMapTotal,UmMinMax,Speci,UmBin
function [Out]=distanceMat_2(In,PlaqueMapTotal)
v2struct(In);
if exist('ZeroBin','var')==0
    ZeroBin=50;
end
if exist('DistanceBitType','var')==0
    DistanceBitType='uint8';
end
if exist('Output')~=1
    Output={'DistInOut';'Membership';'Dist2Border';};
end
if exist('OutCalc')~=1
    OutCalc=0;
end
if exist('InCalc')~=1
    InCalc=0;
end
if ischar(Output)
    Output={Output};
end
cprintf('text','distanceMat_2: ');
%% if imaris file with Surfaces is provided
if exist('PlaqueMapTotal')~=1
    cprintf('text','getPlaqueMap: ');
    VdataSetIn=Application.GetDataSet;
    Timepoints=VdataSetIn.GetSizeT;
    Pix=[VdataSetIn.GetSizeX,VdataSetIn.GetSizeY,VdataSetIn.GetSizeZ];
    PlaqueMapTotal= zeros(Pix(1),Pix(2),Pix(3),Timepoints,'uint8');
    if exist('SuperObject')==1
        J=struct;J.Application=Application;J.Channels=SuperObject;J.Feature='TrackId'; %J.Timepoints=m1;
        [PlaqueMapTotal]=im2Matlab_2(J);
    elseif exist('ObjectList')==1
        for m1=1:Timepoints
            cprintf('text',num2str(m1));
            PlaqueMap2=zeros(Pix(1),Pix(2),Pix(3),'uint8');
            for m=1:size(ObjectList,1)
                J=struct;J.Application=Application;J.Channels=ObjectList(m,1);J.Identity='Surface';J.Timepoints=m1;
                [PlaqueMap]=im2Matlab_2(J);
                PlaqueMap2(PlaqueMap==1)=m;
            end
            PlaqueMapTotal(:,:,:,m1)=PlaqueMap2;
        end
        clear PlaqueMap; clear PlaqueMap2;
    end
end

%% when data table with plaques is provided
if exist('UmBin','var')~=1
    UmBin=1;
end
Pix=[size(PlaqueMapTotal,1);size(PlaqueMapTotal,2);size(PlaqueMapTotal,3)];
if exist('Res')~=1
    Res=Um./Pix;
end
if exist('ResCalc')~=1
    ResCalc=min(Res(:));
end
PixCalc=round(Pix.*Res/ResCalc);

Timepoints=size(PlaqueMapTotal,4);
PlaqueNumber=max(PlaqueMapTotal(:));
Xi=round(linspace(1,Pix(1),PixCalc(1)));
Yi=round(linspace(1,Pix(2),PixCalc(2)));
Zi=round(linspace(1,Pix(3),PixCalc(3)));
Xt=round(linspace(1,PixCalc(1),Pix(1)));
Yt=round(linspace(1,PixCalc(2),Pix(2)));
Zt=round(linspace(1,PixCalc(3),Pix(3)));

Membership=zeros(Pix(1),Pix(2),Pix(3),Timepoints,DistanceBitType);
DistInOut=zeros(Pix(1),Pix(2),Pix(3),Timepoints,DistanceBitType);
cprintf('text','DistanceTransform: ');
for m1=1:Timepoints
    cprintf('text',num2str(m1));
    CurrentStack=PlaqueMapTotal(Xi,Yi,Zi,m1);
    if exist('DilateInOut')==1
        DilateInOut=round(DilateInOut/ResCalc);
        [xx,yy,zz] = ndgrid(-DilateInOut(1):DilateInOut(1));
        Ball= sqrt(xx.^2 + yy.^2 + zz.^2) <= DilateInOut(1);
        CurrentStack=imerode(CurrentStack,Ball);
        % gpuarrayIM2 = imopen(gpuarrayIM,___)
        
        DilateInOut=round(DilateInOut/ResCalc);
        [xx,yy,zz] = ndgrid(-DilateInOut(1):DilateInOut(1));
        Ball= sqrt(xx.^2 + yy.^2 + zz.^2) <= DilateInOut(1);
        CurrentStack=imopen(CurrentStack,Ball);
        
%         CurrentStack=imerode(CurrentStack,Ball);
%         [xx,yy,zz] = ndgrid(-DilateInOut(2):DilateInOut(2));
%         Ball= sqrt(xx.^2 + yy.^2 + zz.^2) <= DilateInOut(2);
%         CurrentStack=imdilate(CurrentStack,Ball);
        
        DistInOut(:,:,:,m1)=cast(CurrentStack(Xt,Yt,Zt),DistanceBitType);
        Output={'DistInOut'};
        clear CurrentStack;
        continue;
    end
    if OutCalc==1
        [Wave1,Wave2]=bwdist(CurrentStack,'quasi-euclidean'); % make distance transform for outside
        DistOut=cast(ceil(Wave1*ResCalc/UmBin),'uint16'); % convert pixel based distance into µm based distance
        clear Wave1;
        Wave2(:)=CurrentStack(Wave2(:));
        Membership(:,:,:,m1)=cast(Wave2(Xt,Yt,Zt),DistanceBitType);
        clear Wave2;
    end
    if InCalc==1 % inside
        Wave1=logical(CurrentStack)==0; % invert so that everything outside plaque is set to 1
        [Wave1]=bwdist(Wave1,'quasi-euclidean'); % make distance transform for inside and store in Stack
        DistIn=cast(ceil(Wave1*ResCalc/UmBin),'uint16');
        clear Wave1;
    end
    
    if OutCalc==1 && InCalc==1
        CurrentStack=DistOut+ZeroBin-(DistIn-UmBin);
    elseif OutCalc==1 && InCalc==0
        CurrentStack=DistOut+ZeroBin;
    elseif OutCalc==0 && InCalc==1
        CurrentStack=DistIn+ZeroBin;
    end
    clear DistOut; clear DistIn;
    DistInOut(:,:,:,m1)=cast(CurrentStack(Xt,Yt,Zt),DistanceBitType);
    clear CurrentStack;
end
if strfind1(Output,'Dist2Border')
    Dist2Border=zeros(PixCalc(1),PixCalc(2),PixCalc(3),DistanceBitType);
    Dist2Border(1,:,:)=1; Dist2Border(end,:,:)=1; Dist2Border(:,1,:)=1; Dist2Border(:,end,:)=1; Dist2Border(:,:,1)=1; Dist2Border(:,:,end)=1;
    Dist2Border=bwdist(Dist2Border,'quasi-euclidean'); % make distance transform for inside and store in Stack
    Dist2Border=(cast((Dist2Border-1)*ResCalc/UmBin,DistanceBitType));
    Dist2Border=Dist2Border(Xt,Yt,Zt,:);
end

Container.PlaqueNumber=PlaqueNumber;
% pack DistInOut,Membership,Dist2Border,Container into Out

Out.Container=Container;
for m=1:size(Output,1)
    Path=['Out.',Output{m,1},'=',Output{m,1},';'];
    eval(Path);
end
if exist('Application','var')==1
    cprintf('text','setPlaqueData: ');
    for m2=1:Timepoints
        cprintf('text',num2str(m2));
        for m=1:size(Output,1)
            J=struct; J.Application=Application; J.TargetChannel=Output{m,1}; J.TargetTimepoint=m2;
            Path=['ex2Imaris_2(',Output{m,1},'(:,:,:,m2),J);'];
            eval(Path);
        end
    end
end
% keyboard;
cprintf('text','\n');
