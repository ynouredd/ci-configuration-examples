#include "mex.h"
#include <math.h>

#define G 6.67430e-11   // Gravitational constant (m^3 kg^-1 s^-1)
#define M 5.972e24      // Mass of the Earth (kg)
#define PI 3.141592653589793
#define KM_TO_M 1000    // Conversion factor from km to m

// Function to calculate the orbital period
double calculate_period(double semi_major_axis) {
    return 2 * PI * sqrt(pow(semi_major_axis, 3) / (G * M));
}

// The gateway function
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    double semi_major_axis;
    double *output;
    mxArray *lhs[1], *rhs[2];

    // Check for proper number of arguments
    if (nrhs != 2) {
        mexErrMsgIdAndTxt("CalculatePeriod:invalidNumInputs", "Two inputs required: position and velocity.");
    }
    if (nlhs > 1) {
        mexErrMsgIdAndTxt("CalculatePeriod:invalidNumOutputs", "One output allowed.");
    }

    // Ensure the inputs are vectors of the same length
    if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || mxGetNumberOfElements(prhs[0]) != 3 ||
        !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) || mxGetNumberOfElements(prhs[1]) != 3) {
        mexErrMsgIdAndTxt("CalculatePeriod:inputNotRealVector", "Inputs must be noncomplex double vectors of length 3.");
    }

    // Prepare arguments for calling calculateSMA
    rhs[0] = prhs[0];  // Position vector
    rhs[1] = prhs[1];  // Velocity vector

    // Call calculateSMA
    if (mexCallMATLAB(1, lhs, 2, rhs, "calculateSMA") != 0) {
        mexErrMsgIdAndTxt("CalculatePeriod:calculateSMACallFailed", "Failed to call calculateSMA.");
    }

    // Get the semi-major axis from the output of calculateSMA
    semi_major_axis = mxGetScalar(lhs[0]) * KM_TO_M;  // Convert from km to m

    // Create the output matrix
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);

    // Get a pointer to the real data in the output matrix
    output = mxGetPr(plhs[0]);

    // Call the computational routine
    output[0] = calculate_period(semi_major_axis);
}