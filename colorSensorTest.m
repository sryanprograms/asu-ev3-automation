global key; 
InitKeyboard(); 
brick.SetColorMode(4,2); 
  while true color = brick.ColorCode(4);
    brick.MoveMotor('A', 50);
    brick.MoveMotor('D', 50);
    if color ~= 5 
      pause(0.5); 
    elseif color == 2 
      brick.beep(); 
      brick.beep(); 
    elseif color == 3 
      pause(0.5); 
      brick.beep(); 
      brick.beep(); 
      brick.beep(); 
    else brick.StopAllMotors(); 
  end 
end
