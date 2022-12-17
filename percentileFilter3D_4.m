function [DataPerc,OrigData]=percentileFilter3D_4(OrigData,Percentile,Res,ResCalc,OrigOutside,BackgroundCorrection,Window,ReplaceWithClosest,TilingSettings,RequestedOutput)
timeTable('Start_PercentileFilter3D');

if exist('RequestedOutput','Var')~=1
    RequestedOutput={'DataPerc';'OrigData'};
end
if exist('TilingSettings','Var')==1 && isempty(TilingSettings)==0
    CalcSettings=struct('Percentile',Percentile,'ResCalc',ResCalc,'BackgroundCorrection',BackgroundCorrection,'Window',Window,'ReplaceWithClosest',ReplaceWithClosest,'RequestedOutput',RequestedOutput);
    [Wave1]=tiledProcessing_2(OrigData,OrigOutside,Res,TilingSettings,mfilename(),CalcSettings);
    DataPerc=Wave1{1};
    if strcmp(RequestedOutput,'DataPerc')==0
        OrigData=Wave1{2};
    end
    return;
%     DataOut=tiledProcessing_2(Data3D,Outside,Res,ResLevels,Calculation,CS) % CS for CalcSettings
end

if isempty(ResCalc); ResCalc=Res; end;
Pix=size(OrigData).'; if size(Pix,1)==2; Pix(3)=1; end;
Data=interpolate3D(OrigData,Res,ResCalc)+1;
Data(Data==65535)=65534;
[~,Window]=imdilateWindow(Window,ResCalc,1);

if exist('OrigOutside')==1
    Outside=interpolate3D_3(OrigOutside,size(Data));
    clear OrigOutside;
    OutsideInd=find(Outside==1);
    Data(Outside==1)=0;
    Wave1=round(linspace(1,size(OutsideInd,1),round(size(OutsideInd,1)*(100-50)/100)));
    Data(OutsideInd(Wave1))=65535;
    clear OutsideInd;
end

if Percentile==50
elseif Percentile>50
    Share2Max=(Percentile-50)/Percentile;
    InsideInd=find(Outside==0);
    Wave1=round(size(InsideInd,1)*Share2Max);
    Data(InsideInd(round(linspace(1,size(InsideInd,1),Wave1))))=65535;
    clear InsideInd;
elseif Percentile<50
    keyboard;
end
DataPerc=medfilt3(Data,Window.','symmetric'); % calculate median
if exist('ReplaceWithClosest')==1 && isempty(ReplaceWithClosest)==0
    Wave1=DataPerc==0|DataPerc==65535;
    if min(Wave1(:))==1 % the whole dataset is excluded
        DataPerc(:)=0;
        return;
    end
    if max(Wave1(:))==1
        [~,Membership]=bwdist(~Wave1,'quasi-euclidean');
        DataPerc(Wave1)=DataPerc(Membership(Wave1));
    end
    clear Membership;
end

ShowIntermediateSteps=0;
if ShowIntermediateSteps==1
    global Application;
    if isempty(Application)
        Application=dataInspector3D({interpolate3D(OrigData,Res,ResCalc);Data;Outside;DataPerc},ResCalc,{'OrigData';'Data';'Outside';'DataPerc'},0,'Test.ims',1);
    else
        ex2Imaris_2(interpolate3D(OrigData,Res,ResCalc),Application,'OrigData');
        ex2Imaris_2(Data,Application,'Data');
        ex2Imaris_2(Outside,Application,'Outside');
        ex2Imaris_2(DataPerc,Application,'DataPerc');
    end
end
clear Outside; clear Data;


if exist('BackgroundCorrection','Var') && isempty(BackgroundCorrection)==0
    if prod(size(OrigData))>1000*1000*1000
        OrigData=divideInt_2(OrigData,DataPerc,BackgroundCorrection);
    else
        DataPerc=interpolate3D_3(DataPerc,Pix)-1;
        OrigData=uint16(single(OrigData)./single(DataPerc)*BackgroundCorrection); % NaN become zero
    end
    OrigData(OrigData==Inf)=0; % set zero when DataPerc equals zero, attention: DataPerc and OrigData can have different Pix
% A1=divideInt_2(OrigData,DataPerc,BackgroundCorrection);
% A1(DataPerc==0)=0;
% A1=divideInt_2(OrigData,DataPerc,BackgroundCorrection);
% A2=find(A1==Inf);
% A3=OrigData(A1==Inf);
% A4=A3(1:100,:);
end
if strfind1(RequestedOutput,'OrigData')==0
    OrigData=[];
end
if strfind1(RequestedOutput,'DataPerc')~=0
    DataPerc=interpolate3D_3(DataPerc,Pix)-1;
else
    DataPerc=[];
end
timeTable('End_PercentileFilter3D');
