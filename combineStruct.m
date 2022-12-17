function [combined]=combineStruct(structArray)
combined=struct;

for m=1:size(structArray,1);
    if isstruct(structArray{m})==0
        structArray{m}=struct;
    end
    M = [fieldnames(combined)', fieldnames(structArray{m})'; struct2cell(combined)', struct2cell(structArray{m})'];
    try
%         M = [fieldnames(combined)' fieldnames(structArray{m})'; struct2cell(combined)' struct2cell(structArray{m})'];
        
        combined=struct(M{:});
    catch % if fieldname present in both then delete field in first and refresh with the latter
        
        
        
        
        [tmp, rows] = unique(M(1,:), 'last');
        M=M(:, rows);
        
        combined=struct(M{:});
    end
end



% for m=1:size(structArray,1);
%     names = [fieldnames(combined); fieldnames(structArray{m})];
%     
%     
%     combined = cell2struct([struct2cell(combined); struct2cell(structArray{m})], names, 1);
% end