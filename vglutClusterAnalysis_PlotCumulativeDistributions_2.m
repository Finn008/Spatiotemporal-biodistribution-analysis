function vglutClusterAnalysis_PlotCumulativeDistributions_2(Framework,Settings,Readout,Groups)
global W;
% Framework=Framework;
[FrameworkUniqueFilenames,A2,Framework.FilenameId]=unique(Framework.Filename);

ReplicateType='Mice'; %'EachPlaque'; % 'Mice';
if strcmp(ReplicateType,'Mice')
    BinInfo={'MouseId',0,0,0; % no binning
%         'Age',-2,0,[0;999]; %     'Time2Treatment',[28],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; %  % 'Time2Treatment',-2,0,[-28;70];
        'PlaqueRadius',Settings.Plot_PlaqueRadiusBin,[0;999],0 %
        'ClusterSize',-2,0,Settings.Plot_ClusterSizeEdges; % [0;5;10;15;20;999]
        'Distance',[1],Settings.Plot_DistanceMinMax,0; % 1µm steps
        };
elseif strcmp(ReplicateType,'EachPlaque')
    BinInfo={'MouseId',0,0,0; % no binning
%         'Age',-2,0,[0;999]; %     'Time2Treatment',[28],[-28;70],0; % 'Time2Treatment',-2,0,[42;70]; %  % 'Time2Treatment',-2,0,[-28;70];
        'FilenameId',0,0,0 %
        'Membership',0,0,0 %
        'ClusterSize',-2,0,Settings.Plot_ClusterSizeEdges; % [0;5;10;15;20;999]
        'Distance',[1],Settings.Plot_DistanceMinMax,0; % 1µm steps
        };
end
BinInfo=array2table(BinInfo,'VariableNames',{'Name';'Binning';'MinMax';'Edges'});
BinInfo.Properties.RowNames=BinInfo.Name;

Distances=BinInfo{'Distance','MinMax'}{1}; Distances=(Distances(1):Distances(2)).';
ClusterSizes=BinInfo{'ClusterSize','Edges'}{1};

[Table]=accumArrayBinning(Framework,BinInfo,'Fraction',[],@nanmean);
% % % [Table]=accumArrayBinning(Framework,BinInfo,'Fraction',[],@nanmedian);
% Table(:,strfind1(Table.Properties.VariableNames.',{'_Bin';'_Max'})) = [];
Table(:,strfind1(Table.Properties.VariableNames.',{'_Max';'ClusterSize_Bin';'Distance_Bin'})) = [];

Table=distributeColumnHorizontally_4(Table,[],'Distance_Min','Fraction',Distances);

Table2=Table;
Table2(:,{'ClusterSize_Min';'Fraction'}) = [];
[Table2,~,Table2Ind]=unique(Table2);
for Row=1:size(Table2,1)
    FractionDistribution=nan(size(ClusterSizes,1),size(Distances,1));
    Wave2=ismember2(Table.ClusterSize_Min(Table2Ind==Row,:),ClusterSizes);
    FractionDistribution(Wave2,:)=Table.Fraction(Table2Ind==Row,:);
    Table2.Distribution(Row,1)={FractionDistribution};
end
Path2file=[W.PathExp,'\Output\ClusterDistribution\',Readout,'\'];
if strcmp(ReplicateType,'Mice')
    Path2file=[Path2file,'Mice\'];
    % Mouse groups
    Wave1=Table2;
    Wave1(:,{'MouseId';'Distribution'})=[];
    [Wave1,~,Wave2]=unique(Wave1);
    Table3=table;
    for Group=1:size(Groups,1)
        for Bin=1:size(Wave1)
            Wave3=Table2(Wave2==Bin&ismember(Table2.MouseId(1:size(Wave2,1)),Groups.MouseIds{Group}),:);
            if size(Wave3,1)==0; continue; end;
            clear Wave4;
            for n=1:size(Wave3,1)
                Wave4(:,:,n)=Wave3.Distribution{n,1};
            end
            Wave4=nanmean(Wave4,3);
            Table3(end+1,Wave1.Properties.VariableNames)=Wave1(Bin,:);
            Table3.Distribution(size(Table3,1))={Wave4};
            Table3.MouseIds(size(Table3,1))=Groups.MouseIds(Group,1);
            Wave5=[];
            for n=1:size(Wave1.Properties.VariableNames,2)
%                 Wave5=[Wave5,n{1},num2str(Wave1{Bin,n})];
                if n>1;Wave5=[Wave5,'_']; end;
                Wave5=[Wave5,regexprep(Wave1.Properties.VariableNames{n},'_',''),num2str(Wave1{Bin,n})];
            end
            Wave6=Groups.MouseIds{Group,1}; Wave6=sprintf([repmat('%d,',1, numel(Wave6)-1), '%d'],Wave6);
            Table3.Description(size(Table3,1),1)={[Groups.Description{Group,1},Wave6,'_',Wave5]};
%             Table3.Description(size(Table3,1),1)={[Groups.Description{Group,1},regexprep(num2str(Groups.MouseIds{Group,1}.'),'  ',','),'_',Wave5]};
        end
    end
elseif strcmp(ReplicateType,'EachPlaque')
    Path2file=[Path2file,'EachPlaque3\'];
    Table3=Table2;
    Table3.Filename=FrameworkUniqueFilenames(Table3.FilenameId);
    Table3(:,'FilenameId')=[];
    for Row=1:size(Table3,1)
        Wave5=[];
        for n=Table3.Properties.VariableNames
            if strfind1(n,{'Distribution';'Description'});continue; end;
            Wave1=Table3{Row,n};
            if isnumeric(Wave1)
                Wave5=[Wave5,n{1},num2str(Wave1)];
            else
                Wave5=[Wave5,n{1},Wave1{1}];
            end
        end
        
        Table3.Description(Row)={Wave5};
    end
    Table3=fuseTable_MatchingColums_4(Table3,PlaqueListSingle,{'MouseId';'Filename';'Membership'},{'PlaqueRadius'});
    Table3.PlaqueRadius=floor(Table3.PlaqueRadius/2)*2;
end

for Row=1:size(Table3,1)
    if strcmp(ReplicateType,'EachPlaque')
        Wave1=[Path2file,'PlaqueRadius',num2str(Table3.PlaqueRadius(Row)),'\'];
    else
        Wave1=Path2file;
    end
    mkdir(Wave1);
    plotClusterSizeDistribution(Table3.Distribution{Row},[Wave1,Table3.Description{Row}],Settings.Plot_DistanceMinMax,[0;6.1],1,Settings.Plot_PercentMax);
end