# Data Processing Script

# Libraries ---------------------------------------------------------------

library(tuber)
library(readr)
library(dplyr)
library(stringr)
library(DT)

# Auth --------------------------------------------------------------------

youtube_api_key <-tuber::yt_get_key()
tuber::yt_set_key(youtube_api_key)

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

dat_videos <- NULL

for (i in 1:nrow(dat_urls)) {
  tmp <-
    dat_urls[i,]["id"] %>%
    dplyr::pull() %>%
    tuber::list_channel_videos(
      .,
      part = "snippet",
      config = list('maxResults' = 200),
      auth = "key"
    )
  dat_videos <- dplyr::bind_rows(dat_videos, tmp)
}

dat_join <-
  dat_videos %>%
  dplyr::left_join(., dat_urls, by = join_by("snippet.channelId" == "id"))

dat_dashboard <-
  dat_join %>%
  dplyr::mutate(
    video_url = paste0(
      "<a href='https://www.youtube.com/watch?v=",
      snippet.resourceId.videoId,
      "' target='_blank'>",
      snippet.title,
      "</a>"
    ),
    channel_url = paste0(
      "<img src='",
      image,
      "' alt='Hex Sticker for Chapter' width='40'></img>",
      "<a href='https://www.youtube.com/channel/",
      snippet.channelId,
      "' target='_blank'>",
      chapter,
      "</a>"
    ),
    date = as.Date(str_sub(snippet.publishedAt, 1, 10))
  ) %>%
  dplyr::arrange(desc(snippet.publishedAt)) %>%
  dplyr::select(date, chapter, channel_url, video_url, channel_image_url)
