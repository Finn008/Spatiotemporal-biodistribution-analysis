function movieBuilder_3(In)
for m=1:5
    try
        set(0,'units','pixels'); ScreenPix=get(0,'screensize'); ScreenPix=ScreenPix(3:4).'; %(1)=Wave1(1,4); ScreenPix(2,1)=Wave1(1,3);
        % try
        
        v2struct(In);
        % generate Yaxis in correct format, provide different graphs in
        % cell rows, timepoints in rows, Xrange in columns
        if exist('OrigYaxis')==1
            if
            Y=OrigYaxis{1,1}.';
            for m=2:size(OrigYaxis,1)
                Y(:,:,m)=OrigYaxis{m,1}.';
            end
            Y=permute(Y,[1,3,2]);
            Sp=OrigYaxis(:,2);
        end
        
        Xpix=size(Y,1);
        GraphNumber=size(Y,2);
        FrameNumber=size(Y,3);
        
        if exist('Layout')==0 || strcmp(Layout,'black')==0
            Layout='white';
        end
        if exist('AddLine')==1 && size(AddLine,3)~=FrameNumber
            AddLine=repmat(AddLine,[1,1,FrameNumber]);
        else
            AddLine=cell(0,0);
        end
        if exist('Path')==0 || isempty(Path)
            Path=['D:\','default'];
        end
        if exist('X')==0 || isempty(X)
            X=(1:1:Xpix).';
            if exist('Xres')
                X=X*Xres;
            end
        end
        if exist('Sp')==0 || isempty(Sp)
            Sp(1:GraphNumber,1)={'b.'};
        elseif ischar(Sp);
            wave1(1:GraphNumber,1)={Sp};
            Sp=wave1;
        end
        
        writerObj = VideoWriter(Path);
        writerObj.FrameRate = Frequency; % How many frames per second.
        writerObj.Quality=100;
        open(writerObj);
        
        if ischar(Tit);
            Tit{1:FrameNumber,1}=Tit;
        elseif size(Tit,1)<FrameNumber;
            Tit(1:FrameNumber,1)=Tit;
        end
        
        for m=1:FrameNumber;
            if m==1
                Fid=figure; hold on;
                set(Fid,'Units','pixels');
                FidPix=get(Fid,'Position');
                %             Factor=ScreenPix./FidPix; Factor=min(Factor(:));
                %             FidPix=floor(FidPix*Factor);
                %             set(Fid,'Position',[1,1,FidPix(2,1),FidPix(1,1)]);
            else
                Fid=figure('Units','pixels','Position',FidPix); hold on;
            end
            %         Fid=figure; hold on;
            for n=1:GraphNumber;
                try
                    plot(X,Y(:,n,m),Sp{n});
                catch
                    plot(X,Y(:,n,m),'color',Sp{n});
                end
            end
            try; xlabel(Xlab); catch; end;
            try; ylabel(Ylab); catch; end;
            try; set(gca,'xlim',Xrange); catch; end;
            try; set(gca,'ylim',Yrange); catch; end;
            try; title(Tit{m}); catch; end;
            whitebg(Layout);
            set(gcf,'color',Layout);
            for n=1:size(AddLine,2)
                LineID=line([AddLine{1,n,m},AddLine{3,n,m}],[AddLine{2,n,m},AddLine{4,n,m}]);
                if size(AddLine,1)>4
                    for m3=1:size(AddLine{5,n,m},1)
                        set(LineID,AddLine{5,n,m}{1,1},AddLine{5,n,m}{1,2});
                    end
                end
            end
            pause(0.1);
            %if mod(i,4)==0, % Uncomment to take 1 out of every 4 frames.
            set(Fid,'Position',FidPix);
            frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
            if size(frame.cdata,1)==FidPix(1,4) && size(frame.cdata,2)==FidPix(1,3)
                writeVideo(writerObj, frame);
            else
            end
            close Fid 1;
        end
        close(writerObj); % Saves the movie.
        % catch error
        %     keyboard;
        %     try;
        %         close(writerObj); % Saves the movie.
        %         close fid 1;
        %     end
        %     disp('ERROR in movieBuilder');
        %     return;
        % end
        break;
    catch error
        displayError(error);
%         movieBuilder_3(i);
    end
end