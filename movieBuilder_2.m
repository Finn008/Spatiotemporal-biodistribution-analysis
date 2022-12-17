function movieBuilder_2(Path,frequency,x,y,xlab,ylab,xRange,yRange,sp,tit,Layout)

if exist('Layout')==0 || strcmp(Layout,'black')==0
    Layout='white';
end

if isempty(Path)
    Path=['D:\','default'];
end
writerObj = VideoWriter(Path);
writerObj.FrameRate = frequency; % How many frames per second.
writerObj.Quality=100;
% writerObj.filename='mp4';

open(writerObj);

Xpix=size(y,1);
GraphNumber=size(y,2);
FrameNumber=size(y,3);

if isempty(x)
    x=(1:1:Xpix).';
end
if isempty(sp)
    sp(1:GraphNumber,1)={'b.'};
elseif ischar(sp);
    wave1(1:GraphNumber,1)={sp};
    sp=wave1;
end

if ischar(tit);
    tit{1:FrameNumber,1}=tit;
elseif size(tit,1)<FrameNumber;
    tit(1:FrameNumber,1)=tit;
end

for m=1:FrameNumber;
    
    fid=figure; hold on;
    for n=1:GraphNumber;
        try
            plot(x,y(:,n,m),sp{n});
        catch
            plot(x,y(:,n,m),'color',sp{n});
        end
        
        
    end
%     try; xlabel(xlab); catch; end;
%     try; ylabel(ylab); catch; end;
%     try; set(gca,'xlim',xRange); catch; end;
%     try; set(gca,'ylim',yRange); catch; end;
%     try; title(tit); catch; end;
%     fid=figure;
%     plot(x,y(:,m),sp{m});
    try; xlabel(xlab); catch; end;
    try; ylabel(ylab); catch; end;
    try; set(gca,'xlim',xRange); catch; end;
    try; set(gca,'ylim',yRange); catch; end;
    try; title(tit{m}); catch; end;
    whitebg(Layout);
    set(gcf,'color',Layout);
    pause(0.1);    
    %if mod(i,4)==0, % Uncomment to take 1 out of every 4 frames.
%     disp(m);
    frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
    writeVideo(writerObj, frame);
    %end
    close fid 1;
end
close(writerObj); % Saves the movie.
