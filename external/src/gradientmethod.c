#include "mex.h"
#include <math.h>
#include <stdlib.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    if (nrhs != 1) {
        mexErrMsgIdAndTxt("MATLAB:gradientMethod:invalidNumInputs", "One input required.");
    }
    
    if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0])) {
        mexErrMsgIdAndTxt("MATLAB:gradientMethod:inputNotRealDouble", "Input must be a real double matrix.");
    }
    
    // Create a copy of the input matrix
    mxArray *inputCopy = mxDuplicateArray(prhs[0]);
    double *SatPositionHistory = mxGetPr(inputCopy);
    mwSize numRows = mxGetM(prhs[0]);
    mwSize numCols = mxGetN(prhs[0]);
    
    // Calculate norms
    double *norms = (double *)mxCalloc(numRows, sizeof(double));
    for (mwSize i = 0; i < numRows; i++) {
        double sum = 0.0;
        for (mwSize j = 0; j < numCols; j++) {
            sum += SatPositionHistory[i + j * numRows] * SatPositionHistory[i + j * numRows];
        }
        norms[i] = sqrt(sum);
    }
    
    // Compute gradients
    double *gradients = (double *)mxCalloc(numRows - 1, sizeof(double));
    for (mwSize i = 0; i < numRows - 1; i++) {
        gradients[i] = norms[i + 1] - norms[i];
    }
    
    // Calculate threshold
    double mean = 0.0, stddev = 0.0;
    for (mwSize i = 0; i < numRows - 1; i++) {
        mean += gradients[i];
    }
    mean /= (numRows - 1);
    
    for (mwSize i = 0; i < numRows - 1; i++) {
        stddev += (gradients[i] - mean) * (gradients[i] - mean);
    }
    stddev = sqrt(stddev / (numRows - 2));
    double gradientThreshold = 0.25 * stddev;
    
    // Detect raw anomalies
    mwSize *rawAnomalies = (mwSize *)mxCalloc(numRows - 1, sizeof(mwSize));
    mwSize rawAnomaliesCount = 0;
    for (mwSize i = 0; i < numRows - 1; i++) {
        if (fabs(gradients[i]) > gradientThreshold) {
            rawAnomalies[rawAnomaliesCount++] = i + 1;
        }
    }
    
    // Prepare output
    plhs[0] = mxCreateDoubleMatrix(rawAnomaliesCount, 1, mxREAL);
    double *anomalies = mxGetPr(plhs[0]);
    
    // Process anomalies
    mwSize anomaliesCount = 0;
    for (mwSize i = 0; i < rawAnomaliesCount; i++) {
        mwSize index = rawAnomalies[i];
        
        if (index > 1 && fabs(gradients[index - 1] + gradients[index - 2]) < gradientThreshold) {
            continue;
        }
        
        // Add one to the index when storing it as an anomaly
        anomalies[anomaliesCount++] = (double)(index + 1);
        
        if (index > 2) {
            for (mwSize j = 0; j < numCols; j++) {
                SatPositionHistory[index + j * numRows] = 
                    2 * SatPositionHistory[(index - 1) + j * numRows] - SatPositionHistory[(index - 2) + j * numRows];
            }
        }
    }
    
    // Resize the output array to the actual number of anomalies detected
    if (anomaliesCount < rawAnomaliesCount) {
        mxSetM(plhs[0], anomaliesCount);
    }
    
    // Clean up
    mxFree(norms);
    mxFree(gradients);
    mxFree(rawAnomalies);
    mxDestroyArray(inputCopy); // Clean up the copy
}