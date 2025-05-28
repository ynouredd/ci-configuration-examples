classdef AOPTest < matlab.unittest.TestCase
    % Test class for calculateAOP MEX function
    
    methods (Test,TestTags = {'Unit Test'})
        function testCircularOrbit(testCase)
            position = [2036, 7730, 1169];
            velocity = [-6.782, 1.777, 3.103];
            expectedAOP = 0;
            
            % Call the MEX function
            calculatedAOP = calculateAOP(position, velocity);
            
            % Verify the result
            testCase.verifyEqual(calculatedAOP, expectedAOP, 'AbsTol', 0.1, ...
                sprintf('AOP test failed for Circular Orbit with position = [%f, %f, %f], velocity = [%f, %f, %f]', ...
                position(1), position(2), position(3), velocity(1), velocity(2), velocity(3)));
        end
        
        function testEllipticalOrbit(testCase)
            position = [-844, 11350, 3211];
            velocity = [-4.847, -1.265, 1.574];
            expectedAOP = 200;
            
            % Call the MEX function
            calculatedAOP = calculateAOP(position, velocity);
            
            % Verify the result
            testCase.verifyEqual(calculatedAOP, expectedAOP, 'AbsTol', 0.1, ...
                sprintf('AOP test failed for Elliptical Orbit with position = [%f, %f, %f], velocity = [%f, %f, %f]', ...
                position(1), position(2), position(3), velocity(1), velocity(2), velocity(3)));
        end
        
        function testInclinedOrbit(testCase)
            position = [2202, 3391, -11109];
            velocity = [2.596, 3.997, 2.204];
            expectedAOP = 90;
            
            % Call the MEX function
            calculatedAOP = calculateAOP(position, velocity);
            
            % Verify the result
            testCase.verifyEqual(calculatedAOP, expectedAOP, 'AbsTol', 0.1, ...
                sprintf('AOP test failed for Inclined Orbit with position = [%f, %f, %f], velocity = [%f, %f, %f]', ...
                position(1), position(2), position(3), velocity(1), velocity(2), velocity(3)));
        end
        
        function testRetrogradeOrbit(testCase)
            position = [-2107, -7595, 1368];
            velocity = [-6.718, 1.209, -3.633];

            expectedAOP = 160;
            
            % Call the MEX function
            calculatedAOP = calculateAOP(position, velocity);
            
            % Verify the result
            testCase.verifyEqual(calculatedAOP, expectedAOP, 'AbsTol', 0.1, ...
                sprintf('AOP test failed for Retrograde Orbit with position = [%f, %f, %f], velocity = [%f, %f, %f]', ...
                position(1), position(2), position(3), velocity(1), velocity(2), velocity(3)));
        end
    end
end