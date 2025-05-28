#include "mex.h"
#include <math.h>

#define MU 398600.4418 // Earth's gravitational parameter in km^3/s^2

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

// Function to calculate the inclination of an orbit
double calculate_inclination(double *r, double *v) {
    // Calculate specific angular momentum vector (h = r x v)
    double h[3];
    h[0] = r[1] * v[2] - r[2] * v[1];
    h[1] = r[2] * v[0] - r[0] * v[2];
    h[2] = r[0] * v[1] - r[1] * v[0];
    
    // Calculate the magnitude of the specific angular momentum vector
    double h_mag = sqrt(h[0] * h[0] + h[1] * h[1] + h[2] * h[2]);
    
    // Calculate the inclination
    double inclination = acos(h[2] / h_mag);
    
    // Convert inclination from radians to degrees
    inclination = inclination * 180.0 / M_PI;
    
    return inclination;
}

// The gateway function
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    // Check for proper number of arguments
    if (nrhs != 2) {
        mexErrMsgIdAndTxt("MATLAB:calculateInc:invalidNumInputs", "Two inputs required (position and velocity vectors).");
    }
    if (nlhs != 1) {
        mexErrMsgIdAndTxt("MATLAB:calculateInc:invalidNumOutputs", "One output required (inclination).");
    }
    
    // Ensure the input arguments are 1x3 vectors
    if (mxGetN(prhs[0]) != 3 || mxGetM(prhs[0]) != 1 || mxGetN(prhs[1]) != 3 || mxGetM(prhs[1]) != 1) {
        mexErrMsgIdAndTxt("MATLAB:calculateInc:invalidInputSize", "Input vectors must be 1x3.");
    }
    
    // Get pointers to the input vectors
    double *r = mxGetPr(prhs[0]);
    double *v = mxGetPr(prhs[1]);
    
    // Create the output matrix
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    
    // Get a pointer to the output data
    double *inclination = mxGetPr(plhs[0]);
    
    // Call the calculation function
    *inclination = calculate_inclination(r, v);
}