classdef GradientMethodTest < matlab.unittest.TestCase
    properties
        % Properties to store data shared across test methods
        SatPositionHistory
        SatVelocityHistory
    end
    
    properties (TestParameter)
        % Test parameters for the combinations of anomalies
        addSpikes = {true, false};
        addNoise = {true, false};
    end
    
    methods (TestClassSetup)
        function createTestData(testCase)
            rng('default');
            load("satellite1data.mat","satPosition","satVelocity")
            testCase.SatPositionHistory = satPosition;
            testCase.SatVelocityHistory = satVelocity;
        end
    end
    
    methods (Test, TestTags = {'GradientMethod'})
        function testAnomalyDetector(testCase, addSpikes, addNoise)
            if addNoise
                [testCase.SatPositionHistory,NoiseIndices] = introduceNoise(testCase.SatPositionHistory);
            end
            
            if addSpikes
                [testCase.SatPositionHistory,SpikesIndices] = introduceSpikes(testCase.SatPositionHistory);
            end
            
            anomalyIndices = gradientmethod(testCase.SatPositionHistory);
            
            if addNoise
                diffs = [true, diff(NoiseIndices) ~= 1, true];
                NoiseIndices = NoiseIndices(diffs(1:end-1) | diffs(2:end));
                testCase.verifyIndicesInAnomalies(NoiseIndices, anomalyIndices, 'Noise Indices');
            end
            
            if addSpikes
                testCase.verifyIndicesInAnomalies(SpikesIndices, anomalyIndices, 'Spike Indices');
            end
        end
    end
    
    methods
        function verifyIndicesInAnomalies(testCase, indices, anomalyIndices, indicesName)
            % Helper method to verify that each index is in anomalyIndices
            for i = 1:length(indices)
                testCase.verifyTrue(any(ismember([indices(i)-1, indices(i), indices(i)+1], anomalyIndices)), ...
                    sprintf('Anomaly index %d from %s not found in anomalyIndices.', indices(i), indicesName));
            end
        end
    end
end