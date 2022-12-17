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
    ShowIntermediateSteps=1;
else
    ShowIntermediateSteps=0;
end


if strfind1(F.Properties.VariableNames.','Family') && isempty(F.Family{1})==0
    keyboard;
    [NameTable,ChannelTable]=fileSiblings_4();
    
    % tif to imaris converter
    if strfind1(NameTable.Properties.RowNames,'FilenameImarisLoadTif')
        [PathRaw,Report]=getPathRaw(NameTable{'FilenameTotalOrig','Filename'});
        if Report==0
            Application=openImaris_4(FilenameTotalOrig);
            keyboard
            for m=1:size(ChannelListOrig,1)
                Application.GetDataSet.SetChannelName(m-1,ChannelListOrig{m});
            end
            if strcmp(F.Filename{1}(end-3:end),'.tif')
                Pix=[Application.GetDataSet.GetSizeX();Application.GetDataSet.GetSizeY();Application.GetDataSet.GetSizeZ()];
                Res=str2double(strsplit(FctSpec.RES,',').');
                Application.GetDataSet.SetExtendMinX(0); Application.GetDataSet.SetExtendMinY(0); Application.GetDataSet.SetExtendMinZ(0);
                Application.GetDataSet.SetExtendMaxX(Pix(1)*Res(1)); Application.GetDataSet.SetExtendMaxY(Pix(2)*Res(2)); Application.GetDataSet.SetExtendMaxZ(Pix(3)*Res(3));
            end
            Application.FileSave(PathRaw,'writer="Imaris5"');
            quitImaris(Application);
            keyboard; % remove sis file and tif files
        end
    end
    
    [FileinfoOrig]=getFileinfo_2(NameTable{'FilenameTotalOrig','Filename'});
    % generate target file
%     Application=openImaris_4(FilenameTotalOrig);
    [Application]=openImaris_4([FileinfoOrig.Pix{1};0;1],[],[],[],[[0;0;0],FileinfoOrig.Um{1}]);
%     dataInspector3D(zeros,FileinfoOrig.Res{1},'Outside',1,FilenameTotal_Outside,0);
    [PathRaw,Report]=getPathRaw(NameTable{'FilenameTotal','Filename'});
    if Report==0 || isfield(FctSpec,'Step')==0 || FctSpec.Step==0
        Application.FileSave(PathRaw,'writer="Imaris5"');
        quitImaris(Application);
    end
end


F.Filename{1}=regexprep(F.Filename{1},'.sis','.tif');
Wave1={'.lsm';'.ids';'.czi';'.sis';'.tif'};
if strfind1(F.Filename{1}(end-3:end),Wave1,1)
    FilenameTotal=[F.Filename{1}(1:end-4),'.ims'];
    FilenameTotalOrig=F.Filename{1};
else
    FilenameTotal=[F.Filename{1},'.ims'];
    FilenameTotalOrig=[F.Filename{1},F.Type{1}];
end

% % tif converter
% if strcmp(F.Filename{1}(end-3:end),'.tif')
%     FilenameTotalOrig=regexprep(FilenameTotalOrig,'.tif','_T001_Z001_C01.tif');
% end


%% Chronic
if isfield(FctSpec,'Chronic')
    [FilenameTotal,TargetTimepoint]=dystrophyDetection_Chronic(FctSpec);
end
[FileinfoOrig]=getFileinfo_2(FilenameTotalOrig);
[PathRaw,Report]=getPathRaw(FilenameTotal);

%% AT8
if isfield(FctSpec,'AT8') && FctSpec.AT8==1
    largeAT8staingins4Tanja(FileinfoOrig,FilenameTotalOrig,FilenameTotal);
    FctSpec.AT8=2;
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
    return;
end
%% rename channels
if strfind1(F.Properties.VariableNames,'ChannelNames')==0
    ChannelListOrig=strsplit(FctSpec.ChannelNames,',').';
else
    ChannelListOrig=strsplit(F.ChannelNames{1},',').';
end

if Report==0 || isfield(FctSpec,'Step')==0 || FctSpec.Step==0
    Application=openImaris_4(FilenameTotalOrig);
    %     Fileinfo=extractFileinfo(FilenameTotalOrig,Application);
    % % %     if ischar(FctSpec.ChannelNames) % rename channels
    
    if size(ChannelListOrig,1)~=size(FileinfoOrig.ChannelList{1},1)
        quitImaris(Application);
        A1=asdf; % make error if more channels present than names
    end
    for m=1:size(ChannelListOrig,1)
        Application.GetDataSet.SetChannelName(m-1,ChannelListOrig{m});
    end
    if strcmp(F.Filename{1}(end-3:end),'.tif')
        Pix=[Application.GetDataSet.GetSizeX();Application.GetDataSet.GetSizeY();Application.GetDataSet.GetSizeZ()];
        Res=str2double(strsplit(FctSpec.RES,',').');
        Application.GetDataSet.SetExtendMinX(0); Application.GetDataSet.SetExtendMinY(0); Application.GetDataSet.SetExtendMinZ(0);
        Application.GetDataSet.SetExtendMaxX(Pix(1)*Res(1)); Application.GetDataSet.SetExtendMaxY(Pix(2)*Res(2)); Application.GetDataSet.SetExtendMaxZ(Pix(3)*Res(3));
    end
    % % %     end
    Application.FileSave(PathRaw,'writer="Imaris5"');
    quitImaris(Application);
    [Fileinfo,Ind,PathRaw]=getFileinfo_2(FilenameTotal);
    try; iFileChanger('W.G.Fileinfo.Results{Q1,1}.ZenInfo',FileinfoOrig.Results{1}.ZenInfo,{'Q1',Ind}); end;
    timeTable('LoadData');
end
Fileinfo=getFileinfo_2(FilenameTotal);

if isequal(FileinfoOrig.Pix{1},Fileinfo.Pix{1})~=1
    disp(FileinfoOrig.Pix{1});disp(Fileinfo.Pix{1});A1=asdf;
end

% open previous results
PathTotalResults=[FilenameTotal,'_Results.mat'];
[PathTotalResults,ReportTotalResults]=getPathRaw(PathTotalResults);
Wave1=dir(PathTotalResults);
if ReportTotalResults==1 && Wave1.datenum>datenum('2016.12.10','yyyy.mm.dd')
    TotalResults=load(PathTotalResults);
    TotalResults=TotalResults.TotalResults;
else
    TotalResults=struct;
end
[Fileinfo,Ind,PathRaw]=getFileinfo_2(FilenameTotal);

Res=Fileinfo.Res{1};
Pix=Fileinfo.Pix{1};
Um=Fileinfo.Um{1};
ReadOuts=table;

% %% check if fluorescence distribution over depth is correct
% dystrophyDetection_DepthIntensityDistribution(FilenameTotal,Fileinfo.Results{1,1}.ZenInfo);

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
if isfield(FctSpec,'Outside')==0 ||FctSpec.Outside==1 
    % Chunk, WholeSlice, InToto
%     if isfield(FctSpec,'Specimen'); FctSpec.Specimen='Chunk'; end;
    [Output]=dystrophyDetection_DetectOutside(FilenameTotal,FctSpec.Specimen,DataBrainArea,FilenameTotalOrig,ChannelListOrig);
%     ex2Imaris_2(Outside,FilenameTotal,'Outside');
    TotalResults.OutsideInfo=Output;
    try; TotalResults.SliceThickness=Output.SliceThickness; end;
    try; TotalResults.TotalVolume=Output.TotalVolume; end;

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
        ChannelNames=FctSpec.IntensityCorrection; if ischar(ChannelNames); ChannelNames={ChannelNames}; end;
        dystrophyDetection_IntensityCorrection(ChannelNames,FilenameTotal,FilenameTotalOrig,ChannelListOrig);
        FctSpec.IntensityCorrection=['Done,',FctSpec.IntensityCorrection];
    else
        ChannelNames=ChannelNames(2:end); % remove entry "Done"
    end
    %     ChannelNames=FctSpec.IntensityCorrection; if ischar(ChannelNames); ChannelNames={ChannelNames}; end;
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
        [PlaqueChannelData,PlaqueData]=dystrophyDetection_PlaqueDetection(FilenameTotal,FctSpec,FilenameTotalOrig,ChannelListOrig);
        FctSpec.Plaque=2;
        TotalResults.TimeStamp.Plaque=datenum(now);
        timeTable('PlaqueDetection');
    elseif FctSpec.Plaque==2
        PlaqueChannelData=im2Matlab_3(FilenameTotal,FctSpec.PlaqueChannelName);
    end
    if FctSpec.Plaque==2
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{FctSpec.PlaqueChannelName},{'Channel'},{'Data'},{FctSpec.PlaqueChannelName},{PlaqueChannelData}}; clear PlaqueChannelData;
    end
end
% catch error
%     Message=displayError(error,0)
% end

%% Nuclei
if isfield(FctSpec,'Nuclei')
    if FctSpec.Nuclei==1
%         ShowIntermediateSteps=1;
        [Nuclei,DAPI,NucleiData]=dystrophyDetection_Nuclei(FilenameTotal,'DAPI',FilenameTotalOrig,ChannelListOrig);
        ex2Imaris_2(Nuclei,FilenameTotal,'Nuclei');
        ex2Imaris_2(DAPI,FilenameTotal,'DAPI');
        imarisSaveHDFlock(FilenameTotal);
        FctSpec.Nuclei=2;
        TotalResults.TimeStamp.Nuclei=datenum(now);
        timeTable('NucleiDetection');
    elseif FctSpec.Nuclei==2
        Nuclei=im2Matlab_3(FilenameTotal,'Nuclei');
        DAPI=im2Matlab_3(FilenameTotal,'DAPI');
    end
    if FctSpec.Nuclei==2
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'DAPI'},{'Channel'},{'Mask'},{'DAPI'},{DAPI}}; clear DAPI;
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Nuclei'},{'Channel'},{'Mask'},{'Nuclei'},{Nuclei}}; clear Nuclei;
    end
end
%% SynucleinFibrils
if isfield(FctSpec,'SynucleinFibrils')
    if FctSpec.SynucleinFibrils==1
        [SynucleinFibrils,PSync]=dystrophyDetection_Corona_2(FilenameTotal,'PSync',FilenameTotalOrig,ChannelListOrig);
        ex2Imaris_2(SynucleinFibrils,FilenameTotal,'SynucleinFibrils');
        ex2Imaris_2(PSync,FilenameTotal,'PSync');
        % make a quality control image
        ChannelInfo=table;
        Wave1={'Channel','PSync';'Colormap',[1;1;1];'IntensityMinMax',[0;40000];'IntensityData',max(PSync.*uint16(SynucleinFibrils<40),[],3);'Res',Res}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
        Wave1={'Channel','Dystrophies';'Colormap',[1;0;1];'IntensityMinMax',[0;40000];'IntensityData',max(PSync.*uint16(SynucleinFibrils>=40),[],3);'Res',Res}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
        Path2file=getPathRaw([FilenameTotal,'_QualityControl_SynucleinFibrils.tif']);
        imageGenerator_2(ChannelInfo,Path2file);
        
        FctSpec.SynucleinFibrils=2;
        TotalResults.TimeStamp.SynucleinFibrils=datenum(now);
        timeTable('SynucleinFibrils');
    elseif FctSpec.SynucleinFibrils==2
        SynucleinFibrils=im2Matlab_3(FilenameTotal,'SynucleinFibrils');
    end
    if FctSpec.SynucleinFibrils==2
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'SynucleinFibrils'},{'Channel'},{'Data'},{'SynucleinFibrils'},{SynucleinFibrils>=40}}; clear SynucleinFibrils;
    end
end

%% Microglia
% try
if isfield(FctSpec,'Microglia')
    if FctSpec.Microglia==1
        ShowIntermediateSteps=1;
        keyboard;
        [Microglia,MicrogliaSoma,MicrogliaFibers,Iba1,MicrogliaInfo]=dystrophyDetection_Microglia_3(FilenameTotal,FilenameTotalOrig,ChannelListOrig);
        TotalResults.MicrogliaInfo=MicrogliaInfo;
        
        FctSpec.Microglia=2;
        TotalResults.TimeStamp.Microglia=datenum(now);
        timeTable('Microglia');
    elseif FctSpec.Microglia==2
        Microglia=im2Matlab_3(FilenameTotal,'Microglia');
        Iba1=im2Matlab_3(FilenameTotal,'Iba1');
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
        [DystrophyData,DystrophyDiameter]=dystrophyDetection_DystrophyDetection(FilenameTotal,FctSpec,FilenameTotalOrig,ChannelListOrig);
        ex2Imaris_2(DystrophyDiameter,FilenameTotal,[FctSpec.DystrophyChannelName,'_Diameter']);
        ex2Imaris_2(DystrophyData,FilenameTotal,FctSpec.DystrophyChannelName);
        FctSpec.Dystrophy=2;
        TotalResults.TimeStamp.Dystrophy=datenum(now);
        timeTable('Dystrophy');
    elseif FctSpec.Dystrophy==2
        DystrophyData=im2Matlab_3(FilenameTotal,FctSpec.DystrophyChannelName);
        DystrophyDiameter=im2Matlab_3(FilenameTotal,[FctSpec.DystrophyChannelName,'_Diameter']);
    end
    if FctSpec.Dystrophy==2
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{FctSpec.DystrophyChannelName},{'Channel'},{'Data'},{FctSpec.DystrophyChannelName},{DystrophyData}}; clear DystrophyData;
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{[FctSpec.DystrophyChannelName,'_Diameter']},{'Channel'},{'Data&Mask'},{[FctSpec.DystrophyChannelName,'_Diameter']},{DystrophyDiameter}}; clear DystrophyDiameter;
    end
    
%     keyboard;
%     imarisSaveHDFlock(FilenameTotal);
%     global Application; Application=openImaris_4(FilenameTotal,[],1,1);
%     global Application; Application=openImaris_4('ExKatrinP_M43_Roi1_IhcAb126468,22C11_REGoccipital_Layer2-3_Date201902061600_HDFlocked.ims',[],1,1);
    
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
        Wave1={'Channel','APP';'Colormap',[0;1;1];'IntensityMinMax',[0;10000];'IntensityData',max(APP.*uint16(APPCorona<=50).*uint16(~Outside),[],3);'Res',Res}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
        Wave1={'Channel','Dystrophies';'Colormap',[1;0;1];'IntensityMinMax',[0;10000];'IntensityData',max(APP.*uint16(APPCorona>50).*uint16(~Outside),[],3);'Res',Res}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
        
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
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'APPCorona'},{'Channel'},{'Data'},{'APPCorona'},{APPCorona>50}}; clear APPCorona;
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
        Wave1={'Channel','Lamp1';'Colormap',[0;1;1];'IntensityMinMax',[0;65535];'IntensityData',max(Lamp1.*uint16(Lamp1Corona<=50),[],3);'Res',Res}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
        Wave1={'Channel','Dystrophies';'Colormap',[1;0;1];'IntensityMinMax',[0;65535];'IntensityData',max(Lamp1.*uint16(Lamp1Corona>50),[],3);'Res',Res}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
        
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
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Lamp1Corona'},{'Channel'},{'Data'},{'Lamp1Corona'},{Lamp1Corona>50}}; clear Lamp1Corona;
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
        Wave1={'Channel','Bace1';'Colormap',[0;1;1];'IntensityMinMax',[0;65535];'IntensityData',max(Bace1.*uint16(Bace1Corona<=8).*uint16(~Outside),[],3);'Res',Res}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
        Wave1={'Channel','Dystrophies';'Colormap',[1;0;1];'IntensityMinMax',[0;65535];'IntensityData',max(Bace1.*uint16(Bace1Corona>8).*uint16(~Outside),[],3);'Res',Res}; ChannelInfo(end+1,Wave1(:,1))=Wave1(:,2).';
        Path2file=getPathRaw([FilenameTotal,'_QualityControl_Bace1.tif']);
        imageGenerator_2(ChannelInfo,Path2file);
        
        FctSpec.Bace1=2;
        TotalResults.TimeStamp.Bace1=datenum(now);
        timeTable('Bace1');
    elseif FctSpec.Bace1==2
        Bace1=im2Matlab_3(FilenameTotal,'Bace1');
        Bace1Corona=im2Matlab_3(FilenameTotal,'Bace1Corona');
    end
    if FctSpec.Bace1==2
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Bace1'},{'Channel'},{'Data'},{'Bace1'},{Bace1}}; clear Bace1;
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Bace1Corona'},{'Channel'},{'Data'},{'Bace1Corona'},{Bace1Corona>8}}; clear Bace1Corona;
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
    if FctSpec.Axons==1
        [GFPM,AxonDiameter]=dystrophyDetection_Axons(FilenameTotal,'GFPM',FilenameTotalOrig,ChannelListOrig);
        %         keyboard;
        
        ex2Imaris_2(GFPM,FilenameTotal,'GFPM');
        ex2Imaris_2(AxonDiameter,FilenameTotal,'AxonDiameter');
        FctSpec.Axons=2;
        TotalResults.TimeStamp.Axons=datenum(now);
        timeTable('Axons');
    elseif FctSpec.Axons==2
        GFPM=im2Matlab_3(FilenameTotal,'GFPM');
        AxonDiameter=im2Matlab_3(FilenameTotal,'AxonDiameter');
    end
    if FctSpec.Axons==2
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'GFPM'},{'Channel'},{'Data'},{'GFPM'},{GFPM}}; clear GFPM;
        ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'AxonDiameter'},{'Channel'},{'Data&Mask'},{'AxonDiameter'},{AxonDiameter}}; clear AxonDiameter;
    end
end
% catch error
%     Message=displayError(error,0)
% end

%% generate overview file
if ShowIntermediateSteps==1
    imarisSaveHDFlock(FilenameTotal);
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
    Fileinfo=getFileinfo_2(FilenameTotal);
    if FctSpec.Plaque==0
        DistInOut=ones(Pix(1),Pix(2),Pix(3),'uint16');
        Membership=ones(Pix(1),Pix(2),Pix(3),'uint16');
        % %     PlaqueData.Data(1,1)={table(1)};
    else
        DistInOut=im2Matlab_3(FilenameTotal,'DistInOut');
        Membership=im2Matlab_3(FilenameTotal,'Membership');
    end
    
    ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'DistInOut'},{'Channel'},{'Mask'},{'DistInOut'},{DistInOut}};
    ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Membership'},{'Channel'},{'Mask'},{'Membership'},{Membership}};
    
    if strfind1(Fileinfo.ChannelList{1},'Outside',1)
        Outside=im2Matlab_3(FilenameTotal,'Outside');
    else
        Outside=zeros(Pix.','uint8');
    end
    
    % % %     Relationship=ones(Pix(1),Pix(2),Pix(3),'uint16');
    % % %     Relationship(Outside>0)=6;
    % % %     ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Relationship'},{'Channel'},{'Mask'},{'Relationship'},{Relationship}};
    ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Outside'},{'Channel'},{'Mask'},{'Outside'},{Outside}};
    ReadOuts(size(ReadOuts,1)+1,{'Name','Identity','CalcType','ChannelName','Data'})={{'Volume'},{'Channel'},{'Data'},{'Volume'},{ones(Pix.','uint8')}};
    
    DistanceRelation={'Standard'};
    DistanceRelation{1,2}=accumarray_9(ReadOuts{strcmp(ReadOuts.CalcType,'Mask'),{'Data';'Name'}},ReadOuts{strcmp(ReadOuts.CalcType,'Data'),{'Data';'Name'}},@sum);
    
    for Ind=strfind1(ReadOuts.CalcType,'Data&Mask',1,1).'
        DistanceRelation(end+1,1)={ReadOuts.Name{Ind}};
        DistanceRelation{end,2}=accumarray_9(ReadOuts{[strfind1(ReadOuts.CalcType,'Mask',1);Ind],{'Data';'Name'}},{ones(Pix.','uint8'),'Volume'},@sum);
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