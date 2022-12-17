function changeStructChildren(Data)
keyboard; % not used since 2015.12.23

global W;
% row2delete=zeros(0,1,'double');


Data(any(cellfun(@(x) any(isnan(x)),Data.Do),2),:) = [];
for m = 1:size(Data,1)
    [DoType]=variableExtract(Data.Do{m},{'Empty'});
    %     [DoType]=variableExtract(Data.Do{m},{'Delete';'move'});
    try
        if DoType.Delete==1;
            Path=[Data.Path{m,1},'=[];'];
            eval(Path);
        end
        
%         if DoType.Table2uint16==1
            
%         end
    end
    % % %     if DoType.Delete==1;
    % % %         Dots=strfind(Data.Path{m,1},'.');
    % % %         MotherName=Data.Path{m,1}(1:Dots(end)-1);
    % % %         Child=Data.Path{m,1}(Dots(end)+1:end);
    % % %         Path=['MotherProxy=',MotherName,';'];
    % % %         eval(Path);
    % % %         try
    % % %             if isstruct(MotherProxy)
    % % %                 Path=[MotherName,'=rmfield(',MotherName,',''',Child,''');'];
    % % %                 eval(Path);
    % % %             else
    % % %                 A1=asdf;
    % % %             end
    % % %         catch
    % % %         end
    % % %     end
    
end
A1=1;


function table2uint16()
global W;

for m=1:size(W.G.Fileinfo,1)
%     m=3334;
    for m2=1:2
        try
            Wave1=W.G.Fileinfo.Results{m,1}.DepthInfo.PercentileProfile{m2,1};
            RowNames=Wave1.Properties.RowNames;
            a=uint16(W.G.Fileinfo.Results{m,1}.DepthInfo.PercentileProfile{m2,1}{:,:});
            Wave2=array2table(a,'RowNames',RowNames);
            W.G.Fileinfo.Results{m,1}.DepthInfo.PercentileProfile{m2,1}=Wave2;
        end
        try
            Wave1=W.G.Fileinfo.Results{m,1}.DepthCorrectionInfo.PercentileProfile{m2,1};
            RowNames=Wave1.Properties.RowNames;
            a=uint16(W.G.Fileinfo.Results{m,1}.DepthCorrectionInfo.PercentileProfile{m2,1}{:,:});
            Wave2=array2table(a,'RowNames',RowNames);
            W.G.Fileinfo.Results{m,1}.DepthCorrectionInfo.PercentileProfile{m2,1}=Wave2;
        end
    end
end
