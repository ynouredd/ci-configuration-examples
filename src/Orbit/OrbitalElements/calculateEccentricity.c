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

// Function to calculate the cross product of two vectors
void crossProduct(double *vec1, double *vec2, double *result) {
    result[0] = vec1[1] * vec2[2] - vec1[2] * vec2[1];
    result[1] = vec1[2] * vec2[0] - vec1[0] * vec2[2];
    result[2] = vec1[0] * vec2[1] - vec1[1] * vec2[0];
}

// The main function to be called from MATLAB
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    // Check for proper number of arguments
    if (nrhs != 2) {
        mexErrMsgIdAndTxt("MATLAB:calculateEccentricity:nargin", "Two input vectors required.");
    }
    if (nlhs != 1) {
        mexErrMsgIdAndTxt("MATLAB:calculateEccentricity:nargout", "One output required.");
    }

    // Get the position and velocity vectors
    double *position = mxGetPr(prhs[0]);
    double *velocity = mxGetPr(prhs[1]);
    int length = mxGetN(prhs[0]);

    // Ensure the vectors are of the correct length
    if (length != 3) {
        mexErrMsgIdAndTxt("MATLAB:calculateEccentricity:invalidInput", "Input vectors must be of length 3.");
    }

    // Calculate the magnitudes of the position and velocity vectors
    double r = magnitude(position, length);
    double v = magnitude(velocity, length);

    // Calculate the specific angular momentum vector (h = r x v)
    double h[3];
    crossProduct(position, velocity, h);

    // Calculate the magnitude of the specific angular momentum vector
    double h_mag = magnitude(h, length);

    // Calculate the eccentricity vector (e = (v x h)/mu - r/|r|)
    double e_vec[3];
    for (int i = 0; i < length; i++) {
        e_vec[i] = (velocity[(i + 1) % 3] * h[(i + 2) % 3] - velocity[(i + 2) % 3] * h[(i + 1) % 3]) / MU - position[i] / r;
    }

    // Calculate the eccentricity (magnitude of the eccentricity vector)
    double eccentricity = magnitude(e_vec, length);

    // Set the output value
    plhs[0] = mxCreateDoubleScalar(eccentricity);
}