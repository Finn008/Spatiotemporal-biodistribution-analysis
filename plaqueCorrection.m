function [PlaqueData]=plaqueCorrection(II)
global W;

v2struct(II);

[Fileinfo,Ind,PathRaw]=getFileinfo_2(FilenameTotal);
Res=Fileinfo.Res{1};
UmStart=Fileinfo.UmStart{1};
%% get PlaqueMapTotal
Application=openImaris_2(PathRaw);
[Vobject,A2,PlaqueList]=selectObject(Application,'Plaques');
if isempty(Vobject)
    quitImaris(Application);
    A1=asdf;
end
[Results]=getObjectInfo_2(Vobject,[],Application,1);


J=struct;J.Application=Application;J.Channels='Plaques';J.Feature='TrackId'; J.ObjectInfo=Results;
[OrigPlaqueMapTotal]=im2Matlab_3(J);
if exist('Zcutoff')~=1; Zcutoff=0; end;
if isequal(Zcutoff,0)==0
    Zcutoff=round(Zcutoff-UmStart(3)./Res(3));
    for Time=1:Fileinfo.GetSizeT
        OrigPlaqueMapTotal(:,:,1:Zcutoff(Time),Time)=0;
    end
end

for Time=1:Fileinfo.GetSizeT
    MetBlue=im2Matlab_3(FilenameTotal,'MetBlue',Time);
    if isequal(Zcutoff,0)==0
        MetBlue(:,:,1:Zcutoff(Time))=0;
        ex2Imaris_2(MetBlue,FilenameTotal,'MetBlue',Time);
    end
    [Table]=intensityWeightedCenterOfMass(OrigPlaqueMapTotal(:,:,:,Time),MetBlue);
    CenterPix(Table.Region,1:3,Time)=Table.CenterOfIntensityMass;
end
clear MetBlue;
CenterPix(CenterPix==0)=NaN;
Xcenter=permute(CenterPix(:,1,:),[3,1,2])*Res(1)+UmStart(1);
Ycenter=permute(CenterPix(:,2,:),[3,1,2])*Res(2)+UmStart(2);
Zcenter=permute(CenterPix(:,3,:),[3,1,2])*Res(3)+UmStart(3);

[PlaqueLocation]=calcDrift_2({Xcenter;Ycenter;Zcenter},[Fileinfo.UmStart{1},Fileinfo.UmEnd{1}],Fileinfo.Pix{1});
PlaqueNumber=size(PlaqueLocation.PixArrayEnlarge{1},2);

NewSize=size(OrigPlaqueMapTotal).';
NewSize(1:3,1)=NewSize(1:3,1)+sum(PlaqueLocation.AddPix,2);
CutPaste=[PlaqueLocation.AddPix(:,1)+1,Fileinfo.Pix{1}+PlaqueLocation.AddPix(:,1)];

PlaqueMapTotal=zeros(NewSize.','uint8');
PlaqueMapTotal(CutPaste(1,1):CutPaste(1,2),CutPaste(2,1):CutPaste(2,2),CutPaste(3,1):CutPaste(3,2),:)=OrigPlaqueMapTotal;
clear OrigPlaqueMapTotal;

%% check if there are some mistakes in plaque tracking
Presence=table;
ErrorMessage='';
for Time=1:Fileinfo.GetSizeT
    for Pl=1:PlaqueNumber
        Presence.Time(size(Presence,1)+1,1)=Time;
        Presence.Pl(size(Presence,1),1)=Pl;
        PixCenter=[PlaqueLocation.PixArrayEnlarge{1}(Time,Pl);PlaqueLocation.PixArrayEnlarge{2}(Time,Pl);PlaqueLocation.PixArrayEnlarge{3}(Time,Pl)];
        Wave1=PlaqueMapTotal(PixCenter(1),PixCenter(2),PixCenter(3),Time);
        PlaqueMapTotal(PixCenter(1),PixCenter(2),PixCenter(3),Time)=Pl;
        if isnan(Results.IDmap(Pl,Time))
            Presence.Status(size(Presence,1),1)=0;
%             PlaqueMapTotal(PixCenter(1),PixCenter(2),PixCenter(3),Time)=Pl;
        else
            Presence.Status(size(Presence,1),1)=1;
        end
        
        if Wave1~=0 && Wave1~=Pl
            Path=['Tp',num2str(Time),'Pl',num2str(Pl),'/',num2str(Wave1),', '];
            ErrorMessage=[ErrorMessage,Path];
            Presence.Status(size(Presence,1),1)=3;
        end
    end
end
if strcmp(ErrorMessage,'')==0
    W.ErrorMessage=ErrorMessage;
    quitImaris(Application);
    A1=asdf;
end

quitImaris(Application);
clear Application;

%% add value 1 to MetBlue if not done before
if exist('MetBluePlus1') && MetBluePlus1==1
    for Time=1:Fileinfo.GetSizeT
        [Data3D]=im2Matlab_3(FilenameTotal,1,Time);
        Overhang=10;
        Wave1=false(size(Data3D)+2*Overhang);
        Wave1(Overhang+1:end-Overhang,Overhang+1:end-Overhang,Overhang+1:end-Overhang)=logical(Data3D);
        
        Window=ones(2*Overhang+1,2*Overhang+1,2*Overhang+1);
        Wave1=imdilate(Wave1,Window);
        Wave1=imerode(Wave1,Window);
        Wave1=Wave1(Overhang+1:end-Overhang,Overhang+1:end-Overhang,Overhang+1:end-Overhang);
        ex2Imaris_2(Data3D+uint8(Wave1),FilenameTotal,'MetBlue',Time);
    end
    clear Wave1; clear Data3D;
end

%% place missing plaques
if exist('Version')==1 && strcmp(Version,'MissingPlaques')
    cprintf('text','Placing data to timepoints: ');
    for Time=1:Fileinfo.GetSizeT
        cprintf('text',[num2str(Time),',']);
        J=struct;
        J.InCalc=0;
        J.OutCalc=1;
        J.ZeroBin=0; % J.ZeroBin=1;
        J.Output={'Membership';'DistInOut'};
        J.Res=Fileinfo.Res{1};
        [Out]=distanceMat_2(J,PlaqueMapTotal(:,:,:,Time));
        MissingPlaques=Out.DistInOut<=15;
        for Pl=find(isnan(Results.IDmap(:,Time))==0).'
            MissingPlaques(Out.Membership==Pl)=0;
        end
        
        MissingPlaques=MissingPlaques(CutPaste(1,1):CutPaste(1,2),CutPaste(2,1):CutPaste(2,2),CutPaste(3,1):CutPaste(3,2));
        MetBlue=im2Matlab_3(FilenameTotal,'MetBlue',Time);
        MetBluePerc=im2Matlab_3(FilenameTotal,'MetBluePerc',Time);
        
        MetBluePerc=MetBluePerc>90;
        Wave1=imopen(MetBluePerc,ones(3,3,3));
        MetBluePerc=MetBluePerc.*Wave1;
        
        MissingPlaques=uint8(MissingPlaques).*MetBlue.*uint8(MetBluePerc);
        ex2Imaris_2(MissingPlaques,FilenameTotal,'MissingPlaque',Time);
        clear MetBlue;
        
    end
    cprintf('text',[' Clock: ',datestr(datenum(now),'mmm.dd HH:MM'),'\n']);
    
    
    Application=openImaris_2(PathRaw);
    
    J=struct; J.Application=Application;
    J.SurfaceName='MissingPlaques';
    J.Channel='MissingPlaque';
    J.Smooth=0.4;
    J.LowerManual=7;
    J.SurfaceFilter='"Volume" above 0.8 um^3';
    
    [PlaqueSurface,PlaqueSurfaceInfo]=generateSurface3(J);
    accessImarisManually(Application,struct('Function','DeleteChannel','ChannelList',{'MissingPlaque'}));
    imarisSaveHDFlock(Application,PathRaw);
    return;
end


%% refine the initial plaque assumption
if exist('RealPlaqueSettings')~=1
    RealPlaqueSettings=0;
elseif strcmp(RealPlaqueSettings,'MetBluePerc')
    keyboard; % distribute ghost plaques not only before but also after e.g. Pl48 in M353 is not present on last tp (tp20)
    [RealPlaquesTotal]=plaqueCorrection_RefineInitialAssumption(PlaqueMapTotal,Fileinfo,FilenameTotal,NewSize,CutPaste,[],[],PlaqueLocation);
    
    for Time=1:size(PlaqueMapTotal,4)
        GhostPlaqueIDs=Presence.Pl(Presence.Time==Time&Presence.Status==0);
        RealPlaques=RealPlaquesTotal(:,:,:,Time);
        RealPlaques(ismember(RealPlaques,GhostPlaqueIDs))=0;
        RealPlaquesTotal(:,:,:,Time)=RealPlaques;
%         disp(Time);
    end
    RealPlaquesTotal(PlaqueMapTotal~=0)=PlaqueMapTotal(PlaqueMapTotal~=0);
    cprintf('text',[' Clock: ',datestr(datenum(now),'mmm.dd HH:MM'),'\n']);
end

%% determine radius of plaques, implement roundation and store under DistInOut
PlaqueMapTotal=PlaqueMapTotal(CutPaste(1,1):CutPaste(1,2),CutPaste(2,1):CutPaste(2,2),CutPaste(3,1):CutPaste(3,2),:);
RealPlaquesTotal=RealPlaquesTotal(CutPaste(1,1):CutPaste(1,2),CutPaste(2,1):CutPaste(2,2),CutPaste(3,1):CutPaste(3,2),:);
if exist('RoundationType')==1
    [PlaqueData,PlaqueMapTotal]=plaqueCorrection_Roundation(FilenameTotal,RoundationType,PlaqueMapTotal,RealPlaquesTotal);
end
%% after roundation redo DistInOut and Membership, determine Relationship and place the data
plaqueCorrection_Environment(PlaqueData,FilenameTotal,PlaqueMapTotal);

clear PlaqueMapTotal;
