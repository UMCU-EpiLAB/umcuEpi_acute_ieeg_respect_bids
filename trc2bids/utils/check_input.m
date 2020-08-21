%% check if the configuration struct contains all the required fields
function check_input(cfg,key)

if (isa(cfg, 'struct')) 
  
  fn = fieldnames(cfg);
  if ~any(strcmp(key, fn))
       
    error('Provide the configuration struct with all the fields example: cfg.proj_dir  cfg.filename  error: %s missing ', key);
  end
  
else
    error('Provide the configuration struct with all the fields example: cfg.proj_dir  cfg.filename');
end
  