function [YaxisTotal,Out]=ableitung_2(Yaxis,Sort,Smooth,Visualize)

Yaxis=double(Yaxis);
if exist('Smooth')~=1
    Smooth=table;
    Smooth.Power=1;
    Smooth.Robust={[]};
    Smooth=repmat(Smooth,[3,1]);
end

Xpix=size(Yaxis,1);
% 1.Ableitung
DerivativeNumber=3;
TraceNumber=size(Yaxis,2);
for m =1:TraceNumber
    NanValues=isnan(Yaxis(:,m));
    %     Yaxis(:,m)=smooth(Yaxis(:,m),Smooth.Span(1,1));
    Yaxis(:,m)=smoothn(Yaxis(:,m),Smooth.Power(1,1),'Robust');
    Yaxis(NanValues==1,m)=nan;
    Yaxis1(:,m)=Yaxis(2:end,m)-Yaxis(1:end-1,m);
    %     Yaxis1(:,m)=smooth(Yaxis1(:,m),Smooth.Span(2,1));
    Yaxis1(:,m)=smoothn(Yaxis1(:,m),Smooth.Power(2,1),'Robust');
    Yaxis1(NanValues(1:end-1)==1,m)=nan;
    Yaxis2(:,m)=Yaxis1(2:end,m)-Yaxis1(1:end-1,m);
    %     Yaxis2(:,m)=smooth(Yaxis2(:,m),Smooth.Span(3,1));
    Yaxis2(:,m)=smoothn(Yaxis2(:,m),Smooth.Power(3,1),'Robust');
    Yaxis2(NanValues(1:end-2)==1,m)=nan;
    
    YaxisTotal(1:Xpix-2,1:3,m)=[Yaxis(1:end-2,m),Yaxis1(1:end-1,m),Yaxis2(:,m)];
    
    for n=1:DerivativeNumber
        YaxisTotal(:,n,m)=YaxisTotal(:,n,m)/max(abs(YaxisTotal(:,n,m)));
        [MaxValues,MaxLocs,MaxWidths,MaxProms] = findpeaksFinn(YaxisTotal(:,n,m),'IncludeBoth');
        [MinValues,MinLocs,MinWidths,MinProms] = findpeaksFinn(-YaxisTotal(:,n,m),'IncludeBoth');
        MinValues=-MinValues;
        
        Maxima(1:size(MaxValues,1),n,m,1)=MaxValues(:);
        Maxima(1:size(MaxLocs,1),n,m,2)=MaxLocs(:);
        Maxima(1:size(MaxProms,1),n,m,3)=MaxProms(:);
        Maxima(1:size(MaxWidths,1),n,m,4)=MaxWidths(:);
        Minima(1:size(MinValues,1),n,m,1)=MinValues(:);
        Minima(1:size(MinLocs,1),n,m,2)=MinLocs(:);
        Minima(1:size(MinProms,1),n,m,3)=MinProms(:);
        Minima(1:size(MinWidths,1),n,m,4)=MinWidths(:);
    end
end

% set positions in 4D stack to NaN instead of zero when simply missing
for m =1:TraceNumber
    for n=1:DerivativeNumber
        NanFinder=sum(Maxima(:,n,m,:),4);
        Maxima(NanFinder==0,n,m,:)=NaN;
        NanFinder=sum(Minima(:,n,m,:),4);
        Minima(NanFinder==0,n,m,:)=NaN;
    end
end


%% sort according to Value
% Maxima and Minima: first dimension: number of peaks per trace, second:
% number of derivative, third: trace, fourth: Values, Locs, Proms or
% Widths, sortIndex
if exist('Sort')==1 && isempty(Sort)==0
    if strcmp(Sort,'Value')
        for m =1:TraceNumber
            for n=1:DerivativeNumber
                [A1,MaxInd]=sort(-Maxima(:,n,m,1)); % minus to get largest value not at the end but in the beginning
                Maxima(:,n,m,5)=MaxInd;
                [A1,MinInd]=sort(Minima(:,n,m,1));
                Minima(:,n,m,5)=MinInd;
                for o=1:4
                    Maxima(:,n,m,o)=Maxima(MaxInd,n,m,o);
                    Minima(:,n,m,o)=Minima(MinInd,n,m,o);
                end
            end
        end
    end
end

Out.MaximaValues=Maxima(:,:,:,1);
Out.MaximaLocs=Maxima(:,:,:,2);
Out.MaximaProms=Maxima(:,:,:,3);
Out.MaximaWidths=Maxima(:,:,:,4);
Out.MinimaValues=Minima(:,:,:,1);
Out.MinimaLocs=Minima(:,:,:,2);
Out.MinimaProms=Minima(:,:,:,3);
Out.MinimaWidths=Minima(:,:,:,4);

%% visualize
if exist('Visualize')==1
    J=struct;
    if size(YaxisTotal,3)>1
        J.Path2file=['D:\Finn\Ableitung.avi'];
        J.Frequency=5;
    else
        J.Path2file=['D:\Finn\Ableitung.jpg'];
    end
%     keyboard; % inlcude timepoint
%     J.Tit='Ableitung: raw-white 1-red 2-cyan';
    J.Tit=strcat(cellstr(num2str((1:size(Yaxis,2)).')),{'. Ableitung: raw-white 1-red 2-cyan'});
    J.Y=YaxisTotal;
%     J.Xres=Zres;
%     J.Xlab='depth [µm]';
%     J.Ylab='Yaxis';
%     try; J.Xrange=ZumRange; end;
    J.Yrange=[-1;1];
    J.Sp={'w.';'r.';'c.'};
    %     J.Style=1;
%     J.AddLine=[{FitMinCenterMax(1);-1;FitMinCenterMax(1);+1;{'Color','w'}},{FitMinCenterMax(3);-1;FitMinCenterMax(3);+1;{'Color','w'}}];
    movieBuilder_4(J);
    
end


