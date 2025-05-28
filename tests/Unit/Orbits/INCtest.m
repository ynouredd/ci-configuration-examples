classdef INCtest < matlab.unittest.TestCase
    methods (Test,TestTags = {'Unit Test'})
        function testNominalCase(testCase)
            % Nominal Case
            position = [7000, 0, 0]; % km
            velocity = [0, 7.5, 0]; % km/s
            expectedInc = 0; % Expected inclination for this case
            actualInc = calculateInc(position, velocity);
            testCase.verifyEqual(actualInc, expectedInc, 'AbsTol', 1e-2);
        end

        function test3DOrbit(testCase)
            % Zero Velocity
            position = [7000, 1000, 500]; % km
            velocity = [1.3, -7.5, 3]; % km/s
            expectedInc = 158.2718;
            actualInc = calculateInc(position, velocity);
            testCase.verifyEqual(actualInc, expectedInc, 'AbsTol', 1e-2);
        end
        
        
        function testInclinedOrbit(testCase)
            % Inclined Orbit
            position = [7000, 0, 0]; % km
            velocity = [0, 5.3, 5.3]; % km/s
            expectedInc = 45; % Expected inclination in degrees
            actualInc = calculateInc(position, velocity);
            testCase.verifyEqual(actualInc, expectedInc, 'AbsTol', 1e-2);
        end
        
        function testPolarOrbit(testCase)
            % Polar Orbit
            position = [0, 7000, 0]; % km
            velocity = [0, 0, 7.5]; % km/s
            expectedInc = 90; % Expected inclination for polar orbit
            actualInc = calculateInc(position, velocity);
            testCase.verifyEqual(actualInc, expectedInc, 'AbsTol', 1e-2);
        end
        
        function testRetrogradeOrbit(testCase)
            % Retrograde Orbit
            position = [-7000, 0, 0]; % km
            velocity = [0, -7.5, 0]; % km/s
            expectedInc = 0; % Expected inclination for retrograde orbit
            actualInc = calculateInc(position, velocity);
            testCase.verifyEqual(actualInc, expectedInc, 'AbsTol', 1e-2);
        end
        
        function testZeroPosition(testCase)
            % Zero Position
            position = [0, 0, 0]; % km
            velocity = [0, 7.5, 0]; % km/s
            expectedInc = NaN; % Expected inclination for invalid orbit
            actualInc = calculateInc(position, velocity);
            testCase.verifyEqual(actualInc, expectedInc, 'AbsTol', 1e-2);
        end
        
        function testZeroVelocity(testCase)
            % Zero Velocity
            position = [7000, 0, 0]; % km
            velocity = [0, 0, 0]; % km/s
            expectedInc = NaN;
            actualInc = calculateInc(position, velocity); % Stationary satellite
            testCase.verifyEqual(actualInc, expectedInc, 'AbsTol', 1e-2);
        end
               
    end
end