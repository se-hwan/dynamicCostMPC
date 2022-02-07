function p = plot_heatmap(Q)
    
    % TODO: divergent colormap, change at 0
    p = figure; hold on;
    imagesc(Q_star)
    colormap("winter") % seasonal theme for plots
    colorbar
    axis tight
    set(gca, 'YDir', 'reverse')
end