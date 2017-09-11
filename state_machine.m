function state_machine(serPort)

disp ('==================')
disp ('Program Starting  ')
disp ('------------------')

SetDriveWheelsCreate(serPort, 0.5, 0.5);
flag=0;
idx1 = 1;
t=0;
SonRead = ReadSonar(serPort, 3);
 if ~any(SonRead) SonLF(idx1) = 100;
    else SonLF(idx1) = SonRead;
    end
    
    SonRead = ReadSonar(serPort, 2);
    if ~any(SonRead) SonFF(idx1) = 100;
    else SonFF(idx1) = SonRead;
    end
    
    DistRead = DistanceSensorRoomba(serPort);
    Dist1 = 0;
    flag2=0;
    while (Dist1<200)
        
         Camera = CameraSensorCreate(serPort);
       if (any(Camera) && flag2~=3 )
           flag=1;
           flag2=1;
       elseif(~any(Camera) && flag2==0)
           flag=0;
           
       elseif(~any(Camera) && flag2==1)
           flag=3;
       
       
       end
           
           switch (flag)
               case (1)
                  
                    if any(Camera) && abs(Camera) > 0.05
            
                 turnAngle (serPort, .2, (Camera * 6));
                 SetDriveWheelsCreate(serPort, 0.5, 0.5); 
                     Dist1=Dist1+ DistRead;
        pause (.1);
        Camera = CameraSensorCreate(serPort);
                    end   
        
               case (0)
                    [BumpRight,BumpLeft,WheDropRight,WheDropLeft,WheDropCaster,BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
        if ~BumpRight && ~BumpLeft && ~BumpFront
            SetDriveWheelsCreate(serPort, 0.5, 0.5);
        elseif BumpRight
                turnAngle (serPort, .2, 70);
        elseif BumpLeft
                turnAngle (serPort, .2, -70);
        else
                turnAngle (serPort, .2, 100);
        end
            Dist1=Dist1+ DistRead;
        pause (.1);
        Camera = CameraSensorCreate(serPort);
               case (3)
                   while (t<1)
                   
                   flag2=3;
                   
          SonRead = ReadSonar(serPort, 3);
        if ~any(SonRead) SonLF(idx1) = 100;
        else SonLF(idx1) = SonRead;
        end
    
        % If distance out of limits turn to get near/away from the wall
        if ( SonLF(idx1) > 0.31 ) turnAngle(serPort, .2, 5);
        elseif ( SonLF(idx1) < 0.28 ) turnAngle(serPort, .2, -5);
        end

        % Read Front Sonar and correct if out-of-range
        SonRead = ReadSonar(serPort, 2);
        if ~any(SonRead) SonFF(idx1) = 100;
        else SonFF(idx1) = SonRead;
        end
    
        % It too near a wall it means needs to turn sharp right!
        if ( SonFF(idx1) < 0.30 ) turnAngle(serPort, .2, -70);
        end
        
        Dist1=Dist1+ DistRead;
        pause (.1);
        
        SetDriveWheelsCreate(serPort, 0.5, 0.5);
                   end
        %Camera = CameraSensorCreate(serPort);
                   
                   
                   
           
           
         
        end 
end 