function [Zoom]=getBFinfo_Zoom(OriginalMetaData,Type,Ch)



if strcmp(Type,'.lsm')
    SearchStrings={'Recording Zoom Y #1'};
elseif strcmp(Type,'.czi')
    SearchStrings={'Global Information|Image|Channel|LaserScanInfo|ZoomX #1';'Global ZoomX|LaserScanInfo|Channel|Image|Information #1'};
    [~,Wave1]=strfind1(OriginalMetaData.Tag,SearchStrings);
    SearchStrings=SearchStrings(max(Wave1(:)),1);
end

% Path=[SearchStrings{1},num2str(Ch)];
Ind=strfind1(OriginalMetaData.Tag,SearchStrings);
Zoom=OriginalMetaData.Num(Ind);

% % % Ind=strfind1(OriginalMetaData.Tag,'Wavelength');
% % % A1=OriginalMetaData(Ind,:);