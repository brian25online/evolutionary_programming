function state_machine_nine(serPort)



flag=0;

% Sets forward velocity using differential system
SetDriveWheelsCreate(serPort, 0.5, 0.5);

% Initialise variables plus 1st sensor read for each.
    idx1 = 1;

% We need to check each sonar for valid reading in case is out of range.
    SonRead = ReadSonar(serPort, 3);
    if ~any(SonRead) SonLF(idx1) = 100;
    else SonLF(idx1) = SonRead;
    end
    
    SonRead = ReadSonar(serPort, 2);
    if ~any(SonRead) SonFF(idx1) = 100;
    else SonFF(idx1) = SonRead;
    end
    t=0;
    while (t~=1)
    Camera = CameraSensorCreate(serPort);
    if (any(Camera))
        flag=1;
    elseif (~any(Camera))
        flag=0;
    end 
    
    switch(flag)
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
           
        pause (.1);
        Camera = CameraSensorCreate(serPort);
            
        case (1)
          turnAngle (serPort, .2, (Camera * 6));
          SetDriveWheelsCreate(serPort, 0.5, 0.5); 
          Dist1=Dist1+ DistRead;
        
        pause (.1);
        Camera = CameraSensorCreate(serPort); 
        if (~any(Camera))
            t=1;
           break; 
        end 
    end   
            
    end 
    while (t~=0)
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
        
        
    end 
    

    

end 