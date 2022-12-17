function [Data3Dcorr]=adjustEachPercPerLayer(Data3Dcorr,PercentileProfile,CorrectionFactor)


if size(CorrectionFactor,1)==1
    AdjustmentType='EachSlice';
else
    AdjustmentType='EachSlice&Percentile';
end
SliceNumber=size(Data3Dcorr,3);

if strcmp(AdjustmentType,'EachSlice')
    for m=1:SliceNumber
        Data3Dcorr(:,:,m)=Data3Dcorr(:,:,m)/CorrectionFactor(1,m);
    end
elseif strcmp(AdjustmentType,'EachSlice&Percentile')
    
    for m=1:SliceNumber
        if isnan(PercentileProfile(1,m))
            Data3Dcorr(:,:,m)=0;
            continue;
        end
        Data2D=Data3Dcorr(:,:,m);
        Data2Dcorr=Data2D;
        Selection=Data2D<=PercentileProfile(1,m);
        Data2Dcorr(Selection)= Data2D(Selection)/CorrectionFactor(1,m);
        for n=2:100
            Selection=Data2D<=PercentileProfile(n,m) & Data2D>PercentileProfile(n-1,m);
            Data2Dcorr(Selection)= Data2D(Selection)/CorrectionFactor(n,m);
        end
        Data3Dcorr(:,:,m)=Data2Dcorr(:,:);
    end
end