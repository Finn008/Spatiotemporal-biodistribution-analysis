function [Transmission]=getBFinfo_Transmission(OriginalMetaData,Type,Ch,FilenameTotal,Track) % originally readTransmissionMetaData

if strcmp(Type,'.lsm')
    Ind=strfind1(OriginalMetaData.Tag,['IlluminationChannel Power #',num2str(Track)]);
    if Ind==0
        keyboard;
        Track=1;
        Ind=strfind1(OriginalMetaData.Tag,['IlluminationChannel Power #',num2str(Track)]);
    end
    Transmission=OriginalMetaData.Value{Ind};
    Ind=strfind1(OriginalMetaData.Tag,'IlluminationChannel Power B/C ');
    IndSub=strfind1(OriginalMetaData.Tag(Ind),['#',num2str(Track)]);
    Ind=Ind(IndSub);
    Selection=OriginalMetaData(Ind,:);
    TransmissionTrend=OriginalMetaData.Num(Ind);
elseif strcmp(Type,'.czi')
    SearchStringTrend={'Global Experiment|AcquisitionBlock|MultiTrackSetup|TrackSetup|Attenuator|Transmission #';'Global Transmission|Attenuator|TrackSetup|MultiTrackSetup|AcquisitionBlock|Experiment #'};
    [~,Wave1]=strfind1(OriginalMetaData.Tag,SearchStringTrend);
    SearchStringTrend=SearchStringTrend(max(Wave1(:)),1);
    Ind=strfind1(OriginalMetaData.Tag,SearchStringTrend);
    % do not look for subchannel
    Selection=OriginalMetaData(Ind,:);
    TransmissionTrend=OriginalMetaData.Num(Ind);
end


if sum(TransmissionTrend)~=0
    Transmission=TransmissionTrend;
end

if find(TransmissionTrend==0.0020)
    keyboard;
    Transmission=Transmission(Transmission~=0.0020);
end
if sum(strfind1(OriginalMetaData.Tag,'BleachSetup'))~=0 && datenum(now)<datenum('2016.04.20','yyyy.mm.dd') && strfind(FilenameTotal,'Sophie')
    %WeirdBleach
    keyboard;
    Transmission=Transmission(1);
end

if strcmp(Type,'.czi')
    Transmission=Transmission*100;
end
if size(Transmission,1)>1
    Transmission=[min(Transmission);max(Transmission)];
end
