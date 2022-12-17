function [XYZ]=calcDrift_2(In,MinMax,Pix)
% Out=struct;
XYZ=table;
Res=(MinMax(:,2)-MinMax(:,1))./Pix;

for iXYZ=1:size(In,1)
    CenterArray=In{iXYZ,1};
    TrackNumber=size(CenterArray,2);
    Difference=CenterArray(1:end-1,:)-CenterArray(2:end,:);
    MeanDifference=nanmean(Difference,2);
    % replace Nan-values
    NanNumber=1000000;
    while NanNumber~=0
        [NanRow,NanCol]=find(isnan(CenterArray));
        AllNanCols=find(sum(isnan(CenterArray),1).'==size(CenterArray,1));
        AllNanCols=ismember(NanCol,AllNanCols);
        NanCol(AllNanCols,:)=[];
        NanRow(AllNanCols,:)=[];
        if size(NanRow,1)==NanNumber
            A1=asdf; % NanEntries not beeing reduced anymore
        else
            NanNumber=size(NanRow,1);
        end
        for m1=1:NanNumber
            try
                FromFollower=CenterArray(NanRow(m1)+1,NanCol(m1))+MeanDifference(NanRow(m1));
            catch
                FromFollower=NaN;
            end
            try
                FromPrevious=CenterArray(NanRow(m1)-1,NanCol(m1))-MeanDifference(NanRow(m1)-1);
            catch
                FromPrevious=NaN;
            end
            CenterArray(NanRow(m1),NanCol(m1))=nanmean([FromFollower;FromPrevious]);
        end
    end
    Norm2First=repmat(CenterArray(1,:),[size(CenterArray,1),1])-CenterArray(:,:);
    MeanNorm2First=nanmean(Norm2First,2);
    
    PixArray=round((CenterArray-MinMax(iXYZ,1))/Res(iXYZ));
    AddPix(iXYZ,1:2)=[1-min(PixArray(:)),max(PixArray(:)-Pix(iXYZ))];
    AddPix(AddPix<0)=0;
    PixArrayEnlarge=PixArray+AddPix(iXYZ,1);
    
    XYZ.NanReplace{iXYZ,1}=CenterArray;
    XYZ.MeanNorm2First{iXYZ,1}=MeanNorm2First;
    XYZ.MeanDifference{iXYZ,1}=MeanNorm2First;
    XYZ.PixArray{iXYZ,1}=PixArray;
    XYZ.PixArrayEnlarge{iXYZ,1}=PixArrayEnlarge;
end
XYZ.AddPix=AddPix;

return;

PixCenter=round((UmCenter-Fileinfo.UmStart{1})./Fileinfo.Res{1});


PlaqueInfo.CorrXYZcenter{iXYZ,1}=[Out.NanReplace{1}(:,iXYZ),Out.NanReplace{2}(:,iXYZ),Out.NanReplace{3}(:,iXYZ)];


for Pl=1:size(PlaqueInfo,1)
    UmCenter=PlaqueInfo.CorrXYZcenter{Pl,1}(Time,:).';
    PixCenter=round((UmCenter-Fileinfo.UmStart{1})./Fileinfo.Res{1});
    PixCenter(PixCenter==0)=1;
    PixCenter(PixCenter==Fileinfo.Pix{1}+1)=Fileinfo.Pix{1}(PixCenter==Fileinfo.Pix{1}+1);
    Wave1=SuperPlaqueMapTotal(PixCenter(1),PixCenter(2),PixCenter(3),Time);
    if Wave1==0
        SuperPlaqueMapTotal(PixCenter(1),PixCenter(2),PixCenter(3),Time)=Pl;
    elseif Wave1==Pl
        
    else
        Path=['Tp',num2str(Time),'Pl',num2str(Pl),'/',num2str(Wave1),', '];
        ErrorMessage=[ErrorMessage,Path];
    end
end



PlaqueInfo=table;
for m=1:TrackNumber
    PlaqueInfo.XYZcenter{m,1}=[In{1}(:,m),In{2}(:,m),In{3}(:,m)];
    PlaqueInfo.CorrXYZcenter{m,1}=[Out.NanReplace{1}(:,m),Out.NanReplace{2}(:,m),Out.NanReplace{3}(:,m)];
    
    [Row,Col]=find(isnan(In{1}(:,m)));
    GhostPlaques=table;
    for m2=1:size(Row,1)
        GhostPlaques.TrackId(m2,1)=m-1;
        GhostPlaques.Timepoint(m2,1)=Row(m2)-1;
        GhostPlaques.XYZcenter(m2,1)={PlaqueInfo.CorrXYZcenter{m,1}(Row(m2),:)};
    end
    PlaqueInfo.GhostPlaques(m,1)={GhostPlaques};
end
if exist('MinMax')==1
        Wave1=CenterArray<MinMax(iXYZ,1);
        Wave2=CenterArray>MinMax(iXYZ,2);
        if max(Wave1(:))>0 || max(Wave2(:))>0
            keyboard; % plaque outside possible range
            Table=table;
            [Table.Timepoint,Table.Pl]=find(Wave1>0);
            Table.End(1:size(Table,1),1)=MinMax(iXYZ,1);
            
            Table2=table;
            [Table2.Timepoint,Table2.Pl]=find(Wave2>0);
            Table2.End(1:size(Table2,1),1)=MinMax(iXYZ,2);
            Table=[Table;Table2];
            clear Table2;
            for n=1:size(Table,1)
                Table.Value(n,1)=CenterArray(Table.Timepoint(n),Table.Pl(n));
                Table.Diff(n,1)=Table.Value(n,1)-Table.End(n,1);
                CenterArray(Table.Timepoint(n),Table.Pl(n))=Table.End(n,1);
            end
            if max(abs(Table.Diff))>10
                keyboard;
            end
            
        end
    end