% Initialize Gyro Sensor
brick.GyroReset('1');

while ~taskCompleted
    % stop button
    if brick.TouchPressed(1)
        brick.StopAllMotors();
        disp('Kill switch pressed.');
        break;
    end
    
    % sensor setups
    distance = brick.UltrasonicDist(4);  % Ultrasonic
    color = brick.ColorCode(3);         % Color
    press = brick.TouchPressed(2);      % Touch 
    currentAngle = brick.GyroAngle('1'); % Gyro

    % drive autonomous
    if ~manualMode
        % gyro-sensor correcyion
        targetAngle = 0; % Target angle for driving in a straight line
        if currentAngle > targetAngle
            % fix motors when vering right
            brick.MoveMotor('A', -(DRIVE_SPEED - 10));
            brick.MoveMotor('D', -(DRIVE_SPEED + 10));
        elseif currentAngle < targetAngle
            % fix motors when veering left
            brick.MoveMotor('A', -(DRIVE_SPEED + 10));
            brick.MoveMotor('D', -(DRIVE_SPEED - 10));
        else
            % straight driving
            brick.MoveMotor('A', -DRIVE_SPEED);
            brick.MoveMotor('D', -DRIVE_SPEED);
        end

        % Stop (Red)
        if color == 5
            brick.StopAllMotors();
            pause(5);
        % Pickup (Blue)
        elseif color == 2 && ~pickupDone
            brick.StopAllMotors();
            manualMode = true;
            disp('Pickup zone. Switching to manual mode.');
        % Dropoff (Green)
        elseif color == 3 && pickupDone && ~dropoffDone
            brick.StopAllMotors();
            manualMode = true;
            disp('Dropoff zone. Switching to manual mode.');
        % End (Yellow)
        elseif color == 4 && dropoffDone
            brick.StopAllMotors();
            disp('Dropoff done!');
            taskCompleted = true;
        % turning and avoiding walls 
        elseif press
            brick.StopAllMotors();
            pause(0.5);
            if distance < 25
                % gyro 90 deg turn right
                targetTurn = currentAngle + 90; % what the angle should be after the turn right
                while brick.GyroAngle('1') < targetTurn
                    brick.MoveMotor('A', TURN_SPEED); % left motor forward
                    brick.MoveMotor('D', -TURN_SPEED); % Right motor back
                end
                brick.StopAllMotors();
            else
                % gyro 90 deg turn left
                targetTurn = currentAngle - 90; % what the angle should be after the turn left
                while brick.GyroAngle('1') > targetTurn
                    brick.MoveMotor('A', -TURN_SPEED); % Left motor back
                    brick.MoveMotor('D', TURN_SPEED);  % right mtor forward
                end
                brick.StopAllMotors();
            end
        end
    end

    % Manual ctrl
    if manualMode
        switch key
            case 'uparrow'  % Forward
                brick.MoveMotor('A', -DRIVE_SPEED);
                brick.MoveMotor('D', -DRIVE_SPEED);
            case 'downarrow' % Backward
                brick.MoveMotor('A', DRIVE_SPEED);
                brick.MoveMotor('D', DRIVE_SPEED);
            case 'leftarrow' % left
                brick.MoveMotor('A', 0);
                brick.MoveMotor('D', -DRIVE_SPEED);
            case 'rightarrow' % right
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
            case 'space' %switch to Autonomous
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
