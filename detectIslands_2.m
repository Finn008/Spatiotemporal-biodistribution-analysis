function [Data3D]=detectIslands_2(Mask,SizeMinMax,Res,Type,Border)


if exist('Border') && isempty(Border)==0
    if strfind(Border,'EqualClosestBorder')
        keyboard;
        BorderVersion='EqualClosestBorder';
    elseif strfind(Border,'Ones')
        BorderVersion='Ones';
%         [Mask,AddBorderMinMaxPaste]=addBorder3D(Mask,Res,Border,1);
    elseif strfind(Border,'Zeros')
        BorderVersion='Zeros';
%         [Mask,AddBorderMinMaxPaste]=addBorder3D(Mask,Res,Border,0);
    end
    Border=str2num(regexprep(Border,BorderVersion,''));
    [Mask,AddBorderMinMaxPaste]=addBorder3D(Mask,Res,Border,BorderVersion);
end


if size(SizeMinMax,1)==1
    SizeMinMax=repmat(SizeMinMax,[3,1]);
end
Data3D=uint8(Mask);
% 13 directions in 1D each value 1, 3 directions in 2D each value 15, 1 direction in 3D value 60
Pix=size(Mask).';
% define windows 1D in XY
Window=zeros(3,3);Window([1;5;9])=1;
WindowTable(1,1)={Window}; % 1
Window=zeros(3,3);Window([2;5;8])=1;
WindowTable(2,1)={Window}; % 2
Window=zeros(3,3);Window([3;5;7])=1;
WindowTable(3,1)={Window}; % 3
Window=zeros(3,3);Window([4;5;6])=1;
WindowTable(4,1)={Window}; % 4

% define windows 1D in XYZ
Window=zeros(3,3,3);Window([1;14;27])=1;
WindowTable(5,1)={Window}; % 1
Window=zeros(3,3,3);Window([2;14;26])=1;
WindowTable(6,1)={Window}; % 2
Window=zeros(3,3,3);Window([3;14;25])=1;
WindowTable(7,1)={Window}; % 3
Window=zeros(3,3,3);Window([4;14;24])=1;
WindowTable(8,1)={Window}; % 4
Window=zeros(3,3,3);Window([5;14;23])=1;
WindowTable(9,1)={Window}; % 5
Window=zeros(3,3,3);Window([6;14;22])=1;
WindowTable(10,1)={Window}; % 6
Window=zeros(3,3,3);Window([7;14;21])=1;
WindowTable(11,1)={Window}; % 7
Window=zeros(3,3,3);Window([8;14;20])=1;
WindowTable(12,1)={Window}; % 8
Window=zeros(3,3,3);Window([9;14;19])=1;
WindowTable(13,1)={Window}; % 9

% define windows 2D in XYZ
Window=zeros(3,3);Window([2;4;5;6;8])=1;
WindowTable(14,1)={Window}; % 1
Window=zeros(3,3,3);Window([5;11;14;17;23])=1;
WindowTable(15,1)={Window}; % 2
Window=zeros(3,3,3);Window([5;13;14;15;23])=1;
WindowTable(16,1)={Window}; % 3


Window2DSum=zeros(3,3);
for WindowId=1:4
    Window2DSum(WindowTable{WindowId,1}==1)=WindowId;
end

Window3DSum=zeros(3,3,3);
for WindowId=5:13
    Window3DSum(WindowTable{WindowId,1}==1)=WindowId;
end

%% 2D

for WindowId=[14,15,16]
    tic;
    Window=WindowTable{WindowId,1};
    if WindowId==14
        Area=Res(1)*Res(2);
    else
        Area=Res(1)*Res(3);
    end
    BW=bwconncomp(Mask,Window);
    Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
    Table.Area=Table.NumPix*Area;
    Table.Diameter=2*(Table.Area/3.1415).^0.5;
    Table=Table(Table.Diameter>SizeMinMax(2,1)&Table.Diameter<SizeMinMax(2,2),:);
    Wave1=zeros(Pix.','uint8');
    Wave1(cell2mat(Table.IdxList))=15; % max value is 1+13=14 until now
    Data3D=Data3D+Wave1;
    disp([num2str(toc/60),' min']);
end

%% 3D
if strcmp(Type,'3D')
    tic
    BW=bwconncomp(Mask,6);
    Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
    Table.Volume=Table.NumPix*prod(Res);
    Table.Diameter=2*(Table.Volume*3/4/3.1415).^(1/3);
%     Table=Table(Table.Volume>SizeMinMax(3,1)&Table.Volume<SizeMinMax(3,2),:);
    Table=Table(Table.Diameter>SizeMinMax(3,1)&Table.Diameter<SizeMinMax(3,2),:);
    Wave1=zeros(Pix.','uint8');
    Wave1(cell2mat(Table.IdxList))=60; % max value is 1+13+3*15=59 until now
    Data3D=Data3D+Wave1;
    disp([num2str(toc/60),' min']);
end

%% 1D
if strcmp(Type,'2D')
    WindowIds=(1:4).';
elseif strcmp(Type,'3D')
    WindowIds=(1:13).';
end

for WindowId=WindowIds.'
    tic;
    Window=WindowTable{WindowId,1};
    [X,Y,Z]=ind2sub(size(Window),find(Window==1));
    X=(X(2)-X(1))*Res(1);
    Y=(Y(2)-Y(1))*Res(2);
    Z=(Z(2)-Z(1))*Res(3);
    Length=(X^2+Y^2+Z^2)^0.5;
    
    BW=bwconncomp(Mask,Window);
    Table=table(cellfun(@numel,BW.PixelIdxList).',BW.PixelIdxList.','VariableNames',{'NumPix','IdxList'}); clear BW;
    Table.Length=Table.NumPix*Length;
    Table=Table(Table.Length>SizeMinMax(1,1)&Table.Length<SizeMinMax(1,2),:);
    
    Wave1=zeros(Pix.','uint8');
    Wave1(cell2mat(Table.IdxList))=1;
    Data3D=Data3D+Wave1;
    disp([num2str(toc/60),' min']);
end




if exist('Border') && isempty(Border)==0
    Data3D=Data3D(AddBorderMinMaxPaste(1,1):AddBorderMinMaxPaste(1,2),AddBorderMinMaxPaste(2,1):AddBorderMinMaxPaste(2,2),AddBorderMinMaxPaste(3,1):AddBorderMinMaxPaste(3,2));
end










