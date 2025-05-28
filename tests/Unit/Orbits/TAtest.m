classdef TAtest < matlab.unittest.TestCase
    % Test class for calculateTA MEX function
    
    methods (Test,TestTags = {'Unit Test'})
        function testShallowEllipticalOrbit(testCase)
            position = [6577,5842, 2052];
            velocity = [-4.606, 4.633, 2.389];
            expectedTA = 17; % Assuming true anomaly is 0 degrees for this case
            
            % Call the MEX function
            calculatedTA = calculateTA(position, velocity);
            
            % Verify the result
            testCase.verifyEqual(calculatedTA, expectedTA, 'AbsTol', 0.1, ...
                sprintf('TA test failed for Circular Orbit with position = [%f, %f, %f], velocity = [%f, %f, %f]', ...
                position(1), position(2), position(3), velocity(1), velocity(2), velocity(3)));
        end
        
        function testSteepEllipticalOrbit(testCase)
            position = [-1932, 9584, 4352];
            velocity = [-7.180, 2.082, 1.471];
            expectedTA = 75; % Assuming true anomaly is 0 degrees for this case
            
            % Call the MEX function
            calculatedTA = calculateTA(position, velocity);
            
            % Verify the result
            testCase.verifyEqual(calculatedTA, expectedTA, 'AbsTol', 0.1, ...
                sprintf('TA test failed for Elliptical Orbit with position = [%f, %f, %f], velocity = [%f, %f, %f]', ...
                position(1), position(2), position(3), velocity(1), velocity(2), velocity(3)));
        end
    end
end