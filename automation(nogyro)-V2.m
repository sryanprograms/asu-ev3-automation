
global key
InitKeyboard();

% Gyro Sensor
brick.GyroReset('1');

while ~taskCompleted
    % Check for key presses
    switch key
        case 'space' % Kill switch
            brick.StopAllMotors();
            disp('Kill switch pressed.');
            break;

        case 'uparrow' % Start auto-driving
            while ~taskCompleted
                % Sensor setups
                distance = brick.UltrasonicDist(4);  % Ultrasonic
                color = brick.ColorCode(3);         % Color
                press = brick.TouchPressed(2);      % Touch 
                currentAngle = brick.GyroAngle('1'); % Gyro
                
                % Autonomous driving logic
                targetAngle = 0; % Target angle for driving in a straight line
                if currentAngle > targetAngle
                    % Fix motors when veering right
                    brick.MoveMotor('A', -(DRIVE_SPEED - 10));
                    brick.MoveMotor('D', -(DRIVE_SPEED + 10));
                elseif currentAngle < targetAngle
                    % Fix motors when veering left
                    brick.MoveMotor('A', -(DRIVE_SPEED + 10));
                    brick.MoveMotor('D', -(DRIVE_SPEED - 10));
                else
                    % Straight driving
                    brick.MoveMotor('A', -DRIVE_SPEED);
                    brick.MoveMotor('D', -DRIVE_SPEED);
                end
                
                % Color-based actions
                if color == 5 % Stop (Red)
                    brick.StopAllMotors();
                    pause(5);
                elseif color == 2 && ~pickupDone % Pickup (Blue)
                    brick.StopAllMotors();
                    manualMode = true;
                    disp('Pickup zone. Switching to manual mode.');
                elseif color == 3 && pickupDone && ~dropoffDone % Dropoff (Green)
                    brick.StopAllMotors();
                    manualMode = true;
                    disp('Dropoff zone. Switching to manual mode.');
                elseif color == 4 && dropoffDone % End (Yellow)
                    brick.StopAllMotors();
                    disp('Dropoff done!');
                    taskCompleted = true;
                elseif press % Turning and avoiding walls
                    brick.StopAllMotors();
                    pause(0.5);
                    if distance < 25
                        % Gyro 90 deg turn right
                        targetTurn = currentAngle + 90;
                        while brick.GyroAngle('1') < targetTurn
                            brick.MoveMotor('A', TURN_SPEED); % Left motor forward
                            brick.MoveMotor('D', -TURN_SPEED); % Right motor back
                        end
                        brick.StopAllMotors();
                    else
                        % Gyro 90 deg turn left
                        targetTurn = currentAngle - 90;
                        while brick.GyroAngle('1') > targetTurn
                            brick.MoveMotor('A', -TURN_SPEED); % Left motor back
                            brick.MoveMotor('D', TURN_SPEED);  % Right motor forward
                        end
                        brick.StopAllMotors();
                    end
                end

                % Break out if kill switch is pressed during autonomous mode
                if strcmp(key, 'space')
                    disp('Kill switch pressed.');
                    brick.StopAllMotors();
                    break;
                end
            end

        case 'q' % Quit
            disp('Exiting program.');
            brick.StopAllMotors();
            break;

        % Add other manual controls if needed
    end
end

CloseKeyboard();
