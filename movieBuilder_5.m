%  call Areafill: J.OrigYaxis={Y(:,1),struct('Color','r','Area',1);Y(:,2),'r';Y(:,3),'w.'};
function movieBuilder_5(In)
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
        if exist('FidPix')~=1; FidPix=[50,50,ScreenPix(1,1)-100,ScreenPix(2,1)-150]; end;
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


% if exist('Sp')==1  && ischar(Sp)
%     Sp={Sp};
% end
if exist('GenerateExcelFile')~=1
    GenerateExcelFile=0;
end

% AreaFill=zeros(0,1);
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

if exist('Y')==1
    keyboard;
    
elseif exist('OrigYaxis')==1
    Y=table;
    %     Sp=cell(0,1);
    if exist('OrigType')~=1
        OrigType=0;
    end
    
    for OInd=1:size(OrigYaxis,1)
        Y2add=OrigYaxis{OInd,1};
        if istable(Y2add)
            Y2add=table2array(Y2add);
        end
        if OrigType==0 % Xdata horizontally, traces vertically, timepoints in Z
            
        elseif OrigType==1 % Xdata vertically, traces horizontally, timepoints in Z
            Y2add=permute(Y2add,[2,1,3,4]);
        elseif OrigType==2 % Xdata horizontally, timepoints vertically, traces in Z
            Y2add=permute(Y2add,[1,3,2,4]);
        elseif OrigType==3 % Xdata horizontally, timepoints vertically, traces in Z
            Y2add=permute(Y2add,[1,3,2,4]);
        elseif OrigType==4 % Xdata vertically, timepoints horizontally, traces in Z
            Y2add=permute(Y2add,[3,1,2,4]);
        end
        
        
        Wave1=Y2add(:,:,1,:);
        Timepoints=repmat(1,[size(Y2add,1),1]);
        for m2=2:size(Y2add,3)
            Wave1=[Wave1;Y2add(:,:,m2,:)];
            Timepoints=[Timepoints;repmat(m2,[size(Y2add,1),1])];
        end
        Y2add=Wave1;
        IndSize=size(Y2add,1);
        Ind=(size(Y,1)+1:size(Y,1)+IndSize).';
        Y.Timepoint(Ind,1)=Timepoints;
        % define color specs
        if size(OrigYaxis,2)==1
        elseif isstruct(OrigYaxis{OInd,2})
            Struct=struct2table(OrigYaxis{OInd,2},'AsArray',1);
            VariableNames=Struct.Properties.VariableNames.';
            Y(Ind,VariableNames)=repmat(Struct(1,VariableNames),[IndSize,1]);
            if strfind1(fieldnames(Struct),'GraphLabel',1)
                Y.GraphLabel(Ind,1)=repmat(Struct.GraphLabel,[size(Ind,1)/size(Struct.GraphLabel,1),1]);
            end
            if strfind1(VariableNames,'Area',1)
                for m=1:size(Ind,1)
                    Y.Area(Ind(m),1)={Y2add(m,:,:,2)};
                end
                Y2add=Y2add(:,:,:,1);
            end
        else
            keyboard;
            Sp(end+1:end+size(Y2add,2),1)=repmat(OrigYaxis(OInd,2),[size(Y2add,2),1]);
        end
        if OInd>1
            Y.Data(Ind,:)=NaN; % set Nan before
        end
        Y.Data(Ind,1:size(Y2add,2))=Y2add;
    end
end

if strfind1(Y.Properties.VariableNames,'Area',1)==0
    Y.Area(1)={[]};
else
    Wave1=cellfun(@isempty,Y.Area);
    YA=Y(Wave1==0,:);
    Y=Y(Wave1==1,:);
    
    for Time=1:max(YA.Timepoint(:))
        Ind=find(YA.Timepoint==Time);
        if size(Ind,1)>1
            for m=1:size(Ind,1)
                Traces(:,1,m)=YA.Data(Ind(m),:).';
                Traces(:,2,m)=YA.Area{Ind(m),:}.';
            end
            [Intersection]=areaIntersection(Traces);
            YA(end+1,:)=YA(Ind(1),:);
            YA.Color(end,1)={IntersectionColor};
            YA.Data(end,:)=Intersection(:,1);
            YA.Area(end,:)={Intersection(:,2).'};
        end
    end
    Y=[YA;Y];
end

Xpix=size(Y.Data,2);
SpecVariableNames=Y.Properties.VariableNames.';
if strfind1(SpecVariableNames,'Timepoint')==0
    Y.Timepoint(:,1)=repmat(1,[size(Y,1),1]);
end

% GraphNumber=size(Table,1);
FrameNumber=max(Y.Timepoint);

if exist('Layout')==0 || strcmp(Layout,'black')==0
    Layout='white';
end
if strfind1(SpecVariableNames,'MarkerSize')==0
    Y.MarkerSize(:,1)=1;
end
if exist('Tit')~=1
    Tit='';
end
if strfind1(SpecVariableNames,'LineWidth')==0
    Y.LineWidth(:,1)=1;
end
if strfind1(SpecVariableNames,'Color')==0
    Y.Color(:,1)={'w'};
end
if strfind1(SpecVariableNames,'LineStyle')==0
    Y.LineStyle(:,1)={'none'};
end
if strfind1(SpecVariableNames,'Marker')==0
    Y.Marker(:,1)={'.'};
end

if strfind1(SpecVariableNames,'MarkerType')==0
    Y.MarkerType(:,1)={'.'};
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
elseif size(X,1)~=Xpix
    X=X(1:Xpix);
end
% if exist('Sp')~=1
%     Sp(1:GraphNumber,1)={'b.'};
% elseif size(Sp,1)~=GraphNumber
%     Sp=repmat(Sp,[GraphNumber,1]);
% end

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

for Tp=1:FrameNumber
    if Cumulative==0 || Tp==1
        Fid=figure;
        %         hold on;
    end
    whitebg(Layout);
    
    % add the graphs
    for Graph=find(Y.Timepoint==Tp).'
        if isempty(Y.Area{Graph})==0 %max(strfind1(Y.Properties.VariableNames,'Area'))~=0 && 
%             Wave1=[X.';Y.Area{Graph};Y.Data(Graph,:)];
%             Wave1(:,isnan(sum(Wave1,1)))=[];
%             X=Wave1(1,:); Y1=Wave1(2,:); Y2=Wave1(3,:);
            Y1=Y.Area{Graph}; Y1(isnan(Y1))=100;
            Y2=Y.Data(Graph,:);Y2(isnan(Y2))=100;
            Xcont=[X.',fliplr(X.')]; %#create continuous x value array for plotting
            Ycont=[Y1,fliplr(Y2)]; %#create y values for out and then back
            Wave1=fill(Xcont,Ycont,Y.Color{Graph}); % #plot filled area
            set(Wave1,'EdgeColor','None');
        else
            try
                if size(X,2)==1
                    if LogScale.Y==0 && LogScale.X==0
                        Y1=Y.Data(Graph,:).';
%                         plot(X,Y1,'Color',Y.Color{Graph},'MarkerSize',Y.MarkerSize(Graph),'LineWidth',Y.LineWidth(Graph));
                        plot(X,Y1,'Color',Y.Color{Graph},'Marker',Y.Marker{Graph},'MarkerSize',Y.MarkerSize(Graph),'LineWidth',Y.LineWidth(Graph),'LineStyle',Y.LineStyle{Graph});
                        if exist('GraphLabel')==1 && GraphLabel==1
                            try %if strfind1(Y.Properties.VariableNames.','GraphLabel',1) && isempty(Y.GraphLabel{Graph})==0
                                %                             Xrange
                                %                             Wave1=find(isnan(Y1)==0).';
                                Wave1=find(isnan(Y1)==0 & Y1<Yrange(2) & Y1>Yrange(1) & X<Xrange(2)*Xres & X>Xrange(1)*Xres);
                                Wave1=Wave1(round(rand(1)*size(Wave1,1)));
                                text(X(Wave1),Y1(Wave1),['\leftarrow',Y.GraphLabel{Graph}]);
                            end
                        end
                        
                    elseif LogScale.Y==10
                        semilogy(X,Y.Data(Graph,:),Y.Color{Graph},Y.MarkerSize(Graph),'LineWidth',Y.LineWidth(Graph));
                    elseif LogScale.X==10
                        semilogx(X,Y.Data(Graph,:),Y.Color{Graph},Y.MarkerSize(Graph),'LineWidth',Y.LineWidth(Graph));
                        
                    end
                    
                    
                    
                else
                    plot(X(:,Graph,Tp),Y(:,Graph,Tp),Sp{Graph},'MarkerSize',MarkerSize,'LineWidth',LineWidth);
                end
            catch
                keyboard; % what is this good for? 2015.08.06
                plot(X,Y(:,Graph,Tp),'color',Sp{Graph},'MarkerSize',MarkerSize,'LineWidth',LineWidth);
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
    %
    %     set(legend(Legend),'TextColor',{'w','r','g','y'},'Location',LegendLocation); legend('boxoff');
    %     set(legend(Legend),'TextColor','r','Location',LegendLocation); legend('boxoff');
    %
    %
    %     Leg=set(legend(Legend));
    %
    %     legtxt=findobj(Leg,'type','text');
    %
    %     Leg.TextColor={'k'};
    %     set(legtxt(1),'color','k')
    try; set(gca,'XTick',Xrange(3):Xrange(4):Xrange(2)); end;
    try; set(gca,'YTick',Yrange(3):Yrange(4):Yrange(2)); end;
    
    try; Wave1=regexprep(Tit{Tp},'_','\\_'); title(Wave1); end;
    
    set(gcf,'color',Layout);
    
    % add Lines
    for n=1:size(AddLine,2)
        LineID=line([AddLine{1,n,Tp},AddLine{3,n,Tp}],[AddLine{2,n,Tp},AddLine{4,n,Tp}]);
        if size(AddLine,1)>4
            for m3=1:size(AddLine{5,n,Tp},1)
                set(LineID,AddLine{5,n,Tp}{1,1},AddLine{5,n,Tp}{1,2},'LineWidth',AxisWidth);
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
            export_fig(Fid,Path2file{Tp,1});
        elseif strfind1({'.eps';'.epsc';'.bmp';'.pdf';'.emf';'.tif'},Type)
            saveas(Fid,Path2file{Tp,1});
        elseif strfind1({'.avi'},Type)
            %             Wave1=[Path2file{1}(1:end-3),'_',num2str(m),'.tif'];
            %             saveas(Fid,Wave1);
            Wave1=[Path2file{1}(1:end-3),'_',num2str(Tp),'.png'];
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
%     keyboard;
    OutputPath=strrep(Path2file{1},Type,'.xlsx');
    
    Y.Data(end+1,:)=X.';Y=[Y(end,:);Y(1:end-1,:)];
    xlsActxWrite(Y,OutputPath,1,[],'Delete',1);
    
%     Wave1=Y;
%     xlswrite(OutputPath,Y);
    
    
%     [Excel,Workbook,Sheets,SheetNumber]=connect2Excel(OutputPath);
    
%     for Tp=max(Y.Timepoint):-1:1
%         Wave1=[X,Y.Data(Y.Timepoint==Tp,:).'];
        
%         Wave1=[X,Y(:,:,Tp)];
%         xlsActxWrite(Wave1,Workbook,num2str(Tp),'Delete',1);
%         Workbook.Save;
%         Workbook.Close;
%     end
end

mouseMoveController(0);


