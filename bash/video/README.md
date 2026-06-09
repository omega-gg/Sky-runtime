# [Bash](../README.md) Video tools

## Configuration

Place your ffmpeg binaries into the SKY_PATH_BIN/ffmpeg folder or set SKY_PATH_FFMPEG.

## Tools

### [concat.sh](concat.sh): Concatenate two videos into one

```
Usage: concat <videoA> <video2> <output>
```

### [concat-zoom.sh](concat-zoom.sh): Zoom on a still image and append it to the video

```
Usage: concat-zoom <image> <video> <output>
                   [codec | lossless]

This command output is usefull to generate a wide background and turn 16:9 into 21:9 \
```

### [cut.sh](cut.sh): Cut the video a the provided timestamps

```
Usage: cut <video> <timeA> <timeB> <output> [precise]
           [codec | lossless]
```

### [reverse.sh](reverse.sh): Reverse the video

```
Usage: reverse <video> <output>
```

### [loop.sh](loop.sh): Generate a looped version of the video

```
Usage: loop <video> <output> [reverse]
```

### [resize.sh](resize.sh): Resize a video to match the length of a longer one

```
Usage: resize <video> <reference video> <output> [skip=0] [chop=0]
              [codec | lossless]
```

### [wide.sh](wide.sh): Turn a 16:9 video into CinemaScope

```
Usage: wide <video> <output> [codec | lossless]
```

### [volume.sh](volume.sh): Adjust the audio volume

```
Usage: volume <input> <output> <volume>
```

### [tempo.sh](tempo.sh): Adjust the audio tempo

```
Usage: tempo <input> <output> <tempo> [volume]
```

### [frame.sh](frame.sh): Extract a still frame from the video

```
Usage: frame <video> <time> <output image> [fast]

Timestamp formats:
    ss[.ms]         26.5
    m:ss[.ms]       0:26.250
    h:mm:ss[.ms]    00:00:26.123

example:
    frame input.mp4 2:10 frame.png
```
