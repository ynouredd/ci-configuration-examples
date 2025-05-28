classdef PowerUsedTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        percentile = {5, 50, 90, 95, 99}
        expSat1Pwr = {181.5, 267.6, 338.3, 357.3, 392.1}
        expSat2Pwr = {74.2, 106.7, 134.5, 142, 156.1}
    end
    
    methods (TestMethodSetup)
        function setUpRandomGenerator(testCase)
            S = RandStream('mt19937ar', 'Seed', 0);
            RandStream.setGlobalStream(S);
        end
    end
    
    methods (Test,ParameterCombination='sequential',TestTags = {'Unit Test'})
        function MediumSatellite(testCase, percentile, expSat1Pwr)
            [percentilePower, ~] = PowerUsed("Satellite1", percentile);
            testCase.verifyEqual(percentilePower, expSat1Pwr, 'AbsTol', 0.1, ...
                sprintf('Power used for Satellite1 at %d percentile is not as expected.', percentile));
        end
        
        function SmallSatellite(testCase, percentile, expSat2Pwr)
            [percentilePower, ~] = PowerUsed("Satellite2", percentile);
            testCase.verifyEqual(percentilePower, expSat2Pwr, 'AbsTol', 0.1, ...
                sprintf('Power used for Satellite2 at %d percentile is not as expected.', percentile));
        end
    end
    
end