classdef OrbitalParameterTest < matlab.unittest.TestCase
    
    properties (TestParameter)
        Pos = {[20000 600000 143000],[2000 60000 14300],[1000 30000 500]};
        Vel = {[-0.7 -0.1 0.1],[-3 -0.1 0.1],[5.1 0 0]};
        Trajectory = {"Trajectory1","Trajectory2","Trajectory3"}
    end
    
    methods (Test, ParameterCombination = 'sequential',TestTags = {'Long Duration'})
        % Test methods
        
        function OrbitParameterFluctuationTest(testCase,Pos,Vel,Trajectory)
            %% Initialize scenario
            timeStart = [2024 1 1 0 0 0];
            timeEnd = [2024 3 1 0 0 0];
            SecondsToPropagate = seconds(datetime(timeEnd)-datetime(timeStart));
            
            InitialPeriod = calculatePeriod(Pos,Vel);
            
            % Propagate satellite over sim time and account for Lunar Gravity
            [SatPositionHistory,SatVelocityHistory] = PropSat(Pos,Vel,SecondsToPropagate,timeStart,1,0);
            
            % Assuming SatVelocityHistory and SatPositionHistory are matrices
            % with the same number of rows
            numEntries = length(SatVelocityHistory);
            
            % Preallocate arrays for the orbital elements
            SMA = zeros(1, numEntries);
            ECC = zeros(1, numEntries);
            INC = zeros(1, numEntries);
            RAAN = zeros(1, numEntries);
            AOP = zeros(1, numEntries);
            TA = zeros(1, numEntries);
            
            % Loop through each entry to calculate orbital elements
            for i = 1:numEntries
                [SMA(i), ECC(i), INC(i), RAAN(i), AOP(i), TA(i)] = findOrbitalElements(SatPositionHistory(i, :), SatVelocityHistory(i, :));
            end
            FinalPeriod = calculatePeriod(SatPositionHistory(end, :),SatVelocityHistory(end, :));
            load(Trajectory,"-regexp","^exp")
            
            % List of variable names to verify
            variables = {'AOP', 'ECC', 'RAAN', 'SMA', 'TA', 'INC'};
            
            % For loop to verify each variable
            for i = 1:length(variables)
                varName = variables{i};
                reducedVar = eval([varName, '(1:1000:end)']);
                expVar = eval(['exp', varName]);
                
                % Verify each reduced variable against the expected one
                verifyEqual(testCase, reducedVar, expVar, 'AbsTol', 1e-6, ...
                    ['Mismatch in ', varName]);
            end
            
            verifyEqual(testCase, FinalPeriod, expFinPeriod, 'AbsTol', 1e-6,'Mismatch in FinPeriod');
            verifyEqual(testCase, InitialPeriod, expInitPeriod, 'AbsTol', 1e-6, 'Mismatch in InitPeriod');
        end
    end
    
end