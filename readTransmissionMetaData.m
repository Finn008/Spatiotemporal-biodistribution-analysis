function [Transmission]=readTransmissionMetaData(OriginalMetaData,Ind,FilenameTotal,Type)
keyboard;
Transmission=OriginalMetaData(Ind,:);
Transmission=sortrows(Transmission,'Tag');
Transmission=cell2mat(Transmission.Value);

TrNumber=size(Transmission,1);
ValSum=sum(Transmission);
DiffNumber=size(unique(Transmission),1);

if ValSum==0
    Output='AllZero';
    Transmission=NaN;
elseif TrNumber==4
    Output='MoreThan3';
    Transmission=NaN;
elseif find(Transmission==0.0020)
    Output='0.0020';
    Transmission=Transmission(Transmission~=0.0020);
elseif TrNumber==1
    Output='OnlyOne';
elseif DiffNumber<3
    Output='2entries';
elseif Transmission(1)>min(Transmission(:)) && Transmission(1)<max(Transmission(:))
    Output='MiddleFirst';
elseif sum(strfind1(OriginalMetaData.Tag,'BleachSetup'))~=0 && datenum(now)<datenum('2016.04.20','yyyy.mm.dd') && strfind(FilenameTotal,'Sophie')
    Output='WeirdBleach';
    Transmission=Transmission(1);
else
    Output='Remaining';
    keyboard;
end

if strcmp(Type,'.czi')
    Transmission=Transmission*100;
end
Transmission=[min(Transmission);max(Transmission)];

