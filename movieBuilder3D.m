function movieBuilder3D(In)
global W;
if W.SingularImarisInstance==1
    mouseMoveController(1);
end

v2struct(In);
Timepoints=max(XYZT.Time);


WriterObj=VideoWriter(Path2file);
WriterObj.FrameRate=Frequency;
WriterObj.Quality=100;
open(WriterObj);

for Time=1:Timepoints
    
    Graphs=XYZT(find(XYZT.Time==Time),:);
    Fid=figure;
    if exist('MaximizeWindow')==1
        set(Fid,'units','normalized','outerposition',[0 0 1 1])   % Figure maximieren auf ganzen Bildschirm
    end
    whitebg('white');
    axes1 = axes('Parent',Fid);
    
    Wave1=Graphs.Data{2,1};
    Fid=plot(Graphs.Data{1,1},[Wave1.X,Wave1.Y],Wave1.Z);
    try; view(axes1,View); end;
    xlim(axes1,Xrange.');
    ylim(axes1,Yrange.');
    zlim(axes1,Zrange.');
    xlabel(Xlab);
    ylabel(Ylab);
    zlabel(Zlab);
    set(Fid,'MarkerSize',2,'LineWidth',1,'MarkerEdgeColor','k','MarkerFaceColor','k');
    
    grid on;
    
    Frame = getframe(gcf);
    writeVideo(WriterObj, Frame);
    pause(1);
    close(gcf);
end

close(WriterObj); % Saves the movie.
if W.SingularImarisInstance==1
    mouseMoveController(0);
end