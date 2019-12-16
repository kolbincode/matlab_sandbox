function image_struct = segmentTrans(seg_dir, input_dir, output_dir, varargin)
%%segmentTrans segments yeast buds from Trans images using yeastSpotter
%%code
%
%   inputs:
%       seg_dir : String variable indicating directory containing the
%       yeast_segmentation code from the Moses lab
%
%       input_dir : String variable indicating directory containing trans
%       images to segment
%
%       output_dir : String variable indicating directory to place
%       segmented images
%
%       varargin : Optional input, name-pair parameters
%           PythonPath : A string specifying the exact location of the
%           python instance to use to run the segmentation code.
%
%   output:
%       image_struct : Structural array containing...

%% Input parser setup
default_python = 'python';
p = inputParser;
addRequired(p, 'seg_dir', @ischar);
addRequired(p, 'input_dir', @ischar);
addRequired(p, 'output_dir', @ischar);
addParameter(p, 'PythonPath', default_python, @ischar);
parse(p, seg_dir, input_dir, output_dir, varargin{:});
%% Edit the opts.py file
fid = fopen(fullfile(seg_dir, 'opts.py'));
lines = textscan(fid, '%s', 'Delimiter', '\n');
% The input directory line is always going to be line 3 in opts.py
if filesep == '\'
    lines{1}{3} = sprintf('input_directory = "%s"', strrep(input_dir, '\', '\\'));
    % The output directory line is always going to be line 6 in opts.py
    lines{1}{6} = sprintf('output_directory = "%s"', strrep(output_dir, '\', '\\'));
else
    lines{1}{3} = sprintf('input_directory = "%s"', input_dir);
    lines{1}{6} = sprintf('output_directory = "%s"', output_dir);
end
%write out the edited lines cell array as opts.py
fclose(fid);
fid_write = fopen(fullfile(seg_dir, 'opts.py'), 'w');
fprintf(fid_write,'%s\n',lines{1}{:});
fclose(fid_write);
%% Run segmentation.py
system(sprintf('%s %s%ssegmentation.py',p.Results.PythonPath, seg_dir, filesep), '-echo');
%% Record binary masks and locations
% parse the outputs_images
out_files = dir(fullfile(output_dir, 'masks', '*.tif'));
% set counter
cnt = 1;
for n = 1:numel(out_files)
    im_mat = imread(fullfile(out_files(n).folder, out_files(n).name));
    for i = 1:max(im_mat(:))
        lin_idxs = find(im_mat == i);
        [rows, cols] = ind2sub(size(im_mat), lin_idxs);
        crop = im_mat(min(rows):max(rows), min(cols):max(cols));
        binary = crop == i;
        binaryYX = [min(cols), min(rows)];
        image_struct(cnt).tile_idx = n;
        image_struct(cnt).binary = binary;
        image_struct(cnt).binaryYX = binaryYX;
        cnt = cnt + 1;
    end
end