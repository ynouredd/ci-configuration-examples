classdef PowerGeneratedTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        percentile = {5, 50, 90, 95, 99}
        expSat1Pwr = {181.5, 267.6, 338.3, 357.3, 392.1}
        expSat2Pwr = {74.2, 106.7, 134.5, 142, 156.1}
    end
    
    methods (TestMethodSetup)
        function setUpRandomGenerator(testCase)
            rng("default"); % Initialize the random number generator
        end
    end
    
    methods (Test,TestTags = {'Unit Test'})
        function Eclipsed(testCase)
            VisibleToSun = zeros(1,10);
            SPEfficiency = 0.3;
            SPArea = 1;
            StartTime = [2024 1 1 0 0 0];
            EndTime = [2024 1 1 0 10 0];
            Wh = PowerGenerated(VisibleToSun,SPEfficiency,SPArea,StartTime,EndTime);
            testCase.verifyEqual(Wh,0)
        end
        
        function AlwaysVisible(testCase)
            VisibleToSun = ones(1,10);
            SPEfficiency = 0.3;
            SPArea = 1;
            StartTime = [2024 1 1 0 0 0];
            EndTime = [2024 1 1 0 10 0];
            Wh = PowerGenerated(VisibleToSun,SPEfficiency,SPArea,StartTime,EndTime);
            testCase.verifyEqual(Wh,4100,'abstol',1)
        end
        
    end
    
end