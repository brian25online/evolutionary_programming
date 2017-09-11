function uzzie(serPort)
LidarRes=LidarSensorCreate(serPort);
    LidarLeft=min(LidarRes(341:681));
    LidarRight=min(LidarRes(2:340));
    LidarFront=min(LidarRes(341));
    LidarLe=min(LidarRes(495:505));
    disp(LidarLe);
    disp(LidarLeft);
end 