return_dir = pwd;
dir_in = 'DCB190p1_cdc14GFP_11072019_001';
cd(dir_in);
mkdir('temp')
cd(return_dir);
dir_out = strcat('DCB190p1_cdc14GFP_11072019_001', filesep, 'temp');
trans_ch = 1;
concatTiles(dir_in, dir_out, trans_ch);
cd(dir_out);
medSubTrans('DCB190p1_cdc14GFP_11072019_001_ch1.tif', 'med_trans.tif');
seg_dir = 'C:\Users\solennde\Documents\GitHub\yeast_segmentation';
mkdir('single_trans');
stack2im('med_trans.tif', 'single_trans');
cd('single_trans');
mkdir('segments');
image_struct = segmentTrans(seg_dir, pwd, 'segments');
S = append_segments(image_struct, 'DCB190p1_cdc14GFP_11072019_001_ch2.tif', 11, 49, 'cdc14_gfp');