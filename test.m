function test(serPort)

SetDriveWheelsCreate(serPort, 0.5, 0.5);

turnAngle(serPort, .2, -90);

travelDist(serPort, .5, 5.5);

turnAngle(serPort, .2, -90);

travelDist(serPort, .5, 2);