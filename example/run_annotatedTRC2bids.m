% Example 
addpath('../trc2bids/')
addpath('../micromed_utils/')
addpath('../external/')

fieldtrip_folder  = '/home/matteo/Desktop/git_rep/fieldtrip/';
fieldtrip_private = '/home/matteo/Desktop/git_rep/fieldtrip/fieldtrip_private/';
jsonlab_folder    = '/home/matteo/Desktop/git_rep/jsonlab/';
addpath(fieldtrip_folder) 
addpath(fieldtrip_private)
addpath(jsonlab_folder)



cfg          = [];
cfg.proj_dir = '/home/matteo/Desktop/tmp/';            % folder to store bids files
cfg.filename = '/home/matteo/Desktop/tmp/example.TRC'; % TRC file


[status,msg,output] = annotatedTRC2bids(cfg)