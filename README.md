# asu-ev3-automation
This is for the ASU FSE EV3 Car Challenge


This code is designed for our EV3 autonomous vehicle to pickup and drop-off people in wheel chirs. The vehicle autonomously navigates through a maze until it reaches the pickup or drop-off zones. At these zones, manual control can be activated on a laptop to handle moving the rider.

Our code includes developing a wall-following algorithm, so the can will follow walls until it encounters a dead-end. At dead-ends, the vehicle will assess whether the left or right path is open, making the necessary turn and then contining.

The system uses:

Gyro Sensor (only in wgyro file): Ensures accurate wall-following and accurate turns.
Ultrasonic Sensor: Detects walls and measures distances to keep a safe distance from walls.
Touch Sensor: Identifies collisions with walls.
Color Sensor: Recognizes stop signs, pickup/drop-off zones, and the start/end points.
Using these sensors, the robot can navigate the maze, switch between autonomous and manual modes, and complete its tasks.
