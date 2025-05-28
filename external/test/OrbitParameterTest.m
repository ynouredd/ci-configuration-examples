classdef OrbitParameterTest < matlab.unittest.TestCase
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
        addMissing = {true, false};
    end
    
    methods (TestClassSetup)
        function createTestData(testCase)
            rng('default');
            load("satellite1data.mat","satPosition","satVelocity")
            testCase.SatPositionHistory = satPosition;
            testCase.SatVelocityHistory = satVelocity;
        end
    end
    
    methods (Test)
        function testAnomalyDetector(testCase, addSpikes, addNoise, addDrift, addMissing)
            if addDrift
                [testCase.SatPositionHistory,DriftIndices] = introduceDrift(testCase.SatPositionHistory);
            end
            
            if addNoise
                [testCase.SatPositionHistory,NoiseIndices] = introduceNoise(testCase.SatPositionHistory);
            end
            
            if addSpikes
                [testCase.SatPositionHistory,SpikesIndices] = introduceSpikes(testCase.SatPositionHistory);
            end
            
            if addMissing
                [testCase.SatPositionHistory,testCase.SatVelocityHistory,MissingIndices] = introduceMissingData(testCase.SatPositionHistory, testCase.SatVelocityHistory);
            end
            
            SMA = zeros(1,length(testCase.SatPositionHistory));
            TA = zeros(1,length(testCase.SatPositionHistory));
            
            for i = 1:length(testCase.SatPositionHistory)
                [SMA(i),TA(i)] = calcSMATA(testCase.SatPositionHistory(i,:),testCase.SatVelocityHistory(i,:));
            end
            
            anomalyIndices = OrbitParameterMethod(SMA, TA);
            
            if addDrift
                testCase.verifyDriftCapture(DriftIndices, anomalyIndices);
            end
            if addNoise
                testCase.verifyIndicesInAnomalies(NoiseIndices, anomalyIndices, 'Noise Indices');
            end
            if addSpikes
                testCase.verifyIndicesInAnomalies(SpikesIndices, anomalyIndices, 'Spike Indices');
            end
            
            if addMissing
                testCase.verifyIndicesInAnomalies(MissingIndices, anomalyIndices, 'Missing Indices');
            end            
        end
    end
    
    methods
        function verifyIndicesInAnomalies(testCase, indices, anomalyIndices, indicesName)
            % Helper method to verify that each index is in anomalyIndices
            for i = 1:length(indices)
                testCase.verifyTrue(ismember(indices(i), anomalyIndices), ...
                    sprintf('Anomaly index %d from %s not found in anomalyIndices.', indices(i), indicesName));
            end
        end
        
        function verifyDriftCapture(testCase, indices, anomalyIndices)
            % Helper method to verify that at least 90% of drift anomalies are captured
            capturedAnomalies = sum(indices<anomalyIndices);
            percentageCaptured = capturedAnomalies / length(indices);
            testCase.verifyGreaterThanOrEqual(percentageCaptured, 0.9, ...
                sprintf('Less than 90%% of anomalies from indices were captured. Captured: %.2f%%', percentageCaptured * 100));
        end
    end
end