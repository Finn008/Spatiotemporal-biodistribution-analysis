function [Outside,Outside2D]=wholeSliceQuantification_Outside(MetBlue,Res,FilenameTotal)

Pix=size(MetBlue).';

MaxProjection=max(MetBlue,[],3);
[Outside2D]=wholeSliceQuantification_Outside_MetBlue_2(MaxProjection,Res);
Outside=repmat(Outside2D,[1,1,Pix(3)]);
return;




for Z=1:size(MetBlue,3)
    Outside(:,:,Z)=wholeSliceQuantification_Outside_MetBlue_2(MetBlue(:,:,Z),Res);
end

Res2=[2;2;Res(3)];
MetBlue=interpolate3D(MetBlue,Res,Res2);
Outside=interpolate3D(Outside,Res,Res2);

dataInspector3D({MetBlue;Outside},Res2,{'MetBlue';'Outside'},1,'Test.ims',1);
keyboard;
%% 3D



% [Outside]=wholeSliceQuantification_OutsideCrude(MetBlue,Res,FilenameTotal);

% if size(Inside,3)~=Pix(3)
Inside=repmat(Inside2D,[1,1,Pix(3)]);


Res2=[2;2;Res(3)];
MetBlue=interpolate3D(MetBlue,Res,Res2);
Inside=interpolate3D(Inside,Res,Res2);

[~,Wave1]=max(permute(sum(sum(MetBlue,1),2),[3,2,1]));
Wave2=MetBlue(:,:,Wave1);
Threshold=prctile(Wave2(Inside(:,:,Wave1)==1),10);

% Threshold=prctile(MetBlue(Inside==1),10); % 50=407, 70=821
Inside=MetBlue>Threshold;
% Inside=imerode(Inside,ones(3,3));

% first make 3D
BW=bwconncomp(Inside,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
Table.Volume=Table.NumPix*prod(Res2);
Table=Table(Table.Volume>(4000*4000*10),:);

Inside(:)=0;
Inside(cell2mat(Table.IdxList))=1;

% remove holes
BW=bwconncomp(1-Inside,6);
Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
Table.Volume=Table.NumPix*prod(Res);
Table=Table(Table.Volume<(30*30*10),:);

Inside(cell2mat(Table.IdxList))=1;



% dataInspector3D({MetBlue;Inside},Res2,{'MetBlue';'Inside'},1,'Test.ims',1);
ex2Imaris_2(Inside,'Test.ims','Inside2');
% ex2Imaris_2(repmat(Inside2D,[1,1,Pix(3)]),'Test.ims','Inside2D');

Outside=~interpolate3D(Inside,[],[],Pix);