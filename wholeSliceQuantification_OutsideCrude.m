function [Outside]=wholeSliceQuantification_OutsideCrude(MetBlue,Res,FctSpec,FilenameTotal)
MaxProjection=max(MetBlue,[],3);
Pix=size(MaxProjection).';
if strcmp(FctSpec.StainingSpec,'MethoxyPBS') % strfind1(FilenameTotal,'ExTanjaB') |
    keyboard;
    [Path,Report]=getPathRaw([FilenameTotal,'_4RegionMarking_Finish.tif']);
    if Report==0
        Wave1=double(prctile(MaxProjection(:),98));
        MetBlue2D=uint16(MaxProjection/(Wave1/65535)); % 1500 to 256
        Colormap=repmat(linspace(0,1,65535).',[1,3]);
        Image=ind2rgb(gray2ind(MetBlue2D,65535),Colormap);
        [Path,Report]=getPathRaw([FilenameTotal,'_4RegionMarking.tif']);
        imwrite(Image,Path);
        Outside=[];
        return;
    else
        DataBrainArea=imread(Path);
        DataBrainArea=max(DataBrainArea,[],3);
        if size(DataBrainArea,1)==Pix(2) && size(DataBrainArea,2)==Pix(1)
            DataBrainArea=permute(flip(DataBrainArea),[2,1]);
        end
        Outside=DataBrainArea==0;
    end
else
    Percentiles=prctile_2(MaxProjection,(1:100).');
    Deviation1=diff(smooth(smooth(smooth(double(Percentiles)))));
    Deviation2=diff(smooth(smooth(smooth(Deviation1))));
    [A1,Wave1]=min(Deviation2);
    Threshold=Percentiles(Wave1)*1/2;
    Inside=MaxProjection>Threshold;
    Inside=imerode(Inside,imdilateWindow([3;3],Res));
    BW=bwconncomp(Inside,4);
    Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
    Table.Volume=Table.NumPix*prod(Res(1:2));
    Table=Table(Table.Volume>(2000*2000),:); % 2mm*2mm
    Inside=false(size(Inside));
    Inside(cell2mat(Table.IdxList))=1;
    % remove holes within Inside
    BW=bwconncomp(logical(1-Inside),4);
    Table=table;
    Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
    Table.IdxList=BW.PixelIdxList.';
    clear BW;
    Table.Area=Table.NumPix*prod(Res(1:2));
    Table=Table(Table.Area<50^2,:); % previously 5, 1000
    Inside(cell2mat(Table.IdxList))=1;
    Outside=1-Inside;
end