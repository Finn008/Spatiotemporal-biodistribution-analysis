function mouse_2(In)
[Speci]=variableExtract(In,'Pause');
if Speci.Pause>0
    Center=[900;900]; Radius=100;Resolution=1;
    [Pos]=circleGenerator(Center,Radius,Resolution);
    CirclePos=
    inputemu('move',Pos.Ch2);
end

return;
% busyTester = clipboard('paste');
% if isempty(busyTester)
%     clipboard('copy', 'busyTester');
% end
%Setup
robot = java.awt.Robot;
import java.awt.event.*;
% screenSizes = get(0, 'MonitorPositions');

if isnumeric(in) && size(in,1)==2
    robot.mouseMove(in(1,1),in(2,1));
end

if ischar(in)
   if strcmp(in,'pressRight') 
       robot.mousePress(InputEvent.BUTTON3_MASK);
   elseif strcmp(in,'releaseRight') 
       robot.mouseRelease(InputEvent.BUTTON3_MASK);
   elseif strcmp(in,'clickRight') 
       robot.mousePress(InputEvent.BUTTON3_MASK);
       robot.mouseRelease(InputEvent.BUTTON3_MASK);
   elseif strcmp(in,'pressLeft') 
       robot.mousePress(InputEvent.BUTTON1_MASK);
       pause(0.5);
   elseif strcmp(in,'releaseLeft') 
       robot.mouseRelease(InputEvent.BUTTON1_MASK);
   elseif strcmp(in,'clickLeft') 
       robot.mousePress(InputEvent.BUTTON1_MASK);
       robot.mouseRelease(InputEvent.BUTTON1_MASK);
   elseif strcmp(in(1),'_')
       wave1=['KeyEvent.VK',in];
       path=['robot.keyPress(',wave1,');'];
       eval(path);
   elseif strcmp(in(1),'/')
       wave1=['KeyEvent.VK_',in(2:end)];
       path=['robot.keyRelease(',wave1,');'];
       eval(path);
   end    
end
status=0;

% if isempty(clipboard('paste'))
%    a1=asdf;
% end
% while status==0
%     clipboard('copy', 'test');
    
%     pause(0.1);
% end
pause(0.5);






return;
%Slow horizontal drag
for ix = 1:500
    robot.mouseMove(ix, 200);
    pause(0.01)
end

return


%Mouse to upper left of primary monitor
robot.mouseMove(1, 1)

%Mouse to center of primary monitor
robot.mouseMove(mean(screenSizes(1,[1 3])),mean(screenSizes(1,[2 4]))) 



