function [DigitalGain]=getBFinfo_DigitalGain(OriginalMetaData,Type,Ch)


try
    if strcmp(Type,'.lsm')
        SearchStrings={'DetectionChannel Amplifier Gain #'};
    elseif strcmp(Type,'.czi')
        DigitalGain=NaN;
        return;
        keyboard;
        SearchStrings={'Global Information|Image|Channel|Gain #';'Global Gain|Channel|Image|Information #'};
        [~,Wave1]=strfind1(OriginalMetaData.Tag,SearchStrings);
        SearchStrings=SearchStrings(max(Wave1(:)),1);
    end
    
    Path=[SearchStrings{1},num2str(Ch)];
    Ind=strfind1(OriginalMetaData.Tag,Path);
    
    DigitalGain=OriginalMetaData.Num(Ind);
catch
    DigitalGain=NaN;
end