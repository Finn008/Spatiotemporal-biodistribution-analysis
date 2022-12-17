function dystrophyDetection()

% do not write all FctSpec values to DystrophyDetection, calculate
% thickness of brain slice, jump over plaque determination if not necessary
% normally set BACE1 to value 2
global W;
timeTable('Start');

F=W.G.T.F{W.Task}(W.File,:);
[FctSpec]=variableExtract(F.DystrophyDetection{1});

global ShowIntermediateSteps;
if (isfield(FctSpec,'Chronic') && FctSpec.Chronic==1) || (isfield(FctSpec,'Axons') && FctSpec.Axons==1) %% || (isfield(FctSpec,'Nuclei') && FctSpec.Nuclei==1)
    ShowIntermediateSteps=0;
else
    ShowIntermediateSteps=0;
end


[NameTable,ChannelTable]=fileSiblings_4();
FilenameTotal=NameTable.Filename{'FilenameTotal'};
% tif to imaris converter
if strfind1(NameTable.Properties.RowNames,'FilenameImarisLoadTif')
    [PathRaw,Report]=getPathRaw(NameTable{'FilenameTotalOrig','Filename'});
    if Report==0
        if strfind1({'XrayPhase';'XrayAbsorption'},FctSpec.ChannelNames)
            [Data3D,Outside]=tifLoader(NameTable.Filename{'FilenameImarisLoadTif'},1);
            Res=FctSpec.RES.';
%             Data3D=im2Matlab_4(NameTable.Filename{'FilenameTotalOrig'},'XrayPhase');
%             Outside=zeros(size(Data3D,1),size(Data3D,2),'uint8');
            ex2Imaris_2(Data3D,NameTable.Filename{'FilenameTotalOrig'},'XrayPhase',1,Res,'single');
            
            

%             [~,Data3D]=percentileFilter3D_4(Data3D,60,Res,[10;10;Res(3)],Outside,5000,[100;100;Res(3)],[],[],{'OrigData'}); % previously 50
%             Min=prctile(Data3D(Data3D~=0),5);
%             Max=prctile(Data3D(:),99);
%             Data3D=(Data3D-Min)*(65535/(Max-Min));
%             ex2Imaris_2(uint16(Data3D),NameTable.Filename{'FilenameTotal'},'XrayPhase3',1,Res);
%             imarisSaveHDFlock(NameTable.Filename{'FilenameTotal'}); Application=openImaris_4(NameTable.Filename{'FilenameTotal'},[],1,1);
%             ex2Imaris_2(Data3D,NameTable.Filename{'FilenameTotalOrig'},'XrayPhase',1,Res,'single');
            clear Data3D;
        else
            Application=openImaris_4(NameTable.Filename{'FilenameImarisLoadTif'});
            if strfind1(F.Properties.VariableNames,'ChannelNames')==0
                ChannelListOrig=strsplit(FctSpec.ChannelNames,',').';
            else
                ChannelListOrig=strsplit(F.ChannelNames{1},',').';
            end
            
            for m=1:size(ChannelListOrig,1)
                Application.GetDataSet.SetChannelName(m-1,ChannelListOrig{m});
            end
            if strcmp(F.Filename{1}(end-3:end),'.tif')
                Pix=[Application.GetDataSet.GetSizeX();Application.GetDataSet.GetSizeY();Application.GetDataSet.GetSizeZ()];
                Res=FctSpec.RES.'; % Res=str2double(strsplit(FctSpec.RES,',').');
                Application.GetDataSet.SetExtendMinX(0); Application.GetDataSet.SetExtendMinY(0); Application.GetDataSet.SetExtendMinZ(0);
                Application.GetDataSet.SetExtendMaxX(Pix(1)*Res(1)); Application.GetDataSet.SetExtendMaxY(Pix(2)*Res(2)); Application.GetDataSet.SetExtendMaxZ(Pix(3)*Res(3));
            end
            Application.FileSave(PathRaw,'writer="Imaris5"');
            quitImaris(Application);
            % %         keyboard; % remove sis file and tif files
        end
    end
end

[FileinfoOrig]=getFileinfo_2(NameTable{'FilenameTotalOrig','Filename'});
Pix=FileinfoOrig.Pix{1};
Res=FileinfoOrig.Res{1};

[PathTotalResults,ReportTotalResults]=getPathRaw(NameTable{'Results','Filename'}{1});
Wave1=dir(PathTotalResults);
TotalResults=struct;
if ReportTotalResults==1 && Wave1.datenum>datenum('2016.12.10','yyyy.mm.dd')
    TotalResults=load(PathTotalResults);
    if isfield(TotalResults,'TotalResults')~=0
        TotalResults=TotalResults.TotalResults;
    end
end
ReadOuts=table;

%% SomaSize
if isfield(FctSpec,'SomaSize') && FctSpec.SomaSize==1
    somaSize_2(F,FilenameTotalOrig);
    timeTable('SomaSize');
end
%% BrainArea
if isfield(FctSpec,'BrainArea') && FctSpec.BrainArea==1
    FilenameTotalBrainArea=regexprep(FilenameTotalOrig,'TyData.lsm','TyBrainArea.tif');
    [PathRaw,Report]=getPathRaw(FilenameTotalBrainArea);
    if Report==0; keyboard;end;
    DataBrainArea=imread(PathRaw);
    DataBrainArea=max(DataBrainArea,[],3);
    DataBrainArea=DataBrainArea>100;
    DataBrainArea=permute(DataBrainArea,[2,1]);
    DataBrainArea=interpolate3D(DataBrainArea,[],[],Pix(1:2));
    if strfind1(FilenameTotal,'ExTanjaB_TrP301S_IhcAT8_M')
        DataBrainArea=1-DataBrainArea;
    end
else
    DataBrainArea=[];
end
% check IntensityProfile
%% Outside
if isfield(FctSpec,'Specimen')==0;FctSpec.Specimen='Chunk'; end;

if isfield(FctSpec,'Outside') && strcmp(FctSpec.Outside,'None')
    Outside=zeros(Pix.','uint8');
end
if isfield(FctSpec,'Outside')==0 || isequal(FctSpec.Outside,1)
    % Chunk, WholeSlice, InToto
    %     if isfield(FctSpec,'Specimen'); FctSpec.Specimen='Chunk'; end;
    [Output]=dystrophyDetection_DetectOutside_2(FctSpec.Specimen,DataBrainArea);
    try
        TotalResults.OutsideInfo=Output;
        TotalResults.SliceThickness=Output.SliceThickness;
        TotalResults.TotalVolume=Output.TotalVolume;
    end
    
    TotalResults.TimeStamp.Outside=datenum(now);
    FctSpec.Outside=2;
    timeTable('Outside');
end
% calculate thickness of brain slice
% MaxProjection=double(permute(sum(sum(Outside,1),2),[3,2,1]));
% MaxProjection=1-(MaxProjection/max(MaxProjection(:)));
%% Imaris Spot detection
if isfield(FctSpec,'ImarisSpot') && FctSpec.ImarisSpot==1
    %     keyboard;
    [ChannelList]=dystrophyDetection_ImarisSpotDetection(FilenameTotal);
    TotalResults.ImarisSpot=ChannelList;
    FctSpec.ImarisSpot=2;
    TotalResults.TimeStamp.ImarisSpot=datenum(now);
    timeTable('ImarisSpotDetection');
end
%% IntensityCorrection
if isfield(FctSpec,'IntensityCorrection')
    ChannelNames=strsplit(FctSpec.IntensityCorrection,',').';
    %     FctSpec.IntensityCorrection
    %     && isempty(strfind(FctSpec.IntensityCorrection,'Done,'))==1
    if strfind1(ChannelNames,'Done',1)==0
%         ChannelNames=FctSpec.IntensityCorrection;
%         if ischar(ChannelNames); ChannelNames={ChannelNames}; end;
%         for Ch=1:size(ChannelNames,1)
%             dystrophyDetection_IntensityCorrection(ChannelNames(Ch),FilenameTotal,FilenameTotalOrig,ChannelListOrig);
        dystrophyDetection_IntensityCorrection(ChannelNames);
%         end
        FctSpec.IntensityCorrection=['Done,',FctSpec.IntensityCorrection];
    end
    ChannelNames(strcmp(ChannelNames,'Done'),:)=[];
    for Ch=1:size(ChannelNames,1)
        [Wave1]=im2Matlab_3(FilenameTotal,ChannelNames{Ch},1);
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={ChannelNames(Ch),{'Channel'},{'Data'},ChannelNames(Ch),{Wave1}};
    end
    clear Wave1;
    timeTable('IntensityCorrection');
end
%% Plaques detection
if isfield(FctSpec,'Plaque')
    if isfield(FctSpec,'PlaqueChannelName')==0; FctSpec.PlaqueChannelName='MetBlue'; end;
    if FctSpec.Plaque==1 % plaque reconstruction
        %         ShowIntermediateSteps=1;
        %         PlaqueChannelName=FctSpec.PlaqueChannelName;
        [PlaqueChannelData,PlaqueData]=dystrophyDetection_PlaqueDetection_2(FctSpec);
        FctSpec.Plaque=2;
        TotalResults.TimeStamp.Plaque=datenum(now);
        timeTable('PlaqueDetection');
    elseif FctSpec.Plaque==2
        PlaqueChannelData=im2Matlab_3(ChannelTable{FctSpec.PlaqueChannelName,'TargetFilename'},FctSpec.PlaqueChannelName);
    end
    if FctSpec.Plaque==2
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{FctSpec.PlaqueChannelName},{'Channel'},{'Data'},{FctSpec.PlaqueChannelName},{PlaqueChannelData}}; clear PlaqueChannelData;
    end
end

%% Blood vessels
if isfield(FctSpec,'Blood')
    if FctSpec.Blood==1
        [Blood]=dystrophyDetection_Blood();
        keyboard;
        ex2Imaris_2(Blood,ChannelTable.TargetFilename{'DAPI'},'Blood');
        ex2Imaris_2(DAPI,ChannelTable.TargetFilename{'DAPI'},'DAPI');
        FctSpec.Blood=2;
        TotalResults.TimeStamp.Blood=datenum(now);
        timeTable('BloodDetection');
    elseif FctSpec.Blood==2
        Blood=im2Matlab_3(ChannelTable{'DAPI','TargetFilename'},'Blood');
        DAPI=im2Matlab_3(ChannelTable{'DAPI','TargetFilename'},'DAPI');
    end
    if FctSpec.Blood==2
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'DAPI'},{'Channel'},{'Mask'},{'DAPI'},{DAPI}}; clear DAPI;
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Blood'},{'Channel'},{'Mask'},{'Blood'},{Blood}}; clear Blood;
    end
end

%% Nuclei
if isfield(FctSpec,'Nuclei')
    if FctSpec.Nuclei==1
        [Nuclei,DAPI,NucleiData]=dystrophyDetection_Nuclei_2();
        ex2Imaris_2(Nuclei,ChannelTable.TargetFilename{'DAPI'},'Nuclei');
        ex2Imaris_2(DAPI,ChannelTable.TargetFilename{'DAPI'},'DAPI');
        FctSpec.Nuclei=2;
        TotalResults.TimeStamp.Nuclei=datenum(now);
        timeTable('NucleiDetection');
    elseif FctSpec.Nuclei==2
        Nuclei=im2Matlab_3(ChannelTable{'DAPI','TargetFilename'},'Nuclei');
        DAPI=im2Matlab_3(ChannelTable{'DAPI','TargetFilename'},'DAPI');
    end
    if FctSpec.Nuclei==2
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'DAPI'},{'Channel'},{'Mask'},{'DAPI'},{DAPI}}; clear DAPI;
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Nuclei'},{'Channel'},{'Mask'},{'Nuclei'},{Nuclei}}; clear Nuclei;
    end
end
%% SynucleinFibrils
if isfield(FctSpec,'SynucleinFibrils')
    if FctSpec.SynucleinFibrils==1
        [SynucleinFibrils,PSync]=dystrophyDetection_Corona_3('PSync');
        
        
        
        ex2Imaris_2(SynucleinFibrils,ChannelTable.TargetFilename{'PSync'},'SynucleinFibrils',[],Res);
        ex2Imaris_2(PSync,ChannelTable.TargetFilename{'PSync'},'PSync');

        Wave1={'PSync';'SynucleinFibrils'};
        ChannelTable.TargetFilename(Wave1)=ChannelTable.TargetFilename('PSync');

        % make a quality control image
        ChannelInfo=table;
        Wave1={'Channel','PSync';'Colormap',[1;1;1];'IntensityMinMax',[0;40000];'IntensityData',max(PSync.*uint16(SynucleinFibrils),[],3);'Res',Res}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
        Wave1={'Channel','Dystrophies';'Colormap',[1;0;1];'IntensityMinMax',[0;40000];'IntensityData',max(PSync.*uint16(SynucleinFibrils),[],3);'Res',Res}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
        Path2file=getPathRaw([FilenameTotal,'_QualityControl_SynucleinFibrils.tif']);
        imageGenerator_2(ChannelInfo,Path2file);
        
        FctSpec.SynucleinFibrils=2;
        TotalResults.TimeStamp.SynucleinFibrils=datenum(now);
        timeTable('SynucleinFibrils');
    elseif FctSpec.SynucleinFibrils==2
%         SynucleinFibrils=im2Matlab_3(FilenameTotal,'SynucleinFibrils');
        SynucleinFibrils=im2Matlab_3(ChannelTable.TargetFilename{'PSync'},'SynucleinFibrils');
    end
    if FctSpec.SynucleinFibrils==2
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'SynucleinFibrils'},{'Channel'},{'Data'},{'SynucleinFibrils'},{SynucleinFibrils}}; clear SynucleinFibrils;
    end
end

%% Microglia
% try
if isfield(FctSpec,'Microglia')
    if FctSpec.Microglia==1
%         ShowIntermediateSteps=1;
%         keyboard;
        [Microglia,MicrogliaSoma,MicrogliaFibers,Iba1,MicrogliaInfo]=dystrophyDetection_Microglia_4();
        TotalResults.MicrogliaInfo=MicrogliaInfo;
        ex2Imaris_2(Microglia,ChannelTable{FctSpec.Microglia,'TargetFilename'},'Microglia');
        ex2Imaris_2(Iba1,ChannelTable{FctSpec.Microglia,'TargetFilename'},'Iba1');
        FctSpec.Microglia=2;
        TotalResults.TimeStamp.Microglia=datenum(now);
        timeTable('Microglia');
    elseif FctSpec.Microglia==2
        Microglia=im2Matlab_3(ChannelTable{FctSpec.Microglia,'TargetFilename'},'Microglia');
        Iba1=im2Matlab_3(ChannelTable{FctSpec.Iba1,'TargetFilename'},'Iba1');
        
        Wave1={'Microglia';'Iba1'};
        ChannelTable.TargetFilename(Wave1)=ChannelTable.TargetFilename('Iba1');

    end
    if FctSpec.Microglia==2
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Microglia'},{'Channel'},{'Data'},{'Microglia'},{Microglia>0}}; clear Microglia;
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Iba1'},{'Channel'},{'Data'},{'Iba1'},{Iba1}}; clear Iba1;
        if exist('MicrogliaSoma','Var')==1 && isempty(MicrogliaSoma)==0
            ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'MicrogliaSoma'},{'Channel'},{'Data'},{'MicrogliaSoma'},{MicrogliaSoma}}; clear MicrogliaSoma;
            ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'MicrogliaFibers'},{'Channel'},{'Data'},{'MicrogliaFibers'},{MicrogliaFibers}}; clear MicrogliaFibers;
        end
    end
end

%% Dystrophy
if isfield(FctSpec,'Dystrophy')
    ShowIntermediateSteps=1;
    if FctSpec.Dystrophy==1
        [DystrophyData,DystrophyDiameter]=dystrophyDetection_DystrophyDetection_2(FctSpec);
        ex2Imaris_2(DystrophyDiameter,ChannelTable.TargetFilename{FctSpec.DystrophyChannelName},[FctSpec.DystrophyChannelName,'_Diameter']);
        ex2Imaris_2(DystrophyData,ChannelTable.TargetFilename{FctSpec.DystrophyChannelName},FctSpec.DystrophyChannelName);
%         ex2Imaris_2(DystrophyDiameter,FilenameTotal,[FctSpec.DystrophyChannelName,'_Diameter']);
%         ex2Imaris_2(DystrophyData,FilenameTotal,FctSpec.DystrophyChannelName);
        FctSpec.Dystrophy=2;
        TotalResults.TimeStamp.Dystrophy=datenum(now);
        timeTable('Dystrophy');
    elseif FctSpec.Dystrophy==2
        DystrophyData=im2Matlab_3(ChannelTable.TargetFilename{FctSpec.DystrophyChannelName},FctSpec.DystrophyChannelName);
        DystrophyDiameter=im2Matlab_3(ChannelTable.TargetFilename{FctSpec.DystrophyChannelName},[FctSpec.DystrophyChannelName,'_Diameter']);
    end
    if FctSpec.Dystrophy==2
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{FctSpec.DystrophyChannelName},{'Channel'},{'Data'},{FctSpec.DystrophyChannelName},{DystrophyData}}; clear DystrophyData;
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{[FctSpec.DystrophyChannelName,'_Diameter']},{'Channel'},{'Data&Mask'},{[FctSpec.DystrophyChannelName,'_Diameter']},{DystrophyDiameter}}; clear DystrophyDiameter;
    end
end
%% Vglut1
if isfield(FctSpec,'Vglut1')
    keyboard; % replace with Dystrophy and specify DystrophyChannel
    if FctSpec.Vglut1==1
        [~,~,Vglut1DystrophiesDiameter,~,Vglut1DystrophiesRadius,Vglut1]=dystrophyDetection_IndividualDystros_2(FilenameTotal,'Vglut1',FilenameTotalOrig,ChannelListOrig);
        
        ex2Imaris_2(Vglut1,FilenameTotal,'Vglut1');
        ex2Imaris_2(Vglut1DystrophiesRadius,FilenameTotal,'Vglut1DystrophiesRadius');
        ex2Imaris_2(Vglut1DystrophiesDiameter,FilenameTotal,'Vglut1DystrophiesDiameter');
        FctSpec.Vglut1=2;
        TotalResults.TimeStamp.Vglut1=datenum(now);
        timeTable('Vglut1');
    elseif FctSpec.Vglut1==2
        Vglut1=im2Matlab_3(FilenameTotal,'Vglut1');
        Vglut1DystrophiesRadius=im2Matlab_3(FilenameTotal,'Vglut1DystrophiesRadius');
        Vglut1DystrophiesDiameter=im2Matlab_3(FilenameTotal,'Vglut1DystrophiesDiameter');
    end
    if FctSpec.Vglut1==2
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Vglut1'},{'Channel'},{'Data'},{'Vglut1'},{Vglut1}}; clear Vglut1;
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Vglut1DystrophiesRadius'},{'Channel'},{'Data&Mask'},{'Vglut1DystrophiesRadius'},{Vglut1DystrophiesRadius}}; clear Vglut1DystrophiesRadius;
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Vglut1DystrophiesDiameter'},{'Channel'},{'Data&Mask'},{'Vglut1DystrophiesDiameter'},{Vglut1DystrophiesDiameter}}; clear Vglut1DystrophiesDiameter;
    end
end

%% APP
if isfield(FctSpec,'APPY188')
    if FctSpec.APPY188==1
        %     keyboard;
        [APPCorona,APP]=dystrophyDetection_Corona_2(FilenameTotal,'APPY188',FilenameTotalOrig,ChannelListOrig);
        %     ex2Imaris_2(Mask,Application,'Test1');
        
        ex2Imaris_2(APP,FilenameTotal,'APPY188');
        ex2Imaris_2(APPCorona,FilenameTotal,'APPCorona');
        %     Mask=Mask>50;
        
        % make a quality control image
        ChannelInfo=table;
        Wave1={'Channel','APP';'Colormap',[0;1;1];'IntensityMinMax',[0;10000];'IntensityData',max(APP.*uint16(APPCorona).*uint16(~Outside),[],3);'Res',Res}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
        Wave1={'Channel','Dystrophies';'Colormap',[1;0;1];'IntensityMinMax',[0;10000];'IntensityData',max(APP.*uint16(APPCorona).*uint16(~Outside),[],3);'Res',Res}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
        
        Path2file=getPathRaw([FilenameTotal,'_QualityControl_APPY188.tif']);
        imageGenerator_2(ChannelInfo,Path2file);
        FctSpec.APPY188=2;
        TotalResults.TimeStamp.APP=datenum(now);
        timeTable('APP');
    elseif FctSpec.APPY188==2
        APP=im2Matlab_3(FilenameTotal,'APPY188');
        APPCorona=im2Matlab_3(FilenameTotal,'APPCorona');
    end
    if FctSpec.APPY188==2
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'APP'},{'Channel'},{'Data'},{'APP'},{APP}}; clear APP;
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'APPCorona'},{'Channel'},{'Data'},{'APPCorona'},{APPCorona}}; clear APPCorona;
    end
end
%% Ubiqutin
if isfield(FctSpec,'Ubiquitin')
    if FctSpec.Ubiquitin==1
        [UbiquitinDystrophies,Ubiquitin,Outside]=dystrophyDetection_Corona_3('Ubiquitin');
        
        ex2Imaris_2(UbiquitinDystrophies,ChannelTable.TargetFilename{'Ubiquitin'},'UbiquitinDystrophies',[],Res);
        ex2Imaris_2(Ubiquitin,ChannelTable.TargetFilename{'Ubiquitin'},'Ubiquitin');
%         imarisSaveHDFlock(ChannelTable.TargetFilename{'Ubiquitin'});
        Wave1={'UbiquitinDystrophies';'Ubiquitin'};
        ChannelTable.TargetFilename(Wave1)=ChannelTable.TargetFilename('Ubiquitin');

        % make a quality control image
%         UbiquitinDystrophies(Outside==1)=0;
%         Ubiquitin(Outside==1)=0;
        ChannelInfo=table;
        Wave1={'Channel','Ubiquitin';'Colormap',[1;1;1];'IntensityMinMax',[0;40000];'IntensityData',max(Ubiquitin.*uint16(~Outside).*uint16(UbiquitinDystrophies),[],3);'Res',Res}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
        Wave1={'Channel','UbiquitinDystrophies';'Colormap',[1;0;1];'IntensityMinMax',[0;40000];'IntensityData',max(Ubiquitin.*uint16(~Outside).*uint16(UbiquitinDystrophies),[],3);'Res',Res}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
        Path2file=getPathRaw([FilenameTotal,'_QualityControl_Ubiquitin.tif']);
        imageGenerator_2(ChannelInfo,Path2file);
        clear Outside;
        
        FctSpec.Ubiquitin=2;
        TotalResults.TimeStamp.Ubiquitin=datenum(now);
        timeTable('Ubiquitin');
    elseif FctSpec.Ubiquitin==2
        Ubiquitin=im2Matlab_3(FilenameTotal,'Ubiquitin');
        UbiquitinDystrophies=im2Matlab_3(ChannelTable.TargetFilename{'UbiquitinDystrophies'},'UbiquitinDystrophies');
    end
    if FctSpec.Ubiquitin==2
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'UbiquitinDystrophies'},{'Channel'},{'Data'},{'UbiquitinDystrophies'},{UbiquitinDystrophies}}; clear UbiquitinDystrophies;
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Ubiquitin'},{'Channel'},{'Data'},{'Ubiquitin'},{Ubiquitin}}; clear Ubiquitin;
    end
end
%% Lamp1
if isfield(FctSpec,'Lamp1')
    if FctSpec.Lamp1==1
        [Lamp1Corona,Lamp1]=dystrophyDetection_Corona_2(FilenameTotal,'Lamp1',FilenameTotalOrig,ChannelListOrig);
        ex2Imaris_2(Lamp1Corona,FilenameTotal,'Lamp1Corona');
        ex2Imaris_2(Lamp1,FilenameTotal,'Lamp1');
        
        % make a quality control image
        ChannelInfo=table;
        Wave1={'Channel','Lamp1';'Colormap',[0;1;1];'IntensityMinMax',[0;65535];'IntensityData',max(Lamp1.*uint16(Lamp1Corona),[],3);'Res',Res}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
        Wave1={'Channel','Dystrophies';'Colormap',[1;0;1];'IntensityMinMax',[0;65535];'IntensityData',max(Lamp1.*uint16(Lamp1Corona),[],3);'Res',Res}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
        
        Path2file=getPathRaw([FilenameTotal,'_QualityControl_Lamp1.tif']);
        imageGenerator_2(ChannelInfo,Path2file);
        
        FctSpec.Lamp1=2;
        TotalResults.TimeStamp.Lamp1=datenum(now);
        timeTable('Lamp1');
    elseif FctSpec.Lamp1==2
        Lamp1=im2Matlab_3(FilenameTotal,'Lamp1');
        Lamp1Corona=im2Matlab_3(FilenameTotal,'Lamp1Corona');
    end
    if FctSpec.Lamp1==2
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Lamp1'},{'Channel'},{'Data'},{'Lamp1'},{Lamp1}}; clear Lamp1;
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Lamp1Corona'},{'Channel'},{'Data'},{'Lamp1Corona'},{Lamp1Corona}}; clear Lamp1Corona;
    end
end
%% Bace1
if isfield(FctSpec,'Bace1')
    if FctSpec.Bace1==1
        [Bace1Corona,Bace1]=dystrophyDetection_Corona_2(FilenameTotal,'Bace1',FilenameTotalOrig,ChannelListOrig);
        ex2Imaris_2(Bace1Corona,FilenameTotal,'Bace1Corona');
        ex2Imaris_2(Bace1,FilenameTotal,'Bace1');
        
        % make a quality control image
        ChannelInfo=table;
        Wave1={'Channel','Bace1';'Colormap',[0;1;1];'IntensityMinMax',[0;65535];'IntensityData',max(Bace1.*uint16(Bace1Corona).*uint16(~Outside),[],3);'Res',Res}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
        Wave1={'Channel','Dystrophies';'Colormap',[1;0;1];'IntensityMinMax',[0;65535];'IntensityData',max(Bace1.*uint16(Bace1Corona).*uint16(~Outside),[],3);'Res',Res}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
        Path2file=getPathRaw([FilenameTotal,'_QualityControl_Bace1.tif']);
        imageGenerator_2(ChannelInfo,Path2file);
        
        FctSpec.Bace1=2;
        TotalResults.TimeStamp.Bace1=datenum(now);
        timeTable('Bace1');
    elseif FctSpec.Bace1==2
        Bace1=im2Matlab_3(ChannelTable{'Bace1','TargetFilename'},'Bace1');
%         Bace1=im2Matlab_3(FilenameTotal,'Bace1');
%         Bace1Corona=im2Matlab_3(FilenameTotal,'Bace1Corona');
        Bace1Corona=im2Matlab_3(ChannelTable{'Bace1','TargetFilename'},'Bace1Corona');
    end
    if FctSpec.Bace1==2
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Bace1'},{'Channel'},{'Data'},{'Bace1'},{Bace1}}; clear Bace1;
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Bace1Corona'},{'Channel'},{'Data'},{'Bace1Corona'},{Bace1Corona}}; clear Bace1Corona;
    end
end
%% Boutons
if isfield(FctSpec,'Boutons') && FctSpec.Boutons==1
    [BoutonInfo]=dystrophyDetection_Boutons(FilenameTotal);
    TotalResults.BoutonInfo=BoutonInfo;
    FctSpec.Boutons=3;
    TotalResults.TimeStamp.Boutons=datenum(now);
    timeTable('Boutons');
end

%% Axon reconstruction
% try
if isfield(FctSpec,'Axons')
    if FctSpec.Axons<3==1
        [GFPM,DystrophyDiameter,AxonSkeleton,AxonData]=dystrophyDetection_Axons_4();
        %         keyboard;
        
        ex2Imaris_2(GFPM,FilenameTotal,'GFPM');
% %         ex2Imaris_2(DystrophyDiameter,FilenameTotal,'AxonDystrophyDiameter');
% %         ex2Imaris_2(AxonSkeleton,FilenameTotal,'AxonSkeleton');
        FctSpec.Axons=2;
        TotalResults.TimeStamp.Axons=datenum(now);
        TotalResults.AxonData=AxonData;
        timeTable('Axons');
    elseif FctSpec.Axons==3
        GFPM=im2Matlab_3(FilenameTotal,'GFPM');
% %         DystrophyDiameter=im2Matlab_3(FilenameTotal,'AxonDystrophyDiameter');
    end
    if FctSpec.Axons==2
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'GFPM'},{'Channel'},{'Data'},{'GFPM'},{GFPM}}; clear GFPM;
% %         ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'AxonMap'},{'Channel'},{'Data&Mask'},{'AxonMap'},{AxonMap}}; clear AxonMap;
    end
end
% catch error
%     Message=displayError(error,0)
% end

%% generate overview file
if ShowIntermediateSteps==1
    imarisSaveHDFlock(ChannelTable.TargetFilename{'ShowIntermediate'});
    % %     Application=openImaris_4(FilenameTotal,[],1,1);
    % %     keyboard;
end

% %% fine-tune analysis for axons and dendrites
% if FctSpec.Axon==2
%     keyboard;
%     dystrophyDetection_Axons(Fileinfo,Application);
%     FctSpec.Axon=2;
% end

%% Intensity distribution
if isfield(FctSpec,'IntDistribution') && FctSpec.IntDistribution==1
    [Fileinfo]=getFileinfo_2(FilenameTotal);
    ChannelList=Fileinfo.ChannelList{1};
    PercDistribution=table; PercDistribution.Percentile=(0:0.1:100).';
    IntDistribution=table;
    for Ch=1:size(ChannelList,1)
        Data3D=im2Matlab_3(FilenameTotal,ChannelList{Ch});x
        PercDistribution{:,ChannelList(Ch)}=prctile_2(Data3D(:),PercDistribution.Percentile);
        Max=max(Data3D(:));
        Wave1=histcounts(Data3D(:),0:Max);
        IntDistribution.Intensity(1:Max,1)=(1:Max).';
        IntDistribution{:,ChannelList(Ch)}=Wave1.';
    end
    TotalResults.PercDistribution=PercDistribution;
    TotalResults.IntDistribution=IntDistribution;
    FctSpec.IntDistribution=2;
    TotalResults.TimeStamp.IntDistribution=datenum(now);
    timeTable('IntensityDistribution');
end
%% extract all results
if size(ReadOuts,1)>0
    Fileinfo=getFileinfo_2(NameTable.Filename{'FilenameTotal'});
    Res=Fileinfo.Res{1};
    Pix=Fileinfo.Pix{1};
    if isfield(FctSpec,'Plaque')==0 || FctSpec.Plaque==0
        DistInOut=ones(Pix(1),Pix(2),Pix(3),'uint16');
        Membership=ones(Pix(1),Pix(2),Pix(3),'uint16');
        % %     PlaqueData.Data(1,1)={table(1)};
    else
        DistInOut=im2Matlab_3(NameTable.Filename{'FilenameTotal'},'DistInOut');
        Membership=im2Matlab_3(NameTable.Filename{'FilenameTotal'},'Membership');
    end
    
    ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'DistInOut'},{'Channel'},{'Mask'},{'DistInOut'},{DistInOut}};
    ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Membership'},{'Channel'},{'Mask'},{'Membership'},{Membership}};
    
    %     if strfind1(Fileinfo.ChannelList{1},'Outside',1)
    %         Outside=im2Matlab_3(FilenameTotal,'Outside');
    try
        [Outside]=uint8(im2Matlab_3(ChannelTable.TargetFilename{'Outside'},'Outside'));
    catch
        Outside=zeros(Pix.','uint8');
    end
     
    % % %     Relationship=ones(Pix(1),Pix(2),Pix(3),'uint16');
    % % %     Relationship(Outside>0)=6;
    % % %     ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Relationship'},{'Channel'},{'Mask'},{'Relationship'},{Relationship}};
    ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Outside'},{'Channel'},{'Mask'},{'Outside'},{Outside}};
    ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Volume'},{'Channel'},{'Data'},{'Volume'},{ones(size(Outside),'uint8')}};
    
    DistanceRelation={'Standard'};
    DistanceRelation{1,2}=accumarray_9(ReadOuts{strcmp(ReadOuts.CalcType,'Mask'),{'Data';'Name'}},ReadOuts{strcmp(ReadOuts.CalcType,'Data'),{'Data';'Name'}},@sum);
    
    for Ind=strfind1(ReadOuts.CalcType,'Data&Mask',1,1).'
        DistanceRelation(end+1,1)={ReadOuts.Name{Ind}};
        DistanceRelation{end,2}=accumarray_9(ReadOuts{[strfind1(ReadOuts.CalcType,'Mask',1);Ind],{'Data';'Name'}},{ones(size(Outside),'uint8'),'Volume'},@sum);
    end
    TotalResults.Res=Res;
    TotalResults.DistanceRelation=DistanceRelation;
    try; TotalResults.PlaqueData=PlaqueData; end;
    % save the data to mat file
    TotalResults.TimeStamp.ExtractResults=datenum(now);
    timeTable('ExtractResults');
end
save(PathTotalResults,'TotalResults');

FctSpec.Step=1;

FctSpec=struct2table(FctSpec);
FctSpecOut=cell(0,2);
for m=1:size(FctSpec,2)
    if FctSpec{1,m}~=0
        FctSpecOut=[FctSpecOut;{FctSpec.Properties.VariableNames{m},num2str(FctSpec{1,m})}];
    end
end
Wave1=variableSetter_2(W.G.T.F{W.Task,1}.DystrophyDetection{W.File},FctSpecOut);

iFileChanger('W.G.T.F{W.Task,1}.DystrophyDetection{W.File}',Wave1);
timeTable('End');