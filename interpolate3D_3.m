function [Data,ResOut,PixOut]=interpolate3D_3(Data,PixOut,Res,ResOut,Function,TilingSettings)

if exist('TilingSettings','Var')==1 && isempty(Tiling)==0
    keyboard;
    CalcSettings=struct('PixOut',PixOut,'ResOut',ResOut,'Function',Function);
    Wave1={'Res','Tiling','Overlap';ResCalc,10^9,10}; Wave1=array2table(Wave1(2:end,:),'VariableNames',Wave1(1,:));
    keyboard; % account for that OutputStack has les voxels than InputStack though processing at maximal resolution
    PlaqueLocalPrc=tiledProcessing_2(Data,[],Res,Wave1,'interpolate3D_3',CalcSettings);
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
if exist('Function','Var')~=1
    Function='sparse';
end

% Xt=round(linspace(1,PixOut(1),Pix(1)));
% Yt=round(linspace(1,PixOut(2),Pix(2)));
% Zt=round(linspace(1,PixOut(3),Pix(3)));
if size(PixOut,1)==2; PixOut(3,1)=1; end;
if strcmp(Function,'sparse')
    Xi=round(linspace(1,Pix(1),PixOut(1)));
    Yi=round(linspace(1,Pix(2),PixOut(2)));
    Zi=round(linspace(1,Pix(3),PixOut(3)));

    for m=1:size(Data,4)
        Data2(:,:,:,m)=Data(Xi,Yi,Zi,m);
    end
    Data=Data2;
    clear Data2;
else
    PixCalc=min([Pix,PixOut],[],2); % if one dimension is extrapolated
%     Wave1=zeros(PixOut.','double');
    Wave1=zeros(PixCalc.','double');
    Wave1(:)=(1:prod(PixCalc));
    
    X=uint16(linspace(1,PixCalc(1),Pix(1)));
    Y=uint16(linspace(1,PixCalc(2),Pix(2)));
    Z=uint16(linspace(1,PixCalc(3),Pix(3)));
%     Wave2(:,:,:)=Wave1(Xt,Yt,Zt);
%     Wave2(:,:,:)=Wave1(Xi,Yi,Zi);
    Wave2=Wave1(X,Y,Z);
    Wave3=accumarray_9(Wave2,Data,Function);
    Wave1(Wave3.Roi1)=Wave3.Value1;
    
%     X=uint16(linspace(1,PixCalc(1),Pix(1)));
%     Y=uint16(linspace(1,PixCalc(2),Pix(2)));
%     Z=uint16(linspace(1,PixCalc(3),Pix(3)));
    X=uint16(linspace(1,PixCalc(1),PixOut(1)));
    Y=uint16(linspace(1,PixCalc(2),PixOut(2)));
    Z=uint16(linspace(1,PixCalc(3),PixOut(3)));
    Data=cast(Wave1(X,Y,Z),class(Data));
    
%     Data=cast(Wave1,class(Data));
end

% Wave3.Test=(1:size(Wave3,1)).';
% Wave3.Test2=Wave3.Test-Wave3.Roi1;
% A1=find(Wave3.Test2~=0,1), 16777217
% max(Wave1(:))       61865984
% prod(PixOut)        61865984
% unique(Wave1(:))    61865984

