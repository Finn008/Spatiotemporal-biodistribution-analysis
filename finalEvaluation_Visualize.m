function finalEvaluation_Visualize(MouseInfo,TimeDistTable)
global W;
SavePath=[W.G.PathOut,'\Unsorted\'];
Experiment=W.G.T.TaskName{W.Task};


for Mouse=12 % 1:size(MouseInfo,1)
    MouseId=MouseInfo.MouseId(Mouse);
    for Roi=1:size(MouseInfo.RoiInfo{Mouse})
        RoiId=MouseInfo.RoiInfo{Mouse}.Roi(Roi);
        PlaqueNumber=10;
        for Pl=1:PlaqueNumber
            Sub=2; % PoolSubRegions={[1;2],[2],[3],[4],[1;2;3;4],[5]};
            Parameters={'Autofluo1','r.','Smooth5VolWeight',0.05;...
                'Boutons1Number','g.','Smooth5VolWeight',0.05;...
                'Dystrophies1','w-','Smooth5VolWeight',2;...
                'MetBlue','b-','NormTp',1;...
                'VglutGreen','g-','NormTp',1;...
                };
            Parameters=cell2table(Parameters,'VariableNames',{'Name','ColorSpec','Calc','Unity'});
            
            plaqueDistRelation(MouseId,RoiId,Pl,Parameters,Sub,TimeDistTable); % Each plaque with all Parameters
            keyboard;
        end
    end
end

%% visualize Plaque Growth
for Mouse=1:size(MouseInfo,1)
    MouseInd=MouseInfo.MouseId(Mouse);
    for Roi=1:size(MouseInfo.RoiInfo{Mouse})
        try
            FitLines=MouseInfo.RoiInfo{Mouse}.TraceData{Roi}.FitLines;
        catch
            continue;
        end
        % visualize PlaqueGrowth
        CoreName=[Experiment,'_M',num2str(MouseInd),'_PlaqueGrowthAsFitLines'];
        J=struct('Tit',CoreName);
        Xaxis=zeros(2,0);
        Yaxis=zeros(2,0);
        for m=1:size(FitLines,1)
            for m2=1:size(FitLines,2)
                Wave2=FitLines{m,m2};
                if isempty(Wave2)==0
                    Xaxis(1:2,size(Xaxis,2)+1)=Wave2.Age;
                    Yaxis(1:2,size(Yaxis,2)+1)=Wave2.Radius;
                end
            end
        end
        Wave3=find(Xaxis(1,:)~=0);
        Xaxis=Xaxis(:,Wave3);
        Yaxis=Yaxis(:,Wave3);
        Xaxis=(Xaxis-MouseInfo.StartTreatmentNum(Mouse)(1))/7;
        J.X=Xaxis;
        J.Y=Yaxis;
        J.Xlab='Treatment onset [weeks]';
        J.Ylab='Radius [µm]';
        J.Style=1;
        J.Path2file=[SavePath,'\',CoreName,'.jpg'];
        J.Sp='w-';
        movieBuilder_4(J);
    end
end

%%


Timepoints=size(PlaqueData.Vector{1}{1}{1,1}{1},2);
PlaqueNumber=size(PlaqueData,1);
%% all Boutondensity in one
MaxDistance=100;
MaxDistance=MaxDistance+51;
for Pl=1:PlaqueNumber
    Bouton1Number(:,:,Pl)=PlaqueData.Vector{Pl,1}{2,Sub}{'Smooth','Boutons1Number'}{1}.Smooth5VolWeight{'Density'}{1:MaxDistance,1:Timepoints};
    Volume(:,:,Pl)=PlaqueData.Vector{Pl,1}{2,Sub}{'Density','Volume'}{1}{1:MaxDistance,1:Timepoints};
    %     Volume(:,:,Pl)=PlaqueData.Vector{Pl,1}{2,Sub}.Volume{1}{1:MaxDistance,1:Timepoints};
end
% Bouton1Number=Bouton1Number/0.05; % Bouton1Number: 0.05
Bouton1Number=Bouton1Number/max(Bouton1Number(:))*max(Volume(:));
Bouton1NumberThresh=Bouton1Number;
Bouton1NumberThresh(Volume<400)=NaN;
Bouton1NumberThresh(1:80,:,:)=Bouton1Number(1:80,:,:);

J=struct;
J.Tit=strcat({'Timepoint: '},num2strArray((1:Timepoints).'));
J.X=(-50:MaxDistance-51).';
J.OrigYaxis=[...
    {Bouton1Number(:,:,1)},{'c.'};...
    {Bouton1Number(:,:,2)},{'r.'};...
    {Bouton1Number(:,:,3)},{'w.'};...
    {Bouton1NumberThresh(:,:,1)},{'c-'};...
    {Bouton1NumberThresh(:,:,2)},{'r-'};...
    {Bouton1NumberThresh(:,:,3)},{'w-'};...
    {Volume(:,:,1)},{'co'};...
    {Volume(:,:,2)},{'ro'};...
    {Volume(:,:,3)},{'wo'};...
    ];
J.OrigType=3;
J.Style=1;
J.Xlab='Distance [µm]';
J.Ylab='Bouton density [/µm^3]';
J.Xrange=[-10;100];
J.Yrange=[0;max(Volume(:))];
J.Frequency=4;
J.Path={[SavePath,NameTable{'Trace','Filename'}{1},',Boutons.avi']};
%     J.Path=strcat({[SavePath,NameTable{'Trace','Filename'}{1},',Pl',num2str(Pl),',Tp']},num2strArray((1:Timepoints).'),{'.jpg'});
%     J.GenerateExcelFile=1;
movieBuilder_4(J);
keyboard;

function plaqueDistRelation(MouseId,RoiId,Pl,Parameters,Sub,TimeDistTable) % Each plaque with all Parameters
Timepoints=9;
J=struct;
J.Tit=strcat({'Timepoint: '},num2strArray((1:Timepoints).'));

for m=1:size(Parameters,1)
    Ind=find(TimeDistTable.Mouse==MouseId & TimeDistTable.Roi==RoiId & TimeDistTable.SubPool==Sub & TimeDistTable.Pl==Pl & strcmp(TimeDistTable.Mod,Parameters.Name{m}));
    Parameters.Data(m,1)={TimeDistTable.Data{Ind}(:,1:Timepoints)};
end

% MaxDistance=100;
% J.X=(-50:MaxDistance).';
% MaxDistance=MaxDistance+51;
Bouton1Number=PlaqueData.Vector{Pl}{2,Sub}{'Smooth','Boutons1Number'}{1}.Smooth5VolWeight{'Density'}{1:MaxDistance,1:Timepoints};
Plaque=PlaqueData.Vector{Pl}{1,Sub}{'NormTp','Plaque'}{1}{1:MaxDistance,1:Timepoints};
AutofluoSurface=PlaqueData.Vector{Pl}{1,Sub}{'Smooth','AutofluoSurface'}{1}.Smooth5VolWeight{'Density'}{1:MaxDistance,1:Timepoints};
Dystrophies=PlaqueData.Vector{Pl}{2,Sub}{'Smooth','Dystrophies2Surf'}{1}.Smooth5VolWeight{'Density'}{1:MaxDistance,1:Timepoints};

Plaque=Plaque./repmat(max(Plaque,[],1),[size(Plaque,1),1]); % Plaque: 100%
Bouton1Number=Bouton1Number/0.05; % Bouton1Number: 0.05
AutofluoSurface=AutofluoSurface/0.05; % AutofluoSurface: 0.1332
Dystrophies=Dystrophies./repmat(max(Dystrophies,[],1),[size(Dystrophies,1),1]);
Dystrophies=Dystrophies/2;
Wave1=isnan(Dystrophies);Wave1(1:50,:)=0;
Dystrophies(Wave1==1)=0;

[First,Last]=firstLastNonzero_3(Plaque);
First=First-51;
Wave1=zeros(1,size(First,2));
Wave2=ones(1,size(First,2));
J.AddLine=[First;Wave1;First;Wave2];
J.AddLine=num2cell(J.AddLine);
Wave1=repmat({{'Color','c'}},[1,size(First,2)]);
J.AddLine=[J.AddLine;Wave1];
J.AddLine=permute(J.AddLine,[1,3,2]);

J.OrigYaxis=[...
    {Plaque},{'c-'};...
    {Bouton1Number},   {'g-'};...
    {Dystrophies},{'w-'};...
    {AutofluoSurface},{'r-'};...
    ];
J.OrigType=3;
J.FontSize=30;
J.AxisWidth=2;
J.MarkerSize=2;
J.LineWidth=2;
J.Xlab='Distance [µm]';
J.Ylab='Bouton density [/µm^3]';
%             J.Ylab='Bouton density [/µm^3]';
J.Xrange=[-10;100];
J.Yrange=[0;1.0];
J.Layout='black';
J.Frequency=4;
J.Path={[SavePath,NameTable{'Trace','Filename'}{1},',Plaque',num2str(Pl),'.avi']};
%     J.Path=strcat({[SavePath,NameTable{'Trace','Filename'}{1},',Pl',num2str(Pl),',Tp']},num2strArray((1:Timepoints).'),{'.jpg'});
%     J.GenerateExcelFile=1;
movieBuilder_4(J);
