if(!require("ecr")) install.packages("ecr")


source("./data/german_credit.r")
source("1_install.r")
source("db_files.r")

german_credit <- german_credit()
#---------- Multi-Objective Optimization Loop ----------

mo_op_loop <- function(inds, num_iterations = 150, resample = 1, indices, bmethod = "fair_smote") {
  train_indices <- indices[[resample]]$train_indices
  test_indices <- indices[[resample]]$test_indices

  df_train <- get_data("german_credit", train_indices) 
  df_test <- get_data("german_credit", test_indices)
  fitness.vals <- compute_fitness(inds, bmethod = bmethod, df_train = df_train, df_test = df_test)
  it_values <- list()
  
  if(bmethod != "no_opt_balance") {
    look_up_table <- fitness.vals$look_up_table
    fitness.vals <- fitness.vals[[1]]
     
    counter <- 0
    mu <- 20
    best_val_new <- 0
    continue <- TRUE
    iteration <- 1 
    
    while(continue) {
      if(iteration >= num_iterations || counter > 10) {
        continue <- FALSE
        print("Aborted")
      }
      
      iteration <- iteration + 1
      fitness.vals <- compute_fitness(inds, look_up_table, bmethod = bmethod, df_train, df_test)
      look_up_table <- fitness.vals$look_up_table
      fitness.vals <- fitness.vals[[1]]
      
      it_values[iteration] <- sapply(1:10, function(r) sapply(fitness.vals, 
                                    function(x) compute_hypervolume(x[[1]]$phenotyp_values[[r]]$values))) %>% max()
      
      best_val_old <- best_val_new
      best_val_new <- max(unlist(it_values), na.rm = TRUE)
      print(paste0("Iteration: ", iteration))
      print(paste0("Mean Hypervolume: ", it_values[iteration]))
      
      if(best_val_new == best_val_old) {
        counter <- counter + 1
      }
      if(best_val_new > best_val_old) {
        counter <- 0
      }
      
      distances <- matrix(0, mu, 3)
      for(dim in 1:3) {
        extreme_points_up <- matrix(0, mu, 1)
        extreme_points_down <- matrix(0, mu, 1)
        
        for(r in 1:10) {
          # Sort population by fitness
          A_j <- sapply(1:mu, function(x) fitness.vals[[x]][[1]]$phenotyp_values[[r]]$values[[dim]])
          A_s_index <- order(A_j, decreasing = FALSE) # first index is the smallest value!
          f_min <- min(A_j) # for fitness normalization
          f_max <- max(A_j)
          
          # Edge cases: best and worst fitness values
          distances[A_s_index[1], dim] <- 2*(A_j[A_s_index[2]] - A_j[A_s_index[1]])/(f_max - f_min) + 
                                           distances[A_s_index[1], dim] # lowest
          distances[A_s_index[length(A_s_index)], dim] <- 2*(A_j[A_s_index[length(A_s_index)]] - 
                                                            A_j[A_s_index[length(A_s_index)-1]])/(f_max - f_min) + 
                                                           distances[A_s_index[1], dim] # highest
                                                           
          # Collective voting: count if extreme points in r-th replication
          extreme_points_up[A_s_index[1]] <- extreme_points_up[A_s_index[1]] + 1
          extreme_points_down[A_s_index[length(A_s_index)]] <- extreme_points_down[A_s_index[length(A_s_index)]] + 1
          
          # Calculate distances
          for(i in 2:(length(A_s_index)-1)) {
            l_nb <- A_s_index[i-1]
            r_nb <- A_s_index[i+1]
            id <- A_s_index[i]
            distances[id, dim] <- distances[id, dim] + (A_j[r_nb] - A_j[l_nb])/(f_max - f_min)
          }
          
          if(r == 10) {
            distances/10
          }
        }
        
        extreme_points <- extreme_points_up - extreme_points_down 
        distances[which.max(extreme_points), dim] <- -Inf
        extreme_points <- extreme_points_down - extreme_points_up
        distances[which.max(extreme_points), dim] <- -Inf
      }
    
      rankings <- lapply(1:10, function(r) {
        ecr::doNondominatedSorting(
          # higher values are better
          lapply(1:3, function(dim) sapply(1:mu, function(x) fitness.vals[[x]][[1]]$phenotyp_values[[r]]$values[[dim]])) %>% 
            do.call(rbind, .)
        )$ranks 
      }) %>% do.call(rbind, .) 
      
      # Borda count - aggregation of ranks  
      agg_rank <- rankings %>% colSums() %>% rank()  # higher is better
      crowd_dist <- apply(distances, 1, prod)
      
      # Ensure no NA values in agg_rank or crowd_dist
      agg_rank <- ifelse(is.na(agg_rank), -Inf, agg_rank)
      crowd_dist <- ifelse(is.na(crowd_dist), -Inf, crowd_dist)

      # Handle ties with crowding distance
      for(i in 1:length(agg_rank)) {
        pos_ties <- which(agg_rank == agg_rank[i])
        if(length(pos_ties) > 1) {
          crowd_dists <- crowd_dist[pos_ties]
          max_crowd_dist <- max(crowd_dists, na.rm = TRUE)
          min_crowd_dist <- min(crowd_dists, na.rm = TRUE)
          agg_rank[pos_ties[crowd_dists == max_crowd_dist]] <- floor(agg_rank[pos_ties[crowd_dists == max_crowd_dist]])
          agg_rank[pos_ties[crowd_dists == min_crowd_dist]] <- -Inf
        }
      }
        
      mating_parents <- inds[sel_topmost_id(agg_rank, 10)]
      
      # Generate offspring
      child_inds <- list()
      for(i in 1:length(mating_parents)) {
        child_inds[[i]] <- ecr::recIntermediate(sample(mating_parents, 2, replace = FALSE))
      }
      
      # Apply mutations
      if(counter >= 5) {
        child_inds <- lapply(child_inds, make_mutations, 0.2)
      } else {
        child_inds <- lapply(child_inds, make_mutations)
      }
      
      child_inds <- lapply(child_inds, repair)
      inds <- append(mating_parents, child_inds)
    }
  }
  
  return(list(inds, it_values, fitness.vals))
}

#---------- Data Preparation ----------

if(file.exists("indices_opt2.Rdata")) {
  load("indices_opt2.Rdata")
} else {
  set.seed(2025)
  indices <- list()
  for(k in 1:50) {
    all_rows <- 1:nrow(german_credit)
    train_indices <- sample(all_rows, nrow(german_credit) * 0.7)
    test_indices <- setdiff(all_rows, train_indices)
    
    validation_indices <- sample(test_indices, length(test_indices)*0.5)
    test_indices <- setdiff(test_indices, validation_indices)
    indices[[k]] <- list(train_indices = train_indices, 
                         test_indices = test_indices, 
                         validation_indices = validation_indices)
  }
  save(indices, file = "indices_opt2.Rdata")
}

#---------- Run Simulations ----------

library(future.apply)
plan(multisession, workers = availableCores() - 1)

process_sim_erg <- function(x) {
  all_data <- data.frame()
  for(i in 1:20) {
    dat <- rowMeans(sapply(1:10, function(j) x[[3]][[i]][[1]]$phenotyp_values[[j]]$values))
    dat <- as.data.frame(t(dat))
    colnames(dat) <- c("unfairness", "performance", "cost")
    all_data <- rbind(all_data, dat)
  }
  return(all_data)
}

# Initialize simulation results lists
sim_erg_fair <- list()
sim_erg_smote <- list()
sim_erg_baseline <- list()

# Run simulations for different methods
for(res in 1:10) {
  inds <- lapply(1:20, function(x) c(sample(1:10, 1), sample(1:10, 1), runif(1), runif(1)))
  sim_erg_fair[[res]] <- mo_op_loop(inds, num_iterations = 100, resample = res, indices, bmethod = "fair_smote")
  sim_erg_smote[[res]] <- mo_op_loop(inds, num_iterations = 100, resample = res, indices, bmethod = "smote")
  sim_erg_baseline[[res]] <- mo_op_loop(inds, num_iterations = 2, resample = res, indices, bmethod = "no_opt_balance")
}

# Process results
lapply(sim_erg_fair, process_sim_erg) %>% do.call(rbind, .) %>% cbind(algo = "fair_smote") -> all_data_female
lapply(sim_erg_smote, process_sim_erg) %>% do.call(rbind, .) %>% cbind(algo = "smote") -> all_data_female2

all_data_comb_female <- rbind(all_data_female, all_data_female2)

setwd("/Volumes/simulation/PACIS 2/")

all_data_comb_female %>% 
  group_by(algo) %>% 
  summarise(across(everything(), list(mean = mean, sd = sd))) %>% 
  mutate(across(where(is.numeric), round, 2)) 
