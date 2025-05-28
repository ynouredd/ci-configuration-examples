classdef CommunicationTest < matlab.unittest.TestCase
    properties
        % Properties to store data shared across test methods
        SatPositionHistory
        SatVelocityHistory
        SecondsToPropagate
        timeStart
    end
    
    properties (TestParameter)
        inertiaMatrix = {[120000, 90000, 1000;90000, 120000, 75000; 1000, 75000, 120000];
            [120000, 0, 0;0, 120000, 0; 0, 0, 120000]}
        Cont1ExpData = {"Cont1Inertia1","Cont1Inertia2"}
        Cont2ExpData = {"Cont2Inertia1","Cont2Inertia2"}
        
        llaInterest = {[42.3 -122.3 50],[42.3 -122.3 5000],[0 0 0],[85 170 300]};
        expPercent = {18.84,19.87,25.55,17.73}
        
        Antenna = {'Hubble.txt','ISS.txt','Landsat.txt'}
        GS = {'Canberra.mat','Madrid.mat','Santiago.mat'}
    end
    
    methods (TestClassSetup)
        function randNumInit(~)
            S = RandStream('mt19937ar', 'Seed', 0);
            RandStream.setGlobalStream(S);
        end
    end
    
    methods (TestMethodSetup)
        function createTestData(testCase)
            %% Initialize scenario
            testCase.timeStart = [2024 1 1 0 0 0];
            timeEnd = [2024 1 2 0 0 0];
            testCase.SecondsToPropagate = seconds(datetime(timeEnd)-datetime(testCase.timeStart));
            
            Pos = [-7254 -910 667];
            Vel = [-1.203 -3.76 -8.042];
            
            % Propagate satellite over sim time and account for Lunar Gravity
            [testCase.SatPositionHistory,testCase.SatVelocityHistory] = PropSat(Pos,Vel,testCase.SecondsToPropagate,testCase.timeStart,1,0);
            
            % Add some anomalies
            testCase.SatPositionHistory = introduceDrift(testCase.SatPositionHistory);
            testCase.SatPositionHistory = introduceNoise(testCase.SatPositionHistory);
            testCase.SatPositionHistory = introduceSpikes(testCase.SatPositionHistory);
        end
    end
    
    methods (Test, ParameterCombination = 'sequential')
        % Test methods
        function attitudeController1(testCase,inertiaMatrix,Cont1ExpData)
            desiredOrientation = calculateNadirOrientation(testCase.SatPositionHistory,testCase.SatVelocityHistory);
            initialOrientation = [0 0 0];
            ControllerValues = [2 0 10];
            
            % Maximum torque that reaction wheels can apply (N*m)
            maxTorque = [25, 25, 25]; % Example values
            
            maxIntegral = 1; % Maximum allowed integral component
            
            dT = testCase.SecondsToPropagate/(length(testCase.SatPositionHistory));
            [orientation, controlEffort] = attitudeControl(initialOrientation, desiredOrientation, dT, inertiaMatrix, maxTorque, ControllerValues, maxIntegral);
            
            load(Cont1ExpData,"expOrient","expConEff")
            
            testCase.verifyEqual(orientation(1:100:end,:),expOrient,'AbsTol', 1e-3)
            testCase.verifyEqual(controlEffort(1:100:end,:),expConEff,'AbsTol', 1e-3)
        end
        
        function attitudeController2(testCase,inertiaMatrix,Cont2ExpData)
            desiredOrientation = calculateNadirOrientation(testCase.SatPositionHistory,testCase.SatVelocityHistory);
            initialOrientation = [0 0 0];
            ControllerValues = [8 0.1 40];
            
            % Maximum torque that reaction wheels can apply (N*m)
            maxTorque = [25, 25, 25]; % Example values
            
            maxIntegral = 1; % Maximum allowed integral component
            
            dT = testCase.SecondsToPropagate/(length(testCase.SatPositionHistory));
            [orientation, controlEffort] = attitudeControl(initialOrientation, desiredOrientation, dT, inertiaMatrix, maxTorque, ControllerValues, maxIntegral);
            
            load(Cont2ExpData,"expOrient","expConEff")
            
            testCase.verifyEqual(orientation(1:100:end,:),expOrient,'AbsTol', 1e-3)
            testCase.verifyEqual(controlEffort(1:100:end,:),expConEff,'AbsTol', 1e-3)
        end
        
        function SatVisibilityTest(testCase,llaInterest,expPercent)
            visible = SatVisibilityHistory(testCase.SatPositionHistory,testCase.timeStart,llaInterest,testCase.SecondsToPropagate);
            dT = testCase.SecondsToPropagate/(length(testCase.SatPositionHistory));           
            percent = sum(visible) * 100 / length(visible);
            testCase.verifyEqual(percent,expPercent, 'AbsTol', 0.1)
        end
    end
    
    methods (Test)
        function SignalNoiseRatioTest(testCase,Antenna,GS)
            dT = testCase.SecondsToPropagate/(length(testCase.SatPositionHistory));
            EbNo = findSignalToNoise(testCase.SatPositionHistory*1e3,testCase.timeStart,GS,Antenna,dT);
            
            % Used to get the expected EbNo to a specific
            % Antenna-GroundStation combination
            varName = [Antenna(1:3), GS(1:3)];
            
            loadedData = load("ExpEbNo.mat",varName);
            loadedVar = loadedData.(varName);
            
            testCase.verifyEqual(EbNo(1:20:end,:),loadedVar,'AbsTol', 1e-3)
        end
    end
    
end