function [Blood]=boutonDetect_DetermineBlood(VglutRed,VglutGreen,Res,Path2fileRatioA,FilenameTotalRatioA,Application)
global W;

Pix=size(VglutGreen).';
Um=Pix.*Res;
ResCalc=[0.4;0.4;0.4];

VglutGreen=VglutGreen(round(linspace(1,Pix(1),round(Um(1)/ResCalc(1)))),round(linspace(1,Pix(2),round(Um(2)/ResCalc(2)))),round(linspace(1,Pix(3),round(Um(3)/ResCalc(3)))));
VglutRed=VglutRed(round(linspace(1,Pix(1),round(Um(1)/ResCalc(1)))),round(linspace(1,Pix(2),round(Um(2)/ResCalc(2)))),round(linspace(1,Pix(3),round(Um(3)/ResCalc(3)))));
PixCalc=size(VglutRed).';
VglutGreenInvert=uint8(255)-VglutGreen;
VglutRedInvert=uint8(255)-VglutRed;

Blood=(uint16(VglutGreenInvert)+uint16(VglutRedInvert))/2;

ex2Imaris_2(Blood,Application,'Blood');
Application.GetImageProcessing.SubtractBackgroundChannel(Application.GetDataSet,0,70);
Application.GetImageProcessing.GaussFilterChannel(Application.GetDataSet,0,0.4);




ex2Imaris_2(Blood,Application,'Blood');
Application.GetImageProcessing.SubtractBackgroundChannel(Application.GetDataSet,0,5);
Blood=im2Matlab_3(Application,'Blood');
BloodMask=Blood>25;
Blood2=VglutRedInvert.*uint8(BloodMask);
ex2Imaris_2(Blood2,Application,'Blood');
Application.GetImageProcessing.GaussFilterChannel(Application.GetDataSet,0,0.8);
Application.GetImageProcessing.GaussFilterChannel(Application.GetDataSet,0,0.8);


Application.GetImageProcessing.GaussFilterChannel(Application.GetDataSet,0,0.8);


ex2Imaris_2(VglutGreenInvert,Application,'InvertGreen');



Outside=VglutRed<=40;
Outside=imdilate(Outside,ones(1,1)); % remove bright noise



VglutRedInvert=VglutRedInvert


ex2Imaris_2(VglutRedInvert,Application,'Invert2');











[Out]=getHistograms_3([],VglutRed,[]);
% keyboard;
Res3D=prod(ResCalc(:));
PercentileSteps=[20;30;40;50;60;70;80;90;95;99];
Blood=zeros(PixCalc(1),PixCalc(2),PixCalc(3),'uint8');


% GrowthCone=zeros(PixCalc(1),PixCalc(2),PixCalc(3),'uint8');

Data2IncludeTotal=zeros(PixCalc(1),PixCalc(2),PixCalc(3),'uint8');
for Perc=1:size(PercentileSteps,1)
    PercId=Out.Percentiles.a(PercentileSteps(Perc));
    if Perc>1 & Out.Percentiles.a(PercentileSteps(Perc))==Out.Percentiles.a(PercentileSteps(Perc-1))
        keyboard;
    end
    if PercId>=255
        keyboard;
    end
    
    Data2Include=VglutRed<=PercId;
    Data2IncludeTotal=Data2IncludeTotal+uint8(Data2Include)*PercId;
    if Perc==1
        %         GrowthCone=Data2Include;
        [Window]=generateEllipse([1.2;1.2;1.2],ResCalc);
        GrowthCone=imerode(Data2Include,Window);
    end
    
    BW=bwconncomp(Data2Include,6);
    Table=table;
    Table.NumPix=cellfun(@numel,BW.PixelIdxList).';
    Table.IdxList=BW.PixelIdxList.';
    %     if Perc==1
    %         Table=Table(Table.Volume>1,:);
    % %         Table.GrowthCone=repmat(1,[size(Table,1),1]);
    %     else
    Table.Volume=Table.NumPix*Res3D;
    Table=Table(Table.Volume>1,:);
    for m=1:size(Table,1)
        Table.GrowthCone(m,1)=sum(GrowthCone(Table.IdxList{m}));
    end
    Table.Volume=(Table.NumPix-Table.GrowthCone)*Res3D;
    Table=Table(Table.Volume>1&Table.GrowthCone>1,:);
    
    PreviousGrowthCone=find(GrowthCone==1);
    GrowthCone=zeros(PixCalc(1),PixCalc(2),PixCalc(3),'uint8');
    for m=1:size(Table,1)
        GrowthCone(Table.IdxList{m})=1;
    end
    GrowthCone(PreviousGrowthCone)=0;
    %     GrowthCone=GrowthCone.*(1-PreviousGrowthCone);
    %     Data2Include=imdilate(Data2Include,Window);
    %     GrowthConeBefore=GrowthCone;
    Data2Include=uint8(Data2Include).*(1-GrowthCone);
    VglutRed(Data2Include==1)=255;
    
    %     VglutRed=VglutRed+(uint8(Data2Include)-GrowthCone)*255;
    Blood=Blood+GrowthCone*Perc;
    A1=1;
end

% ex2Imaris_2(Blood,Application,'Blood');
ex2Imaris_2(Blood,'Test.ims','Blood');
ex2Imaris_2(Data2IncludeTotal,'Test.ims','Data2IncludeTotal');

% ex2Imaris_2(VglutRed,'Test.ims','VglutRed');
Path2fileRatioA='\\GNP90N\share\Finn\Raw data\Test.ims';
Application=openImaris_2(Path2fileRatioA);
Application.SetVisible(1);
imarisSaveHDFlock(Application,Path2fileRatioA);
Application=openImaris_2(Path2fileRatioA); Application.SetVisible(1);


% 
% Blood2=Blood(round(linspace(1,PixCalc(1),Pix(1))),round(linspace(1,PixCalc(2),Pix(2))),round(linspace(1,PixCalc(3),Pix(3))));
% 
% 
% J=struct;J.PixMax=[PixCalc(1);PixCalc(2);PixCalc(3);0;1]; J.Path2file=W.PathImarisSample; Application=openImaris_2(J); Application.SetVisible(1);
% 
% ex2Imaris_2(Blood2,FilenameTotalRatioA,'Blood');
% Application=openImaris_2(Path2fileRatioA);
% Application.SetVisible(1);
% imarisSaveHDFlock(Application,Path2fileRatioA);
% Application=openImaris_2(Path2fileRatioA); Application.SetVisible(1);
