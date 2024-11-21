% brick = ConnectBrick('VIRUS'); run this in the command window before pressing run

global key;
InitKeyboard();

% Set color sensor
brick.SetColorMode(3, 2);

beginMoving = 1;
manualMode = false;  
pickupDone = false;
dropoffDone = false;

while beginMoving
    % Sensor ports
    distance = brick.UltrasonicDist(4);
    color = brick.ColorCode(3);
    press = brick.TouchPressed(2);

    % Check for 'q' quick button or manual mode inputs
    switch key
        case 'q'  % Quick quit button
            disp('Quick quit button pressed. Exiting...');
            brick.StopAllMotors();
            break;

        case 'space'  % Switch to autonomous mode
            disp('Switching to autonomous mode.');
            manualMode = false;

        % Manual control
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
    end

    % Autonomous mode
    if ~manualMode
        % Forward motion
        brick.MoveMotor('A', -50);
        brick.MoveMotor('D', -50);

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
            brick.MoveMotorAngleRel('A', -50, 180, 'D', 50, 180);  
            brick.WaitForMotor('A');
            brick.WaitForMotor('D');

        elseif distance > 25 && press == 1
            % Wall on the right, turn left
            pause(0.5);
            brick.MoveMotorAngleRel('A', 50, 180, 'D', -50, 180); 
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
