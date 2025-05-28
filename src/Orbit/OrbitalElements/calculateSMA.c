#include "mex.h"
#include <math.h>

#define MU 398600.4418 // Standard gravitational parameter for Earth in km^3/s^2

// Function to calculate the dot product of two vectors
double dotProduct(double *vec1, double *vec2, int length) {
    double result = 0.0;
    for (int i = 0; i < length; i++) {
        result += vec1[i] * vec2[i];
    }
    return result;
}

// Function to calculate the magnitude of a vector
double magnitude(double *vec, int length) {
    return sqrt(dotProduct(vec, vec, length));
}

// The main function to be called from MATLAB
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    // Check for proper number of arguments
    if (nrhs != 2) {
        mexErrMsgIdAndTxt("MATLAB:calculateSMA:nargin", "Two input vectors required.");
    }
    if (nlhs != 1) {
        mexErrMsgIdAndTxt("MATLAB:calculateSMA:nargout", "One output required.");
    }

    // Get the position and velocity vectors
    double *position = mxGetPr(prhs[0]);
    double *velocity = mxGetPr(prhs[1]);
    int length = mxGetN(prhs[0]);

    // Ensure the vectors are of the correct length
    if (length != 3) {
        mexErrMsgIdAndTxt("MATLAB:calculateSMA:invalidInput", "Input vectors must be of length 3.");
    }

    // Calculate the magnitudes of the position and velocity vectors
    double r = magnitude(position, length);
    double v = magnitude(velocity, length);

    // Calculate the specific orbital energy
    double specificOrbitalEnergy = (v * v) / 2 - MU / r;

    // Calculate the semi-major axis
    double semiMajorAxis = -MU / (2 * specificOrbitalEnergy);

    // Set the output value
    plhs[0] = mxCreateDoubleScalar(semiMajorAxis);
}