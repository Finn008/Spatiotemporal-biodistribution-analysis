% [Data]=percentileFilter(uint16(rand(100,100,1)*100),90,[3;3;1],[1;1;1],[10;10;1],uint16(rand(100,100,1)));
% [Data]=percentileFilter(uint16(rand(100,100,1)*100),90,[3;3;1],[1;1;1],[10;10;1],uint16([ones(100,50),zeros(100,50)]));
% [Data]=percentileFilter(uint16(rand(100,200,1)*100),90,[1001;1001;1],[1;1;1],[10;10;1],uint16([ones(100,100),zeros(100,100)]));
function [DataPerc,OrigData]=percentileFilter3D_2(OrigData,Percentile,Res,ResCalc,OrigOutside,BackgroundCorrection,Window)
Pix=size(OrigData).'; if size(Pix,1)==2; Pix(3)=1; end;
Data=interpolate3D(OrigData,Res,ResCalc);
Min=min(Data(:));
Max=max(Data(:));

[~,Window]=imdilateWindow(Window,ResCalc,1);

% Data=Data;
if exist('Outside')==1
    Outside=interpolate3D(OrigOutside,Res,ResCalc);
    OutsideInd=find(Outside==1);
    Data(OutsideInd(1:2:size(OutsideInd,1)))=Min;
    Data(OutsideInd(2:2:size(OutsideInd,1)))=Max;
    clear OutsideInd;
end

if Percentile==50
    keyboard;
elseif Percentile>50
    Share2Max=(Percentile-50)/Percentile;
    InsideInd=find(Outside==0);
    Wave1=round(size(InsideInd,1)*Share2Max);
    Data(InsideInd(round(linspace(1,size(InsideInd,1),Wave1))))=Max;
    clear InsideInd;
    DataPerc=medfilt3(Data,Window.'); % calculate median
%     ex2Imaris_2(DataPerc,FilenameTotalTest,'DataPerc2');
elseif Percentile<50
    keyboard;
end

% FilenameTotalTest='Test8.ims';
% dataInspector3D({OrigData;Data;Outside;DataPerc},ResCalc,{'OrigData';'Data';'Outside';'DataPerc'},1,FilenameTotalTest);

DataPerc=interpolate3D(DataPerc,[],[],Pix);



if exist('BackgroundCorrection','Var') && isempty(BackgroundCorrection)==0
%     Data=interpolate3D(Data,[],[],Pix);
%     Factor=str2num(regexprep(SubtractBackground,'Multiply',''));
    OrigData=uint16(single(OrigData)./single(DataPerc)*BackgroundCorrection); % NaN become zero
end