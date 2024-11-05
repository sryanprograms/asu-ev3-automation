global key;
InitKeyboard();

brick.SetColorMode(4,2);
beginMoving = 0;

switch key
        
  case 'space'
    while(beginMoving == 0)
      distance = brick.UltrasonicDist(4);
      color = brick.ColorCode(4);
      press = brick.TouchPressed(1); %change touch port to whatever we end up connecting it to
      brick.MoveMotor('A', 50);
      brick.MoveMotor('D', 50);
    
      if(color == 5)
        % Stop all motors if color is 5 and wait for 3 seconds
        brick.StopAllMotors;
        pause(5);  % Wait for 3 seconds
        
      %move right if there is a wall to the left and a wall in front is touched  
      elseif(distance>=25 && touch==1)
        pause(1);
        brick.MoveMotors('A', -50)
        brick.MoveMotors('D', 50)
        
      %move left if there is a wall to the right and a wall in front is touched  
      elseif(distance<=25 && touch==1)
        pause(1);        
        brick.MoveMotors('A', 50)
        brick.MoveMotors('D', -50)

      %once in pickup zone change to manual control
      elseif(color==2)
        pause(1);
        switch key
          case 'uparrow'
            pause(1);
            brick.MoveMotor('AD', -50);
          case 'downarrow'
            pause(1);
            brick.MoveMotor('AD', 50);
          case 'leftarrow'
            pause(1);
            brick.MoveMotor('A', 0);
            brick.MoveMotor('D', 50);
          case 'rightarrow'
            pause(1)
            brick.MoveMotor('A', 50);
            brick.MoveMotor('D', 0);
          case 0
            disp('No Key Pressed!');
          case 'q'
            brick.StopAllMotors;
            break;  % Uncomment if needed
          case 'a'
            pause(1)
            brick.MoveMotor('B', 50);
          case 'b'
            pause(1)
            brick.MoveMotor('B', -50);
        
       end
   end
end



