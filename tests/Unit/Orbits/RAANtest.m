classdef RAANtest < matlab.unittest.TestCase
    % Test class for calculateRAAN MEX function
    
    methods (Test,TestTags = {'Unit Test'})       
        function testPolarOrbit(testCase)
            position = [1486, 4082, 8156];
            velocity = [-1.980, -5.441, 3.588];
            expectedRAAN = 70;
            
            % Call the MEX function
            calculatedRAAN = calculateRAAN(position, velocity);
            
            % Verify the result
            testCase.verifyEqual(calculatedRAAN, expectedRAAN, 'AbsTol', 0.1, ...
                sprintf('RAAN test failed for Polar Orbit with position = [%f, %f, %f], velocity = [%f, %f, %f]', ...
                position(1), position(2), position(3), velocity(1), velocity(2), velocity(3)));
        end
        
        function testInclinedOrbit(testCase)
            position = [-3.936, 6.053, 5.767];
            velocity = [-4.364, -4.574, 2.537];
            expectedRAAN = 70;
            
            % Call the MEX function
            calculatedRAAN = calculateRAAN(position, velocity);
            
            % Verify the result
            testCase.verifyEqual(calculatedRAAN, expectedRAAN, 'AbsTol', 0.1, ...
                sprintf('RAAN test failed for Inclined Orbit with position = [%f, %f, %f], velocity = [%f, %f, %f]', ...
                position(1), position(2), position(3), velocity(1), velocity(2), velocity(3)));
        end
        
        function testRetrogradeOrbit(testCase)
            position = [5827, 5438, 4677];
            velocity = [3.901, -5.192, 2.059];
            expectedRAAN = 100;
            
            % Call the MEX function
            calculatedRAAN = calculateRAAN(position, velocity);
            
            % Verify the result
            testCase.verifyEqual(calculatedRAAN, expectedRAAN, 'AbsTol', 0.1, ...
                sprintf('RAAN test failed for Retrograde Orbit with position = [%f, %f, %f], velocity = [%f, %f, %f]', ...
                position(1), position(2), position(3), velocity(1), velocity(2), velocity(3)));
        end
        
        function testHyperbolicOrbit(testCase)
            position = [17112, -12901, 12586];
            velocity = [-1.835, -6.020, 3.522];
            expectedRAAN = 20; % Assuming the expected RAAN is 123 degrees for this case
            
            % Call the MEX function
            calculatedRAAN = calculateRAAN(position, velocity);
            
            % Verify the result
            testCase.verifyEqual(calculatedRAAN, expectedRAAN, 'AbsTol', 0.1, ...
                sprintf('RAAN test failed for Hyperbolic Orbit with position = [%f, %f, %f], velocity = [%f, %f, %f]', ...
                position(1), position(2), position(3), velocity(1), velocity(2), velocity(3)));
        end
    end
end