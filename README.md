# video_headline_generator
Project to generate automatically headline for a video

Important Informations
1. Video input recommendation is 16:9 aspect ratio. Ex: 1920x1080
2. The output video will be on `stage` folder. The name will be `final`_NAME_VIDEO_PATH 


# Parameters

+ Parameter 1: Video_Path
+ Parameter 2: Video_Duration to output. If original video duration is longer, will be cut. To render entire video set 0 value.
+ Parameter 3: Input text for headline. Head and botton texts. Both are required.

# Env Variables

+ PREVIEW: If true, will render a preview for headline on video. If false or empty will render all steps. Default is false
+ VERBOSE: If true will render all output from ffmpeg and another logs. If false or empty will render minimal logs. Default is false
+ SHOW_TIMER_AND_PERCENT_ON_BOTTOM: If true will render percent video and duration on video bottom. Default is false
+ THEME: Concept to introduce possibility to choose a limited options for combine font-color, backgroud-color and timer-color. The default options is: DEFAULT
  - [DEFAULT]
    * backgroud_color="white"
    * box_timer_color="black"
    * font_color="black"
    * font_size=56
  - [AUSTIN]
    * backgroud_color="yellow"
    * box_timer_color="black"
    * font_color="black"
    * font_size=50

 Options available: DEFAULT | AUSTIN.

Example Request:
``` 
THEME=AUSTIN PREVIEW=false VERBOSE=false ./scripts.sh stage/video.mp4 15 stage/input_headline_text.txt
```
