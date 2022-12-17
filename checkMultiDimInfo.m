function checkMultiDimInfo(FileinfoList)
global W;
% % % FileinfoList=W.G.Fileinfo(strfind1(W.G.Fileinfo.FilenameTotal,'X156'),:);
% % % FileinfoList=FileinfoList(strfind1(FileinfoList.FilenameTotal,'Trace.ims'),:);

for File=1:size(FileinfoList,1)
    FitCoefCompare=1;
    try
        MultiDimInfo=FileinfoList.Results{File,1}.MultiDimInfo;
        ChannelNumber=size(MultiDimInfo,2);
        Timepoints=size(MultiDimInfo,1);
        
        VariableNames=MultiDimInfo.Properties.VariableNames.';
        for Var=1:size(VariableNames,1)
            FitCoefs=[];
            for Time=1:Timepoints
                Wave1=MultiDimInfo{Time,VariableNames(Var)}{1}.U.FitCoefs(1:3,3).';
                FitCoefs=[FitCoefs;Wave1];
            end
            if Var==1
                FitCoefsFirstVar=FitCoefs;
            else
                if isequal(FitCoefs,FitCoefsFirstVar)~=1
                    keyboard;
                end
            end
        end
        if File>1 && isequal(FitCoefs,FileinfoList.MDIfitcoefs{FitCoefCompare,1})
            FitCoefs=1;
        end
    catch
        ChannelNumber=NaN;
    end
    FileinfoList.MDIchannels(File,1)=ChannelNumber;
    FileinfoList.MDItimepoints(File,1)=Timepoints;
    FileinfoList.MDIfitcoefs(File,1)={FitCoefs};
end
keyboard;