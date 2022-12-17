function plaqueCorrection_Environment(PlaqueData,FilenameTotal,PlaqueMapTotal)
% quadrants =1; lateral to plaque =2; above plaque =3; below plaque =4; Outside =+10?
global W;
cprintf('text','Allocating 3D data:');
Fileinfo=getFileinfo_2(FilenameTotal);
Res=Fileinfo.Res{1};
Pix=Fileinfo.Pix{1};
Timepoints=Fileinfo.GetSizeT;
PlaqueNumber=size(PlaqueData,1);

% determine positions of ghost plaques
[Xcenter,Ycenter,Zcenter]=deal(nan(Timepoints,PlaqueNumber));
for Pl=1:PlaqueNumber
    for Time=1:size(PlaqueData.Data{Pl,1},1)
        try
            Xcenter(Time,Pl)=PlaqueData.Data{Pl,1}.UmCenter{Time,1}(1);
            Ycenter(Time,Pl)=PlaqueData.Data{Pl,1}.UmCenter{Time,1}(2);
            Zcenter(Time,Pl)=PlaqueData.Data{Pl,1}.UmCenter{Time,1}(3);
        end
    end
end
[Out1]=calcDrift_2({Xcenter;Ycenter;Zcenter},[Fileinfo.UmStart{1},Fileinfo.UmEnd{1}],Fileinfo.Pix{1});
for Time=1:Timepoints
    cprintf('text',[' ',num2str(Time),',']);
    
    NewSize=Pix;
    NewSize(1:3,1)=NewSize(1:3,1)+sum(Out1.AddPix,2);
    CutPaste=[Out1.AddPix(:,1)+1,Fileinfo.Pix{1}+Out1.AddPix(:,1)];
    
    PlaqueMap=zeros(NewSize.','uint8');
    PlaqueMap(CutPaste(1,1):CutPaste(1,2),CutPaste(2,1):CutPaste(2,2),CutPaste(3,1):CutPaste(3,2))=PlaqueMapTotal(:,:,:,Time);
    ErrorMessage='';
    for Pl=1:size(Out1.PixArrayEnlarge{1},2)
        PixCenter=[Out1.PixArrayEnlarge{1}(Time,Pl);Out1.PixArrayEnlarge{2}(Time,Pl);Out1.PixArrayEnlarge{3}(Time,Pl)];
        Wave1=PlaqueMap(PixCenter(1),PixCenter(2),PixCenter(3));
        if Wave1==0
            PlaqueMap(PixCenter(1),PixCenter(2),PixCenter(3))=Pl;
        elseif Wave1==Pl
            
        else
            Path=['Tp',num2str(Time),'Pl',num2str(Pl),'/',num2str(Wave1),', '];
            ErrorMessage=[ErrorMessage,Path];
        end
    end
    if strcmp(ErrorMessage,'')==0
        W.ErrorMessage=ErrorMessage;
        keyboard;
    end
    
    
    J=struct;
    J.InCalc=1;
    J.OutCalc=1;
    J.ZeroBin=50;
    J.Output={'Membership';'DistInOut'};
    J.Res=Fileinfo.Res{1}; % donot use J.Um=Fileinfo.Um{1};
    [Out]=distanceMat_2(J,PlaqueMap(:,:,:));
    Membership=Out.Membership;
    DistInOut=Out.DistInOut;
    clear Out;
    
    % determine Plaque Relationship, 1 for everything else, 2 besides plaque, 3 above plaque, 4 below Plaque
    Relationship=uint8(logical(Membership));
    LateralThickness=8;LateralThickness=round(LateralThickness/Res(3));
    
    for Pl=1:PlaqueNumber
        SubChunk=logical(PlaqueMap(:,:,:)); SubChunk(Membership~=Pl)=0; SubChunk=logical(SubChunk);% inside plaque set to 1
        PlaqueMaxProjection=max(SubChunk,[],3);
        MaxSlice=permute(sumdims(SubChunk,[1;2]),[3,2,1]);
        MaxSlice=round(mean(find(MaxSlice==max(MaxSlice(:)))));
        
        % below plaque =4
        Upper=MaxSlice-floor(LateralThickness/2);
        Lower=MaxSlice-round(30/Res(3));
        if Lower<1; Lower=1; end;
        if Upper>0
            SubChunk=repmat(PlaqueMaxProjection,[1,1,Upper-Lower+1]);
            SubChunk2=Relationship(:,:,Lower:Upper);
            SubChunk2(SubChunk==1&Membership(:,:,Lower:Upper)~=0)=4;
            Relationship(:,:,Lower:Upper)=SubChunk2;
        end
        % above plaque =3
        Upper=Pix(3);
        Lower=MaxSlice;
        SubChunk=repmat(PlaqueMaxProjection,[1,1,Upper-Lower+1]);
        SubChunk2=Relationship(:,:,Lower:Upper);
        SubChunk2(SubChunk==1&Membership(:,:,Lower:Upper)==Pl&Relationship(:,:,Lower:Upper)~=4)=3;
        Relationship(:,:,Lower:Upper)=SubChunk2;
        
        % lateral to plaque=2
        Lower=MaxSlice-floor(LateralThickness/2)+1;
        Upper=Lower+LateralThickness-1;
        if Lower<1; Lower=1; end;
        if Upper>Pix(3); Upper=Pix(3); end;
        SubChunk=Relationship(:,:,Lower:Upper);
        SubChunk(Membership(:,:,Lower:Upper)==Pl&Relationship(:,:,Lower:Upper)~=4)=2;
        Relationship(:,:,Lower:Upper)=SubChunk;
        
        % plaque itself
        %         Relationship(Membership==m & DistInOut<=50)=Relationship(Membership==m & DistInOut<=50)+2;
    end
    
    DistInOut=DistInOut(CutPaste(1,1):CutPaste(1,2),CutPaste(2,1):CutPaste(2,2),CutPaste(3,1):CutPaste(3,2));
    Membership=Membership(CutPaste(1,1):CutPaste(1,2),CutPaste(2,1):CutPaste(2,2),CutPaste(3,1):CutPaste(3,2));
    Relationship=Relationship(CutPaste(1,1):CutPaste(1,2),CutPaste(2,1):CutPaste(2,2),CutPaste(3,1):CutPaste(3,2));
    
    % from Membership remove parts outside placed chunk
    [MetBlue]=im2Matlab_3(FilenameTotal,'MetBlue',Time);
    MetBlue=logical(MetBlue);
    Membership=Membership.*uint8(MetBlue);
    clear MetBlue;
    ex2Imaris_2(Relationship,FilenameTotal,'Relationship',Time);
    clear Relationship;
    ex2Imaris_2(DistInOut,FilenameTotal,'DistInOut',Time);
    clear DistInOut;
    ex2Imaris_2(Membership,FilenameTotal,'Membership',Time);
    clear Membership;
end

PathRaw=getPathRaw(FilenameTotal);
Application=openImaris_2(PathRaw);
imarisSaveHDFlock(Application,PathRaw);

cprintf('text',[' Clock: ',datestr(datenum(now),'mmm.dd HH:MM'),'\n']);