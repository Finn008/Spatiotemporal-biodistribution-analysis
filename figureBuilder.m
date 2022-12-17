function figureBuilder(Path,x,y,xlab,ylab,xRange,yRange,sp,tit,Layout)
graphNumber=size(y,2);
if exist('Layout')==0 || strcmp(Layout,'black')==0
    Layout='white';
end
if isempty(sp)
    sp(1:graphNumber,1)={'b.'};
elseif ischar(sp);
    if strcmp(sp,'r2b')
        wave1=rainbow(graphNumber);
        for m=1:graphNumber;
            wave2{m}=wave1(m,:);
        end
        sp=wave2;
    else
        wave1(1:graphNumber,1)={sp};
        sp=wave1;
    end
end
if isempty(x)
    x=(1:1:size(y,1)).';
end

fid=figure; hold on;
for m=1:graphNumber;
%     y=yTotal(:,m)
    try
        plot(x,y(:,m),sp{m});
    catch
        plot(x,y(:,m),'color',sp{m});
    end
end
try; xlabel(xlab); catch; end;
try; ylabel(ylab); catch; end;
try; set(gca,'xlim',xRange); catch; end;
try; set(gca,'ylim',yRange); catch; end;
try; title(tit); catch; end;
whitebg(Layout);
set(gcf,'color',Layout);
if isempty(Path)==0
%     saveas(fid,Path,'jpg');
    saveas(fid,Path,Path(end-2:end));
    close fid 1;
end