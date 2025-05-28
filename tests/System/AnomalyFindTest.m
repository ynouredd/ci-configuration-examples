classdef AnomalyFindTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        InitialSatPosition = {[7543, 11760, 515],[2000, 3000, 7200]};
        InitialSatVelocity = {[-3.211, 0.459, 4.643],[4, 8.2, 3]};
        numStages = {3,2};
        dryMasses = {[25000, 5000, 1000],[23000, 500]}; % kg
        wetMasses = {[50000, 20000, 4000],[50000, 18000]}; % kg
        ISPs = {[300, 350, 400],[330, 380]}; % seconds
        SafetyMargin = {15,30}; % 10% buffer
        latitude = {30,60}; % 5 degrees North
        
        expReqDV = {11.26,14.12};
        expTotalDV = {12.24,15.87}
    end
    
    methods (Test, ParameterCombination = 'sequential')
        function movingWindowAnomaly(testCase,InitialSatPosition,InitialSatVelocity,numStages, dryMasses, wetMasses, ISPs, SafetyMargin, latitude,expReqDV,expTotalDV)
            StartDate = [2024 1 1 0 0 0];
            SecondsToPropagate = 100000;
            
            totalDeltaV = AvailableDeltaV(numStages, dryMasses, wetMasses, ISPs);
            reqDeltaV = RequiredDeltaV(InitialSatPosition, InitialSatVelocity, SafetyMargin, latitude);
            
            verifyEqual(testCase, totalDeltaV, expTotalDV, 'AbsTol', 0.1,'Mismatch in total delta V generetable');
            verifyEqual(testCase, reqDeltaV, expReqDV, 'AbsTol', 0.1,'Mismatch in total delta V required');
            verifyTrue(testCase, reqDeltaV<totalDeltaV, 'DeltaV insufficient for test');
            
            [SatPositionHistory,~] = PropSat(InitialSatPosition,InitialSatVelocity,SecondsToPropagate,StartDate,0,0);
            SatPositionTraining = SatPositionHistory;
            
            % Simulate different kind of anomalous data in position history
            [SatPositionHistory,SpikeIndex] = introduceSpikes(SatPositionHistory);
            [SatPositionHistory,NoiseIndex] = introduceNoise(SatPositionHistory);
            [SatPositionHistory,DriftIndex] = introduceDrift(SatPositionHistory);
            
            anomalyIndices = interpMethod(SatPositionHistory,SatPositionTraining);
            
            diffs = [true, diff(NoiseIndex) ~= 1, true];
            NoiseIndex = NoiseIndex(diffs(1:end-1) | diffs(2:end));
            testCase.verifyIndicesInAnomalies(NoiseIndex, anomalyIndices, 'Noise Indices');
            
            testCase.verifyIndicesInAnomalies(SpikeIndex, anomalyIndices, 'Spike Indices');
            
            testCase.verifyDriftCapture(DriftIndex, anomalyIndices);
        end
    end

    methods (Test, ParameterCombination = 'sequential', TestTags = {'GradientMethod'})        
        function gradientMethodAnomaly(testCase,InitialSatPosition,InitialSatVelocity,numStages, dryMasses, wetMasses, ISPs, SafetyMargin, latitude,expReqDV,expTotalDV)
            StartDate = [2024 1 1 0 0 0];
            SecondsToPropagate = 100000;
            
            totalDeltaV = AvailableDeltaV(numStages, dryMasses, wetMasses, ISPs);
            reqDeltaV = RequiredDeltaV(InitialSatPosition, InitialSatVelocity, SafetyMargin, latitude);
            
            verifyEqual(testCase, totalDeltaV, expTotalDV, 'AbsTol', 0.1,'Mismatch in total delta V generetable');
            verifyEqual(testCase, reqDeltaV, expReqDV, 'AbsTol', 0.1,'Mismatch in total delta V required');
            verifyTrue(testCase, reqDeltaV<totalDeltaV, 'DeltaV insufficient for test');
            
            [SatPositionHistory,~] = PropSat(InitialSatPosition,InitialSatVelocity,SecondsToPropagate,StartDate,0,0);
            
            % Simulate different kind of anomalous data in position history
            [SatPositionHistory,SpikeIndex] = introduceSpikes(SatPositionHistory);
            [SatPositionHistory,NoiseIndex] = introduceNoise(SatPositionHistory);
            
            anomalyIndices = gradientmethod(SatPositionHistory);
            
            diffs = [true, diff(NoiseIndex) ~= 1, true];
            NoiseIndex = NoiseIndex(diffs(1:end-1) | diffs(2:end));
            testCase.verifyIndicesInAnomalies(NoiseIndex, anomalyIndices, 'Noise Indices');
            testCase.verifyIndicesInAnomalies(SpikeIndex, anomalyIndices, 'Spike Indices');            
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