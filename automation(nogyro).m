global key;
InitKeyboard();

%  set color sensor
brick.SetColorMode(3, 2);

beginMoving = 1;
manualMode = false;  
pickupDone = false;
dropoffDone = false;

while beginMoving
    % Kill switch
    if brick.TouchPressed(1)
        brick.StopAllMotors();
        disp('Kill switch pressed.');
        break;
    end
    
    % sensor ports
    distance = brick.UltrasonicDist(4);
    color = brick.ColorCode(3);
    press = brick.TouchPressed(2);

    % autonomous
    if ~manualMode
        % forward
        brick.MoveMotor('A', -50);
        brick.MoveMotor('D', -50);
        
        % stop sign
        if color == 5
            brick.StopAllMotors();
            pause(5);  % Wait for 5 seconds
        % pickup zone
        elseif color == 2 && ~pickupDone
            brick.StopAllMotors();
            manualMode = true;
        % drop-off zone
        elseif color == 3 && pickupDone && ~dropoffDone
            brick.StopAllMotors();
            manualMode = true;
        % follow walls 
        elseif distance <= 25 && press == 1
            % wall on the left turn right
            pause(0.5);
            brick.MoveMotorAngleRel('A', -50, 180, 'D', 50, 180);  
            brick.WaitForMotor('A');
            brick.WaitForMotor('D');
        elseif distance > 25 && press == 1
            % wall on the right turn left
            pause(0.5);
            brick.MoveMotorAngleRel('A', 50, 180, 'D', -50, 180); 
            brick.WaitForMotor('A');
            brick.WaitForMotor('D');
        end
    end

    % manual 
    if manualMode
        switch key
            case 'uparrow'
                brick.MoveMotor('A', 50);
                brick.MoveMotor('D', 50);
            case 'downarrow'
                brick.MoveMotor('A', -50);
                brick.MoveMotor('D', -50);
            case 'leftarrow'
                brick.MoveMotor('A', 0);
                brick.MoveMotor('D', 50);
            case 'rightarrow'
                brick.MoveMotor('A', 50);
                brick.MoveMotor('D', 0);
            case 'a'  % Open mechanical arm
                brick.MoveMotor('B', 50);
                pause(1);
                brick.StopMotor('B');
            case 'b'  % Close mechanical arm
                brick.MoveMotor('B', -50);
                pause(1);
                brick.StopMotor('B');
            case 'space'
                % switch to autonomous
                manualMode = false;
                if color == 2
                    pickupDone = true;
                elseif color == 3
                    dropoffDone = true;
                end
            case 'q'  % quit (kill switch for keyboard)
                brick.StopAllMotors();
                break;
        end
    end

    % Check if the task is complete
    if dropoffDone && color == 4
        brick.StopAllMotors();
        break;
    end
end

CloseKeyboard();
