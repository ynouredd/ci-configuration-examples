This small project is for detecting anomalies in orbital data. Overall there are 5 anomaly detection techniques and 4 types of anomalies listed below. All detection techniques return the index of the anomalous points as the first output. For convenience a folder titled 'Anomaly Addition' is included to be able to add every type of anomaly easily.

Types of anomalies:

1. Spikes

This is where data spikes significantly for a single data point. Think solar radiation causing a bit flip in data measurements

2. Noise

This is where data spikes significantly, continues a normal, but off set, trajectory for a short period, and then suddenly reverts back to the correct value. Think a sudden and constant interference with the magnetometer used for position measurement that is then removed and the magnetometer reverts to correct measurements again

3. Drift

This is where the data slowly drifts away from the anticipated value. The objective here is to detect the anomaly as soon as possible, as the first few points are normally considered within the range of error measurements. Think a sensor being improperly re-calibrated.

4. Missing data

This is where no data is logged for a period of time, and then continued at a different position in the orbit. Think of a sensor going offline for a short period of time before returning to normal operations.

Anomaly detection techniques:

1. Gradient method

This checks for sudden changes in gradient of the position trajectory to detect anomalies. As a result, this primarily works with anomaly spikes and anomaly noises.

2. Interpolation method

This takes a training set of data (say the previous orbit) and interpolates the orbit to get a smooth spline trajectory from it. It then checks the measured data against the closest interpolated point, any value far off from the spline is marked as an anomaly. This works with spikes, noises and drifts.

3. Moving Window Method

Finds the deviation of the current point from the moving window (preceding x amount of points) if the current point is beyond a predefined threshold, it is marked as an anomaly. This works with spikes and noise data

4. Orbit Parameter method

This uses the orbital parameters to detect anomalies. Ideally all the orbital parameters with the exception of True Anomaly should change, and true anomaly should change in a predictable fashion. Check both semi-major axis and true anomaly ensuring the prior doesn't change significantly, and the rate of change of the latter doesn't change significantly. This works with spikes, noise, missing and drifting data

5. Z Score Method

Uses a One-Class SVM model obtained from training data (say the previous orbit) and checks the distance of every point from the model. Any point too far from it is marked as an anomaly. This works with spikes, noise and drifting data

