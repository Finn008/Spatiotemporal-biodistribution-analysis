function [MasterGain]=getBFinfo_MasterGain(OriginalMetaData,Type,Ch)


try
    if strcmp(Type,'.lsm')
        SearchStrings={'DetectionChannel Detector Gain #'};
    elseif strcmp(Type,'.czi')
        SearchStrings={'Global Information|Image|Channel|Gain #';'Global Gain|Channel|Image|Information #'};
        [~,Wave1]=strfind1(OriginalMetaData.Tag,SearchStrings);
        SearchStrings=SearchStrings(max(Wave1(:)),1);
    end
    
    Path=[SearchStrings{1},num2str(Ch)];
    Ind=strfind1(OriginalMetaData.Tag,Path);
    
    MasterGain=OriginalMetaData.Num(Ind);
catch
    MasterGain=NaN;
end