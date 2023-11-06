import matplotlib.pyplot as plt
import numpy as np
from scipy.interpolate import make_interp_spline
from math import pi
from datetime import datetime, timedelta


def tle_epoch_to_date(epoch):
    year = int(epoch // 1000) + 2000  
    days_since_start = int(epoch % 1000) - 1 
    date = datetime(year, 1, 1) + timedelta(days=days_since_start)
    return date


def generate_sma_plot(tle_file_path, label):
    with open(tle_file_path, "r") as tle_file:
        tle_lines = tle_file.read().splitlines()

    sma_dict = {}
    for i in range(0, len(tle_lines), 2):
        tle_line1 = tle_lines[i]
        tle_line2 = tle_lines[i + 1]

       
        tle_epoch = float(tle_line1[18:32])
        epoch_date = tle_epoch_to_date(tle_epoch)

        
        mean_motion = float(tle_line2[52:63]) 
        sma = (398600.448 ** (1/3)) / ((2 * mean_motion * pi) / 86400) ** (2/3)

        if epoch_date not in sma_dict:
            sma_dict[epoch_date] = []
        sma_dict[epoch_date].append(sma)

    epochs = list(sma_dict.keys())
    averaged_sma = [np.mean(sma_dict[epoch]) for epoch in epochs]

    # Convert datetime objects to numerical values for numpy.linspace
    x_numerical = [float((epoch - datetime(1970, 1, 1)).total_seconds()) for epoch in epochs]
    x_smooth = np.linspace(min(x_numerical), max(x_numerical), 300)
    spline = make_interp_spline(x_numerical, averaged_sma, k=3)
    sma_smooth = spline(x_smooth)

    # Convert numerical values back to datetime for the x-axis labels
    x_smooth_dates = [datetime(1970, 1, 1) + timedelta(seconds=x) for x in x_smooth]

    plt.plot(x_smooth_dates, sma_smooth, label=label)

# Create a new figure
plt.figure(figsize=(10, 6))

# Generate plots for different TLE files
generate_sma_plot("tle_satellite1.txt", label="KazSTSat")


# Customize the plot
plt.xlabel("Date")
plt.ylabel("Semi-Major Axis (km)")
plt.title("Semi-Major Axis of KazSTSat")
plt.grid(True)

# Add a legend
plt.legend()

# Save or display the plot
plt.savefig("combined_sma_plot.png", format="png", transparent=True)
plt.show()
