
########################################################################################################
# Food Environment: Exposure analysis (Static Approach) - Density analysis
########################################################################################################

# This R script serves to prepare variables for density analysis, specifically:
#   
# 1. Identifies households whose 100-meter buffer zone is fully contained within the analysis unit (commune) boundary.
# 2. Identifies households whose 100-meter buffer zone partially overlaps with the analysis unit (commune) boundary.
# 3. Calculates the area (in square meters) of each buffer zone that intersects with the analysis unit boundary.

########################################################################################################
########################################################################################################

## 1. Packages and Settings ----

options(scipen    = 999)
options(max.print = 5000)
options(tibble.width = Inf)


if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  tidyverse, here, dplyr, haven, 
  readxl, sf, tmap, leaflet, 
  smoothr, openxlsx
)

# The below gets rid of package function conflicts
filter    <- dplyr::filter
select    <- dplyr::select
summarize <- dplyr::summarize

################################################################################
# food item level 
################################################################################

## 2. Set root ----

# here::here()
here::i_am("cpi_proj_nourish_2wave.Rproj")

# Set the base directory
# input data 
density_shp <- here::here("Vietnam", "Data", "Food environment", "4. Analysis prep", "SHiFT_Vietname_Density_Study_Units_Geoshape_File.rds")

study_shp <- here::here("Vietnam", "Data", "Food environment", "4. Analysis prep", "SHiFT_Vietname_Study_Area_Geoshape_File.rds")

hh_final <- here::here("Vietnam", "Data", "Food environment", "4. Analysis prep", "FE_HH_FINAL_SAMPLE.dta")

outlet_final <- here::here("Vietnam", "Data", "Food environment", "4. Analysis prep", "FE_OUTLETS_FINAL_SAMPLE.dta")

################################################################################
# load the dta file #
################################################################################

# Load shape file for commune boundaries
df_shape <- readRDS(file = density_shp) 
df_shape_org <- readRDS(file = study_shp) 


# Load GPS points data
# HH
hh_gps_final <- read_dta(hh_final) %>% 
  filter(final_sample_hh == 1) %>%
  select(hhid, hh_latitude, hh_longitude, com_name, com_name_id, rural_urban, 
         final_sample_hh, hh_analysis_unit) %>%
  rename(
    "hhdf_hh_analysis_unit" = "hh_analysis_unit"
  )

outlet_gps_final <- read_dta(outlet_final) %>%
  filter(final_sample == 1) %>%
  rename(
    "longitude" = "s4q2longitude", 
    "latitude" = "s4q2latitude"
  )
  
  
# Convert GPS points to sf object
hh_final_gps_sf <- st_as_sf(hh_gps_final, coords = c("hh_longitude", "hh_latitude"), crs = 4326)
outlet_gps_final_sf <- st_as_sf(outlet_gps_final, coords = c("longitude", "latitude"), crs = 4326)

################################################################################


################################################################################
# I. Shape file with buffer 
################################################################################
# Check the map
tmap_mode("view") # interactive mode

tm_shape(df_shape)  + 
  tm_polygons(col = "VARNAME_3")

# Create a buffer around the commune boundary
buffer_size <- 100  # Adjust the buffer size as needed

# some commune did not apply the buffer zone 
df_shape_nobuffer <- df_shape %>%
  filter(hh_analysis_unit < 3)

df_shape_buffer <- df_shape %>%
  filter(hh_analysis_unit >= 3)

# apply buffer zone 
commune_buffers <- st_buffer(df_shape_buffer, dist = buffer_size)
smoothed_buffers <- smooth(commune_buffers, method = "ksmooth") # smoothr

# Check 
tm_shape(df_shape)  + 
  tm_polygons(col = "VARNAME_3", 
              id = "VARNAME_3",
              palette = "viridis", title = "Commune Name", alpha = 0.3, 
              popup.vars = c("Province: " = "NAME_1", "District: " = "NAME_2", "Comune: " = "VARNAME_3"), 
              group = "Commune Geo-boundary") +
  tm_shape(commune_buffers) +
  tm_fill(col = "lightblue", alpha = 0.3) +
  tm_shape(smoothed_buffers) +
  tm_fill(col = "blue", alpha = 0.3)

commune_buffers <- rbind(df_shape_nobuffer, smoothed_buffers)

################################################################################
# II. Identify the HH with buffer zone within the commune or intersect 
# (commune with buffer zone)
################################################################################

# Create buffers around each home
hh_buffers <- st_buffer(hh_final_gps_sf, dist = buffer_size)

##############################
# (1) Within commune boundary 
##############################
# Check if the buffer falls entirely within the commune boundary
hh_buffers$contain_commune <- as.numeric(st_within(hh_buffers, commune_buffers))

hh_buffers <- hh_buffers %>%
  mutate(contain_commune = as.factor(ifelse(!is.na(contain_commune), 1,0)))

# Remove geometry and convert to data frame
# hh_buffers_data <- st_drop_geometry(hh_buffers) %>% as.data.frame()

# Check 
tm_shape(df_shape)  + 
  tm_polygons(col = "VARNAME_3", 
              id = "VARNAME_3",
              palette = "viridis", title = "Commune Name", alpha = 0.3, 
              popup.vars = c("Province: " = "NAME_1", "District: " = "NAME_2", "Comune: " = "VARNAME_3"), 
              group = "Commune Geo-boundary") +
  tm_shape(commune_buffers) +
  tm_fill(col = "lightblue", alpha = 0.3) +
  tm_shape(hh_buffers) +
  tm_dots("hhid", size = 0.05, alpha = 0.3, col = "contain_commune",
          id = "hhid") +
  tm_shape(hh_buffers) +
  tm_fill(col = "blue", alpha = 0.3)
  
######################################
# (2) Intersect with commune boundary # don't need to run this part - title 2 as not using the bufer in final analysis
######################################
# Intersect the buffer zones with the commune boundary
intersections <- st_intersection(hh_buffers, commune_buffers)

# >>>>>>>>>>>>>>>>>>>
# It's important to note that a household's buffer zone can intersect with multiple commune boundaries, 
# particularly for those living in border areas. This can result in duplicate records 
# for the same household ID, as each intersection with a commune is accounted for. 
# For the analysis, we will combined those overlapped buffer zone area 
# associated with the household. 

# Find duplicate hhid values
intersection_data <- st_drop_geometry(intersections) %>% as.data.frame()
length(unique(intersection_data$hhid))
nrow(intersection_data)

duplicate_hhids <- intersection_data$hhid[duplicated(intersection_data$hhid)]

print(duplicate_hhids) 

# Perform spatial join to count outlets within each buffer
dup_intersect <- intersections %>%
  filter(
    hhid %in% duplicate_hhids # & hhdf_hh_analysis_unit == hh_analysis_unit
  )

dup_intersect <- st_make_valid(dup_intersect) 

# Aggregate geometries by 'hhid'
merged_buffers <- dup_intersect %>%
  group_by(hhid) %>%  # Group by household ID
  mutate(geometry = st_union(geometry)) %>%  # Merge geometries within each group
  ungroup() %>%  # Remove the grouping
  filter(hhdf_hh_analysis_unit == hh_analysis_unit)

merged_buffers <- st_make_valid(merged_buffers)  

# # fixing the geo invalid one 
# invalid_merged_buffers <- st_is_valid(merged_buffers, reason = TRUE)
# print(invalid_merged_buffers)
# merged_buffers_fixed <- st_make_valid(merged_buffers)
# st_is_valid(merged_buffers_fixed, reason = TRUE)

# Check 
tm_shape(df_shape)  + 
  tm_polygons(col = "VARNAME_3", 
              id = "VARNAME_3",
              palette = "viridis", title = "Commune Name", alpha = 0.3, 
              popup.vars = c("Province: " = "NAME_1", "District: " = "NAME_2", "Comune: " = "VARNAME_3"), 
              group = "Commune Geo-boundary") +
  tm_shape(df_shape_org) + 
  tm_polygons(col = "VARNAME_3", 
              id = "VARNAME_3",
              palette = "viridis", title = "Commune Name", alpha = 0.3, 
              popup.vars = c("Province: " = "NAME_1", "District: " = "NAME_2", "Comune: " = "VARNAME_3"), 
              group = "Org Geo-boundary") +
  tm_shape(outlet_gps_final_sf) + 
  tm_basemap(server = "OpenStreetMap") +
  tm_dots("outlet_code", size = 0.05, alpha = 0.5, col = "red",
          id = "outlet_code",
          popup.vars = c("Outlet: " = "outlet_code", "District: " = "dist_name", "Comune: " = "com_name_eng"), 
          group = "01: Outlets") +
  tm_shape(commune_buffers) +
  tm_fill(col = "lightblue", alpha = 0.3) +
  tm_shape(dup_intersect) +
  tm_dots("hhid", size = 0.05, alpha = 0.3, col = "contain_commune",
          id = "hhid") +
  tm_shape(dup_intersect) +
  tm_fill(col = "blue", alpha = 0.3) +
  tm_shape(merged_buffers) +
  tm_fill(col = "yellow", alpha = 0.3) +
  tm_shape(merged_buffers) +
  tm_dots()

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# Aggregate geometries by 'hhid'
merged_intersections <- intersections %>%
  group_by(hhid) %>%  # Group by household ID
  mutate(geometry = st_union(geometry)) %>%  # Merge geometries within each group
  slice(1) %>%
  ungroup()  # Remove the grouping

st_is_valid(merged_intersections, reason = TRUE)
merged_intersections <- st_make_valid(merged_intersections) 

# Calculate the area of each remaining buffer zone within the commune boundary
merged_intersections$hh_buffer_area <- as.numeric(st_area(merged_intersections))
merged_intersections$intersect <- as.numeric(1)


# Check 
tm_shape(df_shape)  + 
  tm_polygons(col = "VARNAME_3", 
              id = "VARNAME_3",
              palette = "viridis", title = "Commune Name", alpha = 0.3, 
              popup.vars = c("Province: " = "NAME_1", "District: " = "NAME_2", "Comune: " = "VARNAME_3"), 
              group = "Commune Geo-boundary") +
  tm_shape(outlet_gps_final_sf) + 
  tm_basemap(server = "OpenStreetMap") +
  tm_dots("outlet_code", size = 0.05, alpha = 0.5, col = "red",
          id = "outlet_code",
          popup.vars = c("Outlet: " = "outlet_code", "District: " = "dist_name", "Comune: " = "com_name_eng"), 
          group = "01: Outlets") +
  tm_shape(hh_final_gps_sf) +
  tm_basemap(server = "OpenStreetMap") +
  tm_dots("hhid", size = 0.05, alpha = 0.4, col = "blue", 
          id = "hhid",
          group = "HH/Adolescent") +
  tm_shape(commune_buffers) +
  tm_fill(col = "lightblue", alpha = 0.3) +
  tm_shape(dup_intersect) +
  tm_dots("hhid", size = 0.05, alpha = 0.3, col = "contain_commune",
          id = "hhid") +
  tm_shape(dup_intersect) +
  tm_fill(col = "blue", alpha = 0.3) +
  tm_shape(merged_intersections) +
  tm_fill(col = "yellow", alpha = 0.3) +
  tm_shape(merged_intersections) +
  tm_dots()

# Remove geometry and convert to data frame
merged_intersections_data <- st_drop_geometry(merged_intersections) %>% 
  as.data.frame() %>%
  select(hhid, com_name, com_name_id, rural_urban, final_sample_hh, hh_analysis_unit, 
         contain_commune, 
         intersect, hh_buffer_area) %>%
  mutate(intersect = ifelse(intersect == 1 & contain_commune == 0, 1, 0))

################################################################################
# III. Identify the HH with buffer zone within the commune or intersect 
# (commune without buffer zone)
################################################################################
# hh with buffer inside the commune (with no buffer)
hh_buffers$contain_commune_nobuffer <- as.numeric(st_within(hh_buffers, df_shape))

hh_buffers <- hh_buffers %>%
  mutate(contain_commune_nobuffer = as.factor(ifelse(!is.na(contain_commune_nobuffer), 1,0)))

# Intersect the buffer zones with the commune boundary
intersections_nobuffer <- st_intersection(hh_buffers, df_shape)

# Find duplicate hhid values
length(unique(intersections_nobuffer$hhid))
nrow(intersections_nobuffer)

# Aggregate geometries by 'hhid'
merged_intersections_nobuffer <- intersections_nobuffer %>%
  group_by(hhid) %>%  # Group by household ID
  mutate(geometry = st_union(geometry)) %>%  # Merge geometries within each group
  slice(1) %>%
  ungroup()  # Remove the grouping

st_is_valid(merged_intersections_nobuffer, reason = TRUE)
merged_intersections_nobuffer <- st_make_valid(merged_intersections_nobuffer) 

# Calculate the area of each remaining buffer zone within the commune boundary
merged_intersections_nobuffer$hh_buffer_area_nobuffer <- as.numeric(st_area(merged_intersections_nobuffer))
merged_intersections_nobuffer$intersect_nobuffer <- as.numeric(1)

# Remove geometry and convert to data frame
merged_intersections_nobuffer_data <- st_drop_geometry(merged_intersections_nobuffer) %>% 
  as.data.frame() %>%
  select(hhid, # com_name, com_name_id, rural_urban, final_sample_hh, hh_analysis_unit
         contain_commune_nobuffer, 
         hh_buffer_area_nobuffer, intersect_nobuffer) %>%
  mutate(intersect_nobuffer = ifelse(intersect_nobuffer == 1 & contain_commune_nobuffer == 0, 1, 0))


################################################################################
# IV. Prepare a combined dataset to work in STATA for density analysis
################################################################################

hh_buffer_area_final_df <- left_join(merged_intersections_data, 
                                      merged_intersections_nobuffer_data, 
                                      by = "hhid")

# Save results to Excel file
area_df_dir <- here::here("Vietnam", "Data", "Food environment", "4. Analysis prep", "HH_buffer_100m_area.xlsx")

write.xlsx(list(
  area_calculation = hh_buffer_area_final_df),
  file = area_df_dir)

################################################################################
# V. Plot the Buffer Area
################################################################################
# # created buffer ring - but not working 
# buffer_rings <- st_difference(commune_buffers, df_shape) 
# buffer_rings <- st_make_valid(buffer_rings) # not working 


tm <- tm_shape(df_shape) + # based map - commune shape file # df_shape_org
  tm_basemap(server = "OpenStreetMap") +
  tm_polygons(col = "VARNAME_3", 
              id = "VARNAME_3",
              palette = "viridis", title = "Commune Name", alpha = 0.3, 
              popup.vars = c("Province: " = "NAME_1", "District: " = "NAME_2", "Comune: " = "VARNAME_3"), 
              group = "0: Commune Geo-boundary", 
              legend.show = FALSE) +
  tm_shape(commune_buffers) + # add the commune buffer zone 
  tm_polygons(col = "VARNAME_3", 
              id = "VARNAME_3",
              palette = "viridis", title = "Commune Name", alpha = 0.3, 
              popup.vars = c("Province: " = "NAME_1", "District: " = "NAME_2", "Comune: " = "VARNAME_3"), 
              group = "0: Commune buffer zone", 
              legend.show = FALSE) +
  tm_shape(outlet_gps_final_sf) + 
  tm_basemap(server = "OpenStreetMap") +
  tm_dots("outlet_code", size = 0.05, alpha = 0.5, col = "red",
          id = "outlet_code",
          popup.vars = c("Outlet: " = "outlet_code", "District: " = "dist_name", "Comune: " = "com_name_eng"), 
          group = "1: Outlets") +
  tm_shape(hh_final_gps_sf) +
  tm_basemap(server = "OpenStreetMap") +
  tm_dots("hhid", size = 0.05, alpha = 0.5, col = "blue", 
          id = "hhid",
          popup.vars = c("HHID: " = "hhid", "Comune: " = "com_name"), 
          group = "2: HH/Adolescent") +
  # tm_shape(merged_intersections) +
  # tm_fill(col = "blue", alpha = 0.1,
  #         popup.vars = c("HHID: " = "hhid", "Comune: " = "com_name", "Buffer Area: " = "hh_buffer_area"),
  #         group = "3: HH's buffer area: 100 m radius [within commune with buffer zone]") +
  tm_shape(merged_intersections_nobuffer) +
  tm_fill(col = "yellow", alpha = 0.2, 
          popup.vars = c("HHID: " = "hhid", "Comune: " = "com_name", "Buffer Area: " = "hh_buffer_area_nobuffer"),
          group = "4: HH's buffer area: 100 m radius [within commune without buffer zone]")
  

# Create the observation summary text with line breaks
# # Create the observation summary text with line breaks, styling, bold, and italic
# summary_text <- paste0(
#   "<div style='font-size: 14px; color: darkblue;'>",
#   "<b>Observation Summary:</b><br>",    # Bold heading
#   "Layer 1 (Outlets): ", nrow(outlet_gps_final_sf), " outlets<br>",
#   "Layer 2 (HH/Adolescent): ", nrow(hh_final_gps_sf), " households<br>",
#   "<i>Layer 3 (Buffer within commune with buffer zone):</i> ", nrow(merged_intersections), " households<br>",  # Italic layer name
#   "<i>Layer 4 (Buffer without buffer zone):</i> ", nrow(merged_intersections_nobuffer), " households",       # Italic layer name
#   "</div>"
# )

summary_text <- paste0(
  "<div style='font-size: 14px; color: darkblue;'>",
  "<b>Observation Summary:</b><br>",
  "</div>",
  "<div style='font-size: 14px; color: red;'>",
  "Outlets: ", nrow(outlet_gps_final_sf), " outlets<br>",
  "</div>",
  "<div style='font-size: 14px; color: blue;'>",
  "HH/Adolescent: ", nrow(hh_final_gps_sf), " households<br>",
  "</div>",
  "<div style='font-size: 14px; color: blue;'>",
  "HH within the original commune boundary: ",
  sum(merged_intersections_nobuffer$contain_commune_nobuffer == 1),  # Count TRUE values 
  " households<br>",
  "</div>",
  "HH within the commune with buffer (100 m) boundary: ",
  # sum(merged_intersections$contain_commune == 1), " households<br>", # Count TRUE values
  "</div>"
)

# Convert tmap to leaflet and add the text note
tmap_leaflet(tm) %>%
  addControl(html = summary_text, position = "bottomright")  # Add text note directly

