function displayData()
global w; global i; dbstop if error;
clear a; P0232_2(w.task,[]); global a;


%% before
if strcmp(w.status,'before');
%     mkdir([a.pathOut,'\',a.taskName]);
    mkdir([a.pathOut,'\display']);
    w.DoReport='success';
    return;
end
%% after
if strcmp(w.status,'after');
    
    
    
    
    w.DoReport='success';
    return
end

clear a; P0232_2(w.task,w.file); global a;

path=[a.pathOut,'\',a.taskName,'_BoutonPlaqueRel.mat'];
load(path);
date=[a.filename(1:4),a.filename(6:7),a.filename(9:10)];
path=['data=relData.d',date,';']; eval(path);


% calculate Bouton profile in regards to plaque distance
% first get rid of depth profile
boutonNumber=sum(data.binBoutonNumber,2); boutonNumber=permute(boutonNumber,[3,1,2]);
bVolume=sum(data.binBoutonVolume,2); bVolume=permute(bVolume,[3,1,2]);

plaqueInt=sum(data.binPlaqueInt,2); plaqueInt=permute(plaqueInt,[3,1,2]);
pVolume=sum(data.binPlaqueIntVolume,2); pVolume=permute(pVolume,[3,1,2]);

plaqueNumber=size(bVolume,2);
totalRange=size(bVolume,1);
[plaqueMinBin,plaqueThreshold,plaqueBorder,plaqueRadius,maxDistance,plaqueMaxBin]=deal(zeros(plaqueNumber,1,'double'));
[backgroundFitCoefs]=deal(zeros(plaqueNumber,2,'double'));

bVolume(:)=bVolume(:).*prod(data.res);
pVolume(:)=pVolume(:).*prod(data.res);

% smooth boutonNumber
% for m=1:plaqueNumber;
%     wave1=boutonNumber
%     =smooth(boutonNumber,[3,1],'moving');
% end
boutonDensity=boutonNumber./bVolume;
boutonDensity(bVolume==0)=NaN;
plaqueIntMean=plaqueInt./pVolume;



% % % determine start of plaque border
% % nanIDs=pVolume~=0;
% % for m=1:plaqueNumber;
% %     % determine smallest bin for each plaque
% %     wave1=find(nanIDs(:,m)==1);
% %     plaqueMinBin(m)=min(wave1(:));
% %     plaqueMaxBin(m)=max(wave1(:));
% %     fitRange=nanIDs(:,m);
% %     fitRange(plaqueMinBin(m):plaqueMinBin(m)+19)=0;
% %     fitRange(plaqueMinBin(m)+19+50:end)=0;
% %     Xaxis=1:totalRange; Xaxis=Xaxis.';
% %     backgroundFit=fit(Xaxis(fitRange(:)==1),plaqueIntMean(fitRange(:)==1,m),'poly1');
% %     backgroundFitCoefs(m,1:2)=coeffvalues(backgroundFit);
% %     backgroundFit=Xaxis; backgroundFit=backgroundFitCoefs(m,2)+(Xaxis-1).*backgroundFitCoefs(m,1);
% %     wave1=find(plaqueIntMean(:,m)<1.1*backgroundFit(:));
% %     plaqueThreshold(m)=backgroundFit(wave1(1));
% %     plaqueBorder(m)=wave1(1)-1; % last bin inside plaque
% %     plaqueRadius(m)=plaqueBorder(m)-plaqueMinBin(m)+1;
% %     maxDistance(m)=double(data.maxBin-data.minBin+1)-plaqueBorder(m);
% % end

for m=1:plaqueNumber;
    % for each plaque generate figure showing meanPlaqueInt
    Xaxis1=-plaqueBorder(m)+1:maxDistance(m); Xaxis1=Xaxis1.'; % 0 is the last bin within plaque
    Xaxis2=Xaxis1;
    
    Xaxis1=Xaxis1(~isnan(plaqueIntMean(:,m)));
    Ydata1=plaqueIntMean(~isnan(plaqueIntMean(:,m)),m);
    Ydata1=Ydata1./plaqueThreshold(m)*0.1;
    Ydata2=Ydata1./max(Ydata1(:));
    
    Xaxis2=Xaxis2(~isnan(boutonDensity(:,m)));
    Ydata3=boutonDensity(~isnan(boutonDensity(:,m)),m);
    Ydata3=smooth(Ydata3,5,'moving');
    Ydata3=Ydata3./prctile(Ydata3,95);
    Ydata4=bVolume(~isnan(boutonDensity(:,m)),m);
    Ydata4=Ydata4./max(Ydata4(:));
    
    fig=figure(1); hold on;
    plot(Xaxis1,Ydata1,'-b');
    plot(Xaxis1,Ydata2,'.k');
    plot(Xaxis2,Ydata3,'.g');
    plot(Xaxis2,Ydata4,'.r');
    
%     legend_handle=legend('DepthProfile','fit','Location','best'); set(legend_handle, 'Box', 'off','Color', 'none');
    xlabel('Distance [µm]');
    ylabel('Methoxy intensity');
    title(['tp',num2str(a.TargetTimepoint),',pl',num2str(m)]);
    set(gca,'ylim',[0,1])
    set(gca,'xlim',[-plaqueRadius(m),plaqueMaxBin(m)-plaqueRadius(m)]);
    
    path=[a.pathOut,'\display\',a.taskName,',tp',num2str(a.TargetTimepoint),',pl',num2str(m)];
    saveas(fig,path,'jpg');
    close figure 1;
end

calculateBoutonDepthProfile=0;
if calculateBoutonDepthProfile  ==1;
    % calculate BoutonDepthProfile
    density=data.BoutonDepthProfile(:,2)./data.BoutonDepthProfile(:,1)./prod(data.res);
    volume=data.BoutonDepthProfile(:,1)./prod(data.res);
    
    Xaxis=0:data.res(3):data.res(3)*(data.pix(3)-1);Xaxis=Xaxis.';
    
    nanIDs=isnan(density);
    firstLayer=find(nanIDs==0,1);
    lastLayer=data.pix(3)-find(flip(nanIDs)==0,1)+1;
    nanIDs(firstLayer)=1;
    nanIDs(lastLayer)=1;
    fitDensity=fit(Xaxis(~nanIDs),density(~nanIDs),'poly2');
    fitCoefs=coeffvalues(fitDensity);
    fitDensity = Xaxis; fitDensity = fitCoefs(1).*Xaxis.^2 + fitCoefs(2).*Xaxis + fitCoefs(3);
    
    fig=figure(1); hold on;
    plot(Xaxis,density,'.b');
    plot(Xaxis,fitDensity,'-r');
    legend_handle=legend('DepthProfile','fit','Location','best'); set(legend_handle, 'Box', 'off','Color', 'none');
    xlabel('Depth [µm]');
    ylabel('Bouton density [1/µm^3]');
    title(date);
    set(gca,'ylim',[0,0.04])
    
    path=[a.pathOut,'\',a.taskName,'\',date,'_BoutonDepthProfile'];
    saveas(fig,path,'emf');
    close figure 1;
    
    % fig=figure(1); hold on;
    % [hAx,hLine1,hLine2]=plotyy([Xaxis',Xaxis'],[density',fitDensity'],Xaxis,volume);
    % %set(hLine1,'LineStyle','.','Color','b');
    % %set(hLine2,'LineStyle','.','Color','r');
    % legend_handle=legend('DepthProfile','Volume','fit','Location','best'); set(legend_handle, 'Box', 'off','Color', 'none');
    % xlabel('Depth [µm]');
    % ylabel(hAx(1),'Bouton density [1/µm^3]');
    % ylabel(hAx(2),'Volume [µm^3]');
    % %set(hAx,{'ycolor'},{'b';'r'});
    % set(hAx(1),'ylim',[0,0.04],'ytick',[0,0.01,0.02,0.03,0.04]);
    
    
    
    
    
    
end



w.DoReport='done';