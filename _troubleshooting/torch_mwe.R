#Sys.setenv(OMP_NUM_THREADS='1')
#Sys.setenv(OMP_MAX_ACTIVE_LEVELS='1')
#Sys.setenv(KMP_DUPLICATE_LIB_OK='TRUE')
#Sys.setenv(PYTHONNOUSERSITE='1')

library(reticulate)
library(dplyr)

reticulate::use_condaenv(
  condaenv='baybe', 
  conda='/home/morimoto/miniforge3/bin/conda',
  required=TRUE)
py_config()

#Sys.setenv(CUDA_VISIBLE_DEVICES = "") # These env vars needed to be set so once the torch recommender kicks in it won't crash R.
#Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

torch = import('torch')
baybe = import('baybe')
#torch$set_num_threads(1L)
baybe.parameters = import('baybe.parameters')
baybe.searchspace = import('baybe.searchspace')
baybe.targets = import('baybe.targets')
baybe.objectives = import('baybe.objectives')
Campaign = import('baybe.campaign')

# ncp is a class for NumericalContinuousParameter
NCP = baybe.parameters$NumericalContinuousParameter

parameters = c(
  NCP(name = 'ppm', bounds = c(1, 20)),
  NCP(name = 'min_peakwidth', bounds = c(1, 10)),
  NCP(name = 'max_peakwidth', bounds = c(10, 60)),
  NCP(name = 'mzdiff', bounds = c(-0.001, 0.005))
)

searchspace = baybe.searchspace$SearchSpace$from_product(parameters)

target = baybe.targets$NumericalTarget(name='PPS')
objective = baybe.objectives$SingleTargetObjective(target=target)

campaign = Campaign$Campaign(
  searchspace = searchspace,
  objective = objective
)

py_set_seed(17)
recommendations = campaign$recommend(batch_size = 9L)
recommendations

pps.scores.table = readRDS('_noshare/first_rec_results.rds')
measurements.0 = 
  recommendations |>
  bind_cols(pps.scores.table)

campaign$add_measurements(measurements.0)
campaign$measurements
recommendations.1 = campaign$recommend(batch_size = 9L)
