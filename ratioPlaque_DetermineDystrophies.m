function [Dystrophies1]=ratioPlaque_DetermineDystrophies(FilenameTotalRatioB,FileinfoRatioB)

Pix=FileinfoRatioB.Pix{1};
% determine dystrophic corona
[Dystrophies1]=im2Matlab_3(FilenameTotalRatioB,'MetRedPerc');
Dystrophies1=Dystrophies1>75;
OrigDystrophies=Dystrophies1;
Dystrophies1=imerode(Dystrophies1,ones(3,3,3));

% 3D
BW=bwconncomp(Dystrophies1,6);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
clear BW;
Res3D=prod(FileinfoRatioB.Res{1});
Table.Volume=Table.NumPix*Res3D;
Table=Table(Table.Volume>8,:);

Dystrophies1=zeros(Pix.','uint8');
for m=1:size(Table,1)
    Dystrophies1(Table.IdxList{m})=1;
end

% 2D
BW=bwconncomp(logical(Dystrophies1),4);
Table=table;
Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
Table.IdxList=BW.PixelIdxList.';
clear BW;
Res2D=prod(FileinfoRatioB.Res{1}(1:2));
Table.Area=Table.NumPix*Res2D;
Table=Table(Table.Area>=4,:);
Dystrophies1=false(Pix.');
for m=1:size(Table,1)
    Dystrophies1(Table.IdxList{m})=1;
    %         Dystrophies1(Table.IdxList{m})=Table.Area(m)*10;
end

Wave1=imdilate(Dystrophies1,ones(3,3,3));
Dystrophies1=OrigDystrophies.*Wave1;

% % % % consider plaqueTouch
% % % BW=bwconncomp(Dystrophies1,6);
% % % Table=table;
% % % Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
% % % Table.IdxList=BW.PixelIdxList.';
% % % clear BW;
% % % 
% % % Table.Volume=Table.NumPix*Res3D;
% % % for m=1:size(Table,1)
% % %     Table.PlaqueTouch(m,1)=min(DistInOut(Table.IdxList{m}));
% % % end
% % % Table(Table.PlaqueTouch>50,:)=[];
% % % % Table=Table(Table.Volume>8,:);
% % % 
% % % % Dystrophies1=zeros(Pix.','uint8');
% % % for m=1:size(Table,1)
% % %     Dystrophies1(Table.IdxList{m})=2;
% % % end
% % % 


