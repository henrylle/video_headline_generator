# video_headline_generator
Project to generate automatically headline for a video

Important Informations
1. Video input recommendation is 16:9 aspect ratio. Ex: 1920x1080
2. The output video will be on `stage` folder. The name will be `final`_NAME_VIDEO_PATH 


# Request Example

+ Parameter 1: Video_Path
+ Parameter 2: Video_Duration to output. If original video duration is longer, will be cut. To render entire video set 0 value.
+ Parameter 3: Input text for headline. Head and botton texts. Both are required.
``` 
./scripts.sh video.mp4 15
```
