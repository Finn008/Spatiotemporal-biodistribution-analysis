function plotSurf(Arrays,General,Path2file)

ArrayVars=Arrays.Properties.VariableNames.';
if strcmp(ArrayVars,'MarkerEdgeColor')==0; Arrays.MarkerEdgeColor=Arrays.MarkerFaceColor; end;
if strcmp(ArrayVars,'MarkerFaceColor')==0; Arrays.MarkerFaceColor=Arrays.MarkerEdgeColor; end;
if strcmp(ArrayVars,'Marker')==0; Arrays.Marker(:,1)={'none'}; end;
if strcmp(ArrayVars,'LineStyle')==0; Arrays.Marker(:,1)={'-'}; end;
if strcmp(ArrayVars,'FaceColor')==0; Arrays.FaceColor(:,1)={'none'}; end;
if strcmp(ArrayVars,'SeparateX')==0; Arrays.SeparateX(:,1)=0; end;
if strcmp(ArrayVars,'SeparateY')==0; Arrays.SeparateY(:,1)=0; end;
if strcmp(ArrayVars,'LineWidth')==0; Arrays.LineWidth(:,1)=1; end;

GeneralVars=fieldnames(General);
if strcmp(GeneralVars,'Xlim')==0; General.Xlim=[min(General.XTick);max(General.XTick)]; end;
if strcmp(GeneralVars,'Ylim')==0; General.Ylim=[min(General.YTick);max(General.YTick)]; end;
if strcmp(GeneralVars,'Zlim')==0; General.Zlim=[min(General.ZTick);max(General.ZTick)]; end;

for Arr=1:size(Arrays,1)
    Xarray=Arrays.Xarray{Arr,1};
    Yarray=Arrays.Yarray{Arr,1};
    Zarray=Arrays.Zarray{Arr,1};
    
    if isequal(size(Zarray),size(Xarray))==0
        Xarray=repmat(Xarray.',[size(Yarray,1),1]);
        Yarray=repmat(Yarray,[1,size(Xarray,2)]);
    end
    Pix=size(Xarray).';
    Arrays.Xarray(Arr,1)={Xarray};
    Arrays.Yarray(Arr,1)={Yarray};
    if Arrays.SeparateX(Arr,1)==1
        Data2add=table;
        for X=1:size(Xarray,2)
            Data2add(X,:)=Arrays(Arr,:);
            Wave1=nan(Pix.');
            Wave1(:,X)=Zarray(:,X);
            Data2add.Zarray(X,1)={Wave1};
        end
        Arrays=[Arrays;Data2add];
        Arrays.Delete(Arr,1)=1;
    else
        Arrays.Delete(Arr,1)=0;
    end
end

Arrays(Arrays.Delete==1,:)=[];

if isfield(General,'ImageDimensions')==0
    General.ImageDimensions=[90;55];
end
Figure=figure;
% set(Figure,'Units','centimeters','Position', [0.1,0.1,9,6.3]);
set(Figure,'Units','centimeters','Position', [0.1,0.1,General.ImageDimensions.'/10]);
% Create axes
% Axes=axes('Parent',Figure,'ZTick',General.ZTick,'YTick',General.YTick,'XTick',General.XTick,'XDir','reverse');
Axes=axes('Parent',Figure,'ZTick',General.ZTick,'YTick',General.YTick,'XTick',General.XTick,'XDir','reverse','Xlim',General.Xlim,'Ylim',General.Ylim,'Zlim',General.Zlim,'fontsize',10,'fontname','Arial');
hold(Axes,'on');
view(Axes,General.Rotation); % get(Axes, 'View')

% % xlabel(General.Xlabel);
% % ylabel(General.Ylabel);
% % % zlabel(General.Zlabel);

for Arr=1:size(Arrays,1)
    Xarray=Arrays.Xarray{Arr,1};
    Yarray=Arrays.Yarray{Arr,1};
    Zarray=Arrays.Zarray{Arr,1};
    surf(Xarray,Yarray,Zarray,'Parent',Axes,...
        'MarkerFaceColor',Arrays.MarkerFaceColor{Arr,1},...
        'MarkerEdgeColor',Arrays.MarkerEdgeColor{Arr,1},...
        'EdgeColor',Arrays.EdgeColor{Arr,1},...
        'Marker',Arrays.Marker{Arr,1},...
        'LineStyle',Arrays.LineStyle{Arr,1},...
        'LineWidth',Arrays.LineWidth(Arr,1),...
        'FaceColor',Arrays.FaceColor{Arr,1});
end

% image size: 90mm wide and 63mm high


% % % set(get(gca,'ylabel'),'Rotation',PhiTheta(1));
try; Path2file=[Path2file,'_',General.Title]; end;
set(Axes,'ZGrid','on');

% keyboard;
saveas(Figure,[Path2file,'.fig']);
if isfield(General,'FileType')==0
    print('-dtiff','-r1000',[Path2file,'.tif']);
else    
%     General.FyleType='.jpg';
    saveas(Figure,[Path2file,General.FyleType]);
end



% saveas(Figure,[Path2file,'.tif']);
% saveas(Figure,[Path2file,'.emf']);
close Figure 1;
