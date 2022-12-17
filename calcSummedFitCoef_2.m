% FA,FirstFileId,ResAdjust,ApplyDriftinfo
function [FA,Volume]=calcSummedFitCoef_2(FA,ResAdjust)
global W;

if isstruct(FA)
    v2struct(FA);
% else
%    FA=In;
end
% v2struct(In);
Driftinfo=W.G.Driftinfo;
VariableNames=FA.Properties.VariableNames.';
if isempty(FA)
    FA=table;
    FA.FitCoefOrder=W.G.T.F{W.Task}.FitCoefOrder(:,1);
    FA.FilenameTotal=strcat(W.G.T.F{W.Task}.Filename,W.G.T.F{W.Task}.Type);
    FA.RefFilename=W.G.T.F{W.Task}.FitReference(:,1);
    FA.SourceChannel=W.G.T.F{W.Task}.SourceChannel;
    FA.SourceTimepoint=W.G.T.F{W.Task}.SourceTimepoint;
    FA.TargetChannel=W.G.T.F{W.Task}.TargetChannel(:,1);
    FA.TimeLine=W.G.T.F{W.Task}.TimeLine(:,1);
    FA.TargetTimepoint=W.G.T.F{W.Task}.TargetTimepoint(:,1);
    [Wave1,Wave2]=strfind1(FA.TimeLine,'DoGo');
    FA(Wave2~=1,:)=[];
    FA=sortrows(FA,1);
end
if exist('VolumeType')==0
    VolumeType='Optimal'; % could also be such that first or specified file is in center (advantage that files could be added subsequently)
end
if exist('ApplyDriftinfo')==0
    ApplyDriftinfo=0;
end
if strfind1(VariableNames,'CoefF2R')==0
    FA.CoefF2R(:,1)=repmat({zeros(3,3,'double')},[size(FA,1),1]);
end
if strfind1(VariableNames,'RefFilename')==0
    FA.RefFilename=[{''};FA.FilenameTotal(1:end-1,1)];
end
if strfind1(VariableNames,'Range')==0
    FA.Range(:,1)=repmat({[]},[size(FA,1),1]);
end

%% get fileinfo
for m=1:size(FA,1) % get fileinfo on each file
    [Fileinfo,Ind,A3]=getFileinfo_2(FA.FilenameTotal{m,1});
    if isempty(Fileinfo) || isempty(Ind)
        FA.Exclude(m,1)=1;
        continue;
    end
    try
        FA.DepthCorrectionInfo(m,1)={Fileinfo.Results{1}.DepthCorrectionInfo};
    catch
        FA.DepthCorrectionInfo(m,1)={[]};
    end
    FA.Res(m,1)=Fileinfo.Res(1);
    FA.Um(m,1)=Fileinfo.Um(1);
    FA.Pix(m,1)=Fileinfo.Pix(1);
%     FA.Um(m,1:3)=Fileinfo.Um{1}(1:3);
%     FA.Pix(m,1:3)=Fileinfo.Pix{1}(1:3);
    if ApplyDriftinfo~=0 % 1 to include all values, 2 to include only independent variable (third)
        clear Ind;
        [~,~,Ind]=searchDriftCombi(FA.FilenameTotal{m,1},FA.RefFilename{m,1});
        Ind=Ind(1,1);
        FA.DrIPos(m,1)=Ind;
        if Ind~=0;
            FitCoef=Driftinfo.Results{Ind,1}.FitCoefs;
            if ApplyDriftinfo==2
                FitCoef(:,1:2)=0;
            end
            try % if CoefF2R was already manually set then add the FitCoef
                FA.CoefF2R{m}=FA.CoefF2R{m}+FitCoef;
            catch
                FA.CoefF2R{m}=FitCoef;
            end
            FA.Range{m}=Driftinfo.Results{Ind,1}.Range;
        end
    end
    if isempty(FA.CoefF2R{m,1})
        FA.CoefF2R{m,1}=zeros(3,3);
    end
    FA.FArefPos(m,1)=min(strfind1(FA.FilenameTotal,FA.RefFilename{m,1},1)); % min in case two times same filename
end

try; FA(FA.Exclude==1,:)=[]; end;

if exist('FirstFileId','var') && isempty(FirstFileId)==0
    FA.CoefF2R{FirstFileId}=zeros(3,3,'double');
    FA.FArefPos(FirstFileId)=0;
end
%% only if SumCoef still to be calculated
if strfind1(VariableNames,'SumCoef')==0
    % first go through all that have a fArefPos=0, then go through all the files that have fArefPos equal to the previous
    FA.SumCoef(:,1)=repmat({zeros(3,3,'double')},[size(FA,1),1]);
    Order=0;OrderStage=1; % 
    while OrderStage<=size(Order,1)
        % search ind zeros
        Parents=find(FA.FArefPos==Order(OrderStage,1));
        Order=[Order;Parents];
        for n=1:size(Parents,1)
            if OrderStage==1
                SumCoef=zeros(3,3);
            else
                SumCoef=FA.SumCoef{FA.FArefPos(Parents(n))};
            end
            FA.SumCoef{Parents(n)}=SumCoef+FA.CoefF2R{Parents(n)};
        end
        OrderStage=OrderStage+1;
    end
end

%% calculate the total extension of the volume incorporating fitCoefs of each file
% adjust volumes to the adjustment resolution
LowestRes=zeros(3,1)+10000;
for m=1:size(FA,1)
    LowestRes=min(LowestRes,FA.Res{m,1});
end
% LowestRes=min(FA.Res(:,:),[],1).';
if exist('ResAdjust','var')
    ResAdjust=ResAdjust.*LowestRes;
else
    ResAdjust=LowestRes;
end

%% find Volume such that smallest space is used
if strcmp(VolumeType,'Optimal')
    TotalVolumeUm=repmat([+1000000,-1000000],[3,1]);
    CommonVolumeUm=repmat([-1000000,+1000000],[3,1]);
    for m=1:size(FA,1)
        FitCoefs=FA.SumCoef{m};
        if isempty(FitCoefs); FitCoefs=[0,0,0;0,0,0;0,0,0]; end;
        Zaxis=(-FA.Um{m}(3)/2+ResAdjust(3)/2:ResAdjust(3):FA.Um{m}(3)/2-ResAdjust(3)/2).';
        clear UmMinMax;
        for n=1:3;
            [Drift]=YofBinFnc(Zaxis,FitCoefs(n,1),FitCoefs(n,2),FitCoefs(n,3),FA.Range{m});
            UmMinMaxLay=-FA.Um{m}(n)/2+Drift;
            UmMinMaxLay(:,2)=FA.Um{m}(n)/2+Drift;
            UmMinMax(n,1)=min(UmMinMaxLay(:,1));
            UmMinMax(n,2)=max(UmMinMaxLay(:,2));
        end
        FA.UmMinMax(m,1)={UmMinMax};
        TotalVolumeUm(:,1)=min(UmMinMax(:,1),TotalVolumeUm(:,1));
        TotalVolumeUm(:,2)=max(UmMinMax(:,2),TotalVolumeUm(:,2));
        CommonVolumeUm(:,1)=max(UmMinMax(:,1),CommonVolumeUm(:,1));
        CommonVolumeUm(:,2)=min(UmMinMax(:,2),CommonVolumeUm(:,2));
    end
    TotalVolumePix=floor(TotalVolumeUm(:,1)./ResAdjust(:));
    TotalVolumePix(:,2)=ceil(TotalVolumeUm(:,2)./ResAdjust(:));
    TotalVolumeUm=TotalVolumePix.*repmat(ResAdjust,1,2);
    TotalVolumePix=TotalVolumePix(:,2)-TotalVolumePix(:,1);
       
    CommonVolumePix=floor(CommonVolumeUm(:,1)./ResAdjust(:));
    CommonVolumePix(:,2)=ceil(CommonVolumeUm(:,2)./ResAdjust(:));
    CommonVolumeUm=CommonVolumePix.*repmat(ResAdjust,1,2);
    CommonVolumePix=CommonVolumePix(:,2)-CommonVolumePix(:,1);
end


Volume.CommonVolumeUm=CommonVolumeUm;
Volume.TotalVolumeUm=TotalVolumeUm;
Volume.CommonVolumeUm=CommonVolumeUm;
Volume.CommonVolumePix=CommonVolumePix;
Volume.TotalVolumeUm=TotalVolumeUm;
Volume.TotalVolumePix=TotalVolumePix;
Volume.Resolution=ResAdjust;


