# Data Processing Script - OLD
# This script works. Unfortunately,
# the YouTube RSS feed only grabs
# the latest 15 videos whereas the
# YouTube API will give you all the
# videos from a channel.
# But, I'm keeping this file in case
# it's helpful to you.

# Libraries ---------------------------------------------------------------

library(tidyRSS)
library(readr)
library(dplyr)
library(stringr)
library(DT)

# Data --------------------------------------------------------------------

dat <-
  read_csv("r-ladies_channels.csv")

# Processing --------------------------------------------------------------

dat_urls <-
  dat %>%
  dplyr::mutate(
    feed = paste0("https://www.youtube.com/feeds/videos.xml?channel_id=", id),
    feed_url = paste0("yt:channel:", id),
    channel_image_url = paste0(
      "<img src='",
      image,
      "' alt='Hex Sticker for Chapter' width='40'></img>",
      " <a href='https://www.youtube.com/channel/",
      id,
      "' target='_blank'>",
      chapter,
      "</a><br>"
    ),
  )

dat_feeds  <- NULL

for (i in 1:nrow(dat_urls)) {
  tmp <-
    dat_urls[i, ][4] %>%
    tidyfeed(.,
             config = list('maxResults' = 50))
  
  dat_feeds <- rbind(dat_feeds, tmp)
}

dat_join <-
  dat_feeds %>%
  left_join(., dat_urls, by = "feed_url")

dat_feeds2 <-
  dat_join %>%
  mutate(
    video_url = paste0(
      "<a href='",
      entry_link,
      "' target='_blank'>",
      entry_title,
      "</a>"
    ),
    channel_url = paste0(
      "<img src='",
      image,
      "' alt='Hex Sticker for Chapter' width='40'></img>",
      "<a href='https://www.youtube.com/channel/",
      id,
      "' target='_blank'>",
      chapter,
      "</a>"
    ),
    date = as.Date(str_sub(entry_published, 1, 10))
  ) %>%
  arrange(desc(entry_published)) %>%
  select(date, chapter, channel_url, video_url, channel_image_url)
