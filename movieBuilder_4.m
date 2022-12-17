%  call Areafill: J.OrigYaxis={Y(:,1),struct('Color','r','Area',1);Y(:,2),'r';Y(:,3),'w.'};
function movieBuilder_4(In)
mouseMoveController(1);
v2struct(In);
set(0,'units','pixels'); ScreenPix=get(0,'screensize'); ScreenPix=ScreenPix(3:4).';

if exist('ImageSize')
    FidPix=[50,50,ImageSize(1,1)+50,ImageSize(2,1)+50];
end
if exist('LegendLocation')~=1
    LegendLocation='northeast';
end
if exist('Style')==1
    if Style==1 % large
        if exist('FontSize')~=1; FontSize=30; end;
        if exist('AxisWidth')~=1; AxisWidth=2; end;
        if exist('MarkerSize')~=1; MarkerSize=5; end;
        if exist('LineWidth')~=1; LineWidth=2; end;
        if exist('Layout')~=1; Layout='black'; end;
        FidPix=[50,50,ScreenPix(1,1)-100,ScreenPix(2,1)-150];
    end
else % small
    if exist('FontSize')~=1; FontSize=10; end;
    if exist('AxisWidth')~=1; AxisWidth=1; end;
    if exist('MarkerSize')~=1; MarkerSize=3; end;
    if exist('LineWidth')~=1; LineWidth=1; end;
    if exist('Layout')~=1; Layout='black'; end;
end

try; Wave1=LogScale.X; catch; LogScale.X=0; end;
try; Wave1=LogScale.Y; catch; LogScale.Y=0; end;


if exist('Sp')==1  && ischar(Sp)
    Sp={Sp};
end
if exist('GenerateExcelFile')~=1
    GenerateExcelFile=0;
end

AreaFill=zeros(0,1);
if exist('Path2file')==0 || isempty(Path2file)
    Path2file={['D:\','default']};
end
if exist('Cumulative')~=1
    Cumulative=0;
end
if ischar(Path2file)
    Path2file={Path2file};
end
% generate Yaxis in correct format, provide different graphs in
% cell rows, timepoints in rows, Xrange in columns
if exist('OrigYaxis')==1
    if exist('OrigType')~=1
        OrigType=1;
    end
    
    for m=1:size(OrigYaxis,1)
        Wave1=OrigYaxis{m,1};
        if istable(Wave1)
           Wave1=table2array(Wave1); 
        end
        if OrigType==1 % Xdata already in X, Graphs already in Y and timepoints already in Z
            
        elseif OrigType==2 % Xdata in Y, timepoints in X, traces in Z
            Wave1=permute(Wave1,[2,3,1]);
        elseif OrigType==3 % Xdata alredy in X, timepoints in Y, traces in Z
            Wave1=permute(Wave1,[1,3,2]);
        end
        
        if m==1
            Y=Wave1;
        else
            Y=[Y,Wave1];
        end
        if size(OrigYaxis,2)==1
        elseif isstruct(OrigYaxis{m,2})
            Wave1=OrigYaxis{m,2};
            FieldNames=fieldnames(Wave1);
            Sp(m,1)={OrigYaxis{m,2}.Color};
            if strfind1(FieldNames,'Area')
                AreaFill(end+1,1)=m;
            end
        else
            Sp(m,1)=OrigYaxis(m,2);
        end
        
    end
end

Xpix=size(Y,1);
GraphNumber=size(Y,2);
FrameNumber=size(Y,3);

if exist('Layout')==0 || strcmp(Layout,'black')==0
    Layout='white';
end
if exist('MarkerSize')~=1
    MarkerSize=1;
end
if exist('Tit')~=1
    Tit='';
end
if exist('LineWidth')~=1
    LineWidth=1;
end
if exist('AddLine')==1 
    if size(AddLine,3)~=FrameNumber
        AddLine=repmat(AddLine,[1,1,FrameNumber]);
    end
else
    AddLine=cell(0,0);
end

if exist('X')==0 || isempty(X)
    X=(1:1:Xpix).';
    if exist('Xres')
        X=X*Xres;
    end
end
if exist('Sp')~=1
    Sp(1:GraphNumber,1)={'b.'};
elseif size(Sp,1)~=GraphNumber
    Sp=repmat(Sp,[GraphNumber,1]);
end

if exist('Frequency')==1
    writerObj = VideoWriter(Path2file{1});
    writerObj.FrameRate = Frequency; % How many frames per second.
    writerObj.Quality=100;
    open(writerObj);
    % get Xrange and Yrange
% % %     if exist('Xrange')~=1
% % %         for m=1:size(Y,1)
% % %             Wave1(m,1)=min(isnan(Y(m,:,:)));
% % %         end
% % %         NanRows=find(sum(isnan(Y),3)==size(Y,3));
% % %         
% % %         Wave1=nansum_2(Y,3);
% % %         Wave1=nansum(nansum(Y,2),3);
% % %         Yrange=[min(Y(:));max(Y(:))];
% % %     end
    if exist('Yrange')~=1
        Yrange=[min(Y(:));max(Y(:))];
    end
end

if ischar(Tit);
    Tit=repmat({Tit},[1,FrameNumber]);
elseif size(Tit,1)<FrameNumber;
    Tit(1:FrameNumber,1)=Tit;
end

for m=1:FrameNumber
    if Cumulative==0 || m==1
        Fid=figure;
%         hold on;
    end
    whitebg(Layout);
    
    % add the graphs
    for n=1:GraphNumber;
        if isempty(find(AreaFill==n))==0
            
            Xcont=[X.',fliplr(X.')]; %#create continuous x value array for plotting
            Ycont=[Y(:,n,m).',fliplr(Y(:,n+1,m).')]; %#create y values for out and then back
            fill(Xcont,Ycont,Sp{n}); % #plot filled area
        elseif isempty(find(AreaFill==n-1))==0
            continue;
        else
            try
                if size(X,2)==1
                    if LogScale.Y==0 && LogScale.X==0
                        plot(X,Y(:,n,m),Sp{n},'MarkerSize',MarkerSize,'LineWidth',LineWidth);
                    elseif LogScale.Y==10
                        semilogy(X,Y(:,n,m),Sp{n},'MarkerSize',MarkerSize,'LineWidth',LineWidth);;
                    elseif LogScale.X==10
                        semilogx(X,Y(:,n,m),Sp{n},'MarkerSize',MarkerSize,'LineWidth',LineWidth);;
                        
                    end
                    
                    
                        
                else
                    plot(X(:,n,m),Y(:,n,m),Sp{n},'MarkerSize',MarkerSize,'LineWidth',LineWidth);
                end
            catch
                keyboard; % what is this good for? 2015.08.06
                plot(X,Y(:,n,m),'color',Sp{n},'MarkerSize',MarkerSize,'LineWidth',LineWidth);
            end
        end
        hold on;
    end
    
    % set the layout
    try; xlabel(Xlab); end;
    try; ylabel(Ylab); end;
    try; set(gca,'xlim',Xrange(1:2)); end;
    try; set(gca,'ylim',Yrange(1:2)); end;
    try; set(legend(Legend),'color','none','Location',LegendLocation); legend('boxoff'); end;
    try; set(gca,'XTick',Xrange(3):Xrange(4):Xrange(2)); end;
    try; set(gca,'YTick',Yrange(3):Yrange(4):Yrange(2)); end;
    Wave1=regexprep(Tit{m},'_','\\_');
    try; title(Wave1); end;
    
    set(gcf,'color',Layout);
    
    % add Lines
    for n=1:size(AddLine,2)
        LineID=line([AddLine{1,n,m},AddLine{3,n,m}],[AddLine{2,n,m},AddLine{4,n,m}]);
        if size(AddLine,1)>4
            for m3=1:size(AddLine{5,n,m},1)
                set(LineID,AddLine{5,n,m}{1,1},AddLine{5,n,m}{1,2},'LineWidth',AxisWidth);
            end
        end
    end
    try; set(gca,'FontSize',FontSize); end;
    try; set(gca,'LineWidth',AxisWidth); end;
    
    pause(0.1);
    % set the figure size
    if exist('FidPix')==1
        set(Fid,'Units','pixels','Position',FidPix);
    end
    
    Type=Path2file{1,1}(end-3:end);
    if exist('Frequency')==1
        frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
        if exist('FidPix')==1
            if size(frame.cdata,1)==FidPix(1,4) && size(frame.cdata,2)==FidPix(1,3)
                writeVideo(writerObj, frame);
            else
                keyboard;
            end
        else
            writeVideo(writerObj, frame);
        end
        if Cumulative==0
            close Fid 1;
        end
    else
        
        if strfind1({'.png','.jpg'},Type)
            export_fig(Fid,Path2file{m,1});
        elseif strfind1({'.eps';'.epsc';'.bmp';'.pdf';'.emf';'.tif'},Type)
            saveas(Fid,Path2file{m,1});
        elseif strfind1({'.avi'},Type)
%             Wave1=[Path2file{1}(1:end-3),'_',num2str(m),'.tif'];
%             saveas(Fid,Wave1);
            Wave1=[Path2file{1}(1:end-3),'_',num2str(m),'.png'];
            export_fig(Fid,Wave1);
            
        else
            keyboard;
        end
        close Fid 1;
    end
end
if exist('Frequency')==1
    close(writerObj); % Saves the movie.
    if Cumulative==1
        close Fid 1;
    end
end
if GenerateExcelFile==1
    keyboard;
    OutputPath=strrep(Path2file{1},Type,'.xlsx');
    [Excel,Workbook,Sheets,SheetNumber]=connect2Excel(OutputPath);
    
    for m=FrameNumber:-1:1
        Wave1=[X,Y(:,:,m)];
        xlsActxWrite(Wave1,Workbook,num2str(m));
    end
end

mouseMoveController(0);


