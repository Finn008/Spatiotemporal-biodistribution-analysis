% [numberofsignals,AreaUnderCurve,frequencyofsignals] = CaSignalFinder_MPItest_Petar('\\gnp42n\marvin\AG Herms Share\Finn\Petar\scripts\160310\TimeSeries',0.1,0.5,3.5,0.1,'\\gnp42n\marvin\AG Herms Share\Finn\Petar\scripts\160310\160310_a1043area1_14-19-18_WHISKING');
function [numberofsignals,AreaUnderCurve,frequencyofsignals] = CaSignalFinder_MPItest_Petar(DataPathString, RiseTime, DecayTime, SignalCriterium,absdF,WhiskerTrace)
%function to find Ca signals from intensity time traces of single cells
%output:
%an excel file is created in the Matlab folder with the name of mouse and area,
%like specified in A1 in the input excel file
%numberofsignals: number of Ca signals for the cell corresponding
%to the row
%AreaUnderCurve: area under the whole trace of the cell corresponding to
%the row
%frequencyofsignals: frequency of Ca signals in 1/s for the cell
%corresponding to the row
%input:
%DataPathString is the data path in ''; the data has to be a TimeSeries.mat
%file
%Risetime is the assumed rise time of the Ca Signal
%Decaytime is the assumed decay time of the Ca Signal
%those two basically define the minimum prominence of a peak and the
%minimum distance between two peaks and should orient at the speed of your
%chromo/fluorophore marking the transient
%SignalCriterium is the number of standard deviations, the signal has to be
%higher than the mean/baseline; 3xstd empirically proved to be good choice
%absdF is the absolute dF/F0 value that a peak has to reach to be accepted
%as signal, can be set 0
%WhiskerTrace is a String giving the data path to the corresponding whisker
%trace, the data has to be in an excel file and is assumed to be on column
%only
%if you want to change the smoothening, you have to access the code, the
%smoothening span and algorithm can easily changed; therefor see help
%smooth/the documentation for the smooth command and change the parameters
%in the second section of this function
%the code can handle files with traces for specific ROIs in different
%columns as long as those columns are assigned to that specific ROI in the
%cell intended for the real ROI numbers
%make sure that your excel file has the right form, especially the amount
%of not-trace-data cells has to be right, see the template file called:
%CaSignalFinderExcelTemplate
%% data read-in and processing be aware that DataPath has to be given as a string!
load(DataPathString);
%number of ROIs analyzed
DataSize=size(deltaF);
numberofROIs=DataSize(1);
timepoints=DataSize(2);
A=timepoints;
B=numberofROIs;
SamplingFrequency=SamplingFreq;

t=[0:1/SamplingFrequency:(A-1)/SamplingFrequency]';


%% read in dFoF values
smootheddata_dF=zeros(A,B);
for i=1:B
    smootheddata_dF(:,i)=spikeData(1,i).dFoF;
end

%now determine mean and standard deviation of the dF values as criteria for
%the later peak search, here as well, I tried to eliminate signal and movement
%artifacts for the calculation

mean_dF=mean(smootheddata_dF);
baseline_dF=mean(smootheddata_dF);
stds_dF=std(smootheddata_dF);
% clear signal from movement artifacts/negative peaks
for i=1:B
    movementartifacts(:,i)=smootheddata_dF(:,i)>(mean_dF(:,i)-SignalCriterium*stds_dF(:,i));
end
smootheddata_dF_corrected=movementartifacts.*smootheddata_dF; % suggestion: remove whole frame not only for selected cells but for all
% find baseline and noise/std not considering the signal peaks
% k=1;
for k=1:5
    for i=1:B
        nosignalposition_dF(:,i)=smootheddata_dF_corrected(:,i)<(mean_dF(:,i)+SignalCriterium*stds_dF(:,i));
    end
    baseline_dF=mean(nosignalposition_dF.*smootheddata_dF_corrected);
    stds_dF=std(nosignalposition_dF.*smootheddata_dF_corrected);
%     k=k+1;
end
% stds_dF;
% baseline_dF;
%% find whisker movement locations
% the whisker trace corresponding to the Ca-Imaging data is analyzed using
% the also custome made function findwhiskermovement; to be able to plot
% both data sets in one figure, the whisking data is shifted by -4;
% whilewhisking contains all times during which the mouse is considered to
% whisk

[Whiskerdata,Whisking,totalwhiskingtime,totalnowhiskingtime,numberofwhiskingperiods,startwhisking,stopwhisking]=findwhiskermovement_2(WhiskerTrace,2,7,SamplingFreq);

whilewhisking=find(Whisking==1);
% [WhiskerData,startwhisking,stopwhisking,WhiskingArea,numberofwhiskingperiods,Whisking]=findwhiskermovement(WhiskerTrace,2);
%adjust data values
% WhiskerData=(WhiskerData-4);
% whilewhisking=[];
% 
% for n=1:numberofwhiskingperiods
%     whilewhisking=horzcat(whilewhisking,[startwhisking(n):1:stopwhisking(n)]); %is the total set of timepoints while which the mouse is whisking
% %     whiskingtime(n)=t(stopwhisking(n))-t(startwhisking(n)); %is the set of time spans the whisking periods are lasting
% end
% totalwhiskingtime=sum(whiskingtime(:));

% totalwhiskingtime=sum(Whisking)/SamplingFreq;
% totalnowhiskingtime=sum(1-Whisking)/SamplingFreq;

%% find signals and mark them
% find peaks with specified characteristics; in this step, first all peaks
% with specified characteristics are determined, in successive steps, side
% peaks not representing seperate transients are neglected/cut out; for the
% remaining peaks the code tries to find beginning and end of the transient
% this is done by finding the data points reaching noise level (1xstd)
% closest to the peak; the time span from beginning to end (closest point
% left and right of the peak) is then considered as active time of the
% cell/ROI

% minimum distance between two peaks given by rise+fall time
mindistance=ceil((RiseTime+DecayTime)*SamplingFrequency);
%create zero matrices for signals, area under curve and the signal frequency
numberofsignals=zeros(1,B);
AreaUnderCurve=zeros(1,B);
frequencyofsignals=zeros(1,B);

%find signal peaks for each cell, with criteria of minimum distance and
%minimum height; defined by either the absolute minimum height or the
%relative minimum height defined by the std and the signal criterium; the
%larger value defines the minimum height
for i=1:B
    C=baseline_dF(1,i)+(SignalCriterium*stds_dF(1,i));
    if C>absdF
        minamplitude=C;
    else
        minamplitude=absdF;
    end
    
    [pks,locs_CaSignal]=findpeaks(smootheddata_dF(:,i),...
        'MinPeakHeight',minamplitude,'MinPeakDistance',mindistance'); %find peaks and peak locations
    numberofpeaks=(size(pks));
    %determine number of signals per trace
    
    numberofsignals(1,i)=numberofpeaks(1);
    %% side peak elimination; for each peak the prominence is checked, that means that if there is a larger value within the min distance then the peak is discarded and cut out of the pks/peak locs
    peaks_corrected=pks;
    peaklocs_corrected=locs_CaSignal;
    n=1;
    m=1;
    while n<numberofpeaks(1)+1
        x=peaklocs_corrected(m);
        lowerlimit=x-mindistance; % lower limit of the data that is checked if there is a larger value
        if lowerlimit<1 % with the definition above values below 1 could be reached, this would result in an error, thus the minimum value is set to be 1
            lowerlimit=1;
        end
        LengthofData=size(smootheddata_dF);
        upperlimit=x+mindistance; % upper limit of the data that is checked if there is a larger value
        if upperlimit>LengthofData(1); % with the definition above values above the max could be reached, this would result in an error, thus the max value is set to be the length of the vector
            upperlimit=LengthofData(1);
        end
        if smootheddata_dF(x,i) < max(smootheddata_dF(lowerlimit:upperlimit,i)) %this checks the the peak value is lower than any point in the span defined by lower and upper limit
            peaks_corrected(m)=[]; % if so, erase peak
            peaklocs_corrected(m)=[]; %if so, erase peak
        else
            m=m+1;
        end
        n=n+1;
    end
    numberofpeaks=(size(peaks_corrected)); %find corrected number of peaks
    %determine number of signals per trace
    numberofsignals(1,i)=numberofpeaks(1);
    
    %% find beginning and end of active phases
    % find the data point which is below mean+std closest to a peak the the
    % left and right; the time in between these points is considered as
    % active phase/period (approximation!)
    dbelow=zeros(1,numberofpeaks(1)); %create matrix for the closest value left of each peak
    dabove=zeros(1,numberofpeaks(1)); %create matrix for the closest value right of each peak
    for m=1:numberofpeaks(1)
        d=peaklocs_corrected(m);
        e=find(smootheddata_dF(:,i)<baseline_dF(i)+stds_dF(i)); %find all points smaller than mean+std
        eclosest1=e-d; %find the points closest to the peak, subtract peak location from the locations of the points smaller than mean+std
        eclosestbelow1=find(eclosest1<0,1,'last'); %then order in points left and right to the peak and choose the last left and the first right of the peak
        eclosestabove1=find(eclosest1>0,1,'first'); %the find command only gives you the index, so in the next step the real location is determined
        
        eclosestbelow2=e(eclosestbelow1);
        yclosestabove2=e(eclosestabove1);
        if isempty(eclosestbelow2)==1 %if there is now such value (or a value out of range) the closest below is 1 and the closest above the end value
            eclosestbelow2=1;
        end
        if isempty(yclosestabove2)==1 || yclosestabove2>A
            yclosestabove2=A;
        end
        dbelow(m)=eclosestbelow2;
        dabove(m)=yclosestabove2;
    end
    % resulting from the code above, it is possible that different
    % peaks have the same start and stop points of the active phase
    % if so, this is considered as one active phase (with multiple
    % peaks) and not as multiple active phases with the same start and
    % stop; this is done in the next step clearing out multiple acitve
    % phases
    doubled=[];
    if numberofpeaks(1)>1
        for r=2:numberofpeaks(1)
            if dbelow(r)==dbelow(r-1) && dabove(r)==dabove(r-1)
                doubled=horzcat(doubled,r);
            end
        end
    end
    dbelow(doubled)=[];
    dabove(doubled)=[];
    
    
    startactivity=dbelow;
    stopactivity=dabove;
    sizeactivity=size(startactivity);
    numberofactiveperiods=sizeactivity(2); %determine the number of active periods
    
    %% plot traces and mark signals
    % Ca imaging data and whisking data are now plotted;
    % active phases are marked as areas in cyan
    % whisking phases are marked as areas in gray
    % transient peaks are marked as well, red if the peak does not lay
    % within a whisking period and blue if it does
    
    figure
    hold on
    x=t;
    y=(smootheddata_dF(:,i));
    
    for l=1:numberofactiveperiods
        activetime(l)=t(stopactivity(l))-t(startactivity(l));
        % if ismember(startactivity(l),whilewhisking)==1
        %     g(i)=patch([t(startactivity(l),i) t(stopactivity(l),i) t(stopactivity(l),i) t(startactivity(l),i)], [-6 -6 6 6], 'magenta','FaceAlpha',0.2,'EdgeColor','None');
        % elseif ismember(stopactivity(l),whilewhisking)==1
        %     g(i)=patch([t(startactivity(l),i) t(stopactivity(l),i) t(stopactivity(l),i) t(startactivity(l),i)], [-6 -6 6 6], 'magenta','FaceAlpha',0.2,'EdgeColor','None');
        % else
        g(i)=patch([t(startactivity(l)) t(stopactivity(l)) t(stopactivity(l)) t(startactivity(l))], [-6 -6 6 6], 'cyan','FaceAlpha',0.6, 'EdgeColor','None'); % cyan active periods
        % end
    end
    
    for j=1:numberofwhiskingperiods
        h(i)=patch([t(startwhisking(j)) t(stopwhisking(j)) t(stopwhisking(j)) t(startwhisking(j))], [-6 -6 6 6], [0.7 0.7 0.7],'EdgeColor','None'); %gray whisking periods
    end
    %set(h,'FaceAlpha',0.2);
    %set(h,'EdgeColor','None');
    %hx1 = graph2d.constantline(t(startwhisking,i),'Color','g','LineWidth',2);
    %changedependvar(hx1,'x');
    %hx2 = graph2d.constantline(t(stopwhisking,i),'Color','r','LineWidth',2);
    %changedependvar(hx2,'x');
    plot(x,y,'LineWidth',1.5); %plot the Ca trace
    %axis([0 A/SamplingFrequency -1 max(max(smootheddata_dF))+0.2]) %set the range of the axis ymax and ymin are defined by the max for all cells, x axis runs from 0 to end of t
    axis([0 A/SamplingFrequency -1 1]) %set the range of the y axis -1 to 1, x axis runs from 0 to end of t
    grid on %creates a grid in the figures/plots
    title('Single Cell Intensity-Trace with marked Ca-signals/transients');     %title
    plot(x,(Whiskerdata-4)/5,'k','LineWidth',1.5);                                  %plot the whisking data divided by factor 5
    numberofpeaksduringwhisking(i)=0;                                           %create readout of the number of peaks while whisking
    for q=1:numberofpeaks(1) %mark peaks
        if ismember(peaklocs_corrected(q),whilewhisking)==1
            plot(t(peaklocs_corrected(q)),smootheddata_dF(peaklocs_corrected(q),i),'bv','MarkerFaceColor','b'); %blue, peaks while whisking
            numberofpeaksduringwhisking(i)=numberofpeaksduringwhisking(i)+1; %create a readout of the number of peaks while whisking
        else
            plot(t(peaklocs_corrected(q)),smootheddata_dF(peaklocs_corrected(q),i),'rv','MarkerFaceColor','r'); %red, peaks without whisking
        end
    end
    %plot(t(WhiskingLocations,i),WhiskerData(WhiskingLocations),'bv','MarkerFaceColor','b');
    %y_corrected=smootheddata_dF_corrected(:,i);
    %area(x,y_corrected); %this line can be activated by erasing the % sign
    %in front of area, like this the area under the curve (used for the
    %area under the curve calculation) is marked
    hold off
    
    %determine area under this trace
    
    Wave1=smootheddata_dF_corrected(:,i);
    Wave1(Wave1<0)=0;
    AreaUnderCurveNo(1,i)=sum(Wave1(Whisking==0)*1/SamplingFreq)/totalnowhiskingtime;
    AreaUnderCurveYes(1,i)=sum(Wave1(Whisking==1)*1/SamplingFreq)/totalwhiskingtime;
    
%     AreaUnderCurveYes(1,i)=sum(Wave1*1/SamplingFreq);
    %     AreaUnderCurve(1,i)=trapz(smootheddata_dF_corrected(:,i));
    %determine frequency of signal of this trace
    frequencyofsignalsduringwhisking(1,i)=numberofpeaksduringwhisking(1,i)./totalwhiskingtime*60; %determine frequency of signals while whisking
    frequencyofsignalswithoutwhisking(1,i)=(numberofsignals(1,i)-numberofpeaksduringwhisking(1,i))/(t(end)-totalwhiskingtime)*60; %determine frequency of signals without whisking
    
    %determine active time of this trace/cell
    
    totalactivetime(i) = sum(activetime(:)); %determine total active time
    if numberofactiveperiods==0
        totalactivetime(i)=0; %if there are no active periods, the totalactive time is set to be 0
    end
    
end


%% create an excel file as output
% each column represents one trace/cell; rows represent:
% 1: ROI/cell number
% 2: the number of transient peaks (signals)
% 3: the number of peaks while whisking
% 4: the area under the curve of the Ca trace
% 5: the frequency of signals without whisking
% 6: frequency of signals during whisking
% 7: the total active time of the ROI/cell
% 8: the total whisking time
% 9: total time

Wave1=load('ROI'); Wave1=Wave1.ROI;
Wave1=struct2table(Wave1);
X(1,:)=[1:B];
tangleneuron = Wave1(:,4);
tangleneuron = table2array(tangleneuron);

for m=X(1,:)
    Ind=find(Wave1.nr==m);
    X(2,m)=Wave1.group(Ind);
end

X(4,:)=numberofsignals;
X(5,:)=numberofpeaksduringwhisking;
X(6,:)=AreaUnderCurveYes;
X(7,:)=AreaUnderCurveNo;
X(8,:)=frequencyofsignalswithoutwhisking;
X(9,:)=frequencyofsignalsduringwhisking;
X(10,:)=totalactivetime;
X(11,:)=totalwhiskingtime;
X(12,:)=totalwhiskingtime./t(end,1)*100;
X(13,:)=t(end,1);


X=num2cell(X); %to be able to print it with column/row headers in a xls file, a array has to be created
X(3,:)=tangleneuron;

rowheaders={'ROI number';'Group/Cell number';'Neuron/Tangle';'Number of Transients'; 'Transients during Whisking'; 'Area yes whisking';'Area no whisking';'Frequency no Whisking [1/min]'; 'Frequency with Whisking [1/min]'; 'Active Time [s]'; 'Total Whisking Time [s]'; 'Percentage of Whiskingtime [%]';'Total Time [s]'};
output_matrix=[rowheaders X];                 %concatenate headers and data
transpose=output_matrix';                           %transpose the matrix

FolderName = DataPathString;                        %this part gives names the uotput excel files
alldir = regexp(fileparts(FolderName),filesep,'split');
Ime = alldir (end);                                 %takes last part of the folder path as a file name
FName = strcat(Ime,'_DATA');                        %adds DATA at the end of the excel file name
FinalName = strcat(FName,'_SORTED');                %adds SORTED at the end of the excel file name
expression = '_';
%splits the name between characters '_'
splitStr = regexp(Ime{1},expression,'split');
ShortName = splitStr (1,2);                         %looks for the name part at second position
ShortFinalName = strcat (ShortName, '_SORTED');     %adds SORTED at the end of the excel file name
% sortedtabbygroup = sortrows (transpose,'Group/Cell Number');
sortedtabbygroup = sortrows (transpose(2:end,:),-2); %sorts excel file starting from second row (first row are headers) according to second column
sortedtabbygroup=[transpose(1,:);sortedtabbygroup];
xlswrite(FName{1},transpose);                       %writes unsorted excel file
% xlswrite(FinalName{1},sortedtabbygroup);            %writes sorted excel file
xlswrite(ShortFinalName{1},sortedtabbygroup);       %writes sorted excel file with short name for example 'a826area1_SORTED'

