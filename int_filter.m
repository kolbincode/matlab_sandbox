function S_filter = int_filter(S, channels)
%%int_filter Filters out the yeast buds lacking any fluorescent signal
%
%   inputs :
%       S : A structure array containing tile_idx/image_plane,
%       binary masks, the upper-left index of the masks, cropped trans
%       images, and cropped fluorescent images.
%
%       channels : A cell array specifying the names of the channels to
%       filter.
%
%
%% Parse fluorescent images
% pre-allocate index matrix
idxs = zeros([numel(S), numel(channels)]);
for n = 1:numel(channels)
    %% Separate signal from noise for each image
    images = cellfun(@(x, y) x./y, {S.(channels{n})}, {S.binary}, 'UniformOutput', false);
    thresh_array = cellfun(@multithresh, images);
    %% remove objects from boundary
    thresh_ims = cellfun(@(x, y) x > y, {S.(channels{n})}, num2cell(thresh_array), 'UniformOutput', false);
    clean_bins = cellfun(@imclearborder, thresh_ims, 'UniformOutput', false);
    %% only keep images with one object
    cc = cellfun(@bwconncomp, clean_bins);
    object_idx = [cc.NumObjects] == 1;
    %% filter by max values
    int_bins = cellfun(@(x, y) (x .* y)./y, {S.(channels{n})}, clean_bins, 'UniformOutput', false);
    maxes = cellfun(@(x) max(x(:)), int_bins);
    max_idx = maxes > multithresh(maxes);
    %% Gather means and areas data
    means = cellfun(@(x) nanmean(x(:)), int_bins);
    areas = cellfun(@(x) sum(~isnan(x(:))), int_bins);
    %% filter out large signal areas using isoutlier
    area_idx = ~isoutlier(areas);
    %% calculate total filter
    idxs(:,n) = object_idx & max_idx & area_idx;
end
final_idx = sum(idxs, 2) > 0;
mean_cell = num2cell(means);
[S.means] = mean_cell{:};
area_cell = num2cell(areas);
[S.areas] = area_cell{:};
S_filter = S(final_idx);
    
    
    