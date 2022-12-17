function [ObjectInfo]=spectralAnalysis_Sub1(ObjectInfo,SpectralRange,SpectralRangeNum);

for Obj=1:size(ObjectInfo,1)
    ObjInfo=ObjectInfo.Statistics{Obj,1}.ObjInfo;
    ObjInfo2=table({[]},'VariableNames',{'Axis'},'RowNames',{'Original'});
    MeanMax=0;
    ChannelNames=ObjectInfo.Statistics{Obj,1}.ChannelNames;
    for m=1:size(ObjInfo,1)
        Spectrum=table(SpectralRangeNum,'VariableNames',{'Axis'},'RowNames',SpectralRange);
        Spectrum.Sum=ObjInfo.IntensitySum(m,1:32).';
        Spectrum.Mean=ObjInfo.IntensityMean(m,1:32).';
        Spectrum.StdDev=ObjInfo.IntensityStdDev(m,1:32).';
        MeanMax=max(MeanMax,max(Spectrum.Mean(:)));
        Spectrum.NormMean=Spectrum.Mean/max(Spectrum.Mean(:))*100;
        Spectrum.NormStdDev=Spectrum.StdDev/max(Spectrum.Mean(:))*100;
        ObjInfo.Spectrum(m,1)={Spectrum};
        Wave1=find(smooth(Spectrum.Mean)==max(smooth(Spectrum.Mean)));
        ObjInfo.MaxWavelength(m,1)=Spectrum.Axis(Wave1,1);
    end
    for m=1:size(ObjInfo,1)
        Spectrum=ObjInfo.Spectrum{m,1};
        Spectrum.NormTotalMean=Spectrum.Mean/MeanMax*100;
        Spectrum.NormTotalStDev=Spectrum.StdDev/MeanMax*100;
        ObjInfo.Spectrum(m,1)={Spectrum};
        
        for Var=Spectrum.Properties.VariableNames
            try
                Wave1=ObjInfo2{'Original',Var{1}}{1};
                ObjInfo2{'Original',Var{1}}{1}=[Wave1,ObjInfo.Spectrum{m,1}{:,Var}];
            catch 
                ObjInfo2{'Original',Var{1}}={ObjInfo.Spectrum{m,1}{:,Var}};
            end
        end
    end
    for Var={'Sum','Mean','NormMean','NormTotalMean'}
        Data=ObjInfo2{'Original',Var}{1};
        Table=table;
        Table.Mean=mean(Data,2);
        Table.StDev=std(Data,0,2);
        ObjInfo2{'Mean',Var}={Table};
    end
    
    ObjectInfo.Statistics{Obj,1}.ObjInfo=ObjInfo;
    ObjectInfo.Statistics{Obj,1}.ObjInfo2=ObjInfo2;
    
end