function assigment(serPort)


disp ('==================')
disp ('Program Starting  ')
disp ('------------------')
%display program starting on terminal

idx1=1;
Kp=100;
Ki=5;
Kd=25;

DistRead =DistanceSensorRoomba(serPort);
Dist1=0;

%get max value from elements from the left 
LidarRes=LidarSensorCreate(serPort);
LidarLeft=min(LidarRes(341:681));
LidarRight=min(LidarRes(2:340));
LidarFront=min(LidarRes(341));
%LidarBack=min(LidarRes(150:250));

%SetDriveWheelsCreate(serPort, 0.2, 0.2);
%diff=(LidarLeft-LidarRight);
t=0;
while (t~=1)
%LidarRes=LidarSensorCreate(serPort);
LidarLeft=min(LidarRes(341:681));
LidarRight=min(LidarRes(2:340));
LidarFront=min(LidarRes(341));

disp(LidarLeft);
disp(LidarRight);

disp(LidarFront);

if (LidarLeft==LidarFront)
    disp('called');
    SetDriveWheelsCreate(serPort,0,0);
    t=1;
    break;
   
end
end 
disp('centered');
%Turn=turnAngle(serPort,0.1,40);
while (t==1)
    LidarRes=LidarSensorCreate(serPort);
    LidarFront=min(LidarRes(341));
    disp(LidarFront);
    
turnAngle(serPort,0.2,5);
   
if (LidarFront>3)
    turnAngle(serPort,0,0);
    t=3;
    break;
end 
end 
disp('straight');
travelDist(serPort, .5, 2);
disp('searchbeacon');
Camera = CameraSensorCreate(serPort);
 SetDriveWheelsCreate(serPort,0.2,0.2);

while (~any(Camera))
    Camera = CameraSensorCreate(serPort);

    LidarRes=LidarSensorCreate(serPort);
    LidarLeft=min(LidarRes(341:681));
    LidarRight=min(LidarRes(2:340));
    LidarFront=min(LidarRes(341));
    if (LidarLeft<1.2)
        turnAngle(serPort,0.3,-5);
    elseif(LidarRight<1.2);
        turnAngle(serPort,0.3,5);
    elseif (LidarFront<1.5)
        turnAngle(serPort,0.3,-10);
    end 
      
     SetDriveWheelsCreate(serPort,0.2,0.2);
    pause(.1);
    
    
end 

 Camera=CameraSensorCreate(serPort);
 while  (any(Camera))
      LidarRes=LidarSensorCreate(serPort);
      LidarLeft=min(LidarRes(341:681));
      LidarRight=min(LidarRes(2:340));
      LidarFront=min(LidarRes(341));
      Camera = CameraSensorCreate(serPort);
       if any(Camera) && abs(Camera) > 0.05
            [BumpRight,BumpLeft,WheDropRight,WheDropLeft,WheDropCaster,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
          if BumpFront
              break;
          end
         
            turnAngle (serPort, .2, (Camera * 6));
            disp(Camera);
       end
       SetDriveWheelsCreate(serPort,0.5,0.5);
       pause(.1);
        %disp(Camera);
 end 
      disp('done');
      c=0;
        DistRead = DistanceSensorRoomba(serPort);
        Dist1 = 0;
        z=1
      while (z==1)
    LidarRes=LidarSensorCreate(serPort);
    LidarFront=min(LidarRes(341));
    disp(LidarFront);
    
turnAngle(serPort,0.2,5);
disp(LidarFront);
   
if (LidarFront>2 && LidarFront==4)
    turnAngle(serPort,0,0);
   z=0;
    break;
end 
      end 
       while (z==0)
    LidarRes=LidarSensorCreate(serPort);
    LidarFront=min(LidarRes(341));
    disp(LidarFront);
    
turnAngle(serPort,0.2,5);
disp(LidarFront);
   
if (LidarFront>2 && LidarFront<3.8)
    turnAngle(serPort,0,0);
   z=3;
    break;
end 
      end
      
%//travelDist(serPort,0.2,1);     
SetDriveWheelsCreate(serPort,0.5,0.5);
r=0;
while (r==0)
    
  
    LidarRes=LidarSensorCreate(serPort);
    LidarLeft=min(LidarRes(341:681));
    LidarRight=min(LidarRes(2:340));
    LidarFront=min(LidarRes(341));
    if (LidarFront<1)
        %SetDriveWheelsCreate(serPort,0,0);
        r=1;
        disp('stopped');
        break;
    end 
    disp(LidarFront);
    disp('lidar');
  
  
end
SetDriveWheelsCreate(serPort,0.3,0.3);
q=0;
disp('prep');
Dist2=0;
while (q==0)
    disp('turn');
  SetDriveWheelsCreate(serPort,0.3,0.3);

    LidarRes=LidarSensorCreate(serPort);
    LidarLeft=min(LidarRes(341:681));
    LidarRight=min(LidarRes(2:340));
    LidarFront=min(LidarRes(341));
    LidarLe=min(LidarRes(580:595));
    if (LidarLeft<=1)
        turnAngle(serPort,0.2,-5);
        
    elseif(LidarLeft>1.3)
        turnAngle(serPort,0.2,5);
    end
    
    if (LidarLeft>1 &&LidarLe==4 && Dist2>7.8)
        SetDriveWheelsCreate(serPort,0,0);
        turnAngle(serPort,0.2,85);
        break;
    end
    DistRead = DistanceSensorRoomba(serPort);
   
    Dist2=Dist2+DistRead;
    disp(LidarLeft);
    disp(LidarLe);
    disp(Dist2);
     SetDriveWheelsCreate(serPort,0.3,0.3);
     pause(.1);
end 
s=0;
SetDriveWheelsCreate(serPort,0.3,0.3);
travelDist(serPort,0.3,3);


end 
 