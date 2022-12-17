function [Ind,Driftinfo,NumInd]=searchDriftCombi(FFilename,RFilename)
global W;

try % if RFilename is empty
    [~,FNameTable,~]=fileSiblings(FFilename);
    [~,RNameTable,~]=fileSiblings(RFilename);
catch
    Ind=[];
    Driftinfo=[];
    NumInd=0;
    return;
end
RowNames=W.G.Driftinfo.Properties.RowNames;

[~,Wave1]=strfind1([W.G.Driftinfo.Ffilename,W.G.Driftinfo.Rfilename],{FNameTable.Filename{'Original'};RNameTable.Filename{'Original'}},1);
Ind{1}=find(Wave1(:,1)==1&Wave1(:,2)==2);
Ind{2,1}=find(Wave1(:,1)==2&Wave1(:,2)==1);
NumInd=[0;0];
for m=1:2
    if isempty(Ind{m,1})
        Ind{m,1}=uniqueInd(W.G.Driftinfo,[1;8]);
        Driftinfo(m,:)=emptyRow(W.G.Driftinfo(1,:));
    else
        NumInd(m,1)=Ind{m,1};
        Ind{m,1}=RowNames{Ind{m,1}};
        Driftinfo(m,:)=W.G.Driftinfo(NumInd(m,1),:);
    end
end
