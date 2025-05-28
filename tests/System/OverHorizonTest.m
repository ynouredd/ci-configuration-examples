classdef OverHorizonTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        % Define test parameters
        Position = {[7000 0 0],[35000 0 0],[1000000 0 0],[7543, 11760, 515],[12667, 19739, 8655]};
        Velocity = {[0 7.5 0],[0 3.374 0],[0 0.3 0],[-4.211, 4.459, 2.243],[-3.4393, 1.7828, 0.9679]};
        expGenOrbitVisib = {0, 32.4, 49.7, 27.5, 38.4};
        
        llaInterest = {[42.2834 -122.2631 100],[0 -118.8 100],[-100 60 100],[-42.2834 58.7 100]}
        expGeoSyncOrbitVisib = {100 100 100 0};

        lunarGrav = {0,1}
        expVisLG = {48.75,48.82}

        atmDrag = {0,1}
        expVisAD = {16.0,13.2}
    end
    
    methods (Test, ParameterCombination='sequential')
        % Test methods
        
        function GenOrbits(testCase,Position,Velocity,expGenOrbitVisib)
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.AbsoluteTolerance
            
            timeStart = [2024 7 24 12 0 0];
            timeEnd = [2024 7 26 12 0 0];
            lla = [42.2834 -122.2631 100];
            SecondsToPropagate = seconds(datetime(timeEnd)-datetime(timeStart));
            SatPosition = PropSat(Position,Velocity,SecondsToPropagate,timeStart,0,0);
            
            visible = SatVisibilityHistory(SatPosition,timeStart,lla,SecondsToPropagate);
            
            percent = sum(visible)*100 / length(visible);
            testCase.verifyThat(percent,IsEqualTo(expGenOrbitVisib,"Within",AbsoluteTolerance(1)))
        end
    end

    methods (Test,ParameterCombination='sequential',TestTags={'Long Duration'})
        
        function Geostationary(testCase,llaInterest,expGeoSyncOrbitVisib)
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.AbsoluteTolerance
            
            timeStart = [2024 7 24 12 0 0];
            timeEnd = [2024 7 27 12 0 0];
            PositionGeosync = [42164 0 0];
            VelocityGeosync = [0 3.075 0];
            
            SecondsToPropagate = seconds(datetime(timeEnd)-datetime(timeStart));
            SatPosition = PropSat(PositionGeosync,VelocityGeosync,SecondsToPropagate,timeStart,0,0);
            visible = SatVisibilityHistory(SatPosition,timeStart,llaInterest,SecondsToPropagate);
            
            percent = sum(visible)*100 / length(visible);
            testCase.verifyThat(percent,IsEqualTo(expGeoSyncOrbitVisib,"Within",AbsoluteTolerance(1)))
        end
        
        function OrbitsWithLunGrav(testCase,lunarGrav,expVisLG)
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.AbsoluteTolerance
            
            timeStart = [2024 1 1 0 0 0];
            timeEnd = [2024 1 8 0 0 0];
            Pos = [588550 0 0];
            Vel = [0 1.6 0];
            
            lla = [42.2834 -122.2631 100];
            SecondsToPropagate = seconds(datetime(timeEnd)-datetime(timeStart));
            
            SatPosition = PropSat(Pos,Vel,SecondsToPropagate,timeStart,lunarGrav,0);
            
            visible = SatVisibilityHistory(SatPosition,timeStart,lla,SecondsToPropagate);
            
            percent = sum(visible)*100 / length(visible);
            testCase.verifyThat(percent,IsEqualTo(expVisLG,"Within",AbsoluteTolerance(0.01)))
        end
        
        function OrbitsWithDrag(testCase,atmDrag,expVisAD)
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.AbsoluteTolerance

            timeStart = [2024 1 1 0 0 0];
            timeEnd = [2024 1 4 0 0 0];
            Pos = [6500 0 0];
            Vel = [0 8.3 0];
            
            lla = [5 -122.2631 100];
            SecondsToPropagate = seconds(datetime(timeEnd)-datetime(timeStart));

            SatPosition = PropSat(Pos,Vel,SecondsToPropagate,timeStart,0,atmDrag);

            visible = SatVisibilityHistory(SatPosition,timeStart,lla,SecondsToPropagate);

            percent = sum(visible)*100 / length(visible);
            testCase.verifyThat(percent,IsEqualTo(expVisAD,"Within",AbsoluteTolerance(0.1)))
        end
        
    end
    
end