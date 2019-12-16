function concatTiles(dir_in, dir_out, trans_ch)
%concatTile concatenates all image files generated from Nikon Element's
%Scan Large Image module into image files containing only a single image
%channel
%   input :
%       dir_in : String variable that points to the directory containing
%       the images to concatenate
%
%       dir_out : String variable that points to the directory to output
%       the concatenated images
%
%       trans_ch : Scalar variable that indicates which channel corresponse
%       to the trans images, typically 1
%% parse the directory for .tif files
files = dir(fullfile(dir_in,'*.tif'));
%% Check if channel number, height, and width of images are consistent
c_array = zeros([numel(files), 1]);
h_array = c_array;
w_array = c_array;
z_array = c_array;
parfor n = 1:numel(files)
    info = imfinfo(fullfile(files(n).folder, files(n).name));
    c_array(n) = numel(info);
    h_array(n) = info.Height;
    w_array(n) = info.Width;
    % Fill in z_array
    name_cell = strsplit(files(n).name, '_');
    z_cell = strsplit(name_cell{end}, '.');
    num_cell = strsplit(z_cell{1}, 'z');
    z_array(n) = str2double(strip(num_cell{2}, 'left', '0'));
end
if numel(unique(c_array)) ~= 1
    error('Image files in %s different number of channels', dir_in);
end
if numel(unique(h_array)) ~= 1
    error('Image files in %s different heights', dir_in);
end
if numel(unique(w_array)) ~= 1
    error('Image files in %s different widths', dir_in);
end
%% Read and append images
% Parse basename from dir_in
name_cell = strsplit(dir_in, filesep);
basename = name_cell{end};
% determine number of z planes
z_num = max(z_array);
% parse only mid-z-plane
mid_z = ceil(z_num/2);
parfor c = 1:unique(c_array)
    for n = 1:numel(files)
        if c == trans_ch
            name_cell = strsplit(files(n).name, '_');
            z_cell = strsplit(name_cell{end}, '.');
            num_cell = strsplit(z_cell{1}, 'z');
            z = str2double(strip(num_cell{2}, 'left', '0'));
            if z == mid_z
                im_mat = imread(fullfile(files(n).folder, files(n).name), c);
                if n == 1
                    imwrite(im_mat, sprintf('%s%s%s_ch%d.tif', dir_out, filesep, basename, c), 'tiff');
                else
                    imwrite(im_mat, sprintf('%s%s%s_ch%d.tif', dir_out, filesep, basename, c), 'tiff', 'WriteMode', 'append');
                end
            end
        else
            im_mat = imread(fullfile(files(n).folder, files(n).name), c);
            if n == 1
                imwrite(im_mat, sprintf('%s%s%s_ch%d.tif', dir_out, filesep, basename, c), 'tiff');
            else
                imwrite(im_mat, sprintf('%s%s%s_ch%d.tif', dir_out, filesep, basename, c), 'tiff', 'WriteMode', 'append');
            end
        end
    end
end