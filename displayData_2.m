function displayData_2(In)
global W;
Wave1=strfind1(W.G.Fileinfo.DisplayData,'Do#Go|');
FileList=W.G.Fileinfo(Wave1,:);


for m=1:size(FileList,1)
    DisplayData=variableExtract(FileList.DisplayData{m,1});
    SavePath=[W.G.PathOut,'\depthCorrection\',FileList.FilenameTotal{m,1}];
    Pix=FileList.Pix{m,1};
    Xaxis=linspace(0,FileList.Um{m,1}(3),FileList.Pix{m,1}(3));
    if strcmp(DisplayData.Type,'BeforeAfterDepthCorrection')
        try
            DepthInfo=FileList.Results{m,1}.DepthInfo;
        catch
            disp([FileList.FilenameTotal{m,1},'       no DepthInfo available']);
            continue;
        end
        DepthCorrectionInfo=FileList.Results{m,1}.DepthCorrectionInfo;
        
        
        clear Container;
        Container{1,1}=DepthInfo.PercentileProfile{1,1};
        Container{2,1}=DepthCorrectionInfo.PercentileProfile{1,1};
        Container{3,1}=DepthInfo.PercentileProfile{2,1};
        Container{4,1}=DepthCorrectionInfo.PercentileProfile{2,1};
        
        for m2=1:4
            PercentileProfile=double(Container{m2,1}{:,:});
            NormPercentileProfile=PercentileProfile;
            for n=1:size(PercentileProfile,1);
                NormPercentileProfile(n,:)=PercentileProfile(n,:)/max(PercentileProfile(n,:))*100;
            end
            Container{m2,1}=NormPercentileProfile;
        end
        
        NormPercentileProfileBlue1=Container{1,1};
        NormPercentileProfileBlue2=Container{2,1};
        NormPercentileProfileRed1=Container{3,1};
        NormPercentileProfileRed2=Container{4,1};
        CorectionFactorBlue=DepthCorrectionInfo.CorrectionFactor{1,1};
        CorectionFactorBlue=max(CorectionFactorBlue(:))./CorectionFactorBlue;
        CorectionFactorBlue=CorectionFactorBlue/max(CorectionFactorBlue(:))*100;
        
        CorectionFactorRed=DepthCorrectionInfo.CorrectionFactor{2,1};
        CorectionFactorRed=max(CorectionFactorRed(:))./CorectionFactorRed;
        CorectionFactorRed=CorectionFactorRed/max(CorectionFactorRed(:))*100;
        
        TargetPercentile=60;
        J=struct;
        J.Tit=[num2str(TargetPercentile),'%,Blue(w),Red(r),Before(-),After(o)'];
        J.X=Xaxis;
        
        J.OrigYaxis=[...
            {NormPercentileProfileBlue1(TargetPercentile,:)},{'w-'};...
            {NormPercentileProfileBlue2(TargetPercentile,:)},{'wo'};...
            {CorectionFactorBlue},{'w.'};...
            {NormPercentileProfileRed1(TargetPercentile,:)},{'r-'};...
            {NormPercentileProfileRed2(TargetPercentile,:)},{'ro'};...
            {CorectionFactorRed},{'r.'};...
            ];
        J.OrigType=2;
        J.Xlab='depth [µm]';
        J.Ylab='intensity [a.u.]';
        J.Xrange=[0;max(Xaxis)];
        J.Yrange=[0;100];
        J.Style=1;
        J.Path2file=[SavePath,',BeforeAfterDepthCorrection.jpg'];
        movieBuilder_4(J);
        
    elseif strcmp(DisplayData.Type,'PercentileProfile')
        
        
        [Out]=returnLaserCorrection(FileList.FilenameTotal{m,1});
        
        LaserProfile=linspace(1,1/Out.LaserRatio,Pix(3));
        keyboard; %PercentileProfile now uint16 not table anymore
        AllPercentiles=FileList.Results{m,1}.DepthInfo.PercentileProfile{1,1}.Properties.RowNames;
        PercNumber=size(AllPercentiles,1);
        
        Exponent=[0.004;0.005];
        DepthInfo=FileList.Results{m,1}.DepthInfo;
        for m1=1:2
            OpticProfile=exp(-Xaxis*Exponent(m1,1)); OpticProfile=OpticProfile/min(OpticProfile);
            PercentileProfile=double(DepthInfo.PercentileProfile{m1,1}{:,:});
            LaserCorrPercentileProfile=PercentileProfile.*repmat(LaserProfile,[PercNumber,1]); % correct PercentileProfile for LaserProfile
            LaserOpticCorrPercentileProfile=LaserCorrPercentileProfile.*repmat(OpticProfile,[PercNumber,1]);
            [NormPercentileProfile]=normalizePercProfile(PercentileProfile);
            [NormLaserCorrPercentileProfile]=normalizePercProfile(LaserCorrPercentileProfile);
            [NormLaserOpticCorrPercentileProfile]=normalizePercProfile(LaserOpticCorrPercentileProfile);
            
            DepthInfo.NormPercentileProfile{m1,1}=NormPercentileProfile;
            DepthInfo.NormLaserCorrPercentileProfile{m1,1}=NormLaserCorrPercentileProfile;
            DepthInfo.NormLaserOpticCorrPercentileProfile{m1,1}=NormLaserOpticCorrPercentileProfile;
            DepthInfo.OpticProfile{m1,1}=OpticProfile;
        end
        LaserProfile=LaserProfile/max(LaserProfile)*100;
        OpticProfile1=DepthInfo.OpticProfile{1,1}/max(DepthInfo.OpticProfile{1,1})*100;
        OpticProfile2=DepthInfo.OpticProfile{2,1}/max(DepthInfo.OpticProfile{2,1})*100;
        
        J=struct;
        J.Tit=strcat({'Percentile: '},AllPercentiles(1:PercNumber),'%');
        J.Frequency=5;
        J.X=Xaxis;
        J.OrigYaxis=[   {DepthInfo.NormLaserCorrPercentileProfile{1,1}(1:PercNumber,:)},{'w.'};... % channel 1 corrected for laser adjustment
            {DepthInfo.NormLaserCorrPercentileProfile{2,1}(1:PercNumber,:)},{'r.'};... % channel 2 corrected for laser adjustment
            {DepthInfo.NormLaserOpticCorrPercentileProfile{1,1}(1:PercNumber,:)},{'c.'};... % channel 1 after including exponent
            {DepthInfo.NormLaserOpticCorrPercentileProfile{2,1}(1:PercNumber,:)},{'y.'};... % channel 2 after including exponent
            {repmat(LaserProfile,[PercNumber,1])},{'g-'};... % laser transmission change
            {repmat(OpticProfile1,[PercNumber,1])},{'w-'};... % change of channel 1 due to exponential decay
            {repmat(OpticProfile2,[PercNumber,1])},{'r-'};... % change of channel 2 due to exponential decay
            ];
        J.OrigType=2;
        J.Xlab='depth [µm]';
        J.Ylab='intensity [a.u.]';
        J.Xrange=[0;max(Xaxis)];
        J.Yrange=[0;100];
        J.Layout='black';
        J.Path=[SavePath,',NormPercentileProfile.avi'];
        movieBuilder_4(J);
        
    elseif strcmp(DisplayData.Type,'Ableitung')
        
        J=struct;
        J.Path=[SavePath,',',BaseName,',Ableitung.avi'];
        J.Tit=strcat({'Percentile: '},AllPercentiles,'%');
        J.Frequency=5;
        J.Y=Abl;
        J.Xres=Zres;
        J.Xlab='depth [µm]';
        J.Ylab='Yaxis';
        J.Xrange=ZumRange;
        J.Yrange=[-1;1];
        J.Sp={'w.';'r.';'c.'};
        J.Layout='black';
        J.AddLine=[{FitMinCenterMax(1);-1;FitMinCenterMax(1);+1;{'Color','w'}},{FitMinCenterMax(3);-1;FitMinCenterMax(3);+1;{'Color','w'}}];
        movieBuilder_3(J);
        
    end
    
    Wave1=variableSetter_2(W.G.Fileinfo.DisplayData{m,1},{'Do','Fin'});
    iFileChanger('W.G.Fileinfo.DisplayData{Q1,1}',Wave1,{'Q1',FileList.Properties.RowNames{m}});
end
A1=1;

