function sizeStuff()
global l; global w; dbstop if error;

% [t]=getI(l(w.task)); try; [f]=getI(l(w.task).l(w.file)); catch; end;
t=l.t(w.task,:);
try; f=l.t(w.task).f(w.file); catch; end;

if strcmp(w.status,'useRefFile');
%     [FileName,PathName,FilterIndex] = uigetfile('*.*','Browse Export',l.g.pathRaw{1});
%     [FileName,PathName,FilterIndex] = uigetfile('*.*');
    w.doN = input('which doN? ');
    filename = input('which file? ');
    
    if filename==0; 
        return; 
    elseif isnumeric(filename)
        filename=[t.f{1}.filename{filename,w.doN},t.f{1}.type{filename,w.doN}]
    end;
    [fileinfo]=GetFileInfo(filename); %     [fileinfo]=P0236(filename); % get information on that file
    if isempty(fileinfo)==0
        t.res(1,w.doN)=fileinfo.res;
        t.um(1,w.doN)=fileinfo.um;
        t.pix(1,w.doN)=fileinfo.pix;
        %     t.center=[0;0;0];
        t.umStart(1,w.doN)=fileinfo.umStart;
        t.umEnd(1,w.doN)=fileinfo.umEnd;
        % generate XYZumStart and End
        l.t(w.task,:)=t;
    end
end


if strfind1({'commonVolume';'totalVolume'},w.status);
    w.doN = input('which doN? ');
    %     [fitArr,summedExtension]=CalcSummedFitCoef();
    
%     [fitArr,totalVolume,commonVolume]=CalcSummedFitCoef([]);
    [fA,volume]=CalcSummedFitCoef([]);
    %     t.um=summedMaxDist2Center.*2;
    if strcmp(w.status,'commonVolume');
        t.umStart{1,w.doN}=volume.totalVolume(:,1);
        t.umEnd{1,w.doN}=volume.totalVolume(:,2);
    end
    if strcmp(w.status,'totalVolume');
        t.umStart{1,w.doN}=volume.totalVolume(:,1);
        t.umEnd{1,w.doN}=volume.totalVolume(:,2);
    end
    %     t.res=[l(l.g.v4).Xres;l(l.g.v4).Yres;l(l.g.v4).Zres];
    t.umStart{1,w.doN}=floor(t.umStart{1,w.doN}./t.res{1,w.doN}).*t.res{1,w.doN};
    t.umEnd{1,w.doN}=ceil(t.umEnd{1,w.doN}./t.res{1,w.doN}).*t.res{1,w.doN};
    t.um{1,w.doN}=t.umEnd{1,w.doN}-t.umStart{1,w.doN};
    t.pix{1,w.doN}=t.um{1,w.doN}./t.res{1,w.doN};
    l.t(w.task,:)=t;
%     t.center=[0;0;0];
end

if strcmp(w.status,'umPixCalc');
    if size(t.umStart,2)>1;
        prompt = 'which doN? ';
        w.doN = input(prompt);
    else
        w.doN = 1;
    end
    
    umStart=t.umStart(:,w.doN);
    umEnd=t.umEnd(:,w.doN);
    res=t.res(:,w.doN);
    for m=1:3;
        if isnan(umStart)==0; % calculate pix from um
            umStart=floor(umStart./res).*res;
            umEnd=ceil(umEnd./res).*res;
            um=umEnd-umStart;
            pix=um./res;
        end
    end
    l.t(w.task).umStart(:,w.doN)=umStart;
    l.t(w.task).umEnd(:,w.doN)=umEnd;
    l.t(w.task).um(:,w.doN)=um;
    l.t(w.task).pix(:,w.doN)=pix;
    
    determineTimeandChannel=0;
    if determineTimeandChannel==1;
        TargetChannel={t.TargetChannel};
        TargetTimepoint=f.TargetTimepoint(1,w.doN);
        channels=f.channels(1,w.doN);
        timepoints=f.timepoints(1,w.doN);
        
        wave1=[TargetChannel];
        wave1=max(wave1(:));
        wave2=[TargetTimepoint];
        wave2=max(wave2(:));
        if channels<wave1 || isnan(channels); channels=wave1; end;
        if timepoints<wave2 || isnan(timepoints); timepoints=wave2; end;
    end
    
end


a1=1;
