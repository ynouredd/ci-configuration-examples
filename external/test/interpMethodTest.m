classdef interpMethodTest < matlab.unittest.TestCase
    properties
        % Properties to store data shared across test methods
        SatPositionHistory
        SatVelocityHistory
        SatPositionTraining
    end
    
    properties (TestParameter)
        % Test parameters for the combinations of anomalies
        addSpikes = {true, false};
        addNoise = {true, false};
        addDrift = {true, false};
    end
    
    properties (MethodSetupParameter)
        Orbit = {"1","2","3"}
    end
    
    methods (TestMethodSetup)
        function createTestData(testCase, Orbit)
            rng('default');
            load(strcat("satellite",Orbit,"data.mat"),"satPosition","satVelocity")
            testCase.SatPositionHistory = satPosition;
            testCase.SatVelocityHistory = satVelocity;
            testCase.SatPositionTraining = satPosition;
        end
    end
    
    methods (Test)
        function testAnomalyDetector(testCase, addSpikes, addNoise, addDrift)
            if addNoise
                [testCase.SatPositionHistory,NoiseIndices] = introduceNoise(testCase.SatPositionHistory);
            end
            
            if addDrift
                [testCase.SatPositionHistory,DriftIndices] = introduceDrift(testCase.SatPositionHistory);
            end
            
            if addSpikes
                [testCase.SatPositionHistory,SpikesIndices] = introduceSpikes(testCase.SatPositionHistory);
            end
            
            anomalyIndices = interpMethod(testCase.SatPositionHistory,testCase.SatPositionTraining);
            
            if addNoise
                diffs = [true, diff(NoiseIndices) ~= 1, true];
                NoiseIndices = NoiseIndices(diffs(1:end-1) | diffs(2:end));
                testCase.verifyIndicesInAnomalies(NoiseIndices, anomalyIndices, 'Noise Indices');
            end
            
            if addSpikes
                testCase.verifyIndicesInAnomalies(SpikesIndices, anomalyIndices, 'Spike Indices');
            end
            
            if addDrift
                testCase.verifyDriftCapture(DriftIndices, anomalyIndices);
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
        
        function verifyDriftCapture(testCase, indices, anomalyIndices)
            % Helper method to verify that at least 90% of drift anomalies are captured
            capturedAnomalies = sum(indices<anomalyIndices);
            percentageCaptured = capturedAnomalies / length(indices);
            testCase.verifyGreaterThanOrEqual(percentageCaptured, 0.9999, ...
                sprintf('Less than 90%% of anomalies from indices were captured. Captured: %.2f%%', percentageCaptured * 100));
        end
    end
end