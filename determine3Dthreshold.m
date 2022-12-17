function determine3Dthreshold()

Path2file='\\swbgnps003\SWBGNPS003\Finn Peters\Finns programs\dystrophyDetection_Nuclei\dystrophyDetection_Nuclei.xlsx';
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(Path2file);

Table=xlsActxGet(Workbook,'BasinThresholds',1);
Dimensions={'Volume';'DistanceMax';'DistanceMean';};
Table=Table(Table.Include==1,[Dimensions;{'Category'}]);
Table.Category=Table.Category+1;
Pix=[100;100;100];
DimInfo=table;
for Dim=1:size(Dimensions,1)
    DimInfo.Name{Dim}=Dimensions{Dim};
    DimInfo.Min(Dim)=min(Table{:,Dimensions{Dim}});
    DimInfo.Max(Dim)=max(Table{:,Dimensions{Dim}});
    DimInfo.Mean(Dim)=mean(Table{:,Dimensions{Dim}});
    DimInfo.PercMinMax(Dim,1:2)=[prctile(Table{:,Dimensions{Dim}},10),prctile(Table{:,Dimensions{Dim}},90)];
    DimInfo.Range(Dim)=DimInfo.PercMinMax(Dim,2)-DimInfo.PercMinMax(Dim,1);
    DimInfo.Unit(Dim)=DimInfo.Range(Dim)/(Pix(Dim)-1);
    DimInfo.Axis(Dim)={linspace(DimInfo.PercMinMax(Dim,1),DimInfo.PercMinMax(Dim,2),Pix(Dim)).'};
    Wave1=Table{:,Dimensions{Dim}};
    Wave1(Wave1<DimInfo.PercMinMax(Dim,1))=DimInfo.PercMinMax(Dim,1);
    Wave1(Wave1>DimInfo.PercMinMax(Dim,2))=DimInfo.PercMinMax(Dim,2);
    
    Wave1=round((Wave1-DimInfo.PercMinMax(Dim,1))/DimInfo.Unit(Dim))+1;
    
    Table.Data(:,Dim)=Wave1;
end
SpotNumber=[size(find(Table.Category==1),1);size(find(Table.Category==2),1)];
% VolumeMax=min([100,max(Table.Volume)]);
% DistanceMaxMax=min([100,max(Table.DistanceMax)]);
% DistanceMeanMax=min([100,max(Table.DistanceMean)]);
% Pix=[VolumeMax;DistanceMaxMax;DistanceMeanMax];
% Res=[1;1;1];

% Data3D=zeros(VolumeMax,DistanceMaxMax,DistanceMeanMax,'uint16');
Data3D=zeros(Pix.','uint16');
for Spot=1:size(Table,1)
    Data3D(Table.Data(Spot,1),Table.Data(Spot,2),Table.Data(Spot,3))=Table.Category(Spot);
end

DataSmooth=double(Data3D);
DataSmooth(Data3D==1)=-1/SpotNumber(1);
DataSmooth(Data3D==2)=1/SpotNumber(2);
Iterate=100;
[Window,~]=imdilateWindow_2([10;10;10],[1;1;1],1,'sphere');
for m=1:Iterate
    DataSmooth=imfilter(DataSmooth,double(Window)/sum(Window(:)),'symmetric');
end
MinMax=[max(DataSmooth(:));min(DataSmooth(:))];
DataSmooth=DataSmooth*30000/max([MinMax(1);-MinMax(2)])+30000;
% ex2Imaris_2(DataSmooth,Application,'DataSmooth');


[Distance,Membership]=distanceMat_4(Data3D,{'DistInOut';'Membership'},[1;1;1],1,1,0,0,'uint16');

Data3D=imdilate(Data3D>0,strel('sphere',3));
Data3D=Membership.*uint16(Data3D);
global Application;
if isempty(Application)==1
%     [Application]=openImaris_3([Pix;0;1],DimInfo.Unit,1,1,DimInfo.PercMinMax);
    [Application]=openImaris_3([Pix;0;1],[1;1;1],1,1);
end
ex2Imaris_2(Data3D,Application,'Data3D');
ex2Imaris_2(DataSmooth,Application,'DataSmooth');
% ex2Imaris_2(Distance,Application,'Distance');
% ex2Imaris_2(Membership,Application,'Membership');
keyboard;
