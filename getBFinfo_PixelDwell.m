function [PixelDwell]=getBFinfo_PixelDwell(OriginalMetaData,Type,Ch)



if strcmp(Type,'.lsm')
    SearchStrings={'Track Pixel Time #1'};
elseif strcmp(Type,'.czi')
    SearchStrings={'Global Information|Image|Channel|LaserScanInfo|PixelTime #1';'Global PixelTime|LaserScanInfo|Channel|Image|Information #1'};
    [~,Wave1]=strfind1(OriginalMetaData.Tag,SearchStrings);
    SearchStrings=SearchStrings(max(Wave1(:)),1);
end

% Path=[SearchStrings{1},num2str(Ch)];
Ind=strfind1(OriginalMetaData.Tag,SearchStrings);
PixelDwell=OriginalMetaData.Num(Ind);

% % % Ind=strfind1(OriginalMetaData.Tag,'Wavelength');
% % % A1=OriginalMetaData(Ind,:);