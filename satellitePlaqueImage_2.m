function satellitePlaqueImage_2(MouseInfo,NewBornPlaqueList,PlaqueList,PlaqueListSingle)
global W;
PlaqueDetectionLimit=4;

%% generate satellite plaque image via imaris
for MouseId=[] % [312;348;369;370;372;374;377;381;384;9347;314;336;341;353;375].'
    disp(MouseId);
    Mouse=find(MouseInfo.MouseId==MouseId);
    % NB360
    clear Timepoints;
    if MouseId==318
        Timepoints=[4;17]; %[3;7;17]; % 3.9 and 6.1 months, treatment for 2.1m
    elseif MouseId==331
        Timepoints=[4;17]; %[1;2;3;5;6;7;8;9;10;11;12;13;14;15;16;17]; % 3.8 and 6.1 months, treatment for 2.1m
    elseif MouseId==346
        Timepoints=[2;5;15]; % 3.6, 4.4 and 6.7 months, treatment for 2.3m
    elseif MouseId==347
        Timepoints=[1;5;15]; % 3.9 and 6.2 months, treatment for 2.1m
    elseif MouseId==371
        Timepoints=[2;5;15]; % 3.6, 4.4 and 6.7 months, treatment for 2.3m
    end
    % Vehicle
    if MouseId==314
        Timepoints=[4;17]; %[3;5;6;7;8;9;17]; % 3.8 and 6.1 months, treatment for 2.1m
    elseif MouseId==336
        Timepoints=[4;17]; %[3;5;6;7;8;9;17]; % 3.8 and 6.1 months, treatment for 2.1m
    elseif MouseId==341
        Timepoints=[1;14]; %[1;4;14]; % 3.2, 3.9 and 6.2 months, treatment for 2.3m
    elseif MouseId==353
        Timepoints=[1;14]; %[2;5;15]; % 3.6, 4.4 and 6.7 months, treatment for 2.3m
    elseif MouseId==375
        Timepoints=[1;14]; %[2;5;15]; % 3.6, 4.4 and 6.7 months, treatment for 2.3m
    end
    % APPPS1xTauKO
    if MouseId==312
        Timepoints=[1;14];
    elseif MouseId==348
        Timepoints=[1;10];
    elseif MouseId==369
        Timepoints=[1;13];
    elseif MouseId==370
        Timepoints=[1;13];
    elseif MouseId==372
        Timepoints=[1;13];
    elseif MouseId==374
        Timepoints=[1;11];
    elseif MouseId==377
        Timepoints=[1;13];
    elseif MouseId==381
        Timepoints=[1;12];
    elseif MouseId==384
        Timepoints=[1;12];
    elseif MouseId==9347
        Timepoints=[1;12];
    end
    
    RoiInfo=MouseInfo.RoiInfo{Mouse,1};
    
    Filename=MouseInfo.RoiInfo{Mouse,1}.Files{1,1}.Filenames{1};
    [NameTable,SibInfo]=fileSiblings_3(Filename);
    FilenameTotal=['SatellitePlaques_M',num2str(MouseId),'.ims'];
    FilenameTotalTrace=NameTable.FilenameTotal{'Trace'};
    FileinfoTrace=getFileinfo_2(FilenameTotalTrace);
    Res=FileinfoTrace.Res{1};
    Pix=FileinfoTrace.Pix{1};
    
    % generate 3D file
    Make3DImage=1;
    if Make3DImage==1
        [PathRaw,Report]=getPathRaw(FilenameTotal);
        if Report==0
            J=struct;J.PixMax=[Pix(1);Pix(2);Pix(3);0;2]; J.Resolution=Res; J.Path2file=W.PathImarisSample;
            Application=openImaris_2(J); Application.SetVisible(1);
            Application.FileSave(PathRaw,'writer="Imaris5"');
            quitImaris(Application);
            clear Application;
        end
        %     Timepoints=[Timepoints(1);Timepoints];
        for Time=1:size(Timepoints,1)
            Membership=im2Matlab_3(FilenameTotalTrace,'Membership',Timepoints(Time));
            DistInOut=im2Matlab_3(FilenameTotalTrace,'DistInOut',Timepoints(Time));
            PlaqueMap=Membership; PlaqueMap(DistInOut>50)=0;
            MetBlue=im2Matlab_3(FilenameTotalTrace,'MetBlue',Timepoints(Time));
            
            ex2Imaris_2(MetBlue,FilenameTotal,'MetBlue',Time);
            ex2Imaris_2(PlaqueMap,FilenameTotal,'PlaqueMap',Time);
            % remove plaques from PlaqueMape below PlaqueDetectionLimit
            TimeList=MouseInfo.RoiInfo{3,1}.Files{1,1}.Age;
            
            PlaqueListSingle2=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId & PlaqueListSingle.RadiusFit1<PlaqueDetectionLimit & PlaqueListSingle.Age==TimeList(Timepoints(Time)),:);
            
            PlaqueMap(ismember(PlaqueMap,PlaqueListSingle2.PlId))=0;
            
            PlaqueBirthReference=2;
            if Time==1 || (PlaqueBirthReference==2 && Time~=size(Timepoints,1))
                ex2Imaris_2(logical(PlaqueMap),FilenameTotal,'PreExistingPlaques',Time);
                continue;
            end
            Array=uint16(logical(PlaqueMap));
            NewBornPlaqueList2=NewBornPlaqueList(NewBornPlaqueList.MouseId==MouseId,:);
            
            
            
            if PlaqueBirthReference==1 % NewPlaques are those formed within period to last timepoint
                Wave1=TimeList(Timepoints(Time-1));
                Wave2=TimeList(Timepoints(Time));
            elseif PlaqueBirthReference==2 % NewPlaques always counted from timepoint of treatment start
                %                 keyboard; % set time to treatment start
                Wave1=NewBornPlaqueList2.StartTreatmentNum(1);
                Wave2=TimeList(Timepoints(Time));
                
            end
            
            NewBornPlaqueList2=NewBornPlaqueList2(NewBornPlaqueList2.PlBirth>Wave1&NewBornPlaqueList2.PlBirth<=Wave2,:);
            %         NewBornPlaqueList2(NewBornPlaqueList2.PlBirth<NewBornPlaqueList2.StartTreatmentNum,:)=[];
            for Pl=1:size(NewBornPlaqueList2,1)
                PlId=NewBornPlaqueList2.PlId(Pl);
                PlBirth=NewBornPlaqueList2.PlBirth(Pl);
                PlaqueListSingle2=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId & PlaqueListSingle.PlId==PlId & PlaqueListSingle.Age==PlBirth,:);
                if size(PlaqueListSingle2,1)>1; keyboard; end;
                Distance2ClosestPlaque=PlaqueListSingle2.Distance2ClosestPlaque(1);
                ClosestPlaque=PlaqueListSingle2.ClosestPlaque(1);
                Array(PlaqueMap==PlId)=round(Distance2ClosestPlaque);
            end
            
            ex2Imaris_2(Array,FilenameTotal,'ClosestDistance',Time);
            PreExistingPlaques=Array;
            PreExistingPlaques(Array>1)=0;
            ex2Imaris_2(PreExistingPlaques,FilenameTotal,'PreExistingPlaques',Time);
            NewPlaques=logical(Array);
            NewPlaques(Array==1)=0;
            ex2Imaris_2(NewPlaques,FilenameTotal,'NewPlaques',Time);
            %         end
        end
    end
    imarisSaveHDFlock(FilenameTotal);
    %     Application=openImaris_2(FilenameTotal,1);
    
end

%% make projection image for each mouse

ImarisFile=1;
Wave1=[318,4,17;331,4,17;346,5,15;347,5,15;371,2,15]; % NB360
Wave1=[Wave1;314,4,17;336,4,17;338,3,14;341,1,14;353,1,14;375,1,14]; % Vehicle
Wave1=[Wave1;312,1,14;348,1,10;369,1,13;370,1,13;372,1,13;374,1,11;377,1,13;381,1,12;384,1,12;9347,1,12]; % APPPS1xTauKO
MouseInfo.SatelliteStart(:,1)=NaN;
MouseInfo.SatelliteStart(ismember2(Wave1(:,1),MouseInfo.MouseId),1)=Wave1(:,2);

NewBornPlaqueList=fuseTable_MatchingColums_4(NewBornPlaqueList,PlaqueListSingle,{'MouseId';'RoiId';'Time';'PlId'},{'UmCenter'},{'UmCenter'});
PlaqueListSingle.ClosestPlaque=PlaqueListSingle.PlId;
NewBornPlaqueList=fuseTable_MatchingColums_4(NewBornPlaqueList,PlaqueListSingle,{'MouseId';'RoiId';'Time';'ClosestPlaque'},{'UmCenter'},{'UmCenterParent'});

for MouseId=[348;370;372;374;377;381;384;9347;314;336;338;341;353].' %[375,369]%[312;348;369;370;372;374;377;381;384;9347;314;336;338;341;353;375].'
    disp(MouseId);
    Mouse=find(MouseInfo.MouseId==MouseId);
    RoiInfo=MouseInfo.RoiInfo{Mouse,1};
    Filename=MouseInfo.RoiInfo{Mouse,1}.Files{1,1}.Filenames{1};
    [NameTable,SibInfo]=fileSiblings_3(Filename);
    FilenameTotalTrace=NameTable.FilenameTotal{'Trace'};
    FileinfoTrace=getFileinfo_2(FilenameTotalTrace);
    Res=FileinfoTrace.Res{1};
    Pix=FileinfoTrace.Pix{1};
    
    Timepoints=FileinfoTrace.GetSizeT;
    for Time=1:Timepoints
        Membership=im2Matlab_3(FilenameTotalTrace,'Membership',Time);
        DistInOut=im2Matlab_3(FilenameTotalTrace,'DistInOut',Time);
        PlaqueMap=Membership; PlaqueMap(DistInOut>50)=0;
        MetBlue=im2Matlab_3(FilenameTotalTrace,'MetBlue',Time);
        [MetBlue2Dall,Wave1]=max(MetBlue,[],3);
        MetBlue(PlaqueMap==0)=0;
        [MetBlue2D,Wave1]=max(MetBlue,[],3);
        Wave2=(Wave1-1)*prod(size(Wave1));
        Wave1(:)=1:prod(size(Wave1));
        PlaqueMap2D=Wave1+Wave2;
        PlaqueMap2D(:)=PlaqueMap(PlaqueMap2D);PlaqueMap2D=uint16(PlaqueMap2D);
        NewBornPlaqueList2=NewBornPlaqueList(NewBornPlaqueList.MouseId==MouseId & NewBornPlaqueList.Time>MouseInfo.SatelliteStart(Mouse) & NewBornPlaqueList.Time<=Time,:);
        if find(isnan(NewBornPlaqueList2.ClosestPlaque)); keyboard; end;
        [PlaqueMap2Dnew,Wave2]=ismember(PlaqueMap2D,NewBornPlaqueList2.PlId);
        PlaqueDistance2D=ones(size(PlaqueMap2D),'uint8');
        PlaqueDistance2D(PlaqueMap2Dnew==1)=NewBornPlaqueList2.Distance2ClosestPlaque(uint16(Wave2(PlaqueMap2Dnew==1)))+1;
        PlaqueMap2Dold=logical(PlaqueMap2D)-PlaqueMap2Dnew;
        PlaqueMap2DnewInvert=~logical(PlaqueMap2Dnew);
        
        % create lines
        if size(NewBornPlaqueList2,1)>0
            NewBornPlaqueList3=NewBornPlaqueList2;
            for m=1:size(NewBornPlaqueList3,1)
                try % some plaques do not exist in later timepoints because out of chunk
                    UmCenter=PlaqueListSingle.UmCenter{PlaqueListSingle.MouseId==MouseId&PlaqueListSingle.Time==Time&PlaqueListSingle.PlId==NewBornPlaqueList3.PlId(m)&PlaqueListSingle.RoiId==NewBornPlaqueList3.RoiId(m)};
                    UmCenterParent=PlaqueListSingle.UmCenter{PlaqueListSingle.MouseId==MouseId&PlaqueListSingle.Time==Time&PlaqueListSingle.PlId==NewBornPlaqueList3.ClosestPlaque(m)&PlaqueListSingle.RoiId==NewBornPlaqueList3.RoiId(m)};
                    NewBornPlaqueList3.Point1(m,1:2)=flip(ceil((UmCenter(1:2)-FileinfoTrace.UmStart{1}(1:2))./Res(1:2)));
                    NewBornPlaqueList3.Point2(m,1:2)=flip(ceil((UmCenterParent(1:2)-FileinfoTrace.UmStart{1}(1:2))./Res(1:2)));
                catch
                    NewBornPlaqueList3.Remove(m,1)=1;
                end
            end
            try; NewBornPlaqueList3(NewBornPlaqueList3.Remove==1,:)=[]; end;
            LineTable=table;
            LineTable.Ind=NewBornPlaqueList3.Distance2ClosestPlaque;
            LineTable.P1=NewBornPlaqueList3.Point1;
            LineTable.P2=NewBornPlaqueList3.Point2;
            Connections=drawLineOnImage(LineTable,size(PlaqueMap2D).',3);
        else
            Connections=zeros(size(PlaqueMap2Dnew));
        end
        ColorMinMax=[1;61];
        % black background
        ChannelInfo=table;
        ChannelInfo(1,{'Channel','Colormap','IntensityMinMax','IntensityGamma','IntensityData'})={'Old',{[1,1,1]},{[0;80]},1,MetBlue2D.*uint8(PlaqueMap2Dold)};
        ChannelInfo(2,{'Channel','Colormap','IntensityMinMax','IntensityGamma','IntensityData','ColorData','ColorMinMax'})={'New',{'Spectrum'},{[0;80]},1,MetBlue2D.*uint8(PlaqueMap2Dnew),PlaqueDistance2D,{ColorMinMax}};
        ChannelInfo(3,{'Channel','Colormap','IntensityMinMax','IntensityGamma','IntensityData','ColorData','ColorMinMax'})={'New',{'Spectrum'},{[0;1]},1,logical(Connections).*PlaqueMap2DnewInvert,Connections,{ColorMinMax}};
        Path2file=[W.G.PathOut,'\SatellitePlaques\','SatellitePlaques_M',num2str(MouseId),'_Time',num2str(Time),'_Version1.tif'];
        imageGenerator_2(ChannelInfo,Path2file);

        % white background
        ChannelInfo=table;
        ChannelInfo(1,{'Channel','Colormap','IntensityMinMax','IntensityGamma','IntensityData'})={'Old',{[0,0,0]},{[0;80]},1,MetBlue2D.*uint8(PlaqueMap2Dold)};
        ChannelInfo(2,{'Channel','Colormap','IntensityMinMax','IntensityGamma','IntensityData','ColorData','ColorMinMax'})={'New',{'Spectrum'},{[0;80]},1,MetBlue2D.*uint8(PlaqueMap2Dnew),PlaqueDistance2D,{ColorMinMax}};
        ChannelInfo(3,{'Channel','Colormap','IntensityMinMax','IntensityGamma','IntensityData','ColorData','ColorMinMax'})={'New',{'Spectrum'},{[0;1]},1,logical(Connections).*PlaqueMap2DnewInvert,Connections,{ColorMinMax}};
        Path2file=[W.G.PathOut,'\SatellitePlaques\','SatellitePlaques_M',num2str(MouseId),'_Time',num2str(Time),'_Version2.tif'];
        imageGenerator_2(ChannelInfo,Path2file,[1;1;1]);
        
        % white background all Methoxy-signal
        ChannelInfo=table;
        ChannelInfo(1,{'Channel','Colormap','IntensityMinMax','IntensityGamma','IntensityData'})={'Old',{[0,0,0]},{[0;80]},1,MetBlue2Dall.*uint8(PlaqueMap2DnewInvert)};
        ChannelInfo(2,{'Channel','Colormap','IntensityMinMax','IntensityGamma','IntensityData','ColorData','ColorMinMax'})={'New',{'Spectrum'},{[0;80]},1,MetBlue2Dall.*uint8(PlaqueMap2Dnew),PlaqueDistance2D,{ColorMinMax}};
        ChannelInfo(3,{'Channel','Colormap','IntensityMinMax','IntensityGamma','IntensityData','ColorData','ColorMinMax'})={'New',{'Spectrum'},{[0;1]},1,logical(Connections).*PlaqueMap2DnewInvert,Connections,{ColorMinMax}};
        Path2file=[W.G.PathOut,'\SatellitePlaques\','SatellitePlaques_M',num2str(MouseId),'_Time',num2str(Time),'_Version3.tif'];
        imageGenerator_2(ChannelInfo,Path2file,[1;1;1]);
        
        if ImarisFile==1
            FilenameTotalSatellite=['SatellitePlaques_M',num2str(MouseId),'.ims'];
            [PlaqueMapNew,Wave2]=ismember(PlaqueMap,NewBornPlaqueList2.PlId);
            PlaqueDistance=zeros(size(PlaqueMap),'uint8');
            PlaqueDistance(PlaqueMapNew==1)=NewBornPlaqueList2.Distance2ClosestPlaque(uint16(Wave2(PlaqueMapNew==1)));
            
            PlaqueMap=logical(PlaqueMap);
            if Time==1
                dataInspector3D({PlaqueMap},Res,'PlaqueMap',1,FilenameTotalSatellite,0);
            else
                ex2Imaris_2(PlaqueMap,FilenameTotalSatellite,'PlaqueMap',Time);
            end
            ex2Imaris_2(PlaqueDistance,FilenameTotalSatellite,'PlaqueDistance',Time);
        end
    end
    if ImarisFile==1
        Application=openImaris_2(FilenameTotalSatellite,1);
        
        J=struct;
        J.Application=Application;
        J.SurfaceName='Plaques';
        J.Channel='PlaqueMap';
        J.Smooth=0.4;
        J.LowerManual=0.9;
        generateSurface3(J);
        
        
        imarisSaveHDFlock(Application,FilenameTotalSatellite);
    end
end


%% revise from here
keyboard
for Time=1:size(Timepoints,1)
    Membership=im2Matlab_3(FilenameTotalTrace,'Membership',Timepoints(Time));
    DistInOut=im2Matlab_3(FilenameTotalTrace,'DistInOut',Timepoints(Time));
    PlaqueMap=Membership; PlaqueMap(DistInOut>50)=0;
    MetBlue=im2Matlab_3(FilenameTotalTrace,'MetBlue',Timepoints(Time));
    
    if Time==1
        
    else
        Array=uint16(logical(PlaqueMap));
        NewBornPlaqueList2=NewBornPlaqueList(NewBornPlaqueList.MouseId==MouseId,:);
        for Pl=1:size(NewBornPlaqueList2,1)
            PlId=NewBornPlaqueList2.PlId(Pl);
            PlBirth=NewBornPlaqueList2.PlBirth(Pl);
            PlaqueListSingle2=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId & PlaqueListSingle.PlId==PlId & PlaqueListSingle.Age==PlBirth,:);
            if size(PlaqueListSingle2,1)>1; keyboard; end;
            Distance2ClosestPlaque=PlaqueListSingle2.Distance2ClosestPlaque(1);
            ClosestPlaque=PlaqueListSingle2.ClosestPlaque(1);
            Array(PlaqueMap==PlId)=round(Distance2ClosestPlaque);
        end
        
        ex2Imaris_2(Array,FilenameTotal,'ClosestDistance',Time);
        PreExistingPlaques=Array;
        PreExistingPlaques(Array>1)=0;
        ex2Imaris_2(PreExistingPlaques,FilenameTotal,'PreExistingPlaques',Time);
        NewPlaques=logical(Array);
        NewPlaques(Array==1)=0;
        ex2Imaris_2(NewPlaques,FilenameTotal,'NewPlaques',Time);
    end
end




Projection=max(Membership,[],3);
Pix=size(Projection).';
Array=uint16(logical(Projection));
NewBornPlaqueList2=NewBornPlaqueList(NewBornPlaqueList.MouseId==MouseId,:);
for Pl=1:size(NewBornPlaqueList2,1)
    PlId=NewBornPlaqueList2.PlId(Pl);
    PlBirth=NewBornPlaqueList2.PlBirth(Pl);
    PlaqueListSingle2=PlaqueListSingle(PlaqueListSingle.MouseId==MouseId & PlaqueListSingle.PlId==PlId & PlaqueListSingle.Age==PlBirth,:);
    if size(PlaqueListSingle2,1)>1; keyboard; end;
    Distance2ClosestPlaque=PlaqueListSingle2.Distance2ClosestPlaque(1);
    ClosestPlaque=PlaqueListSingle2.ClosestPlaque(1);
    Array(Projection==PlId)=round(Distance2ClosestPlaque);
end
Max=150;
Colormap=jet(Max);
Colormap(1,:)=[0,0,0];
Colormap(2,:)=[1,1,1];
Image=gray2rgb_2(Array,Colormap);
Path2file=[W.G.PathOut,'\SatellitePlaques\'];
Path=[Path2file,MouseInfo.TreatmentType{Mouse},'_M',num2str(MouseInfo.MouseId(Mouse)),'.tif'];
imwrite(Image,Path);

%% distance transformation figure
Membership=im2Matlab_3(FilenameTotalTrace,'Membership',FileinfoTrace.GetSizeT(1));
DistInOut=im2Matlab_3(FilenameTotalTrace,'DistInOut',FileinfoTrace.GetSizeT(1));
PlaqueMap=Membership; PlaqueMap(DistInOut>50)=0;
MetBlue=im2Matlab_3(FilenameTotalTrace,'MetBlue',FileinfoTrace.GetSizeT(1));


ex2Imaris_2(Membership,FilenameTotal,'Membership');
% make distance transformation only for plaques that touch slice 361 (144µm)

Wave1=PlaqueMap(:,:,361);
PlaqueIds=unique(Wave1(:)); PlaqueIds=PlaqueIds(2:end);
PlaqueMap(ismember(PlaqueMap,PlaqueIds)==0)=0;

[Distance,Membership]=distanceMat_4(PlaqueMap,{'DistInOut';'Membership'},Res,1,1,1,50);
ex2Imaris_2(Distance,Application,'DistInOutSlice');
ex2Imaris_2(Membership,Application,'MembershipSlice');
