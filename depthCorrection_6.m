function [Data4D,Out]=depthCorrection_6(In)
global W;
v2struct(In);
Out=struct;

%% check if depthCorrection info already exists
[Fileinfo,IndFileinfo,Path2file]=getFileinfo_2(FilenameTotal);
if isnumeric(TargetChannel)==0
    TargetChannel=strfind1(Fileinfo.ChannelList{1},TargetChannel);
end
try
    DepthCorrectionInfo=Fileinfo.Results{1}.DepthCorrectionInfo;
    DepthInfo=Fileinfo.Results{1}.DepthInfo;
    if istable(DepthCorrectionInfo)==0; DepthCorrectionInfo=table; end;
catch
    DepthCorrectionInfo=table;
end

RefreshDepthCorrection=1;
try
    if DepthCorrectionInfo.Datenum(TargetChannel,1)>datenum('2015.11.04 16:14','yyyy.mm.dd HH:MM') &&... % date of the last depthCorrection update version
            DepthCorrectionInfo.Datenum(TargetChannel,1)>Fileinfo.Datenum(1) % was the original file replaced by a newer one
        RefreshDepthCorrection=0;
        if strcmp(CorrType,'InVivo') && isequal(DepthCorrectionInfo.CorrectionRange{TargetChannel,1},CorrectionRange)==0
            RefreshDepthCorrection=1;
        end
        if strcmp(CorrType,'InVivoFixed') && DepthCorrectionInfo.Exponent(TargetChannel,1)~=Exponent
            RefreshDepthCorrection=1;
        end
        
    end
end
if RefreshDepthCorrection==0 && exist('DataOutput')~=1
    Out=[];
    Data4D=[];
    evalin('caller','global W;'); return;
end
if isfield(In,'Resolution'); keyboard; J.Resolution=In.Resolution; J.Fileinfo=Fileinfo; end;
[Data3D]=im2Matlab_3(FilenameTotal,TargetChannel,1);

OriginalData3D=Data3D;
SavePath=[W.G.PathOut,'\depthCorrection\',FilenameTotal];
%% refresh depthCorrectionInfo
% RefreshDepthCorrection=1;
if RefreshDepthCorrection==1
    Pix=[size(Data3D,1);size(Data3D,2);size(Data3D,3)];
    PixTotal=prod(Pix(:));
    if exist('Zres')==0; Zres=Fileinfo.Res{1}(3);end;
    if exist('Display')==0; Display=[];end;
    if exist('Inclusion')==0; Inclusion=[];end;
    
    % calculate histogram for the raw data and provide fit information
    J=struct;
    J.SavePath=SavePath;
    J.BaseName=num2str(TargetChannel);
    J.ZumBin=Zres;
    J.Zres=Zres;
    J.Display=Display;
    [Out1]=getHistograms_3(J,Data3D,Inclusion);
    try
        DepthInfo=Fileinfo.Results{1}.DepthInfo;
        if istable(DepthInfo)==0; DepthInfo=table; end;
    catch
        DepthInfo=table;
    end
    DepthInfo(TargetChannel,:)=emptyRow(DepthInfo);
    
    DepthInfo=fuseTable_3(DepthInfo,Out1.DepthInfo,[1,TargetChannel]);
    iFileChanger('W.G.Fileinfo.Results{Q1,1}.DepthInfo',DepthInfo,{'Q1',IndFileinfo});
    
    %% fit the data
    DepthCorrectionInfo(TargetChannel,:)=emptyRow(DepthCorrectionInfo);
    if exist('CorrType')~=1
        CorrType='None';
        DepthCorrectionInfo=fuseTable_3(DepthCorrectionInfo,DepthInfo(TargetChannel,:),[1,TargetChannel]);
        CorrectionFactor=ones(1,Pix(3));
    else
        DepthXaxis=linspace(0,Fileinfo.Um{1}(3),Pix(3));
        if strcmp(CorrType,'Immuno')
            J=struct;
            J.CorrType=CorrType;
            J.Xaxis=DepthXaxis.';
            J.NormPercentileProfile=Out1.NormPercentileProfileAvg;
            J.SavePath=SavePath;
            J.Zres=Zres;
            J.Fileinfo=Fileinfo;
            try; J.FitMinCenterMax=FitMinCenterMax; end;
            try; J.Exponent=Exponent; end;
            [FitOut]=fitFunction(J);
            
            DepthCorrectionInfo.FitTotal(TargetChannel,1)={FitOut.FitTotal};
            DepthCorrectionInfo.FitMinCenterMax(TargetChannel,1)={FitOut.FitMinCenterMax};
            DepthCorrectionInfo.Exponent(TargetChannel,1)=Exponent;
            % apply the fit information to the raw 3D stack
            Downshift=1;
            CorrectionFactor=FitOut.FitTotal*Downshift;
            
            [Data3D]=adjustEachPercPerLayer(Data3D,Out1.PercentileProfile{1:100,:},CorrectionFactor);
            
        end
        if strcmp(CorrType,'InVivoFixed')
            [Wave1]=returnLaserCorrection(FilenameTotal,TargetChannel);
            CorrectionFactor=Wave1.LaserProfile;
            FitOptics=YofBinFnc_2(DepthXaxis,[1;Exponent],[],'exp1');
            CorrectionFactor=CorrectionFactor.*FitOptics;
            CorrectionFactor=CorrectionFactor/max(CorrectionFactor(:));
            
            [CorrectionFactor]=optimizeCorrectionFactor(CorrectionFactor,Out1.PercentileProfile,'99.9995');
            [Data3D]=adjustEachPercPerLayer(Data3D,Out1.PercentileProfile,CorrectionFactor);
            DepthCorrectionInfo.Exponent(TargetChannel,1)=Exponent;
        end
        
        J=struct;
        J.SavePath=SavePath;
        J.BaseName=[num2str(TargetChannel),'corr'];
        J.ZumBin=Zres;
        J.Zres=Zres;
        J.Display=Display;
        [Out2]=getHistograms_3(J,Data3D,Inclusion);
        DepthCorrectionInfo=fuseTable_3(DepthCorrectionInfo,Out2.DepthInfo,[1,TargetChannel]);
%         keyboard;
        % display PercentileProfile
        J=struct;
        J.Path2file=[SavePath,'_Ch',num2str(TargetChannel),'DepthCorr.avi'];
        
        J.Tit=strcat({'Percentile: '},DepthInfo.Percentiles{TargetChannel}.Properties.RowNames(1:100),'%');
        J.Frequency=5;
        J.OrigYaxis=[...
            {Out1.NormPercentileProfile{1:100,:}},{'w.'};...
            {Out2.NormPercentileProfile{1:100,:}},{'r.'};...
            ];
        J.Xres=Zres;
        J.Xlab='Depth [µm]';
        J.Ylab='Yaxis';
        J.Yrange=[0;100];
        J.OrigType=2;
        movieBuilder_4(J);
    end
    DepthCorrectionInfo.CorrectionFactor(TargetChannel,1)={CorrectionFactor};
    iFileChanger('W.G.Fileinfo.Results{Q1,1}.DepthCorrectionInfo',DepthCorrectionInfo,{'Q1',IndFileinfo});
    
    
    
    
    
else
    PercentileProfile=DepthInfo.PercentileProfile{TargetChannel}{1:100,:};
    CorrectionFactor=DepthCorrectionInfo.CorrectionFactor{TargetChannel};
    
    [Data3D]=adjustEachPercPerLayer(Data3D,PercentileProfile,CorrectionFactor);
    Out.DepthCorrectionInfo=DepthCorrectionInfo(TargetChannel,:);
end
%% apply driftCorrectionInfo in the wanted manner
% 'Normal',[]: just provide normalized file without further changes
% 'AdjustmentFactor',[]: calculate change to original data
% 'Normalize2FirstFile','allPercentiles': equalize values for each percentile
% 'Normalize2FirstFile',[50;100]: equalize percentile range
% 'Normalize2Percentile',{'100',30000}: multiply such that percentile 100 is set to 30000
% 'IntensityBinning3D','allPercentiles': bin intensity ranges to one value
% 'IntensityBinningLayer','allPercentiles': bin intensity ranges to one value
if exist('DataOutput')~=1
    DataOutput=cell(0,0);
end
for m=1:size(DataOutput,1)
    Data3Dcorr=Data3D;
    
    
    %% AdjustmentFactor
    if strcmp(DataOutput{m,1},'AdjustmentFactor')==1
        Slice=round(DepthCorrectionInfo.FitMinCenterMax{TargetChannel,1}(1));
        BottomSliceNormalizer=mean(mean(Data4D(:,:,Slice,m-1)./OriginalData3D(:,:,Slice)));
        Data3Dcorr=uint16(double(Data4D(:,:,:,m-1))./double(OriginalData3D(:,:,:))/BottomSliceNormalizer*100);
    end
    if strcmp(DataOutput{m,1},'IntensityBinning3D')
        
        [PercTable]=generatePercTable(DataOutput{m,2},DepthCorrectionInfo,TargetChannel);
        Data3Dcopy=Data3Dcorr;
        Data3Dcopy(Data3Dcorr<=PercTable.SourceValue(1))=PercTable.TargetValue(1);
        for n=2:size(PercTable,1)
            Data3Dcopy(Data3Dcorr<=PercTable.SourceValue(n) & Data3Dcorr>PercTable.SourceValue(n-1))=PercTable.TargetValue(n);
        end
        Data3Dcorr=Data3Dcopy;
        clear Data3Dcopy;
    end
    %% adjust such that each layer is seperately set to percentiles 1 to 100
    if strcmp(DataOutput{m,1},'IntensityBinning2D')
        for m2=1:size(Data3Dcorr,3)
            [PercTable]=generatePercTable(DataOutput{m,2},DepthCorrectionInfo,TargetChannel,m2);
            Data2D=Data3Dcorr(:,:,m2);
            Data2Dcopy=Data2D;
            Data2D(Data2Dcopy<=PercTable.SourceValue(1))=PercTable.TargetValue(1);
            for m3=2:size(PercTable,1)
                Data2D(Data2Dcopy<=PercTable.SourceValue(m3) & Data2Dcopy>PercTable.SourceValue(m3-1))=PercTable.TargetValue(m3);
            end
            Data3Dcorr(:,:,m2)=Data2D;
        end
    end
    
    %% normalize to specified percentile
    if strcmp(DataOutput{m,1},'Normalize2FirstFile')
        RefF=W.G.T.F{W.Task}(1,:);
        [RefFileinfo]=GetFileInfo([RefF.filename{1},RefF.type{1}]);
        RefPercentilesAvg=RefFileinfo.depthCorrectionInfo{1}.PercentilesAvg{TargetChannel}{1:100,1};
        PercentilesAvg=DepthCorrectionInfo.PercentilesAvg{TargetChannel}{1:100,1};
        Ratio=PercentilesAvg./RefPercentilesAvg*100;
        
        if strcmp(DataOutput{m,2},'allPercentiles')
            NormalizationFactor=smooth(smooth(Ratio));
            
            SourceValues=DepthCorrectionInfo.Percentiles{TargetChannel}{1:100,1};
            
            Data3Dcopy=Data3Dcorr;
            Selection=logical(Data3Dcorr<=SourceValues(1));
            Data3Dcopy(Selection)=Data3Dcorr(Selection)*(100/NormalizationFactor(1));
            for n=2:100
                Selection=logical(Data3Dcorr<=SourceValues(n) & Data3Dcorr>SourceValues(n-1));
                Data3Dcopy(Selection)=Data3Dcorr(Selection)*(100/NormalizationFactor(n,1));
            end
            
            Data3Dcorr=Data3Dcopy;
            clear Data3Dcopy;
            Yaxis=[repmat(100,[100,1]),Ratio,NormalizationFactor];
            Path=[SavePath,',',num2str(TargetChannel),',NormalizeAllPercentiles','.emf'];
        elseif isnumeric(DataOutput{m,2})==1 % use range from 50 to 100 percentile for adjustment
            Start=DataOutput{m,2}(1,1);
            End=DataOutput{m,2}(2,1);
            NormalizationFactor=mean(Ratio(Start:End));
            Data3Dcorr=Data3Dcorr*(100/NormalizationFactor);
            Yaxis=[repmat(100,[100,1]),Ratio,repmat(NormalizationFactor,[100,1])];
            Path=[SavePath,',',num2str(TargetChannel),',NormalizeAllPercentilesRange','.emf'];
        end
        figureBuilder(Path,(1:100).',Yaxis,'Percentile [%]','Intensity',[],[],{'k-';'r.';'r-';},'PercentileComparison');
    end
    %% normalize to specified percentile
    if strcmp(DataOutput{m,1},'Normalize2Percentile')==1
        PercentileNormalizer=table;
        PercentileNormalizer.SourcePerc=DataOutput{m,2}{1,1};
        PercentileNormalizer.TargetValue=double(DataOutput{m,2}{1,2});
        PercentileNormalizer.CurrentValue=double(DepthCorrectionInfo.PercentilesAvg{TargetChannel}{PercentileNormalizer.SourcePerc,1});
        PercentileNormalizer.FinalFactor=PercentileNormalizer.TargetValue/PercentileNormalizer.CurrentValue;
        
        Data3Dcorr=Data3Dcorr*PercentileNormalizer.FinalFactor;
    end
    %% convert to selected bittype
    if size(DataOutput,2)==3 && isempty(DataOutput{m,3})==0
        TargetBitType=DataOutput{m,3};
        SourceBitType=class(Data3Dcorr);
        if strcmp(TargetBitType,'uint8') && strcmp(SourceBitType,'uint16')
            %             Data3Dcorr=Data3Dcorr/256;
            Data3Dcorr=uint8(Data3Dcorr);
        end
        
    end
    
    %% store the adjusted data in the output stack Data4D
    Data4D(m,1)={Data3Dcorr}; % Data4D(:,:,:,m)=Data3Dcorr(:,:,:);
end
if exist('Data4D')==1 & size(Data4D,1)==1
    Data4D=Data4D{1};
end

evalin('caller','global W;');