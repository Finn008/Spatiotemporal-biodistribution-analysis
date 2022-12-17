function [BoutonList]=boutonDetect_LoadBoutonData(BoutonList,D2DRatioA,Pix,DistInOut,Membership,Relationship)

Fileinfo=getFileinfo_2(D2DRatioA.FilenameTotal);
% FilenameTotal=ReadOuts.ApplyD2D{iRead}.FilenameTotal;
% Fileinfo=getFileinfo_2(FilenameTotal);
% Path=[FilenameTotal,'_Statistics',ReadOuts.ChannelName{iRead,1},'.mat'];
% Path=getPathRaw(Path);
% Statistics=load(Path);
% Statistics=Statistics.Statistics;
% if isstruct(Statistics)==0
%     Statistics=struct('ObjInfo',Statistics);
% end

% if strfind1(Statistics.ObjInfo.Properties.VariableNames.','PixXYZ') % if Spots
try
    Rotate=D2DRatioA.Rotate;
catch
    Rotate=[];
end
[~,BoutonList.PlaquePixXYZ,BoutonList.PlaquePixLinInd]=umXYZ2pixXYZ(BoutonList.XYZum,Fileinfo.UmStart{1}.',Fileinfo.UmEnd{1}.',Pix.',Rotate);
% [~,Statistics.ObjInfo.PixXYZ,Statistics.ObjInfo.Ind]=umXYZ2pixXYZ(Statistics.ObjInfo{:,{'PositionX','PositionY','PositionZ'}},Fileinfo.UmStart{1}.',Fileinfo.UmEnd{1}.',Pix.',Rotate);
BoutonList.DistInOut=DistInOut(BoutonList.PlaquePixLinInd);
BoutonList.Membership=Membership(BoutonList.PlaquePixLinInd);
BoutonList.Relationship=Relationship(BoutonList.PlaquePixLinInd);
% end

% Path=['Co.Statistics.',ReadOuts.Name{iRead,1},'=Statistics;'];
% eval(Path);
