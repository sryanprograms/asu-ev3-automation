% Connect to the brick
% brick = ConnectBrick('TacoBrick');  
global key;
InitKeyboard();

% Set color sensor
brick.SetColorMode(3, 2);

beginMoving = false;  % Start in a stationary state
manualMode = false;  
pickupDone = false;
dropoffDone = false;

while true
    pause(0.5);
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
    end % End of switch statement

    % Autonomous mode
    if beginMoving && ~manualMode
        % First: Check for stop sign, pickup zone, or drop-off zone
        if color == 5
            % Stop sign
            disp('Stop sign detected. Halting for 5 seconds.');
            brick.StopAllMotors();
            pause(5); % Wait for 5 seconds

        elseif color == 2 && ~pickupDone
            % Pickup zone
            disp('Pickup zone detected. Switching to manual mode.');
            brick.StopAllMotors();
            manualMode = true;

        elseif color == 3 && pickupDone && ~dropoffDone
            % Drop-off zone
            disp('Drop-off zone detected. Switching to manual mode.');
            brick.StopAllMotors();
            manualMode = true;

        else
            % No color condition met: Continue to wall-following logic or forward motion
            if press == 1
                if distance <= 25
                    % Obstacle detected, turn left
                    disp('Obstacle detected on the left. Turning left...');
                    brick.MoveMotorAngleRel('A', 25, 360, 'Brake'); 
                    brick.MoveMotorAngleRel('D', -25, 360, 'Brake'); 
                else
                    % No obstacle, turn right
                    disp('No obstacle detected on the right. Turning right...');
                    brick.MoveMotorAngleRel('A', -25, 360, 'Brake'); 
                    brick.MoveMotorAngleRel('D', 25, 360, 'Brake'); 
                end

                % Wait for both motors to complete their motions
                brick.WaitForMotor('A');
                brick.WaitForMotor('D');
            else
                % Move straight if no pressing or color conditions are met
                brick.MoveMotor('A', -25); % Move both motors backward
                brick.MoveMotor('D', -25);
            end
        end
    end % End of autonomous mode check

    % Check if the task is complete
    if dropoffDone && color == 4
        brick.StopAllMotors();
        disp('Task complete. Exiting...');
        break;
    end
end % End of while loop

CloseKeyboard(); % Close the keyboard interface
