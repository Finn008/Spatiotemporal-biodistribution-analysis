function finalEvaluation_VolumeDistribution_Plot(Xaxis,Yaxis,Zarray,Color,Path2file)

if iscell(Zarray)==0
    Zarray={Zarray};
end
Xarray=repmat(Xaxis.',[size(Yaxis,1),1]);
Yarray=repmat(Yaxis,[1,size(Xaxis,1)]);

Figure=figure;
hold on;
for Zar=1:size(Zarray,1)
    Wave1=repmat(permute(Color{Zar,1},[3,2,1]),[size(Yaxis,1),size(Xaxis,1),1]);
%     Wave1=repmat(Color{Zar,1},[size(X,1),size(Y,1)]);
    surf(Xarray,Yarray,Zarray{Zar,1},Wave1);
%     surf(Xarray,Yarray,Zarray{Zar,1});
end
saveas(Figure,[Path2file,'.fig']);
close Figure 1;


% Zarray2=[Zarray(100:200,:);Zarray(1:99,:)];
% surf(Xarray,Yarray,Zarray2);