#include "mex.h"
#include <math.h>

#define MU 398600.4418 // Earth's gravitational parameter in km^3/s^2
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

// Function to calculate the RAAN of an orbit
double calculate_raan(double *r, double *v) {
    // Calculate specific angular momentum vector (h = r x v)
    double h[3];
    h[0] = r[1] * v[2] - r[2] * v[1];
    h[1] = r[2] * v[0] - r[0] * v[2];
    h[2] = r[0] * v[1] - r[1] * v[0];
    
    // Calculate the magnitude of the specific angular momentum vector
    double h_mag = sqrt(h[0] * h[0] + h[1] * h[1] + h[2] * h[2]);
    
    // Calculate the node vector (n = k x h, where k is the unit vector in z-direction)
    double n[3];
    n[0] = -h[1];
    n[1] = h[0];
    n[2] = 0.0;
    
    // Calculate the magnitude of the node vector
    double n_mag = sqrt(n[0] * n[0] + n[1] * n[1]);
    
    // Calculate the RAAN
    double raan = acos(n[0] / n_mag);
    
    // Adjust RAAN based on the sign of n[1]
    if (n[1] < 0) {
        raan = 2 * M_PI - raan;
    }
    
    // Convert RAAN from radians to degrees
    raan = raan * 180.0 / M_PI;
    
    return raan;
}

// The gateway function
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    // Check for proper number of arguments
    if (nrhs != 2) {
        mexErrMsgIdAndTxt("MATLAB:calculateRAAN:invalidNumInputs", "Two inputs required (position and velocity vectors).");
    }
    if (nlhs != 1) {
        mexErrMsgIdAndTxt("MATLAB:calculateRAAN:invalidNumOutputs", "One output required (RAAN).");
    }
    
    // Ensure the input arguments are 1x3 vectors
    if (mxGetN(prhs[0]) != 3 || mxGetM(prhs[0]) != 1 || mxGetN(prhs[1]) != 3 || mxGetM(prhs[1]) != 1) {
        mexErrMsgIdAndTxt("MATLAB:calculateRAAN:invalidInputSize", "Input vectors must be 1x3.");
    }
    
    // Get pointers to the input vectors
    double *r = mxGetPr(prhs[0]);
    double *v = mxGetPr(prhs[1]);
    
    // Create the output matrix
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    
    // Get a pointer to the output data
    double *raan = mxGetPr(plhs[0]);
    
    // Call the calculation function
    *raan = calculate_raan(r, v);
}