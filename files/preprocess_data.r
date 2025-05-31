preprocess_data <- function(data, label_col) {
  data %>%
    dplyr::select(-dplyr::any_of(label_col)) %>%
    mutate(across(where(is.character), as.factor)) %>%
    one_hot_encode() %>%
    mutate(across(everything(), as.numeric)) %>%
    na.omit()
}

