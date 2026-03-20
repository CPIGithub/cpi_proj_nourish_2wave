
################################################################################
################################################################################

library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(patchwork)

################################################################################
################################################################################

#====================================================
# 1. Load Excel data
#====================================================
file_path <- "I:/ .shortcut-targets-by-id/1qS9e_FKPO2IwvcIAch8aqRrLnWosl6ja/2nd round Project Nourish Survey/02_workflow/04_result/01_sumstat_formatted_Maternal_Health_Service_U2Mom.xlsx"

# remove accidental extra space after I:/ if needed
file_path <- gsub("I:/\\s+", "I:/", file_path)

df <- read_excel(file_path, sheet = "equiplot")

#====================================================
# 2. Keep relevant columns and reshape
#====================================================
df_long <- df %>%
  select(indicator, mv_q1, mv_q2, mv_q3, mv_q4, mv_q5, order) %>%
  pivot_longer(
    cols = starts_with("mv_q"),
    names_to = "quintile",
    values_to = "value"
  ) %>%
  mutate(
    quintile = recode(
      quintile,
      mv_q1 = "Q1",
      mv_q2 = "Q2",
      mv_q3 = "Q3",
      mv_q4 = "Q4",
      mv_q5 = "Q5"
    ),
    quintile = factor(quintile, levels = c("Q1", "Q2", "Q3", "Q4", "Q5"))
  )

#====================================================
# 3. Create two subsets
#====================================================

# (A) Women's empowerment by multivariate vulnerability quintile
df_emp <- df_long %>%
  filter(order >= 19) %>%
  mutate(
    indicator = factor(
      indicator,
      levels = rev(df %>% filter(order >= 19) %>% arrange(order) %>% pull(indicator))
    )
  )

# (B) Perinatal health services utilization by multivariate vulnerability quintile
df_mom <- df_long %>%
  filter(order < 10) %>%
  mutate(
    indicator = factor(
      indicator,
      levels = rev(df %>% filter(order < 10) %>% arrange(order) %>% pull(indicator))
    )
  )

#====================================================
# 4. Common theme / colors
#====================================================
q_colors <- c(
  "Q1" = "#143d46",
  "Q2" = "#0c6b78",
  "Q3" = "#4f9aa8",
  "Q4" = "#efc76a",
  "Q5" = "#f2a900"
)

common_theme <- theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 20, hjust = 0.5),
    axis.text.y = element_text(size = 16, color = "#005b6e"),
    axis.text.x = element_text(size = 13, color = "#005b6e"),
    axis.title.x = element_text(size = 17, color = "#005b6e"),
    legend.position = "top",
    legend.direction = "horizontal",
    legend.text = element_text(size = 14),
    panel.grid.major.y = element_line(color = "#d9e1e5", linewidth = 0.8),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    axis.title.y = element_blank(),
    plot.background = element_rect(fill = "#dbe5e8", color = NA),
    panel.background = element_rect(fill = "#f7f7f7", color = NA),
    plot.margin = margin(15, 20, 15, 20)
  )

#====================================================
# 5. Plot function
#====================================================

make_equiplot <- function(dat, plot_title,
                          show_legend = TRUE,
                          title_width = 60,
                          title_align = "center",
                          title_size = 18,
                          point_size = 3.5,
                          title_color = "#1f4e79",
                          y_text_size = 16,   # 🔹 NEW
                          x_text_size = 13,   # 🔹 NEW
                          x_title_size = 15   # 🔹 NEW
) {
  
  # wrap title
  wrapped_title <- stringr::str_wrap(plot_title, width = title_width)
  
  # alignment
  hjust_val <- ifelse(title_align == "left", 0, 0.5)
  
  p <- ggplot(dat, aes(x = value, y = indicator, group = indicator)) +
    geom_line(linewidth = 0.9, color = "#1f4e79") +
    geom_point(aes(color = quintile), size = point_size) +
    
    scale_x_continuous(
      limits = c(0, 100),
      breaks = seq(0, 100, by = 10),
      expand = expansion(mult = c(0.02, 0.02))
    ) +
    scale_color_manual(values = q_colors) +
    
    labs(
      title = wrapped_title,
      x = "% of Mothers with U2 children",
      color = NULL
    ) +
    
    common_theme +
    
    theme(
      # 🔹 Title
      plot.title = element_text(
        size = title_size,
        hjust = hjust_val,
        lineheight = 1.1,
        margin = margin(b = 10),
        color = title_color
      ),
      
      # 🔹 Axis text control
      axis.text.y = element_text(size = y_text_size, color = "#005b6e"),
      axis.text.x = element_text(size = x_text_size, color = "#005b6e"),
      axis.title.x = element_text(size = x_title_size, color = "#005b6e")
    )
  
  if (!show_legend) {
    p <- p + theme(legend.position = "none")
  }
  
  p
}

#====================================================
# 6. Make the two plots
#====================================================
p1 <- make_equiplot(
  df_emp,
  "(A) Women's empowerment indicators by multivariate index of vulnerability quintile",
  title_align = "center",
  title_size = 15, 
  point_size = 4,
  y_text_size = 12,   # ↓ reduce slightly
  x_text_size = 11,   # ↑ increase slightly
  x_title_size = 12
  )

p2 <- make_equiplot(
  df_mom,
  "(B) Perinatal health services utilization by multivariate index of vulnerability quintile", 
  title_align = "center",
  title_size = 15, 
  point_size = 4,
  y_text_size = 12,   # ↓ reduce slightly
  x_text_size = 11,   # ↑ increase slightly
  x_title_size = 12
  )

#====================================================
# 7. Combine into 2 rows x 1 column
#====================================================
combined_plot <- p1 / p2 +
  plot_layout(heights = c(1, 1))

# Show plot
combined_plot

#====================================================
# 8. Export
#====================================================
ggsave(
  filename = "EquiPlot_Combined_MVR.png",
  plot = combined_plot,
  width = 14,
  height = 16,
  dpi = 300
)


################################################################################


library(tidyverse)

# Example data
df <- tribble(
  ~indicator, ~mv_q1, ~mv_q2, ~mv_q3, ~mv_q4, ~mv_q5, ~order,
  "Decision Authority",                67.6, 67.6, 84.6, 74.6, 82.2, 21,
  "Child Feeding",                     21.7, 22.1, 56.3, 56.7, 59.1, 22,
  "Child Health",                       4.6,  7.8, 33.0, 29.5, 41.4, 23,
  "Child Well-being",                   7.5, 33.2, 44.0, 52.1, 64.0, 24,
  "Household Purchase",                32.0, 68.9, 73.2, 76.7, 78.1, 25,
  "Women's Control Over Earnings",      2.0, 23.2, 28.8, 41.8, 48.1, 26,
  "Family Visit",                      27.9, 31.5, 54.0, 62.7, 61.8, 27,
  "Women's Health",                    33.8, 56.7, 60.1, 62.4, 68.6, 28
)

# If you already have the Excel/Stata-imported data, use that instead of the tribble above

plot_df <- df %>%
  filter(order >= 19) %>%
  pivot_longer(
    cols = starts_with("mv_q"),
    names_to = "quintile",
    values_to = "value"
  ) %>%
  mutate(
    quintile = recode(
      quintile,
      mv_q1 = "Q1",
      mv_q2 = "Q2",
      mv_q3 = "Q3",
      mv_q4 = "Q4",
      mv_q5 = "Q5"
    ),
    quintile = factor(quintile, levels = c("Q1", "Q2", "Q3", "Q4", "Q5")),
    indicator = factor(indicator, levels = df %>% arrange(order) %>% pull(indicator))
  )

ggplot(plot_df, aes(x = value, y = indicator, group = indicator)) +
  geom_line(linewidth = 0.8, color = "#1f4e79") +
  geom_point(aes(color = quintile), size = 3.2) +
  scale_x_continuous(limits = c(0, 100), breaks = seq(0, 100, by = 10)) +
  scale_color_manual(
    values = c(
      "Q1" = "#143d46",
      "Q2" = "#0c6b78",
      "Q3" = "#4f9aa8",
      "Q4" = "#efc76a",
      "Q5" = "#f2a900"
    )
  ) +
  labs(
    title = "(A) Women's empowerment indicators by multivariate index of vulnerability quintile",
    x = "% of Mothers with U2 children",
    y = NULL,
    color = NULL
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 20, hjust = 0.5),
    axis.text.y = element_text(size = 13),
    axis.text.x = element_text(size = 12),
    axis.title.x = element_text(size = 15),
    legend.position = "top",
    legend.direction = "horizontal",
    legend.text = element_text(size = 13),
    panel.grid.major.y = element_line(color = "#d9d9d9", linewidth = 0.6),
    panel.grid.minor = element_blank()
  )
