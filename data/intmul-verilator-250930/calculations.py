import sys
import numpy as np
from utils import printd
# We need to import the clustering tools
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score

def _calculate_percent_drop(original, new):
    """Internal helper to calculate percentage drop, handling division by zero."""
    if original == 0:
        return 0.0
    
    # Calculate the percentage drop
    drop = original - new
    percent_drop = (drop / original) * 100
    return percent_drop

def _min_only(data):
    min_x         = min(data)

    # Define outlier bounds
    lower_bound = min_x
    upper_bound = min_x

    # Filter the data
    filtered_data = [x for x in data if lower_bound <= x <= upper_bound]

# If filtering somehow removes all data, return the original to be safe
    if not filtered_data:
        return data

    return filtered_data

def _no_filter(data):
    filtered_data = [x for x in data]
    return filtered_data

def _filter_outliers_iqr(data):
    """Filters outliers from a list of data using the IQR method."""
    # A dataset needs at least a few points to calculate IQR meaningfully
    if len(data) < 4:
        return data

    data_array = np.array(data)

    # Calculate quartiles
    q1 = np.percentile(data_array, 25)
    q3 = np.percentile(data_array, 75)
    iqr = q3 - q1

    # Define outlier bounds
    lower_bound = q1 - (1.5 * iqr)
    upper_bound = q3 + (1.5 * iqr)

    # Filter the data
    filtered_data = [x for x in data if lower_bound <= x <= upper_bound]

    # If filtering somehow removes all data, return the original to be safe
    if not filtered_data:
        return data

    return filtered_data

def _isolate_first_cluster(data):
    """
    Identifies clusters in the data and returns only the points belonging
    to the cluster with the lowest mean (the first peak).
    Uses a smarter filtering method to isolate the primary execution peak.
    
    This is a targeted filtering method to remove noise and interrupt-induced peaks.
    """
    # Reshape data for sklearn clustering
    data_array = np.array(data).reshape(-1, 1)

    # Cannot cluster if there are too few unique data points.
    # In this case, we fall back to a simple min-based filter.
    if len(np.unique(data_array)) < 2:
        min_val = data_array.min()
        return [x for x in data if x == min_val]

    # --- Find the Optimal Number of Clusters (k) ---
    best_score = -1
    optimal_k = 1 # Default to 1 cluster if no better option is found
    
    # We test for a small number of clusters (2 to 5 is usually sufficient)
    for k in range(2, 6):
        if k >= len(np.unique(data_array)):
            break
        
        kmeans = KMeans(n_clusters=k, random_state=42, n_init='auto').fit(data_array)
        score = silhouette_score(data_array, kmeans.labels_)
        
        if score > best_score:
            best_score = score
            optimal_k = k

    # If the best we can do is 1 cluster, just return the original data
    if optimal_k == 1:
        return data

    # --- Isolate the First Cluster using the Optimal k ---
    kmeans = KMeans(n_clusters=optimal_k, random_state=42, n_init='auto').fit(data_array)
    
    # Find the cluster with the lowest execution time centroid
    centroids = kmeans.cluster_centers_.flatten()
    first_cluster_index = np.argmin(centroids)
#    printd(str(centroids),level="warning") 
    # Return only the data points that belong to that first cluster
    filtered_data = data_array[kmeans.labels_ == first_cluster_index]
    
    return filtered_data.flatten().tolist()

# --- _estimate_interrupt_latency is currently UNUSED 
def _estimate_interrupt_latency(data_array):
    """
    Finds the optimal number of clusters (k) using silhouette scores and
    calculates the interrupt latency as the difference between the first
    two cluster centroids.
    
    Args:
        data_array (np.array): The array of cycle counts.

    Returns:
        int or None: The estimated interrupt latency, or None if it cannot be determined.
    """
    # Reshape data for sklearn
    data_reshaped = data_array.reshape(-1, 1)
    
    best_score = -1.0
    optimal_k = -1
    
    # Test for a small number of clusters (e.g., 2 to 5)
    for k in range(2, 6):
        # We can't have more clusters than unique data points
        if k >= len(np.unique(data_reshaped)):
            break
            
        kmeans = KMeans(n_clusters=k, random_state=42, n_init='auto').fit(data_reshaped)
        score = silhouette_score(data_reshaped, kmeans.labels_)
        
        if score > best_score:
            best_score = score
            optimal_k = k
            
    # If we couldn't find a reasonable clustering (e.g., k > 1), we can't estimate.
    if optimal_k < 2:
        return None
        
    # Now, run KMeans one last time with the best k found
    kmeans = KMeans(n_clusters=optimal_k, random_state=42, n_init='auto').fit(data_reshaped)
    
    # Get the cluster centers and sort them
    centroids = np.sort(kmeans.cluster_centers_.flatten())
    
    # We need at least two centroids to calculate a difference
    if len(centroids) < 2:
        return None
        
    # The first interrupt latency is the difference between the two lowest-time states
    latency = centroids[1] - centroids[0]
    
    return int(latency)


def calculate_stats(cycles_list, limb_size):
    """
    Performs comprehensive statistical analysis, including interrupt latency estimation.

    Args:
        cycles_list (list): The raw list of cycle counts.
        limb_size (int): The number of limbs for this data set.

    Returns:
        dict: A dictionary containing all calculated metrics.
    """
    if not cycles_list:
        return None

    # --- 1. Original Data ---
    original_data = np.array(cycles_list)

    # --- Estimate Interrupt Latency ---
    # We only attempt this for "medium" limb sizes where clustering is meaningful.
    interrupt_latency = None
    # UNUSED : This will estiamte the first interrupt latency. Uncomment this part to get non-zero estimate.
#    if limb_size > 20:
#        interrupt_latency = _estimate_interrupt_latency(original_data)

    original_avg = int(original_data.mean())
    original_rmse = int(original_data.std())
    original_max = original_data.max()

    filtered_data_list = None
    # --- 2. Apply filtering ---

# OPTION A : IQR + k-means clustering
    # First, filter out the outrageous outliers (e.g. those with long interrupt delays
    pre_filtered_data_list = _filter_outliers_iqr(original_data.tolist())
    # Now, apply k-means clustering to find the first cluster (i.e. most noise-free data).
    # Discard the other clusters (i.e. noisy data) from analysis.
    filtered_data_list = _isolate_first_cluster(pre_filtered_data_list)

    # Uncomment lines below to Try other options.
#  OPTION B:  filtered_data_list = _no_filter(original_data.tolist())
#  OPTION C:  filtered_data_list = _min_only(original_data.tolist())

    if not filtered_data_list:
        printd("No filtered data was found. Have you selected a valid filtering criteria?", level='error')
        sys.exit(1)

    filtered_data = np.array(filtered_data_list)
    outliers_removed = len(original_data) - len(filtered_data)

    if filtered_data.size == 0:
        return None

    min_val = filtered_data.min()
    filtered_max = filtered_data.max()
    filtered_avg = int(filtered_data.mean())
    filtered_rmse = int(filtered_data.std())

    # --- 3. Comparison Metrics ---
    avg_percent_drop = _calculate_percent_drop(original_avg, filtered_avg)
    rmse_percent_drop = _calculate_percent_drop(original_rmse, filtered_rmse)
    max_percent_drop = _calculate_percent_drop(original_max, filtered_max)

    # --- 4. Return all metrics and data arrays in a dictionary ---
    return {
        # Raw Data for Plotting
        'original_data': original_data,
        'filtered_data': filtered_data,
        
        # Core Metrics
        'min_val': min_val,
        'original_max': original_max,
        'filtered_max': filtered_max,
        'outliers_removed': outliers_removed,
        
        # Average & RMSE
        'original_avg': original_avg,
        'original_rmse': original_rmse,
        'filtered_avg': filtered_avg,
        'filtered_rmse': filtered_rmse,
        
        # Percentage Drops
        'max_percent_drop': max_percent_drop,
        'avg_percent_drop': avg_percent_drop,
        'rmse_percent_drop': rmse_percent_drop,
        'interrupt_latency': interrupt_latency
    }
