classdef ECCtest < matlab.unittest.TestCase
    % Test class for calculateEccentricity MEX function
    
    properties (TestParameter)
        % Define test parameters
        TestCases = struct( ...
            'CircularOrbit', struct('position', [-2366, 9158, 3234], 'velocity', [-5.711, -2.083, 1.717], 'expectedEcc', 0), ...
            'EllipticalOrbit', struct('position', [-1829, 6997, 2480], 'velocity', [-8.154, -1.969, 2.705], 'expectedEcc', 0.5), ...
            'ParabolicTrajectory', struct('position', [-16614, 65634, 23166], 'velocity', [-3.112, -0.537, 1.081], 'expectedEcc', 1), ...
            'HyperbolicTrajectory', struct('position', [-25258, 99780, 35219], 'velocity', [-3.381, -0.319, 1.241], 'expectedEcc', 2.5) ...
        );
    end
    
    methods (Test, ParameterCombination='sequential',TestTags = {'Unit Test'})
        function testEccentricity(testCase, TestCases)
            % Extract parameters from the test case
            position = TestCases.position;
            velocity = TestCases.velocity;
            expectedEcc = TestCases.expectedEcc;
            
            % Call the MEX function
            calculatedEcc = calculateEccentricity(position, velocity);
            
            % Verify the result
            testCase.verifyEqual(calculatedEcc, expectedEcc, 'AbsTol', 1e-3, ...
                sprintf('Eccentricity test failed for position = [%f, %f, %f], velocity = [%f, %f, %f]', ...
                position(1), position(2), position(3), velocity(1), velocity(2), velocity(3)));
        end
    end
end