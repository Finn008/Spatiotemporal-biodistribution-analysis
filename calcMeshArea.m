function [Area]=calcMeshArea(Data,Res)

Pix=size(Data).';

Table=table;
% cprintf('text','calcMeshArea: '); tic;
for Y=1:Pix(2)-1
%     cprintf('text',['_Y',num2str(Y),'Time',num2str(round(toc))]); %'X',num2str(X),
    for X=1:Pix(1)-1
        Ind=size(Table,1)+1;
        clear Vectors;
        Vectors(1,:)=[X,Y,Data(X,Y)];
        Vectors(2,:)=[X+1,Y,Data(X+1,Y)];
        Vectors(3,:)=[X,Y+1,Data(X,Y+1)];
        Vectors(4,:)=[X+1,Y+1,Data(X+1,Y+1)];
        
        if find(isnan(Vectors))
            Table.Area(Ind,1)=0;
            continue;
        end
        Vectors=Vectors.*repmat(Res.',[4,1]);
        A=Vectors(2,:)-Vectors(1,:);
        B=Vectors(3,:)-Vectors(1,:);
        C=Vectors(4,:)-Vectors(1,:);
        Table.Area(Ind,1)=1/2*(norm(cross(A,C)) + norm(cross(B,C)));
    end
end

Area=sum(Table.Area(:));
% cprintf('text','\n');