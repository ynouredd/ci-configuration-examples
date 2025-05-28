#include "mex.h"
#include <math.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

/* Function to calculate the cross product of two vectors */
void crossProduct(double *a, double *b, double *result) {
    result[0] = a[1] * b[2] - a[2] * b[1];
    result[1] = a[2] * b[0] - a[0] * b[2];
    result[2] = a[0] * b[1] - a[1] * b[0];
}

/* Function to calculate the dot product of two vectors */
double dotProduct(double *a, double *b) {
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
}

/* Function to calculate the magnitude of a vector */
double magnitude(double *a) {
    return sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2]);
}

/* Function to normalize a vector */
void normalize(double *a, double *result) {
    double mag = magnitude(a);
    result[0] = a[0] / mag;
    result[1] = a[1] / mag;
    result[2] = a[2] / mag;
}

/* Function to calculate the angle between two vectors in degrees */
double angleBetweenVectors(double *a, double *b) {
    double dot = dotProduct(a, b);
    double magA = magnitude(a);
    double magB = magnitude(b);
    double angle = acos(dot / (magA * magB)) * (180.0 / M_PI);
    return angle;
}

/* Function to determine the direction of the angle */
double signedAngle(double *a, double *b, double *ref) {
    double angle = angleBetweenVectors(a, b);
    double cross[3];
    crossProduct(a, b, cross);
    double direction = dotProduct(cross, ref);
    if (direction < 0) {
        angle = 360 - angle;
    }
    return angle;
}

/* The gateway function */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    /* Check for proper number of arguments */
    if (nrhs != 2) {
        mexErrMsgIdAndTxt("MATLAB:calculateAOP:invalidNumInputs", "Two inputs required.");
    }
    if (nlhs != 1) {
        mexErrMsgIdAndTxt("MATLAB:calculateAOP:invalidNumOutputs", "One output required.");
    }

    /* Get the input arguments */
    double *position = mxGetPr(prhs[0]);
    double *velocity = mxGetPr(prhs[1]);

    /* Calculate the specific angular momentum vector (h) */
    double h[3];
    crossProduct(position, velocity, h);

    /* Calculate the node vector (n) */
    double k[3] = {0, 0, 1};  // Unit vector along the Z-axis
    double n[3];
    crossProduct(k, h, n);

    /* Normalize the node vector */
    double n_normalized[3];
    normalize(n, n_normalized);

    /* Calculate the eccentricity vector (e) */
    double mu = 398600.4418;  // Standard gravitational parameter for Earth in km^3/s^2
    double r = magnitude(position);
    double v = magnitude(velocity);
    double vr = dotProduct(position, velocity) / r;

    double e[3];
    for (int i = 0; i < 3; i++) {
        e[i] = (1.0 / mu) * ((v * v - mu / r) * position[i] - r * vr * velocity[i]);
    }

    /* Normalize the eccentricity vector */
    double e_normalized[3];
    normalize(e, e_normalized);

    /* Calculate the angle between the node vector and the eccentricity vector */
    double angle = signedAngle(n_normalized, e_normalized, h);

    /* Set the output */
    plhs[0] = mxCreateDoubleScalar(angle);
}