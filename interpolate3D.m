function [Data,Out]=interpolate3D(Data,Res,ResOut,PixOut)

if isstruct(Res)
    v2struct(Res);
end

if exist('Type')~=1
   Type='';
end

Pix=size(Data).';
if size(Pix,1)==2; Pix(3,1)=1; end;
Pix=Pix(1:3);
if exist('PixOut')~=1 || isempty(PixOut)
    if exist('ResOut')==0 || isempty(ResOut) % use lowest res isotropically
        ResOut=repmat(min(Res(:)),[3,1]);
    end
    PixOut=round(Pix.*Res./ResOut);
end

Xi=round(linspace(1,Pix(1),PixOut(1)));
Yi=round(linspace(1,Pix(2),PixOut(2)));
Zi=round(linspace(1,Pix(3),PixOut(3)));

Xt=round(linspace(1,PixOut(1),Pix(1)));
Yt=round(linspace(1,PixOut(2),Pix(2)));
Zt=round(linspace(1,PixOut(3),Pix(3)));

for m=1:size(Data,4)
    Data2(:,:,:,m)=Data(Xi,Yi,Zi,m);
end
Data=Data2;
clear Data2;

if strfind1(Type,{'Smooth3D';'Gaussian3D'})
    Data=double(Data);
    PixKernel=2.*round((Kernel/ResOut(1)+1)/2)-1; % round to next odd
    if exist('Repeat')~=1
        Repeat=1;
    end
    for m=1:size(Data,4)
        if strfind1(Type,'Gaussian3D')
            for Rep=1:Repeat
                Data(:,:,:,m)=smooth3(Data(:,:,:,m),'gaussian',PixKernel);
            end
        elseif strfind1(Type,'Smooth3D')
            for Rep=1:size(Repeat)
            Data(:,:,:,m)=smooth3(Data(:,:,:,m),'box',PixKernel);
            end
        end

    end
    for m=1:size(Data,4)
        Data2(:,:,:,m)=Data(Xt,Yt,Zt,m);
    end
    Data=Data2;
    clear Data2;
end

Out=struct;
Out.Res=ResOut;
Out.Pix=PixOut;
