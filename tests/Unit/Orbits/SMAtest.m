classdef SMAtest < matlab.unittest.TestCase
    methods (Test,TestTags = {'Unit Test'})
        function testNominalCase(testCase)
            % Nominal Case
            position = [7000, 0, 0]; % km
            velocity = [0, 7.5, 0]; % km/s
            expectedSMA = 6.9158e+03; % Example expected value
            actualSMA = calculateSMA(position, velocity);
            testCase.verifyEqual(actualSMA, expectedSMA, 'RelTol', 1e-2);
        end
        
        function testZeroVelocity(testCase)
            % Zero Velocity
            position = [7000, 0, 0]; % km
            velocity = [0, 0, 0]; % km/s
            expectedSMA = 3500; % Hypothetical expectation for zero velocity
            actualSMA = calculateSMA(position, velocity);
            testCase.verifyEqual(actualSMA, expectedSMA);
        end
        
        function testZeroPosition(testCase)
            % Zero Position
            position = [0, 0, 0]; % km
            velocity = [0, 7.5, 0]; % km/s
            expectedSMA = 0; % Hypothetical expectation for zero position
            actualSMA = calculateSMA(position, velocity);
            testCase.verifyEqual(actualSMA, expectedSMA);
        end
        
        function testNegativeValues(testCase)
            % Negative Position or Velocity
            position = [-7000, 0, 0]; % km
            velocity = [0, -7.5, 0]; % km/s
            expectedSMA = 6.9158e+03; % Example expected value
            actualSMA = calculateSMA(position, velocity);
            testCase.verifyEqual(actualSMA, expectedSMA, 'RelTol', 1e-2);
        end
        
        function testHyperbolicTrajectory(testCase)
            % Very Large Values
            position = [1e9, 0, 0]; % km
            velocity = [0, 1e5, 0]; % km/s
            % Example expected value (this needs to be calculated correctly)
            expectedSMA = -3.9860e-05; 
            actualSMA = calculateSMA(position, velocity);
            testCase.verifyEqual(actualSMA, expectedSMA, 'RelTol', 1e-2);
        end
        
        function testCircularOrbit(testCase)
            % Circular Orbit
            position = [7000, 0, 0]; % km
            velocity = [0, 7.546, 0]; % km/s
            expectedSMA = 7000; % Example expected value for circular orbit
            actualSMA = calculateSMA(position, velocity);
            testCase.verifyEqual(actualSMA, expectedSMA, 'RelTol', 1e-2);
        end
        
        function testInvalidInputs(testCase)
            % Invalid Inputs
            position = 'invalid'; % Non-numeric input
            velocity = [0, 7.5, 0]; % km/s
            testCase.verifyError(@() calculateSMA(position, velocity), 'MATLAB:calculateSMA:nargout');
        end
    end
end