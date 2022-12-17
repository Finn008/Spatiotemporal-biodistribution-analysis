function [CorrectionFactor]=optimizeCorrectionFactor(CorrectionFactor,PercentileProfile,NormalizationPerc)
if size(CorrectionFactor,1)==1
    AdjustmentType='EachSlice';
else
    AdjustmentType='EachSlice&Percentile';
end
% adjust the CorrectionFactor such that it avoids division by more than 1
if exist('NormalizationPerc')==1
    if strcmp(AdjustmentType,'EachSlice&Percentile')
        keyboard;
    end
    Matrix=table;
    Matrix.CorrectionFactor=CorrectionFactor.';
    Matrix.RequiredFactor=ones(size(Matrix,1),1)./Matrix.CorrectionFactor; % check what factor is necessary to compensate for strongest downgrading
    Matrix.NormPercValue=double(PercentileProfile{NormalizationPerc,:}.');
    Matrix.PossibleFactor=repmat(65535,[size(Matrix,1),1])./Matrix.NormPercValue; % calculate maximal multiplication factor normalizing NormalizationPerc to 65535 for each bin
    MaxRequiredFactor=max(Matrix.RequiredFactor(:));
    MaxPossibleFactor=min(Matrix.PossibleFactor(:));
    if MaxRequiredFactor>1
        % adjust maximally to the RequiredFactor
        FinalFactor=min(MaxRequiredFactor,MaxPossibleFactor);
        CorrectionFactor=CorrectionFactor*FinalFactor;
    end
    
end