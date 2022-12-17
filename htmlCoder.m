function [HtmlStr]=htmlCoder(In,ImageInfo)
global W;

% replace '' with '<br>'
In.Content=regexprep(In.Content,'\n','<br>');

TotalString='';
for m=In.Content.'
    TotalString=[TotalString,m{1}(1)];
end
% TotalString=strjoin(In.Content.','');
% PathImages='C:\Users\Admins\Google Drive\Trainer\Images';
% PathImages='C:\Users\fipeter\Google Drive\Trainer\Images';
% ImageInfo=table;
% ImageInd=strfind(Wave1,'QQ');

for m=1:size(ImageInfo,1)
    Ind=strfind(TotalString,ImageInfo.Name{m,1});
    if isempty(Ind)==0
        Wave1=imfinfo([W.Path2Images,'\',ImageInfo.Name{m,1}]);
        if ImageInfo.Width{m,1}==0
            Factor=ImageInfo.Height{m,1}/Wave1.Height;
            ImageInfo.Width{m,1}=round(Wave1.Width*Factor);
        elseif ImageInfo.Height{m,1}==0
            Factor=ImageInfo.Width{m,1}/Wave1.Width;
            ImageInfo.Height{m,1}=round(Wave1.Height*Factor);
        end
        ImageInfo.NameSize(m,1)=size(ImageInfo.Name{m,1},2);
        ImageInfo.Ind(m,1)=Ind;
        In.ImagePath{Ind,1}=[W.Path2Images,'\',ImageInfo.Name{m,1}];
        In.ImageWidth(Ind,1)=ImageInfo.Width{m,1};
        In.ImageHeight(Ind,1)=ImageInfo.Height{m,1};
        In.ImagePath(ImageInfo.Ind(m)+1:ImageInfo.Ind(m)+ImageInfo.NameSize(m)-1,:)={'delete'};
    end
end
try; In(strfind1(In.ImagePath,'delete'),:)=[]; end;

if strfind1(In.Properties.VariableNames,'ImagePath')==0
    In.ImagePath{1}=[];
end

HtmlStr='';
for m=1:size(In,1)
    StartTags='';
    EndTags='';
    
    if isempty(In.ImagePath{m,1})==0 % Image
        In.Content{m,1}=['<img src="file:///',In.ImagePath{m,1},'" width="',num2str(In.ImageWidth(m,1)),'" height="',num2str(In.ImageHeight(m,1)),'">'];
    end
    
    if In.Bold(m)==1 % bold
        StartTags=[StartTags,'<b>'];
        EndTags=['</b>',EndTags];
    end
    if In.Italic(m)==1 % italic
        StartTags=[StartTags,'<i>'];
        EndTags=['</i>',EndTags];
    end
    if In.Underline(m)==1 % italic
        StartTags=[StartTags,'<u>'];
        EndTags=['</u>',EndTags];
    end
    %     StartTags=[StartTags,'<font color="red">'];
    %     EndTags=['</font>',EndTags];
    if isnan(In.ColorR(m))==0
        RGBstr=[num2str(In.ColorR(m)),',',num2str(In.ColorG(m)),',',num2str(In.ColorB(m))];
        StartTags=[StartTags,'<font color="rgb(',RGBstr,')">'];
        EndTags=['</font>',EndTags];
    end
    
    %     <font color="rgb(255,0,0)">This is some text!</font>
    if iscell(In.Content{m})
        A1=qwertrztzuuio; % cell in content not allowed
    end
    if isnumeric(In.Content{m})
        String2Add=num2str(In.Content{m});
    else
        String2Add=In.Content{m};
    end
    
    HtmlStr=[HtmlStr,StartTags,String2Add,EndTags];
end


% formats total
StartTags='<body>';
EndTags='</body>';
% StartTags=[StartTags,'<b>'];
% EndTags=['</b>',EndTags];
HtmlStr=[StartTags,HtmlStr,EndTags];

return;
%% outside


'<b><div style="font-family:impact;color:green">''Matlab'
HtmlStr=[HtmlStr,'{\color{',In.Content{m,1},'}',In.Content{m,1},'}'];
% ('string','{\color{red} A}ustralia');
HtmlStr = ['<b><div style="font-family:impact;color:green">'...
    'Matlab</div></b> GUI is <i>' ...
    '<font color="red">highly</font></i> customizable'];


% set(handles.edit1,'String','test');
% set(handles.edit1,'Max',5);
% jScrollPane = findjobj(handles.edit1); % Get the Java scroll-pane container reference
% jViewPort = jScrollPane.getViewport;
% jEditbox = jViewPort.getComponent(0);
% jEditbox.setPage('http://undocumentedmatlab.com/blog/rich-matlab-editbox-contents/');