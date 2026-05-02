################################################################################
################################################################################
library(tidyverse)
library(gridExtra)
library(grid)
library(stringr)

################################################################################
################################################################################

df <- tribble(
  ~factor, ~A, ~B, ~C, ~D, ~E, ~F, ~G, ~H,
  "Wealth Quintile", 39.9, 18.9, 17.1, 35.0, 27.0, 35.8, 32.0, 42.9,
  "Household Income", 0.6, 0.0, 8.8, 3.8, 0.0, 0.3, 0.2, 0.2,
  "Women’s Empowerment", 5.1, 3.1, 1.1, 0.2, 0.3, 0.2, 0.5, 0.6,
  "Distance to Health Facility", 26.9, 59.6, 6.1, 1.0, 11.3, 7.6, 10.0, 12.6,
  "Accessibility Strata", 3.4, 3.3, 28.2, 33.4, 31.6, 22.7, 31.9, 21.3,
  "Maternal Education", 17.3, 3.0, 22.0, 11.8, 11.7, 14.5, 4.4, 2.1,
  "Residual (unexplained)", 6.9, 12.1, 16.6, 14.8, 18.1, 18.7, 21.1, 20.2
)

factor_order <- c(
  "Wealth Quintile",
  "Household Income",
  "Women’s Empowerment",
  "Distance to Health Facility",
  "Accessibility Strata",
  "Maternal Education",
  "Residual (unexplained)"
)

indicator_titles <- c(
  A = "(A) Antenatal Care (Any Provider)",
  B = "(B) Antenatal Care (Trained Provider, ≥4 Visit)",
  C = "(C) Institutional Deliveries",
  D = "(D) Delivery (Trained Provider)",
  E = "(E) Postnatal Care (Any Provider)",
  F = "(F) Postnatal Care (Trained Provider)",
  G = "(G) Newborn Care within 24 Hours (Any Provider)",
  H = "(H) Newborn Care within 24 Hours (Trained Provider)"
)

factor_colors <- c(
  "Wealth Quintile" = "#ed1c24",
  "Household Income" = "#2f6173",
  "Women’s Empowerment" = "#20a97b",
  "Distance to Health Facility" = "#6f3fb4",
  "Accessibility Strata" = "#2682bd",
  "Maternal Education" = "#a9cfe8",
  "Residual (unexplained)" = "#b8b8b8"
)

plot_data <- df %>%
  pivot_longer(
    cols = A:H,
    names_to = "indicator",
    values_to = "percent"
  ) %>%
  mutate(
    factor = factor(factor, levels = factor_order),
    indicator = factor(indicator, levels = names(indicator_titles))
  )

################################################################################
make_donut <- function(indicator_id) {
  
  dat <- plot_data %>%
    filter(indicator == indicator_id) %>%
    arrange(factor) %>%
    mutate(
      fraction = percent / sum(percent),
      ymax = cumsum(fraction),
      ymin = lag(ymax, default = 0),
      label = paste0(as.character(factor), ": ", sprintf("%.1f%%", percent))
    )
  
  ggplot(dat) +
    geom_rect(
      aes(
        ymin = ymin,
        ymax = ymax,
        xmin = 2.7,
        xmax = 4,
        fill = factor
      ),
      color = "#eeeeee",
      linewidth = 0.6
    ) +
    coord_polar(theta = "y") +
    xlim(c(1.7, 6.2)) +
    scale_fill_manual(
      values = factor_colors,
      breaks = factor_order,
      labels = dat$label
    ) +
    labs(
      title = indicator_titles[[indicator_id]],
      fill = NULL
    ) +
    theme_void() +
    theme(
      plot.background = element_rect(fill = "#eeeeee", color = NA),
      panel.background = element_rect(fill = "#eeeeee", color = NA),
      plot.title = element_text(
        size = 16,
        color = "#555555",
        hjust = 0,
        margin = margin(b = 18)
      ),
      legend.position = "right",
      legend.text = element_text(size = 9),
      legend.key.size = unit(0.55, "cm"),
      legend.background = element_rect(fill = "#eeeeee", color = NA)
    )
}
################################################################################

p_list <- map(names(indicator_titles), make_donut)

grid.arrange(
  grobs = p_list,
  ncol = 2
)



################################################################################
################################################################################
# ----------------------------
# 2. Donut function for one panel
# ----------------------------

make_one_donut <- function(indicator_id, panel_title, bg_color = "white") {
  
  dat <- plot_data %>%
    filter(indicator == indicator_id) %>%
    arrange(factor) %>%
    mutate(
      fraction = percent / sum(percent),
      ymax = cumsum(fraction),
      ymin = lag(ymax, default = 0),
      label = paste0(as.character(factor), ": ", sprintf("%.1f%%", percent))
    )
  
  ggplot(dat) +
    geom_rect(
      aes(
        ymin = ymin,
        ymax = ymax,
        xmin = 2.2,      # wider donut
        xmax = 4.2,
        fill = factor
      ),
      color = bg_color,
      linewidth = 0.7
    ) +
    coord_polar(theta = "y") +
    
    # expand plotting space to allow legend and bigger donut
    xlim(c(1.2, 6.8)) +
    
    scale_fill_manual(
      values = factor_colors,
      breaks = factor_order,
      labels = dat$label
    ) +
    
    labs(
      title = str_wrap(panel_title, width = 40),  # automatic wrap
      fill = NULL
    ) +
    
    theme_void() +
    theme(
      # Background
      plot.background  = element_rect(fill = bg_color, color = NA),
      panel.background = element_rect(fill = bg_color, color = NA),
      legend.background = element_rect(fill = bg_color, color = NA),
      legend.key = element_rect(fill = bg_color, color = NA),
      
      # Title (centered, larger, same style as legend)
      plot.title = element_text(
        size = 18,
        color = "#4d4d4d",
        hjust = 0.5,
        face = "plain",
        margin = margin(b = 12)
      ),
      
      # Legend text (same style as title, slightly smaller)
      legend.text = element_text(
        size = 12,
        color = "#4d4d4d"
      ),
      
      legend.position = "right",
      legend.key.size = unit(0.6, "cm"),
      legend.spacing.y = unit(0.1, "cm"),
      
      plot.margin = margin(10, 10, 10, 10)
    )
}

# ----------------------------
# 3. Create each plot separately
#    You can edit each title here
# ----------------------------
pA <- make_one_donut("A", "(A) Antenatal Care\n(Any Provider)")
pB <- make_one_donut("B", "(B) Antenatal Care\n(Trained Provider, ≥4 Visit)")
pC <- make_one_donut("C", "(C) Institutional Deliveries")
pD <- make_one_donut("D", "(D) Delivery\n(Trained Provider)")
pE <- make_one_donut("E", "(E) Postnatal Care\n(Any Provider)")
pF <- make_one_donut("F", "(F) Postnatal Care\n(Trained Provider)")
pG <- make_one_donut("G", "(G) Newborn Care within 24 Hours\n(Any Provider)")
pH <- make_one_donut("H", "(H) Newborn Care within 24 Hours\n(Trained Provider)")

# ----------------------------
# 4. Combine flexibly
# ----------------------------

# Example: 4 rows x 2 columns
grid.arrange(
  pA, pB,
  pC, pD,
  pE, pF,
  pG, pH,
  ncol = 2,
  nrow = 4,
  top = NULL
)
