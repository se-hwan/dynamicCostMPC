function p = plot_heatmap(Q_star)
    
    % TODO: divergent colormap, change at 0
    p = figure; hold on;
    imagesc(Q_star)
    colormap(bluewhitered) % seasonal theme for plots
    colorbar
    caxis([0 45])
    axis tight
    set(gca, 'YDir', 'reverse')
end