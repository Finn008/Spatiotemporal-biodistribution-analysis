function [Detection]=getBFinfo_Detection(OriginalMetaData,Type,Ch,FilenameTotal)

Detection=nan(1,2);
if strcmp(Type,'.lsm')
    Ind=strfind1(OriginalMetaData.Tag,['DetectionChannel SPI Wavelength Start #',num2str(Ch)]);
%     if Ind==0
%         Ch=1;
%         Ind=strfind1(OriginalMetaData.Tag,['IlluminationChannel Power #',num2str(Ch)]);
%     end
    Detection=OriginalMetaData.Value{Ind};
    Ind=strfind1(OriginalMetaData.Tag,['DetectionChannel SPI Wavelength End #',num2str(Ch)]);
    Detection(1,2)=OriginalMetaData.Value{Ind};
elseif strcmp(Type,'.czi')
    Detection=[NaN,NaN];
%     keyboard;
%     SearchStringTrend={'Global Experiment|AcquisitionBlock|MultiTrackSetup|TrackSetup|Attenuator|Transmission #';'Global Transmission|Attenuator|TrackSetup|MultiTrackSetup|AcquisitionBlock|Experiment #'};
%     [~,Wave1]=strfind1(OriginalMetaData.Tag,SearchStringTrend);
%     SearchStringTrend=SearchStringTrend(max(Wave1(:)),1);
%     Ind=strfind1(OriginalMetaData.Tag,SearchStringTrend);
%     % do not look for subchannel
%     Selection=OriginalMetaData(Ind,:);
%     TransmissionTrend=OriginalMetaData.Num(Ind);
end