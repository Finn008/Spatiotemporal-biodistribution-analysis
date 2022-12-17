function Out=filenameExtract(FilenameTotal)
Wave1=regexprep(FilenameTotal,'.ims','_');
[Out]=variableExtract(Wave1,{'Ex';'M';'Roi';'Ty';'Hem';'Dat';'Tr';'Ihc';'Ihd';'REG';'Line';'Slice';'Age'},{'None','_'});

return;
%%
% Age: Age
% Ex: Experimentor
% M: MouseId
% Roi: Roi
% Ty: ImageType
% Hem: Hemisphere
% Dat: Date
% REG: BrainRegion
% Tr: Treatment
% Ihc: ImmunoStaining antibodies
% Ihd: ImmunoStaining date/id'
% Line: MouseLine

