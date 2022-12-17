function [Whiskerdata,Whisking,TotalWhiskingTime,TotalNoWhiskingTime,Numberofwhiskingperiods,StartWhisking,StopWhisking]=findwhiskermovement_2(DataPathString,MovementCriterium,IntervalThreshold,SamplingFreq)
%read in data
Whiskerdata=xlsread(DataPathString);
FrameNumber=size(Whiskerdata,1);

%smooth data
Whiskerdata=smooth(Whiskerdata,5);

%find baseline and noise/std
MeanWhisker=mean(Whiskerdata);
StdWhisker=std(Whiskerdata);
%find baseline and noise/std not considering the signal peaks
for n=1:6
    NoSignalPosition=Whiskerdata<(MeanWhisker+MovementCriterium*StdWhisker);
    MeanWhisker=mean(NoSignalPosition.*Whiskerdata);
    StdWhisker=std(NoSignalPosition.*Whiskerdata);
end
%normalize data
NormWhiskerdata=(Whiskerdata-MeanWhisker)./MeanWhisker;
NormWhiskerMax=max(NormWhiskerdata);
NormWhiskerdata=NormWhiskerdata.*3./NormWhiskerMax;
%find baseline and noise/std of normalized data
MeanNormwhisker=mean(NormWhiskerdata);
StdNormwhisker=std(NormWhiskerdata);
%find baseline and noise/std of the normalized data not considering the signal peaks
for n=1:5
    NoSignalPosition=NormWhiskerdata<(MeanNormwhisker+MovementCriterium*StdNormwhisker);
    MeanNormwhisker=mean(NoSignalPosition.*NormWhiskerdata);
    StdNormwhisker=std(NoSignalPosition.*NormWhiskerdata);
end

% find signals with specified characteristics and mark them
MinAmplitudeWhisker=MeanNormwhisker+MovementCriterium*StdNormwhisker;
[PeaksWhisker,MovementLocations]=findpeaks(NormWhiskerdata(:),...
    'MinPeakHeight',MinAmplitudeWhisker);
PeakNumber=(size(PeaksWhisker));
% find beginning and end of whisking phase
% there are multiple peaks per whisking phase, with the code below start
% and stop of the whisking phase are found as data points below 1xstd
% closest to the peaks. Followingly the same starting and stopping points
%will be found multiple times, to clear those out, the second loop is
% in the code, finding all double/multiple starts and stops
Xbelow=zeros(1,PeakNumber(1));
Xabove=zeros(1,PeakNumber(1));
for n=1:PeakNumber(1)
    x=MovementLocations(n);
    y=find(NormWhiskerdata<(MeanNormwhisker+StdNormwhisker));
    yclosest1=y-x;
    yclosestbelow1=find(yclosest1<0,1,'last');
    yclosestabove1=find(yclosest1>0,1,'first');
    
    yclosestbelow2=y(yclosestbelow1);
    yclosestabove2=y(yclosestabove1);
    if isempty(yclosestbelow2)==1
        yclosestbelow2=1;
    end
    if isempty(yclosestabove2)==1
        yclosestabove2=FrameNumber(1);
    end
    Xbelow(n)=yclosestbelow2;
    Xabove(n)=yclosestabove2;
end
DoubledWhisking=[];
if PeakNumber(1)>1
    for n=2:PeakNumber(1)
        if Xbelow(n)==Xbelow(n-1) && Xabove(n)==Xabove(n-1)
            DoubledWhisking=horzcat(DoubledWhisking,n);
        end
    end
end
Xbelow(DoubledWhisking)=[];
Xabove(DoubledWhisking)=[];

% Table=table;
StartWhisking=Xbelow.';
StopWhisking=Xabove.';
% sizestartwhisking=size(StartWhisking);
% Numberofwhiskingperiods=sizestartwhisking(2);






%determine area under this trace
AreaUnderCurveWhisker=trapz(NormWhiskerdata);
%determine frequency of movement
FrequencyOfWhiskerMovement=PeakNumber(1)/FrameNumber(1);


Whisking=zeros(FrameNumber,1);
for m=1:size(StartWhisking,1)
    Whisking(StartWhisking(m):StopWhisking(m))=1;
end

Start=find(Whisking~=Whisking(1),1);
for m=1:1000000
    End=find(Whisking(Start:end)~=Whisking(Start),1)+Start-1;
    if isempty(End); break; end;
    Interval=End-Start;
    if Interval<IntervalThreshold
        Whisking(Start:End-1)=Whisking(Start-1);
    end
    Start=End;
end

TotalWhiskingTime=sum(Whisking)/SamplingFreq;
TotalNoWhiskingTime=sum(1-Whisking)/SamplingFreq;

StartWhisking=[];
StopWhisking=[];

Start=find(Whisking==1,1);
for m=1:1000000
    Ind=size(StartWhisking,1)+1;
    Start=find(Whisking(Start:end)==1,1)+Start-1;
    if isempty(Start); break; end;
    StartWhisking(Ind,1)=Start;
    End=find(Whisking(Start:end)==0,1)+Start-1;
    if isempty(End); End=FrameNumber+1; end;
    StopWhisking(Ind,1)=End-1;
%     if isempty(End); break; end;
    Start=End;
    if Start>FrameNumber; break; end;
end

Numberofwhiskingperiods=size(StartWhisking,1);
% %plot traces and mark signals
% figure
% hold on
% plot(NormWhiskerdata);
% ylim([-0.5 4]);
% grid on
% title('Whiskermovements');
% plot(Xbelow,NormWhiskerdata(Xbelow),'bv','MarkerFaceColor','b');
% plot(Xabove,NormWhiskerdata(Xabove),'rv','MarkerFaceColor','r');
% plot(Whisking,'-r');
% hold off

