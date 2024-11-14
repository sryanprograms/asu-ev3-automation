global key;
InitKeyboard();

% Initialize sensors
brick.SetColorMode(4, 2);  % Set color sensor to Color Code mode

beginMoving = 1;
manualMode = false;  % Flag for manual mode
pickupDone = false;
dropoffDone = false;

% Main loop
while beginMoving
    % Kill switch (touch sensor)
    if brick.TouchPressed(1)
        brick.StopAllMotors();
        disp('Kill switch pressed.');
        break;
    end
    
    % Read sensor values
    distance = brick.UltrasonicDist(4);
    color = brick.ColorCode(4);
    press = brick.TouchPressed(1);

    % Autonomous Movement
    if ~manualMode
        % Move forward
        brick.MoveMotor('A', 50);
        brick.MoveMotor('D', 50);
        
        % If red color is detected, stop for 5 seconds (stop sign)
        if color == 5
            brick.StopAllMotors();
            pause(5);  % Wait for 5 seconds
        % Detect blue color for pickup zone
        elseif color == 2 && ~pickupDone
            brick.StopAllMotors();
            manualMode = true;
        % Detect green color for drop-off zone
        elseif color == 3 && pickupDone && ~dropoffDone
            brick.StopAllMotors();
            manualMode = true;
        % Wall-following logic
        elseif distance <= 25 && press == 1
            % Wall on the left, move right
            pause(0.5);
            brick.MoveMotorAngleRel('A', -50, 180, 'D', 50, 180);  % Turn right
            brick.WaitForMotor('A');
            brick.WaitForMotor('D');
        elseif distance > 25 && press == 1
            % Wall on the right, move left
            pause(0.5);
            brick.MoveMotorAngleRel('A', 50, 180, 'D', -50, 180);  % Turn left
            brick.WaitForMotor('A');
            brick.WaitForMotor('D');
        end
    end

    % Manual Control
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
                % Switch back to autonomous mode
                manualMode = false;
                if color == 2
                    pickupDone = true;
                elseif color == 3
                    dropoffDone = true;
                end
            case 'q'  % Quit the program
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

% Cleanup
CloseKeyboard();
