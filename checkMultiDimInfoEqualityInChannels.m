function [FitCoefs]=checkMultiDimInfoEqualityInChannels(MultiDimInfo)
% keyboard; % not working yet
VariableNames=MultiDimInfo.Properties.VariableNames.';
Timepoints=size(MultiDimInfo,1);
for Time=1:Timepoints
%     FirstFitCoefB2Trace=[];
    for Var=1:size(VariableNames,1)
        try
            FitCoef=MultiDimInfo{Time,VariableNames(Var)}{1}.U.FitCoefs(1:3,3).';
            if Var==1
                FitCoefs(Time,1:3)=FitCoef;
            elseif isequal(FitCoefsFirstVar(Time,1:3),FitCoef)~=1
                keyboard;
            end
        catch
        end
%         if isstruct(Wave1)
%             Wave1=Wave1.
%             FitCoefB2Trace=[FitCoefB2Trace;Wave1];
%             
%         end
    end
%     A1=unique(FitCoefB2Trace);
%     if Var==1
%         FitCoefsFirstVar=FitCoefB2Trace;
%     else
%         if isequal(FitCoefB2Trace,FitCoefsFirstVar)~=1
%             keyboard;
%         end
%     end
end