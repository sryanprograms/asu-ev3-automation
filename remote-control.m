%REMOTE CONTROL CODE
global key;
InitKeyboard();
brick.SetColorMode(4,2);
while true
   color = brick.ColorCode(4);
   if (color ~= 5)
       pause(0.1);
       switch key
           case 'uparrow'
               brick.MoveMotor('AD', -50);
           case 'downarrow'
               brick.MoveMotor('AD', 50);
           case 'leftarrow'
               brick.MoveMotor('A', 0);
               brick.MoveMotor('D', 50);
           case 'rightarrow'
               brick.MoveMotor('A', 50);
               brick.MoveMotor('D', 0);
           case 0
               disp('No Key Pressed!');
           case 'q'
              brick.StopAllMotors;
              break;  % Uncomment if needed
           case 'a'
               brick.MoveMotor('B', 50);
           case 'b'
               brick.MoveMotor('B', -50);
       end
   else
       % Stop all motors if color is 5 and wait for 3 seconds
       brick.StopAllMotors;
       pause(3);  % Wait for 3 seconds
   end
end
CloseKeyboard();  % Uncomment if needed

