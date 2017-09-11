function PID(serPort)

SetDriveWheelsCreate(serPort,0.3,0.3);

index =1;

Kp=100;
Ki=25;
Kd=75;

DistRead=DistanceSensorRoomba(serPort);

Dist1=0;

LidarRes = LidarSensorCreate(serPort);
[LidarM, LidarD] = min(LidarRes(341:681));

t=1;
while (Dist1 < 18)
    pause(.1)
    
 
        
        

    % Read Left side of Lidar
    LidarRes = LidarSensorCreate(serPort);
    [LidarM, LidarD] = min(LidarRes(341:681));
    
    % Now do a simple porportional action, turning proportionally to how
    % far is from the set-point (0.5)
    % Watch the sign of the error!!
    CumError=0;
    ErrorPrev=0;
    DErrorDiff=0;
    b=mod(t,2);
  
    DError = abs(LidarM - 0.5);
    CumError=CumError + DError;
    if (b==0)
        DErrorDiff=DError-ErrorPrev;
    else 
        ErrorPrev=DError;
    end 
    KOut = Kp * DError + Ki*CumError +Kd*DErrorDiff;
    % We also need to limit the action, in this case max correction to
    % 50Deg (or -50 but that one is automatically limmited by reading 0)
    if (KOut > 50) KOut = 50;
    end
    turnAngle(serPort, .2, KOut);
    
    % Read Odometry sensor and accumulate distance measured.
    DistRead = DistanceSensorRoomba(serPort);
    Dist1 = Dist1 + DistRead;
    
    % Reset straight line and advance
    SetDriveWheelsCreate(serPort, 0.5, 0.5);
        ++t;
   


    % Stop motors
    SetDriveWheelsCreate(serPort, 0, 0);
    
end 