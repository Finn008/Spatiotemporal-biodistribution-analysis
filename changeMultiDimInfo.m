function changeMultiDimInfo()
global W;
Fileinfo=W.G.Fileinfo;
% go through W.G.Fileinfo.Results.DepthCorrectionInfo and DepthInfo
Wave1=whos('Fileinfo');
SizeGB(1,1)=Wave1.bytes/1000000000;
Timer=datenum(now);
for m=1:size(Fileinfo)
    
    try
        Fileinfo.Results{m,1}.DepthCorrectionInfo=convertPPback(Fileinfo.Results{m,1}.DepthCorrectionInfo);
    end
    try
        Fileinfo.Results{m,1}.DepthInfo=convertPPback(Fileinfo.Results{m,1}.DepthInfo);
    end
    try
        MultiDimInfo=Fileinfo.Results{m,1}.MultiDimInfo;
        if istable(MultiDimInfo)
            for Row=1:size(MultiDimInfo,1)
                for Col=1:size(MultiDimInfo,2)
                    
                    try
                        MultiDimInfo{Row,Col}{1}=rmfield(MultiDimInfo{Row,Col}{1},{'Fileinfo';'P';'FA'});
                    end
%                     MultiDimInfo{Row,Col}{1}.Fileinfo=[];
%                     MultiDimInfo{Row,Col}{1}.P=[];
%                     MultiDimInfo{Row,Col}{1}.FA=[];
% % % % % % %                     try
% % % % % % %                         MultiDimInfo{Row,Col}{1}.Fileinfo.Results{1}.DepthCorrectionInfo=convertPPback(MultiDimInfo{Row,Col}{1}.Fileinfo.Results{1}.DepthCorrectionInfo);
% % % % % % %                     end
% % % % % % %                     try
% % % % % % %                         MultiDimInfo{Row,Col}{1}.Fileinfo.Results{1}.DepthInfo=convertPPback(MultiDimInfo{Row,Col}{1}.Fileinfo.Results{1}.DepthInfo);
% % % % % % %                     end
                end
            end
        end
        Fileinfo.Results{m,1}.MultiDimInfo=MultiDimInfo;
    end
    if datenum(now)-Timer>(1/24/60/60*20)
        disp(m);
        Timer=datenum(now);
    end
end

Wave1=whos('Fileinfo');
SizeGB(2,1)=Wave1.bytes/1000000000;

keyboard;
keyboard; % really?
keyboard; % really?
W.G.Fileinfo=Fileinfo;

function [DepthInfo]=convertPP(DepthInfo)
keyboard;
for m=1:size(DepthInfo,1)
    DepthInfo.PercentileProfile(m,1)={uint16(DepthInfo.PercentileProfile{m,1}{:,:})};
end

function [DepthInfo]=convertPPback(DepthInfo)

for m=1:size(DepthInfo,1)
    Wave1=DepthInfo.Percentiles{m,1};
    Wave2=DepthInfo.PercentileProfile{m,1};
    Wave1{:,1:size(Wave2,2)}=Wave2;
    DepthInfo.PercentileProfile(m,1)={Wave1};
end