import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from sklearn.linear_model import LinearRegression

def create_comparison_histogram_grid(all_stats_data, main_title):
    """
    Generates a grid of histograms comparing original and filtered data with
    improved clarity and richer colors.
    Also, contains a shared x-axis for consistent scaling and linked zooming.

    Args:
        all_stats_data (dict): A dictionary where keys are limb sizes and
                               values are the stat dictionaries from
                               `calculate_stats`.
        main_title (str): The main title for the entire plot figure.
    (This function remains available for use by other scripts, such as a single-file analyzer).
    """
    sorted_limbs = sorted(all_stats_data.keys())
    
    if not sorted_limbs:
        print("No data available to plot.")
        return

    # Determine the grid layout (4 columns)
    num_plots = len(sorted_limbs)
    num_cols = 4
    num_rows = (num_plots + num_cols - 1) // num_cols

    # Create the figure and subplots with shared axes for a clean look
    # `sharex=True` tells Matplotlib to link all x-axes together.
    fig, axes = plt.subplots(
        num_rows, 
        num_cols, 
        figsize=(18, 4.5 * num_rows), 
        sharex=True, # All subplots will share the same x-axis
        sharey=True  # All subplots will share the same y-axis
    )

    # Ensure axes is always a 2D array for consistent indexing
    if num_rows == 1: axes = np.array([axes])
    if num_cols == 1: axes = axes.reshape(-1, 1)
    # Flatten the axes array for easy iteration
    axes_flat = axes.flatten()

    # Loop through the data and create a plot for each limb size
    for i, limb_size in enumerate(sorted_limbs):
        ax = axes_flat[i]
        stats = all_stats_data[limb_size]
        
        original_data = stats['original_data']
        filtered_data = stats['filtered_data']

        # --- Binning Strategy for a Shared Axis ---
        # With a shared axis, we must ensure the histograms align correctly.
        # We plot the original data first, let Matplotlib define the bins across
        # its full range, and then use those exact same bins for the filtered data.
        
        # 1. Plot original data (outliers) and capture the bins used.
        #    Using a large number of bins gives a fine-grained view of outliers.
        _, bins, _ = ax.hist(
            original_data,
            bins=125, 
            color='crimson',
            alpha=0.2,
            label='Original data'
        )

        # 2. Plot the filtered data on top, with richer color and less transparency
        # Use *same bins* for perfect alignment.
        ax.hist(
            filtered_data,
            bins=bins, # This is the key for alignment
            color='dodgerblue',
            alpha=0.9,
            edgecolor='black',
            linewidth=0.5,
            label='Filtered Data'
        )
        
        # Add a vertical line for the mean of the FILTERED data
        ax.axvline(
            stats['filtered_avg'],
            color='#333333', # Dark gray
            linestyle='--',
            linewidth=1.5,
            label=f"Mean (Filt): {stats['filtered_avg']:,}"
        )

        ax.set_title(f'{limb_size} Limbs', weight='bold')
        ax.set_yscale('log')
        ax.legend(loc='upper right')
        ax.grid(True, which='both', linestyle=':', linewidth=0.5)

    # Hide any unused subplots
    for j in range(num_plots, len(axes_flat)):
        axes_flat[j].set_visible(False)

    # Add shared labels for the entire figure
    # Matplotlib will automatically handle showing tick labels only on the bottom and left plots.
    fig.text(0.5, 0.04, 'RDTSC Cycles', ha='center', va='center', fontsize=14)
    fig.text(0.07, 0.5, 'Frequency (log scale)', ha='center', va='center', rotation='vertical', fontsize=14)
    
    fig.suptitle(main_title, fontsize=18, weight='bold')
    plt.tight_layout(rect=[0.08, 0.06, 1, 0.95])
    
    # The plotting module is responsible for showing the plot
    plt.show()

def create_correlation_plot(correlation_points):
    """
    Creates a scatter plot with flexible point coloring based on different attributes.

    Args:
        correlation_points (list): A list of dictionaries, where each dictionary
                                   contains a full row of data.
    """
    if not correlation_points:
        print("No data available for correlation analysis.")
        return

    # Extract x and y data from the list of dictionaries
    x_values = [p['original_rmse'] for p in correlation_points]
    y_values = [p['interrupt_latency'] for p in correlation_points]
    x_data = np.array(x_values).reshape(-1, 1)
    y_data = np.array(y_values)

    # --- Linear Regression (remains the same) ---
    model = LinearRegression()
    model.fit(x_data, y_data)
    y_pred = model.predict(x_data)
    r_squared = model.score(x_data, y_data)
    
    plt.figure(figsize=(12, 8))

    # --- MODIFICATION: Flexible Coloring Logic ---
    # Choose which attribute to color by. Uncomment ONE of the following schemes.
    
    #coloring_scheme = 'by_radix'
    coloring_scheme = 'by_limb_size'
    # coloring_scheme = 'by_arch'
    #coloring_scheme = 'by_type'
    #coloring_scheme = 'by_version'
    #coloring_scheme = 'none' # For a single color plot

    legend_handles = []
    
    # --- Option 1: Color by Radix (Categorical) ---
    if coloring_scheme == 'by_radix':
        color_key = 'radix'
        unique_categories = sorted(list(set(p[color_key] for p in correlation_points)))
        color_map = {category: f'C{i}' for i, category in enumerate(unique_categories)}
        colors = [color_map[p[color_key]] for p in correlation_points]
        
        scatter = plt.scatter(x_data, y_data, c=colors, alpha=0.8, s=50)
        
        # Create a manual legend
        for category, color in color_map.items():
            legend_handles.append(mpatches.Patch(color=color, label=f'Radix {category}'))

    # --- Option 2: Color by Limb Size (Continuous) ---
    elif coloring_scheme == 'by_limb_size':
        color_key = 'limb_size'
        color_values = [p[color_key] for p in correlation_points]
        
        scatter = plt.scatter(x_data, y_data, c=color_values, cmap='viridis', alpha=0.8, s=50)
        
        # Add a color bar to explain the colors
        cbar = plt.colorbar(scatter)
        cbar.set_label('Limb Size', fontsize=12)

    # --- Option 3: Color by Architecture (Categorical) ---
    elif coloring_scheme == 'by_arch':
        color_key = 'arch'
        unique_categories = sorted(list(set(p[color_key] for p in correlation_points)))
        color_map = {category: f'C{i}' for i, category in enumerate(unique_categories)}
        colors = [color_map[p[color_key]] for p in correlation_points]
        
        scatter = plt.scatter(x_data, y_data, c=colors, alpha=0.8, s=50)
        
        # Create a manual legend
        for category, color in color_map.items():
            legend_handles.append(mpatches.Patch(color=color, label=f'Arch: {category}'))
    
    # --- Option 4: Color by Type (Categorical) ---
    elif coloring_scheme == 'by_type':
        color_key = 'type'
        unique_categories = sorted(list(set(p[color_key] for p in correlation_points)))
        color_map = {category: f'C{i}' for i, category in enumerate(unique_categories)}
        colors = [color_map[p[color_key]] for p in correlation_points]
        plt.scatter(x_data, y_data, c=colors, alpha=0.8, s=50)
        for category, color in color_map.items():
            legend_handles.append(mpatches.Patch(color=color, label=f'Type: {category}'))

    # --- Option 5: Color by Version (Categorical) ---
    elif coloring_scheme == 'by_version':
        color_key = 'version'
        unique_categories = sorted(list(set(p[color_key] for p in correlation_points)))
        color_map = {category: f'C{i}' for i, category in enumerate(unique_categories)}
        colors = [color_map[p[color_key]] for p in correlation_points]
        plt.scatter(x_data, y_data, c=colors, alpha=0.8, s=50)
        for category, color in color_map.items():
            legend_handles.append(mpatches.Patch(color=color, label=f'Version: {category}'))
            
    # --- Default: Single Color ---
    else:
        plt.scatter(x_data, y_data, color='dodgerblue', alpha=0.7)

    # Plot the line of best fit
    plt.plot(x_data, y_pred, color='crimson', linestyle='--', linewidth=2, 
             label=f'Best Fit Line (R² = {r_squared:.3f})')
    legend_handles.append(plt.Line2D([0], [0], color='crimson', lw=2, linestyle='--', label=f'Best Fit (R²={r_squared:.3f})'))

    plt.title('Correlation: Original RMSE vs. Estimated Interrupt Latency', fontsize=16)
    plt.xlabel('Original Data RMSE (Cycle Count)', fontsize=12)
    plt.ylabel('Estimated Interrupt Latency (Cycles)', fontsize=12)
    plt.legend(handles=legend_handles)
    plt.grid(True, linestyle=':', alpha=0.7)
