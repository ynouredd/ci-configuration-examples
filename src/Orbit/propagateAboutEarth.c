#include "mex.h"
#include <math.h>

// Gravitational constant times the mass of the Earth (in appropriate units)
#define GM 398600.4418 // km^3/s^2

void propagate(double *r, double *v, double dt, double *r_out, double *v_out) {
    double r_mag = sqrt(r[0]*r[0] + r[1]*r[1] + r[2]*r[2]);
    double a[3];

    // Check if r_mag is NaN or zero to avoid division by zero or undefined behavior
    if (isnan(r_mag) || r_mag == 0) {
        mexErrMsgIdAndTxt("MATLAB:propagateAboutEarthject:invalidMagnitude", "Position magnitude is NaN or zero, leading to undefined behavior.");
        return;
    }

    // Calculate acceleration
    for (int i = 0; i < 3; i++) {
        a[i] = -GM * r[i] / (r_mag * r_mag * r_mag);
    }
    
    // Update velocity
    for (int i = 0; i < 3; i++) {
        v_out[i] = v[i] + a[i] * dt;
    }
    
    // Update position
    for (int i = 0; i < 3; i++) {
        r_out[i] = r[i] + v_out[i] * dt;
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    // Check for proper number of arguments
    if (nrhs != 3) {
        mexErrMsgIdAndTxt("MATLAB:propagateAboutEarthject:invalidNumInputs", "Three input arguments required.");
    }
    if (nlhs != 2) {
        mexErrMsgIdAndTxt("MATLAB:propagateAboutEarthject:invalidNumOutputs", "Two output arguments required.");
    }
    
    // Input arguments
    double *r = mxGetPr(prhs[0]);
    double *v = mxGetPr(prhs[1]);
    double dt = mxGetScalar(prhs[2]);
    
    // Output arguments
    plhs[0] = mxCreateDoubleMatrix(3, 1, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(3, 1, mxREAL);
    double *r_out = mxGetPr(plhs[0]);
    double *v_out = mxGetPr(plhs[1]);
    
    // Propagate the object
    propagate(r, v, dt, r_out, v_out);
}