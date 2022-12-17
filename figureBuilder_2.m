function figureBuilder_2(In)
v2struct(In);

Xpix=size(Y,1);
GraphNumber=size(Y,2);

if exist('Layout')==0 || strcmp(Layout,'black')==0
    Layout='white';
end
if exist('AddLine')==1 && size(AddLine,3)~=FrameNumber
    AddLine=repmat(AddLine,[1,1,FrameNumber]);
else
    AddLine=cell(0,0);
end
if exist('Path')==0 || isempty(Path)
    Path=['D:\','default'];
end
if exist('X')==0 || isempty(X)
    X=(1:1:Xpix).';
    if exist('Xres')
        X=X*Xres;
    end
end
if exist('Sp')==0 || isempty(Sp)
    Sp(1:GraphNumber,1)={'b.'};
elseif ischar(Sp);
    wave1(1:GraphNumber,1)={Sp};
    Sp=wave1;
end

Fid=figure; hold on;
whitebg(Layout);
set(gcf,'color',Layout);
try; xlabel(Xlab); catch; end;
try; ylabel(Ylab); catch; end;
try; set(gca,'xlim',Xrange); catch; end;
try; set(gca,'ylim',Yrange); catch; end;
try; title(Tit); catch; end;
if exist('Y2')
    plotyy(X,Y,X,Y2);
else
    for n=1:GraphNumber;
        try
            plot(X,Y(:,n),Sp{n});
        catch
            plot(X,Y(:,n),'color',Sp{n});
        end
    end
end


for n=1:size(AddLine,2)
    LineID=line([AddLine{1,n,m},AddLine{3,n,m}],[AddLine{2,n,m},AddLine{4,n,m}]);
    if size(AddLine,1)>4
        for m3=1:size(AddLine{5,n,m},1)
            set(LineID,AddLine{5,n,m}{1,1},AddLine{5,n,m}{1,2});
        end
    end
end
pause(0.1);
if isempty(Path)==0
    %     saveas(fid,Path,'jpg');
    saveas(Fid,Path,Path(end-2:end));
    export_fig(Fid,Path);
end
close Fid 1;