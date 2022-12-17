function [SingleStacks,MouseInfo]=finalEvaluation_Boutons1Global(SingleStacks,MouseInfo)


% SingleStacks=SingleStacks(strfind1(SingleStacks.Filename,'Sophie'),:);

SingleStacks(:,{'TargetTimepoint','Date','PlaqueIDs'})=[];
AgeGroups=[2,3;4.5,8;12,13];
Xaxis=(0:0.01:5).';
% Yaxis=zeros(size(Xaxis,1),1);
for File=1:size(SingleStacks,1)
    try
        Boutons1Number=SingleStacks.DistRelation{File}.Data{1,2}.Boutons1Number;
    catch
        continue;
    end
    PixVol=SingleStacks.DistRelation{File}.Data{1,2}.Volume;
    Res3D=SingleStacks.Res3D(File,1);
    SingleStacks.BoutonDensity(File,1)=Boutons1Number/(PixVol*Res3D);
    Mouse=find(MouseInfo.MouseId==SingleStacks.MouseId(File,1));
    Roi=SingleStacks.Roi(File,1);
    Age=MouseInfo.RoiInfo{Mouse}.Files{Roi}.Age/(365/12);
    SingleStacks.Age(File,1)=Age;
    AgeGroup=find(AgeGroups(:,1)<Age&AgeGroups(:,2)>Age);
    SingleStacks.AgeGroup(File,1)=AgeGroup;
    Histogram=SingleStacks.DistRelation{File}.Data{1,2}.Boutons1Histogram{1,1};
    Histogram(:,2)=Histogram(:,2)/sum(Histogram(:,2));
%     Yaxis(:)=0;
    Start=find(Xaxis==Histogram(1,1));
    clear Yaxis;
    Yaxis(Start:Start+size(Histogram,1)-1,1)=Histogram(:,2);
    SingleStacks.Histogram(File,1:size(Yaxis,1))=Yaxis;
end

% pool data per mouse
for Mouse=1:size(MouseInfo,1)
    Selection=find(SingleStacks.Mouse==MouseInfo.MouseId(Mouse));
    if isempty(Selection); continue; end;
    Selection=SingleStacks(Selection,:);
    for AgeGroup=unique(Selection.AgeGroup).'
        Wave1=find(Selection.AgeGroup==AgeGroup);
        MouseInfo.AgeGroup(Mouse)=AgeGroup;
        MouseInfo.BoutonDensity(Mouse)=mean(Selection.BoutonDensity(Wave1,1));
        Histogram=mean(Selection.Histogram(Wave1,:),1);
        MouseInfo.Histogram(Mouse,1:size(Histogram,2))=Histogram;
    end
end

% sort into Age and treatmentgroups
Table=table;
for Treatment={'Synuclein','Wt'}
    for AgeGroup=1:3
        Ind=size(Table,1)+1;
        Table.TreatmentType(Ind,1)=Treatment;
        Table.AgeGroup(Ind,1)=AgeGroup;
        Selection=MouseInfo(strcmp(MouseInfo.TreatmentType,Treatment{1})&MouseInfo.AgeGroup==AgeGroup,:);
        Wave1=nan(1,10);
        Wave1(1,1:size(Selection,1))=Selection.BoutonDensity;
        Table.BoutonDensity(Ind,1:size(Wave1,2))=Wave1;
%         Table.Histogram(Ind,1)={Selection.Histogram};
%         Table.Histogram(Ind,1)={Selection.Histogram};
        MeanHistogram=mean(Selection.Histogram,1);
        StdDevHistogram=std(Selection.Histogram,[],1);
        MeanHistogram=smoothn(MeanHistogram,3);
        Table.MeanHistogram(Ind,1:size(MeanHistogram,2))=MeanHistogram;
        Table.StdDevHistogram(Ind,1:size(StdDevHistogram,2))=StdDevHistogram;
    end
end




