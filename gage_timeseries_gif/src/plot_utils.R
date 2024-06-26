

#' Plot bar chart of active gages
#' @param gage_melt long form, gage site_no & years active
#' @param yr year being shown
plot_gage_timeseries <- function(gage_melt, yr, font_fam){
  
  # store vars for plotting
  active_year <- as.numeric(yr)
  yr_max <- max(gage_melt$year)
  
  gages_by_year <- gage_melt |>
    group_by(year) |>
    summarize(n_sites = length(unique(site)))
  
  ## plot bar chart
  active_year <- yr
  
  gages_by_year |>
    ggplot(
      aes(year, n_sites)
    ) +
    geom_bar(stat = "identity", fill = "#ededed", width = 0.8) +
    geom_bar(data = .%>% filter(year == active_year), 
             stat = "identity",
             fill = '#0962b2') +
    geom_textline(data = gages_by_year, 
                  aes(x = year, y = n_sites, 
                      label = "Number of active gages through time"),
                  hjust = 0.05,
                  color = 'grey70', size = 8/.pt, vjust = -0.35, text_smoothing = 30,
                  family = font_fam, linecolor = NA
    ) +
    scale_x_continuous(
      breaks = scales::breaks_width(10), 
      expand = c(0,0.025),
      limits = c(NA, 2022)
    ) +
    scale_y_continuous(
      breaks = scales::breaks_width(2000),
      expand = expansion(add = c(500,0))
    ) +
    ylab(NULL) + xlab(NULL) +
    theme(
      text = element_text(size = 22/.pt, margin=margin(r = 0, t = 0)),
      plot.background = element_rect(fill = 'white'),
      panel.background = element_rect(fill = 'white'),
      axis.line = element_line(color = "#ededed", linewidth = 0.25),
      axis.ticks = element_blank(),
      axis.text.y = element_text(hjust = 1, margin=margin(r = -0.5, t = 0)),
      axis.text.x = element_text(vjust = 0, margin=margin(r = 0, t = -2))
    )
  
}

#' Plot map of active gages
#' @param gage_melt long form, gage site_no & years active
#' @param active_year year being shown
#' @param site_map shifted sites to matcvh state_map
#' @param state_map shifted states and territories
plot_gage_map <- function(gage_melt, active_year, site_map, state_map){
  
  # filter gage data to given year
  yr_gages <- gage_melt |>
    filter(year == as.numeric(active_year)) |>
    distinct(site)
  
  # convert to sf 
  states.sf <- state_map |> st_as_sf()
  sites.sf <- site_map |> st_as_sf() |> 
    distinct() |> 
    st_transform(st_crs(states.sf)) |>
    st_intersection(states.sf) # drops south pacific islands
                                  
  # sites active in a given year
  gages_active <- sites.sf |>
    filter(site_no %in% yr_gages$site)
  
  # plot map
  gage_map <- gages_active |>
    ggplot() +
    geom_sf(data = states.sf, fill = '#ededed',
            linewidth = 0.25, color = 'white') +
    geom_sf(color = '#0962b2', size = 0.1, alpha = 0.7) +
    theme_void() 
  
  return(gage_map)
  
}


#' Compose map and bar chart together
#' @param bar_chart timeseries bar chart of active flow gages
#' @param year year being shown
#' @param gage_map map of active gages
compose_chart <- function(bar_chart, gage_map, year){
  
  ggdraw(xlim = c(0, 1), ylim = c(0,1)) +
    # create background canvas
    draw_grob(grid::rectGrob(
      x = 0, y = 0, 
      width = 2, height = 2,
      gp = grid::gpar(fill = 'white', alpha = 1, col = 'white')
    )) +
    draw_plot(
      gage_map,
      x = 0,
      y = 0.2,
      height = 0.8
      )+
    draw_plot(
      bar_chart,
      x = 0.05,
      y = 0,
      height = 0.25, width = 1 - 0.1
    )
  
  ggsave(sprintf('out/gage_time_%s.png', year), width = 5, height = 4, dpi = 300, units = 'in')
  
}

#' Animate frames to create gif
#' @param frames list of pngs, frames for gif
#' @param out_file output file name for gif
#' @param frame_delay_cs time spent on each frame
#' @param reduce logical, whether or not to apply gifsicle compression
#' @param frame_rate frames per second 
animate_frames_gif <- function(frames, out_file, reduce = TRUE, frame_delay_cs, frame_rate){
  frames %>%
    image_read() %>%
    image_join() %>%
    image_animate(
      delay = frame_delay_cs,
      optimize = TRUE,
      fps = frame_rate
    ) %>%
    image_write(out_file)
  
  if(reduce == TRUE){
    optimize_gif(out_file, frame_delay_cs)
  }
  
  return(out_file)
  
}

#' Resize frames
#' @param frames list of pngs, frames for gif
#' @param scale_width desired output frame width
#' @param scale_percent optional, resize frames using percent of current size
#' @param dir_out Directory to store resized frames 
resize_frames <- function(frames, scale_width, scale_percent = NULL, dir_out) {
  
  if(!dir.exists(dir_out)) dir.create(dir_out)
  
  frames_in <- frames %>%
    image_read() %>%
    image_join()
  info <- image_info(frames_in)
  
  # scale png frames proportionally 
  # either based on a percentage of current size or width
  if(!is.null(scale_percent)){
    scale_width <- info$width*(scale_percent/100)
  }
  
  frames_scaled <- frames_in %>%
    image_scale(scale_width) 
  
  png_names <-  sprintf('%s/%s', dir_out, gsub('out/', '', frames)) 
  map2(as.list(frames_scaled), png_names, ~image_write(.x, .y))
  
  return(png_names)
  
}


#' Optimize gif
#' @param out_file output file name for gif
#' @param frame_delay_cs time spent on each frame
optimize_gif <- function(out_file, frame_delay_cs) {
  
  # simplify the gif with gifsicle - cuts size by about 2/3
  gifsicle_command <- sprintf('gifsicle -b -O3 -d %s --colors 20 %s',
                              frame_delay_cs, out_file)
  system(gifsicle_command)
  
  return(out_file)
}

