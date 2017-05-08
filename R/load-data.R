# Load in link data, shapefile and M50 stats
links <- read_csv("data/links.csv") %>% 
    slice(2:11) %>% 
    select(siteID, Sec) %>% 
    mutate(siteID = as.factor(siteID))

comb_stats <- readRDS("data/combStats.rds") %>% 
    ungroup() %>% 
    mutate(month = month(month, label = TRUE, abbr = FALSE)) %>% 
    left_join(links, by = "siteID") 

# Create factor levels to order M50 sections
lev <- c("N11 - CHE", "CHE - CAR", "CAR - BAL", "BAL - FIR", "FIR - N81", "N81 - N7", "N7 - N4",
         "N4 - N3", "N3 - N2")

m50_secs <- st_read("data/m50-secs-wgs.shp") %>% 
    left_join(comb_stats, by = c("sec" = "Sec")) %>% 
    filter(!sec %in% c("BMN - M1, N2 - BMN")) %>% 
    mutate(sec = factor(sec, levels = lev)) %>% 
    arrange(sec)


# Create colour palette for leaflet map
pal <- colorFactor(
    palette = "Set1",
    domain = m50_secs$sec,
    ordered = FALSE)



# Dates for dashboard sidebar dropdowns
years <- c(2015)
months <- month(seq.Date(as.Date("2015-01-01"), 
                         as.Date("2015-12-31"), 
                         by = "month"),
                label = TRUE, 
                abbr = FALSE)

# Text output explaining indicators
ind_expl <- paste("Vehicle Km", "Explanation of vkm", sep = "\n")