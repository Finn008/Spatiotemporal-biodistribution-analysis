function spectralAnalysis()
global W;

F=W.G.T.F{W.Task}(W.File,:);
FilenameTotal=[F.Filename{1},'.ims'];
[FctSpec]=variableExtract(F.SpectralAnalysis{1},{'Do';'Step'});


[Fileinfo,~,Path2file]=getFileinfo_2(FilenameTotal);

if FctSpec.Step==0
    Application=openImaris_2(Path2file);
    setVisible(Application);
    
    [Data]=im2Matlab_2(Application);
    Data=permute(Data,[1,2,3,5,4]);
    SpectralRange=Fileinfo.ChannelList{1};
    for m=1:size(SpectralRange,1)
        SpectralRangeNum(m,1)=str2num(SpectralRange{m,1});
    end
    
    SummedIntensity=sum(Data,4);
    SummedIntensity=uint8(SummedIntensity./max(SummedIntensity(:))*255);
    ex2Imaris_2(SummedIntensity,Application,'SummedIntensity',1);
    
    % generate 3D map with max wavelength
    Pix=size(MaxData).';
    MaxData=maxID(Data);
    MaxData=uint8(MaxData);
    ex2Imaris_2(MaxData,Application,'MaxWavelength',1);
    MaxDataInvert=repmat(max(MaxData(:)),[Pix(1),Pix(2),Pix(3)])-MaxData;
    ex2Imaris_2(MaxDataInvert,Application,'MaxWavelengthInvert',1);
    
    % generate gaussian filtered MaxWavelength
    J=struct;
    J.Res=Fileinfo.Res{1};
    J.Type='Gaussian3D';
    J.Kernel=0.6;
    J.Repeat=3;
    [MaxDataGaussian,Out]=interpolate3D(MaxData,J);
    ex2Imaris_2(uint8(MaxDataGaussian),Application,'MaxWavelengthGaussian',1);
    
    ObjectInfo=table;
    ObjectInfo.Name={'BlueAutofluo';'RedAutofluo';'Intensity';'Spots1'};
    ObjectInfo.Properties.RowNames=ObjectInfo.Name;
    
    
    
    % import surface info
    for Obj=2:size(ObjectInfo,1)
        Object=ObjectInfo.Name{Obj,1};
        [Statistics]=getObjectInfo_2(Object,[],Application);
        ObjectInfo.Statistics(Obj,1)={Statistics};
    end
    
    [ObjectInfo]=spectralAnalysis_Sub1(ObjectInfo,SpectralRange,SpectralRangeNum);
    
    
        
      
    
    
    
    
    
    %     J=struct;J.Application=Application;J.Channels='AutofluoSurf1';J.Feature='Id';
    %     [AutofluoSurf1]=im2Matlab_2(J);
    %
    %     Table=table;
    %     Table.Id=unique(AutofluoSurf1);
    %     Table(1,:)=[];
    %
    %
    %     J=struct; J.ExcludeRoiIds={[0]};
    %     for Ch=1:size(Data,4)
    %         Out=Summer_3({Data(:,:,:,Ch)},{AutofluoSurf1},J);
    %         Size(Ch,:)=Out.NumRes.';
    %         IntensitySum(Ch,:)=Out.SumRes.';
    %     end
    %     MeanMax=0;
    %     for m=1:size(Table,1)
    %         Spectrum=table;
    %         Spectrum.Axis=SpectralRangeNum;
    %         Spectrum.Properties.RowNames=SpectralRange;
    %         Spectrum.Sum=IntensitySum(:,m);
    %         Spectrum.Mean=IntensitySum(:,m)./Size(:,m);
    %         MeanMax=max(MeanMax,max(Spectrum.Mean(:)));
    %         Spectrum.Norm=Spectrum.Mean/max(Spectrum.Mean(:))*100;
    %         Table.Spectrum(m,1)={Spectrum};
    %     end
    
    %     for m=1:size(Table,1)
    %         Table.Spectrum{m,1}.NormTotal=Table.Spectrum{m,1}.Mean/MeanMax*100;
    %     end
    
    
    
    
    quitImaris(Application);
    
    SpectralResults=struct;
    SpectralResults.Table=Table;
    
    Path=[F.Filename{1},'_SpectralResults.mat'];
    Path=getPathRaw(Path);
    save(Path,'_SpectralResults');
    
    Wave1=variableSetter_2(F.SpectralAnalysis{1},{'Do','Fin';'Step','1'});
    iFileChanger('W.G.T.F{W.Task,1}.SpectralAnalysis{W.File}',Wave1);
end

if FctSpec.Step==1
    
    [ObjectInfo]=spectralAnalysis_Sub2(ObjectInfo);
    
    
end
