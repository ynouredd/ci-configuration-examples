classdef PowerGenerationTest < matlab.unittest.TestCase
    properties
        % Properties to store data shared across test methods
        SatPositionHistory
        simDuration
        timeStart
        timeEnd
        Visible
        DragUsed
    end
    
    properties (TestParameter)
        % Define test parameters
        SPArea = {0, 15, 30};
        PowerConsumpPercentile = {50, 90, 95};
        ExpectedValue = {[0 0],[87.02 84.66],[173.37 168.67]}
    end
    
    properties (ClassSetupParameter)
        % Combined method setup parameter for initial position and velocity vectors
        atmDrag = {0, 1}
    end
    
    methods (TestClassSetup)
        function createTestData(testCase,atmDrag)
            Position = [6520 0 0];
            Velocity = [0 8.3 0];
            
            testCase.timeStart = [2024 1 1 0 0 0];
            testCase.timeEnd = [2024 1 4 0 0 0];
            testCase.DragUsed = atmDrag;
            SecondsToPropagate = seconds(datetime(testCase.timeEnd)-datetime(testCase.timeStart));
            
            % Propagate satellite over duration of simulation, account for atmoshperic
            % drag and using a 50 square meter cross sectional area
            [testCase.SatPositionHistory,~,testCase.simDuration] = PropSat(Position,Velocity,SecondsToPropagate,testCase.timeStart,0,atmDrag,50);
            
            testCase.Visible = VisibleToSun(testCase.SatPositionHistory,testCase.timeStart,SecondsToPropagate);
        end
    end
    
    methods (Test, ParameterCombination = 'sequential',TestTags={'Long Duration'})
        function PowerGenTest(testCase,SPArea,PowerConsumpPercentile,ExpectedValue)
            testCase.timeEnd = datevec(datetime(testCase.timeStart)+seconds(testCase.simDuration));
            S = RandStream('mt19937ar', 'Seed', 0);
            RandStream.setGlobalStream(S);
            SPEfficiency = 0.3;
            Wh = PowerGenerated(testCase.Visible,SPEfficiency,SPArea,testCase.timeStart,testCase.timeEnd);
            percentilePower = PowerUsed("Satellite1.mat",PowerConsumpPercentile/100);
            PowerNeeded = percentilePower * testCase.simDuration;
            percentageMet = (Wh / PowerNeeded) * 100;
            testCase.verifyEqual(percentageMet, ExpectedValue(testCase.DragUsed+1), 'AbsTol', 1e-1);
        end
    end
    
end