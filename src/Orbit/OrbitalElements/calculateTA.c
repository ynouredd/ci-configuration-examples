#include "mex.h"
#include <math.h>

#define PI 3.14159265358979323846

void calculateTA(double *r, double *v, double *true_anomaly) {
    // Calculate the magnitude of the position vector
    double r_mag = sqrt(r[0]*r[0] + r[1]*r[1] + r[2]*r[2]);
    
    // Calculate the magnitude of the velocity vector
    double v_mag = sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
    
    // Calculate the specific angular momentum vector
    double h[3] = {
        r[1]*v[2] - r[2]*v[1],
        r[2]*v[0] - r[0]*v[2],
        r[0]*v[1] - r[1]*v[0]
    };
    
    // Calculate the magnitude of the specific angular momentum vector
    double h_mag = sqrt(h[0]*h[0] + h[1]*h[1] + h[2]*h[2]);
    
    // Calculate the eccentricity vector
    double mu = 398600.4418; // Earth's gravitational parameter in km^3/s^2
    double e[3] = {
        (1.0/mu) * ((v_mag*v_mag - mu/r_mag)*r[0] - (r[0]*v[0] + r[1]*v[1] + r[2]*v[2])*v[0]),
        (1.0/mu) * ((v_mag*v_mag - mu/r_mag)*r[1] - (r[0]*v[0] + r[1]*v[1] + r[2]*v[2])*v[1]),
        (1.0/mu) * ((v_mag*v_mag - mu/r_mag)*r[2] - (r[0]*v[0] + r[1]*v[1] + r[2]*v[2])*v[2])
    };
    
    // Calculate the magnitude of the eccentricity vector
    double e_mag = sqrt(e[0]*e[0] + e[1]*e[1] + e[2]*e[2]);
    
    // Calculate the true anomaly
    double dot_product = (r[0]*e[0] + r[1]*e[1] + r[2]*e[2]) / (r_mag * e_mag);
    double theta = acos(dot_product);
    
    // Determine if the true anomaly should be greater than 180 degrees
    if (r[0]*v[0] + r[1]*v[1] + r[2]*v[2] < 0) {
        theta = 2 * PI - theta;
    }
    
    // Convert true anomaly to degrees
    *true_anomaly = theta * (180.0 / PI);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    if (nrhs != 2) {
        mexErrMsgIdAndTxt("calculateTA:invalidNumInputs", "Two input arguments required.");
    }
    if (nlhs != 1) {
        mexErrMsgIdAndTxt("calculateTA:invalidNumOutputs", "One output argument required.");
    }
    
    double *position = mxGetPr(prhs[0]);
    double *velocity = mxGetPr(prhs[1]);
    
    if (mxGetN(prhs[0]) != 3 || mxGetM(prhs[0]) != 1) {
        mexErrMsgIdAndTxt("calculateTA:invalidInput", "Position must be a 1x3 vector.");
    }
    if (mxGetN(prhs[1]) != 3 || mxGetM(prhs[1]) != 1) {
        mexErrMsgIdAndTxt("calculateTA:invalidInput", "Velocity must be a 1x3 vector.");
    }
    
    plhs[0] = mxCreateDoubleScalar(mxREAL);
    double *true_anomaly = mxGetPr(plhs[0]);
    
    calculateTA(position, velocity, true_anomaly);
}