add_structural_information <- function(dataset_name, data, label, posClass, sensAttrs, numericalFeatures){
    if(!exists("structural_information")){
        structural_information <<- list()
    }

    structural_information[[dataset_name]] <<- list(data = data, label = label, posClass = posClass, sensAttrs = sensAttrs, numericalFeatures = numericalFeatures)
}
