

function [Wavelength]=getBFinfo_Wavelength(OriginalMetaData,Type,Ch,Track)



if strcmp(Type,'.lsm')
    SearchStrings={'IlluminationChannel Name #'};
elseif strcmp(Type,'.czi')
    SearchStrings={'Global Information|Image|Channel|Wavelength #';'Global Wavelength|Channel|Image|Information #';'Global Information|Image|Channel|ExcitationWavelength #'};
    [~,Wave1]=strfind1(OriginalMetaData.Tag,SearchStrings);
    SearchStrings=SearchStrings(max(Wave1(:)),1);
end

Path=[SearchStrings{1},num2str(Track)];
Ind=strfind1(OriginalMetaData.Tag,Path);
if Ind==0
    keyboard;
    Track=1;
    Path=[SearchStrings{1},num2str(Track)];
    Ind=strfind1(OriginalMetaData.Tag,Path);
end

Wavelength=OriginalMetaData.Num(Ind);

% % % Ind=strfind1(OriginalMetaData.Tag,'Wavelength');
% % % A1=OriginalMetaData(Ind,:);

