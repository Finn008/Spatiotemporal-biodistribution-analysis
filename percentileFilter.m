% [Data]=percentileFilter(uint16(rand(100,100,1)*100),90,[3;3;1],[1;1;1],[10;10;1],uint16(rand(100,100,1)));
% [Data]=percentileFilter(uint16(rand(100,100,1)*100),90,[3;3;1],[1;1;1],[10;10;1],uint16([ones(100,50),zeros(100,50)]));
% [Data]=percentileFilter(uint16(rand(100,200,1)*100),90,[1001;1001;1],[1;1;1],[10;10;1],uint16([ones(100,100),zeros(100,100)]));
function [DataPerc]=percentileFilter(Data,Percentile,Window,Res,ResCalc,Outside)
% tic;
Pix=size(Data).'; if size(Pix,1)==2; Pix(3)=1; end;
% Res2=[1.6;1.6;Res(3)];
Data=interpolate3D(Data,Res,ResCalc);
Min=min(Data(:));
Max=max(Data(:));
% [Window,WindowPix]=imdilateWindow([10;10;Res(3)],Res2);

OrigData=Data;
if exist('Outside')==1
    Outside=interpolate3D(Outside,Res,ResCalc);
    Outside2Ind=find(Outside==1);
    Data(Outside2Ind(1:2:size(Outside2Ind,1)))=Min;
    Data(Outside2Ind(2:2:size(Outside2Ind,1)))=Max;
    clear Outside2Ind;
%     [~,Membership]=bwdist(1-Outside2,'quasi-euclidean');
%     disp(['Distance: ',num2str(toc/60),' min']);
%     Data2(Outside2==1)=median(Data2(Outside2~=1));
%     for m=1:3
%         Data2Perc=medfilt3(Data2,Window.');
%         Data2(Outside2==1)=Data2Perc(Membership(Outside2==1));
%     end
%     disp(['OutsideMedian: ',num2str(toc/60),' min']);
%     [Distance,Membership]=distanceMat_4(Outside2,{'DistInOut';'Membership'},Res,1,1,1,50,'uint16',0.8);
end

% tic;
% Data2Perc=uint16(medfilt3(Data2,Window.')); % calculate median
DataPerc=medfilt3(Data,Window.'); % calculate median

FilenameTotalTest='Test5.ims';
dataInspector3D({OrigData;Data;Outside;DataPerc},ResCalc,{'OrigData';'Data';'Outside';'DataPerc'},1,FilenameTotalTest);
% disp(['Median: ',num2str(toc/60),' min']);
if Percentile==50
    keyboard;
elseif Percentile>50
    SubThreshold=find(Outside~=1 & OrigData<=DataPerc);
    VoxInside=sum(1-Outside(:));
    VoxSubThreshold=size(SubThreshold,1);
    Ratio=VoxSubThreshold/VoxInside*100;
    if Ratio<40 || Ratio>60
        keyboard;
    end
    
    % now set 40% (Percentile-50) to maximum in Data2
    Wave1=round(VoxInside*(Percentile/100-0.5));
    Data(SubThreshold(round(linspace(1,size(SubThreshold,1),Wave1))))=Max;
    ex2Imaris_2(Data,FilenameTotalTest,'Data2');
%     OrigData2=Data2;
    
    DataPerc=medfilt3(Data,Window.'); % calculate median
    ex2Imaris_2(DataPerc,FilenameTotalTest,'DataPerc2');
    SubThreshold=find(Outside~=1 & OrigData<DataPerc);
    VoxSubThreshold=size(SubThreshold,1);
    Ratio=VoxSubThreshold/VoxInside*100;
    if Ratio<Percentile-5 || Ratio>Percentile+5
        keyboard;
    end
elseif Percentile<50
    keyboard;
end

DataPerc=interpolate3D(DataPerc,[],[],Pix);
% disp(['Finish: ',num2str(toc/60),' min']);
% keyboard




