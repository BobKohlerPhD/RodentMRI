
#------------Read in and extract relevant imaging data + covariates --------------#
#df_image <- read.csv("path_to_your_data.csv")
#df_cov <- read.csv("path_to_your_data.csv")

# Function for identifying specific imaging data by string if needed
imaging_cols <- grep("^img_", names(df_image), value = TRUE)

# Select imaging data based on above as well as covariate data
imaging_data <- df %>% select(all_of(imaging_cols))
covariate_data <- df_cov %>% select(subject_id, batch, age, sex)

# Transpose imaging data [row=feature, columns=subject] as it must be in matrix for neurocombat 
imaging_matrix <- t(as.matrix(imaging_data))


#-------neuroCombat setup------#
nc_model <- model.matrix(~ age + sex, 
                         data = covariate_data)

combat_output <- neuroCombat(
  dat   = imaging_matrix,
  batch = covariate_data$batch,
  mod   = nc_model,
  eb    = TRUE)

harmonized_data <- as.data.frame(t(combat_output$dat.combat))
harmonized_data$subject_id <- df$subject_id

#--------------Plot Original vs. Harmonized Data----------------#
original_data <- df %>%
  select(subject_id, img_feature1) %>%
  mutate(Harmonization = "Original")

harmonized_data <- harmonized_data %>%
  select(subject_id, img_feature1) %>%
  mutate(Harmonization = "Harmonized")

combined_data <- merge(original_data, harmonized_data, by = "subject_id")

ggplot(combined_data, aes(x = Harmonization, 
                          y = img_feature1, 
                          fill = Harmonization)) +
  geom_boxplot(aes(fill = harmonized),
               color = "black",
               position = "dodge",
               width = .65,
               fatten = 1.25,
               linewidth = 1.25,
               outlier.shape =NA)+
  scale_color_npg()+
  geom_point(position = position_jitter(width = .2, seed = 0),
             size = 3, 
             alpha = .25) +
  scale_fill_npg()+
  coord_flip(ylim = c(0.2, 0.75))+
  labs(x = "",
       y = "Left Cingulate Cingulum Fractional Anisotropy", 
       title = "Neurocombat Harmonized Data Comparison")+
  theme_grey()+
  theme(text=element_text(family="Arial"),
        strip.background = element_blank(),
        strip.text = element_text(size = 18, face = "bold", color = "black"),
        plot.title = element_text(size = 22, face = "bold"),
        axis.title.x = element_text(size = 20, face = "bold"),
        axis.title.y = element_text(size = 20, face = "bold"),
        plot.title.position = "plot",
        axis.line = element_line(linewidth = 1.25), 
        axis.ticks.length = unit(.25,"cm"),
        axis.text.y = element_text(size = 18,  color = "black"),
        axis.text.x = element_text(size = 18,  color = "black"),
        legend.text = element_text(size = 0, color = "black", face = "bold"),
        legend.title = element_text(size = 0, color = "black", face = "bold"),
        legend.position = "none")  + 
  facet_wrap(~harmonized, ncol = 2, strip.position = "top")
