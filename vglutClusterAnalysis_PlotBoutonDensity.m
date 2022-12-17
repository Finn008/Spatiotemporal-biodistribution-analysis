function vglutClusterAnalysis_PlotBoutonDensity(Title,Table,MouseInfo,MouseIds,RadiiBinning,RadiusMinMax,DistanceBinning,DistanceMinMax,TimeBinning,TimeMinMax,Path2file)

Table=Table(Table.Time2Treatment_Min==TimeMinMax(1)...
    & Table.Time2Treatment_Max==TimeMinMax(2)...
    & Table.Time2Treatment_Bin==TimeBinning...
    & Table.Distance_Min>=DistanceMinMax(1)...
    & Table.Distance_Max<=DistanceMinMax(2)...
    & Table.PlaqueRadius_Bin==RadiiBinning...
    ,:);

Distances=(DistanceMinMax(1):1:DistanceMinMax(2)).';
PlaqueRadii=(RadiusMinMax(1):RadiiBinning:RadiusMinMax(2)-RadiiBinning).'; PlaqueRadii(:,2)=PlaqueRadii+RadiiBinning;
BoutonDensity=nan(size(Distances,1),size(PlaqueRadii,1),size(MouseIds,1));
BoutonDensityFit=BoutonDensity;

ExcelTable=table;
ExcelTable('MouseId',{'Specification';'PlRad';'Data'})={{'MouseId'},NaN,MouseInfo.MouseId.'};

Ft= fittype('Y0+Span*(1-exp(-K*x))',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'Y0','Span','K'});
Opts=fitoptions('Method','NonlinearLeastSquares');
Opts.Robust='Bisquare';
Opts.MaxIter=1000;


Opts.Lower=[-Inf,70,0];
Opts.Upper=[120,Inf,1];
Opts.Startpoint=[0,0,0.4];
for Tr=1:size(MouseIds,1)
    for PlRad=1:size(PlaqueRadii,1)
        Selection=Table(Table.PlaqueRadius_Min==PlaqueRadii(PlRad,1)...
            & Table.PlaqueRadius_Max==PlaqueRadii(PlRad,2)...
            ,:);
        
        [~,Mice]=ismember(MouseIds{Tr},MouseInfo.MouseId);
        
        Data2add=Selection.BoutonDensity(:,Mice);
        MeanData=nanmean(Data2add,2);
        MeanData(MeanData==0)=NaN;
        BoutonDensity(Selection.Distance_Min-DistanceMinMax(1)+1,PlRad,Tr)=MeanData;
        
        X=(1:(DistanceMinMax(2)-DistanceMinMax(1)+1)).'; % 21 beeing DistanceBin 1 µm (DistanceMinMax(1))
        FitData=nan(size(Data2add));
        for Mouse=0:size(Mice,1)
            Y=nan(size(X));
            if Mouse==0
                Y(Selection.Distance_Min-DistanceMinMax(1),1)=MeanData;
            else
                Y(Selection.Distance_Min-DistanceMinMax(1),1)=Data2add(:,Mouse);
            end
            InitialNans=isnan(Y);
            if sum(InitialNans(1-DistanceMinMax(1):10-DistanceMinMax(1)))>2 % 9 bins must be present between 1 to 10 µm
%                 continue;
                K=NaN;
                Yfit=ones(size(InitialNans));
            else
                
                Y(Y>130)=NaN;
                Wave1=find(InitialNans(1:-DistanceMinMax(1))==0,1);
                if isempty(Wave1)==0
                    Y(Wave1)=NaN;
                end
                Opts.Exclude=isnan(Y);
                FitExp1=fit(X,Y,Ft,Opts);
                Yfit=feval(FitExp1,X);
                Yfit(InitialNans)=NaN;
                K=FitExp1.K;
            end
            if Mouse>=1
                MouseInd=find(MouseInfo.MouseId==MouseIds{Tr}(Mouse));
                RowId=struct('Specification',{{'MonophasicK'}},'PlRad',mean(PlaqueRadii(PlRad,:)));
                ExcelTable=addData2OutputTable_2(ExcelTable,K,RowId,MouseInd);
                
                Wave1=Yfit/nanmean(Yfit(20-DistanceMinMax(1):end));
                Wave2=find(Wave1>0.95,1)+DistanceMinMax(1);
                RowId=struct('Specification',{{'Above95th'}},'PlRad',mean(PlaqueRadii(PlRad,:)));
                ExcelTable=addData2OutputTable_2(ExcelTable,Wave2,RowId,MouseInd);

                Wave2=find(Wave1>0.90,1)+DistanceMinMax(1);
                RowId=struct('Specification',{{'Above90th'}},'PlRad',mean(PlaqueRadii(PlRad,:)));
                ExcelTable=addData2OutputTable_2(ExcelTable,Wave2,RowId,MouseInd);
                
                Wave2=find(Wave1>0.50,1)+DistanceMinMax(1);
                RowId=struct('Specification',{{'Above50th'}},'PlRad',mean(PlaqueRadii(PlRad,:)));
                ExcelTable=addData2OutputTable_2(ExcelTable,Wave2,RowId,MouseInd);
            end
            
            if Mouse<0
                figure;
                hold on;
                plot(X,Y,'ok');
                plot(X,Yfit,'-r');
                
                set(gca,'xlim',[10;70]);
                set(gca,'XTick',(10:10:70));
                set(gca,'ylim',[0;150]);
                set(gca,'YTick',(0:10:150));
                
                Path=[W.G.PathOut,'\Boutons2'];
                if exist(Path)~=7
                    mkdir(Path);
                end
                if Mouse==0
                    BoutonDensityFit(:,PlRad,Tr)=Yfit;
                    Filename=['Rad',num2str(PlaqueRadii(PlRad,2)),'_Tr',num2str(Tr)];
                else
                    Filename=['Rad',num2str(PlaqueRadii(PlRad,2)),'_M',num2str(MouseIds{Tr}(Mouse))];
                end
                saveas(gcf,[Path,'\',Filename,'.png'])
                close Figure 1;
            end
        end
    end
end
OrigExcelTable=ExcelTable;
ExcelTable.Data(ExcelTable.Data==-19)=NaN;
[TableExport]=table2cell_2(ExcelTable);
TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
PathExcelExport=['\\GNP90N\share\Finn\Raw data\VGLUT1.xlsx'];
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
xlsActxWrite(TableExport,Workbook,'BoutonLossSlopes',[],'Delete');
Workbook.Save;
Workbook.Close;
close all;


PlotVersion=2;
if PlotVersion==2
    Figure=figure;
    set(Figure,'Units','centimeters','Position',[0,0,8,5.5]);
    hold on
    
    [X,Y,Z]=surfPlotSeparateLines_2(Distances,mean(PlaqueRadii,2),BoutonDensity,'Vertical');
    surf(X,Y,Z(:,:,1),'Marker','.','MarkerSize',6,'EdgeColor',[160,160,160]/255,'LineStyle','none');
    surf(X-0.1,Y,Z(:,:,2),'Marker','.','MarkerSize',6,'EdgeColor',[255,160,160]/255,'LineStyle','none');
    
    [X,Y,Z]=surfPlotSeparateLines_2(Distances,mean(PlaqueRadii,2),BoutonDensityFit,'Vertical');
    surf(X-0.2,Y,Z(:,:,1),'LineWidth',1,'EdgeColor','black');
    surf(X-0.3,Y,Z(:,:,2),'LineWidth',1,'EdgeColor','red');
    
%     uistack(Plot3,'top');
    
    grid on;
%     box on;
    set(gca,'xlim',[0;20]);
    set(gca,'XTick',(0:4:20));
    set(gca,'ylim',[-10;50]);
    set(gca,'YTick',(-20:10:50));
    set(gca,'zlim',[0;125]);
    set(gca,'ZTick',(0:50:150));
    set(gca,'FontSize',9);
    set(gca,'LineWidth',0.5);
    view(-37,40); % [A1,A2]=view();
    
    X1=[NaN,0,NaN;NaN,20,NaN];
    Y1=[NaN,50,NaN;NaN,50,NaN];
    Z1=[NaN,125,NaN;NaN,125,NaN];
    surf(X1,Y1,Z1,'LineWidth',0.5,'EdgeColor','black');
    
    X1=[NaN,20,NaN;NaN,20,NaN];
    Y1=[NaN,50,NaN;NaN,-100,NaN];
    Z1=[NaN,125,NaN;NaN,125,NaN];
    surf(X1,Y1,Z1,'LineWidth',0.5,'EdgeColor','black');
    
    X1=[NaN,20,NaN;NaN,20,NaN];
    Y1=[NaN,-10,NaN;NaN,-10,NaN];
    Z1=[NaN,0,NaN;NaN,125,NaN];
    surf(X1,Y1,Z1,'LineWidth',0.5,'EdgeColor','black');
    
    set(Figure,'PaperPositionMode','auto');
    Path2file=[W.G.PathOut,'\Vglut Clusters\Boutons2\',Title];
    print('-dtiff','-r1000',[Path2file,'.tif']);
    savefig(gcf,[Path2file,'.fig']);
    close Figure 1;
    
    % % % [TableExport]=table2cell_2(ExcelTable);
    % % % TableExport(1,end-size(MouseInfo,1)+1:end)=num2cell(MouseInfo.MouseId);
    % % % PathExcelExport=['\\GNP90N\share\Finn\Raw data\VGLUT1.xlsx'];
    % % % [Excel,Workbook,Sheets,SheetNumber]=connect2Excel(PathExcelExport);
    % % % xlsActxWrite(TableExport,Workbook,'ClDistrDist2Pl',[],'Delete');
end

Ax = gca;
Ax.XColor = 'red';