global key;
InitKeyboard();

brick.SetColorMode(4, 2);
brick.GyroCalibrate(2);

beginMoving = 1;
manualMode = false;
pickupDone = false;
dropoffDone = false;

TURN_SPEED = 50;
STRAIGHT_SPEED = 50;
TURN_ANGLE = 90;

% Function to make a precise turn using the gyro sensor
function turnAngle(targetAngle)
    initialAngle = brick.GyroAngle(2);
    while abs(brick.GyroAngle(2) - initialAngle) < targetAngle
        if targetAngle > 0  % Turn right
            brick.MoveMotor('A', TURN_SPEED);
            brick.MoveMotor('D', -TURN_SPEED);
        else  % Turn left
            brick.MoveMotor('A', -TURN_SPEED);
            brick.MoveMotor('D', TURN_SPEED);
        end
    end
    brick.StopAllMotors();
end

% Main loop
while beginMoving
    % Read sensor values
    distance = brick.UltrasonicDist(4);
    color = brick.ColorCode(4);
    press = brick.TouchPressed(1);
    currentAngle = brick.GyroAngle(2);

    % Autonomous Movement
    if ~manualMode
        % Move forward and adjust to stay straight path
        error = currentAngle;  % Error from the initial heading (0 degrees)
        correction = 0.5 * error;  % Adjust this gain value as needed
        brick.MoveMotor('A', STRAIGHT_SPEED - correction);
        brick.MoveMotor('D', STRAIGHT_SPEED + correction);

        % Check color zones
        if color == 5  % Red zone: stop 
            brick.StopAllMotors();
            disp('Red Zone Detected: Stopping');
            pause(5);  % Wait for 5 seconds

        elseif color == 2 && ~pickupDone  % Blue zone: pickup 
            brick.StopAllMotors();
            disp('Pickup Zone Detected: Switching to Manual Control');
            manualMode = true;

        elseif color == 3 && pickupDone && ~dropoffDone  % Green zone: drop-off 
            brick.StopAllMotors();
            disp('Dropoff Zone Detected: Switching to Manual Control');
            manualMode = true;

        % Wall-following logic with gyro turns
        elseif distance <= 25 && press == 1
            disp('Turning right due to wall on the left');
            turnAngle(90);  % Turn right 90 degrees

        elseif distance > 25 && press == 1
            disp('Turning left due to wall on the right');
            turnAngle(-90);  % Turn left 90 degrees
        end
    end

    % Manual
    if manualMode
        switch key
            case 'uparrow'
                brick.MoveMotor('A', STRAIGHT_SPEED);
                brick.MoveMotor('D', STRAIGHT_SPEED);
            case 'downarrow'
                brick.MoveMotor('A', -STRAIGHT_SPEED);
                brick.MoveMotor('D', -STRAIGHT_SPEED);
            case 'leftarrow'
                turnAngle(-45);  % Turn left 45 degrees
            case 'rightarrow'
                turnAngle(45);   % Turn right 45 degrees
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

    % Check if dropoff complete
    if dropoffDone && color == 4
        disp('Reached the final zone. Task Complete!');
        brick.StopAllMotors();
        break;
    end
end

CloseKeyboard();

