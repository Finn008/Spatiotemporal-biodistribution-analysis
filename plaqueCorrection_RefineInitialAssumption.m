function [RealPlaquesTotal]=plaqueCorrection_RefineInitialAssumption(PlaqueMapTotal,Fileinfo,FilenameTotal,NewSize,CutPaste,RealPlaquesIn,MicroscopyType,PlaqueLocation)

Res=Fileinfo.Res{1};
Pix=size(PlaqueMapTotal).'; Pix=(Pix(1:3));
if exist('MicroscopyType')~=1 || isempty(MicroscopyType); MicroscopyType='InVivo'; end;
for Time=1:Fileinfo.GetSizeT
    cprintf('text',[num2str(Time),',']);
    PlaqueMap=PlaqueMapTotal(:,:,:,Time);
    [Distance,Membership]=distanceMat_4(PlaqueMap,{'DistInOut';'Membership'},Res,1,1,0,0,'uint8',0.4); % 21min
    if exist('RealPlaquesIn')==1 && isempty(RealPlaquesIn)==0
        RealPlaques2=RealPlaquesIn(:,:,:,Time);
    else
        RealPlaques2=im2Matlab_3(FilenameTotal,'MetBluePerc',Time);
        RealPlaques2=RealPlaques2>90;
    end
    
    if exist('NewSize')==1 && isempty(NewSize)==0
        RealPlaques=zeros(NewSize(1:3).','uint8');
        RealPlaques(CutPaste(1,1):CutPaste(1,2),CutPaste(2,1):CutPaste(2,2),CutPaste(3,1):CutPaste(3,2),:)=RealPlaques2;
    else
        RealPlaques=uint8(RealPlaques2);
    end
    
        
    if strcmp(MicroscopyType,'InVivo')
        Window=ones(3,3);
        RealPlaques2=imerode(RealPlaques,Window);
        BW=bwconncomp(RealPlaques2,4);
    elseif strcmp(MicroscopyType,'ExVivo')
        % remove small 2D structures, 1027.07.24
        Window=imdilateWindow([1.5;1.5],Res);
        RealPlaques2=imerode(RealPlaques,Window);
        RealPlaques2(Distance>10)=0;
        BW=bwconncomp(RealPlaques2,4);
        Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
        Table.Area=Table.NumPix*prod(Res(1:2));
        Table=Table(Table.Area>=1,:);
        
        RealPlaques2=zeros(Pix.','uint8');
        RealPlaques2(cell2mat(Table.IdxList))=1;
       
        BW=bwconncomp(RealPlaques2,6);
    end
    
    Table=table;
    Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
    Table.IdxList=BW.PixelIdxList.';
    clear BW;
    Table(Table.NumPix<=2,:)=[];
    for m=1:size(Table,1)
        Table.PlaqueTouch(m,1)=max(PlaqueMap(Table.IdxList{m}));
    end
    Table(Table.PlaqueTouch==0,:)=[];
    RealPlaques2(:)=0;
    RealPlaques2(cell2mat(Table.IdxList))=1;
    
    RealPlaques2=imdilate(RealPlaques2,Window);
    
    RealPlaques=RealPlaques.*RealPlaques2;
    RealPlaques=uint8(RealPlaques).*uint8(Membership);
    if exist('PlaqueLocation')==1 && isempty(PlaqueLocation)==0
        PlaqueNumber=size(PlaqueLocation.PixArrayEnlarge{1},2);
        for Pl=1:PlaqueNumber
            PixCenter=[PlaqueLocation.PixArrayEnlarge{1}(Time,Pl);PlaqueLocation.PixArrayEnlarge{2}(Time,Pl);PlaqueLocation.PixArrayEnlarge{3}(Time,Pl)];
            RealPlaques(PixCenter(1),PixCenter(2),PixCenter(3))=Pl;
        end
    end
    
    Wave1=unique(RealPlaques(:));
    Wave2=unique(PlaqueMap(:));
    if size(Wave1,1)~=size(Wave2,1)
        RealPlaques(PlaqueMap~=0)=PlaqueMap(PlaqueMap~=0);
    end
    RealPlaquesTotal(:,:,:,Time)=RealPlaques;
end