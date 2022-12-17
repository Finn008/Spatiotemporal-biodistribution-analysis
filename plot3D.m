function plot3D(Path2Folder,ExcelFilenameTotal,ExcelSheet,ExcelSheet2)
Path2Folder='\\fs-mu.dzne.de\ag-herms\Finn Peters\data\X0103 presentations\X0233 TauKO\MethoxyX04\2018.03.27_2\';
ExcelFilenameTotal='3D_TauKO_MethoxyX04.xlsx';
Path2Excel=[Path2Folder,ExcelFilenameTotal];
if exist('Path2Excel','Var')==0
    keyboard;
end
if exist('ExcelSheet','Var')==0
    ExcelSheet='Data';
end
if exist('ExcelSheet2','Var')==0
    ExcelSheet2='General';
end
if exist('ExcelSheet3','Var')==0
    ExcelSheet3='Groups';
end
[Excel,Workbook,Sheets,SheetNumber]=connect2Excel(Path2Excel);

[Table,TableColor]=xlsActxGet(Workbook,ExcelSheet,0,0,Excel,1);
Table2=xlsActxGet(Workbook,ExcelSheet2,1);
Groups=xlsActxGet(Workbook,ExcelSheet3,1);

% calculate mean values

GroupNames=Table(strfind1(Table(:,1),'Groups'),2:end).';
Yaxis=cell2mat(Table(strfind1(Table(:,1),'Yaxis')+1:end,1));
Xvalues=cell2mat(Table(strfind1(Table(:,1),'Xaxis'),2:end)).';
Xaxis=unique(Xvalues);
MouseInfo=table;
[MouseInfo.MouseId,Wave1]=unique(cell2mat(Table(strfind1(Table(:,1),'MouseId'),2:end).'));
MouseInfo.Group=GroupNames(Wave1,1);
DataArray=cell2mat(Table(strfind1(Table(:,1),'Yaxis')+1:end,2:end));

% exclude red cells
TableColor=TableColor(strfind1(Table(:,1),'Yaxis')+1:end,2:end,:);
Exclude=zeros(size(TableColor,1),size(TableColor,2),'uint8');
Exclude(TableColor(:,:,1)==255&TableColor(:,:,2)==0&TableColor(:,:,3)==0)=1;
DataArray(Exclude==1)=NaN;

%normalize
Xlim=[min(Xaxis(:));max(Xaxis(:))];
Ylim=[min(Yaxis(:));max(Yaxis(:))];
Zlim=[min(DataArray(:));max(DataArray(:))];
try; Xlim=Table2{strfind1(Table2.Tag1,'Xlim'),{'Value1','Value2'}}.'; end;
try; Ylim=Table2{strfind1(Table2.Tag1,'Ylim'),{'Value1','Value2'}}.'; end;
try; Zlim=Table2{strfind1(Table2.Tag1,'Zlim'),{'Value1','Value2'}}.'; end;
try
    Rotation=Table2{strfind1(Table2.Tag1,'Rotation'),{'Value1','Value2'}}.';
catch
    Rotation=[147,22];
end

% % % Table2.Group=replaceMixedCell(Table2.Group,'nan',{['']});
% Groups=Groups(ismember(Groups.Name,unique(Table2.Group)),:);
% Groups=table;
% Groups.Name=unique(GroupNames);
% Groups.Name=Table2.Group();
% Groups=Groups(ismember(Groups.Name,unique(Table2.Group)),:);

% Interpolate=strfind1(Table2.Tag1,'Interpolate')~=0;
% Groups.Color=[Groups.R,Groups.G,Groups.B];

if strfind1(Groups.Properties.VariableNames,'Marker')==0
    Groups.Marker(:,1)={'none'};
end
if strfind1(Groups.Properties.VariableNames,'LineStyle')==0
    Groups.LineStyle(:,1)={'-'};
end


    
% % % Wave1={'r';'w';'m';'c';'g';'y';'b'};
% % % Groups.Color=Wave1(1:size(Groups,1));

for Group=1:size(Groups,1)
    Mice=strfind1(MouseInfo.Group,Groups.Name{Group});
    Groups.MouseIds(Group,1)={MouseInfo.MouseId(Mice)};
    Groups.Xarray(Group,1)={Xaxis};
    Groups.Yarray(Group,1)={Yaxis};
    
    Groups.Color(Group,1)={[Groups.R(Group);Groups.G(Group);Groups.B(Group)]};
    try
        Wave1=Table2{strcmp(Table2.Tag1,'Color')&strcmp(Table2.Group,Groups.Name{Group}),{'R','G','B'}}.'; 
        Groups.Color(Group,1)={Wave1};
    end
    % calculate mean and SEM
    clear ZArray;
%     clear SemArray;
%     clear FitArray;
    for X=1:size(Xaxis,1)
        Data=DataArray(:,find(strcmp(GroupNames,Groups.Name{Group})&Xvalues==Xaxis(X)));
        N=size(Data,2)-sum(isnan(Data),2);
        if strcmp(Groups.DataCalc{Group},'Mean')
            ZArray(:,X)=nanmean(Data,2);
        elseif strfind1(Groups.DataCalc{Group},'SEM')
%             ZArray(:,X)=nansem_1(Data);
            if strfind1(Groups.DataCalc{Group},'+')
                ZArray(:,X)=nanmean(Data,2)+nansem_1(Data);
            elseif strfind1(Groups.DataCalc{Group},'-')
                ZArray(:,X)=nanmean(Data,2)-nansem_1(Data);
            end
        elseif strcmp(Groups.DataCalc{Group},'Interpolate')
            Wave1=repmat(Yaxis,[size(Data,2),1]);
            Wave1(:,2)=Data(:);
            Wave1(isnan(Wave1(:,2)),:)=[];
            Fit=fit(Wave1(:,1),Wave1(:,2),'smoothingspline');
            Wave1=Fit(Yaxis); Wave1(N<2)=NaN;
            ZArray(:,X)=Wave1;
        end
    end
    Wave1=ZArray(Yaxis>=Ylim(1)&Yaxis<Ylim(2),Xaxis>=Xlim(1)&Xaxis<=Xlim(2),:);
    Groups.MinMax(Group,1:2)=[min(Wave1(:)),max(Wave1(:))];
    Groups.Zarray(Group,1)={ZArray};
    Groups.SeparateX(Group,1)=1;
    Groups.MarkerFaceColor(Group,1)=Groups.Color(Group,1);
    Groups.FaceColor(Group,1)=Groups.Color(Group,1);
    Groups.EdgeColor(Group,1)=Groups.Color(Group,1);
end
Groups(:,{'R','G','B'}) = [];
%normalize
for Group=1:size(Groups,1)
    Groups.Zarray(Group,1)={Groups.Zarray{Group,1}/max(Groups.MinMax(:,2))*100};
end



% % % % Wave1=DataArray(Yaxis>=Ylim(1)&Yaxis<Ylim(2),Xvalues>=Xlim(1)&Xvalues<=Xlim(2));
% % % % Wave1=max(Wave1(:));
% % % % % Wave1=DataArray(Xvalues>=Xlim(1)&Xvalues<=Xlim(2),Yaxis>=Ylim(1)&Yaxis<Ylim(2));
% % % % DataArray=DataArray/Wave1*100;

General=struct;
% % % General.Title=Title;
General.Xlim=Xlim;
General.Ylim=Ylim;
General.Zlim=Zlim;
General.XTick=Xaxis;
General.YTick=Yaxis;
General.ZTick=(1:1:100).';

try; Wave1=Table2{strfind1(Table2.Tag1,'Xtick'),{'Value1','Value2','Value3'}}.'; General.XTick=(Wave1(1):Wave1(2):Wave1(3)).'; end;
try; Wave1=Table2{strfind1(Table2.Tag1,'Ytick'),{'Value1','Value2','Value3'}}.'; General.YTick=(Wave1(1):Wave1(2):Wave1(3)).'; end;
try; Wave1=Table2{strfind1(Table2.Tag1,'Ztick'),{'Value1','Value2','Value3'}}.'; General.ZTick=(Wave1(1):Wave1(2):Wave1(3)).'; end;

General.Rotation=Rotation.'; % [147,22]
General.Xlabel='Plaque radius [µm]';
General.Ylabel='Distance to plaque border [µm]';
General.Zlabel='Intensity [%]';
General.FyleType='.emf';
try
    General.ImageDimensions=Table2{strfind1(Table2.Tag1,'ImageDimensions'),{'Value1','Value2'}}.';
catch
    General.ImageDimensions=[90;55];
end
Path2file=[Path2Folder,regexprep(ExcelFilenameTotal,'.xlsx','')];

plotSurf(Groups,General,Path2file);
