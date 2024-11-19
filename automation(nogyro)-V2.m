% Initialize Gyro Sensor
brick.GyroReset('1'); % Reset the gyro sensor to zero

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
    currentAngle = brick.GyroAngle('1'); % Gyro sensor for angle

    % Autonomous Mode
    if ~manualMode
        % Straight-Line Correction with Gyro Sensor
        targetAngle = 0; % Target angle for straight-line movement
        if currentAngle > targetAngle
            % Adjust motors to correct veering to the right
            brick.MoveMotor('A', -(DRIVE_SPEED - 10)); % Negative for forward
            brick.MoveMotor('D', -(DRIVE_SPEED + 10));
        elseif currentAngle < targetAngle
            % Adjust motors to correct veering to the left
            brick.MoveMotor('A', -(DRIVE_SPEED + 10));
            brick.MoveMotor('D', -(DRIVE_SPEED - 10));
        else
            % Drive straight
            brick.MoveMotor('A', -DRIVE_SPEED);
            brick.MoveMotor('D', -DRIVE_SPEED);
        end

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
                % Gyro-Based 90-degree Right Turn
                targetTurn = currentAngle + 90; % Target angle after 90-degree turn
                while brick.GyroAngle('1') < targetTurn
                    brick.MoveMotor('A', TURN_SPEED); % Reverse logic: left motor forward
                    brick.MoveMotor('D', -TURN_SPEED); % Right motor backward
                end
                brick.StopAllMotors();
            else
                disp('Path clear on the left. Turning left...');
                % Gyro-Based 90-degree Left Turn
                targetTurn = currentAngle - 90; % Target angle after 90-degree turn
                while brick.GyroAngle('1') > targetTurn
                    brick.MoveMotor('A', -TURN_SPEED); % Reverse logic: left motor backward
                    brick.MoveMotor('D', TURN_SPEED);  % Right motor forward
                end
                brick.StopAllMotors();
            end
        end
    end

    % Manual Mode (reversed directions for control)
    if manualMode
        switch key
            case 'uparrow'  % Forward (negative due to reversed orientation)
                brick.MoveMotor('A', -DRIVE_SPEED);
                brick.MoveMotor('D', -DRIVE_SPEED);
            case 'downarrow' % Backward (positive due to reversed orientation)
                brick.MoveMotor('A', DRIVE_SPEED);
                brick.MoveMotor('D', DRIVE_SPEED);
            case 'leftarrow' % Turn left
                brick.MoveMotor('A', 0);
                brick.MoveMotor('D', -DRIVE_SPEED);
            case 'rightarrow' % Turn right
                brick.MoveMotor('A', -DRIVE_SPEED);
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
