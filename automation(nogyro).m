%brick = ConnectBrick('TacoBrick');  % Connect to the brick
global key;
InitKeyboard();

% Set color sensor
brick.SetColorMode(3, 2);

beginMoving = false;  % Start in a stationary state
manualMode = false;  
pickupDone = false;
dropoffDone = false;

while true
    % Sensor ports
    distance = brick.UltrasonicDist(4);
    color = brick.ColorCode(3);
    press = brick.TouchPressed(2);

    % Check for key inputs
    switch key
        case 'q'  % Quick quit button
            disp('Quick quit button pressed. Exiting...');
            brick.StopAllMotors();
            break;

        case 'space'  % Switch to autonomous mode
            disp('Switching to autonomous mode.');
            manualMode = false;
            beginMoving = true;

        % Manual control
        case 'uparrow'  % Start autonomous movement
            pause(2);
            brick.MoveMotor('A', -25);
            brick.MoveMotor('D', -25);
        case 'downarrow'
            pause(2);
            brick.MoveMotor('A', 25);
            brick.MoveMotor('D', 25);
        case 'leftarrow'
            pause(2);
            brick.MoveMotor('A', 0);
            brick.MoveMotor('D', -25);
        case 'rightarrow'
            pause(2);
            brick.MoveMotor('A', -25);
            brick.MoveMotor('D', 0);
        case 'a'  % Open mechanical arm
            brick.MoveMotor('B', 25);
            pause(2);
            brick.StopMotor('B');
        case 'b'  % Close mechanical arm
            brick.MoveMotor('B', -25);
            pause(2);
            brick.StopMotor('B');
        otherwise
            % Stop all motors when no key is pressed
            if manualMode
                brick.StopMotor('A');
                brick.StopMotor('D');
            end
    end

    % Autonomous mode
    if beginMoving && ~manualMode
        % Forward motion
        brick.MoveMotor('A', -25);
        brick.MoveMotor('D', -25);

        % Stop sign
        if color == 5
            brick.StopAllMotors();
            pause(5);  % Wait for 5 seconds

        % Pickup zone
        elseif color == 2 && ~pickupDone
            brick.StopAllMotors();
            disp('Pickup zone reached. Switching to manual mode.');
            manualMode = true;

        % Drop-off zone
        elseif color == 3 && pickupDone && ~dropoffDone
            brick.StopAllMotors();
            disp('Drop-off zone reached. Switching to manual mode.');
            manualMode = true;

        % Wall-following logic
        elseif distance <= 25 && press == 1
            % Wall on the left, turn right
            pause(0.5);
            brick.MoveMotorAngleRel('A', -25, 180, 'D', 25, 180);  
            brick.WaitForMotor('A');
            brick.WaitForMotor('D');

        elseif distance > 25 && press == 1
            % Wall on the right, turn left
            pause(0.5);
            brick.MoveMotorAngleRel('A', 25, 180, 'D', -25, 180); 
            brick.WaitForMotor('A');
            brick.WaitForMotor('D');
        end
    end

    % Check if the task is complete
    if dropoffDone && color == 4
        brick.StopAllMotors();
        disp('Task complete. Exiting...');
        break;
    end
end

CloseKeyboard();
