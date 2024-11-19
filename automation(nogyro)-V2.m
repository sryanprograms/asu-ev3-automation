% Main Loop
while ~taskCompleted
    % Kill Switch
    if brick.TouchPressed(1)
        brick.StopAllMotors();
        disp('Kill switch pressed.');
        break;
    end
    
    % Sensor Inputs
    distance = brick.UltrasonicDist(4);  % Ultrasonic sensor (on left)
    color = brick.ColorCode(3);         % Color sensor
    press = brick.TouchPressed(2);      % Touch sensor (front)

    % Autonomous Mode
    if ~manualMode
        % Drive Forward
        brick.MoveMotor('A', -DRIVE_SPEED);
        brick.MoveMotor('D', -DRIVE_SPEED);

        % Stop at Stop Signs (Red)
        if color == 5
            brick.StopAllMotors();
            pause(5);
        % Pickup Zone (Blue)
        elseif color == 2 && ~pickupDone
            brick.StopAllMotors();
            manualMode = true;
            disp('Pickup zone reached. Switching to manual mode.');
        % Dropoff Zone (Green)
        elseif color == 3 && pickupDone && ~dropoffDone
            brick.StopAllMotors();
            manualMode = true;
            disp('Dropoff zone reached. Switching to manual mode.');
        % End Zone (Yellow)
        elseif color == 4 && dropoffDone
            brick.StopAllMotors();
            disp('Task completed!');
            taskCompleted = true;
        % Obstacle Detection and Response
        elseif press
            brick.StopAllMotors();
            pause(0.5);
            if distance < 25
                disp('Obstacle detected on the left. Turning right...');
                % Turn right
                brick.MoveMotorAngleRel('A', -TURN_SPEED, 360, 'D', TURN_SPEED, 360);
                brick.WaitForMotor('A');
                brick.WaitForMotor('D');
            else
                disp('Path clear on the left. Turning left...');
                % Turn left
                brick.MoveMotorAngleRel('A', TURN_SPEED, 360, 'D', -TURN_SPEED, 360);
                brick.WaitForMotor('A');
                brick.WaitForMotor('D');
            end
        end
    end

    % Manual Mode (remains unchanged from previous example)
    if manualMode
        switch key
            case 'uparrow'
                brick.MoveMotor('A', DRIVE_SPEED);
                brick.MoveMotor('D', DRIVE_SPEED);
            case 'downarrow'
                brick.MoveMotor('A', -DRIVE_SPEED);
                brick.MoveMotor('D', -DRIVE_SPEED);
            case 'leftarrow'
                brick.MoveMotor('A', 0);
                brick.MoveMotor('D', DRIVE_SPEED);
            case 'rightarrow'
                brick.MoveMotor('A', DRIVE_SPEED);
                brick.MoveMotor('D', 0);
            case 'a'  % Open Arm
                brick.MoveMotor('B', 50);
                pause(1);
                brick.StopMotor('B');
            case 'b'  % Close Arm
                brick.MoveMotor('B', -50);
                pause(1);
                brick.StopMotor('B');
            case 'space'
                disp('Switching to autonomous mode...');
                manualMode = false;
                if color == 2
                    pickupDone = true;
                    disp('Pickup completed.');
                elseif color == 3
                    dropoffDone = true;
                    disp('Dropoff completed.');
                end
            case 'q'  % Quit
                disp('Exiting program.');
                brick.StopAllMotors();
                break;
        end
    end
end

