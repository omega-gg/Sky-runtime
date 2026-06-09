# [Bash](../README.md) Image tools

## Configuration

Place your ffmpeg binaries into the SKY_PATH_BIN/ffmpeg folder or set SKY_PATH_FFMPEG.

Place your imageMagick binaries into the SKY_PATH_BIN/imageMagick folder or set
SKY_PATH_IMAGE_MAGICK.

Place your fonts into SKY_PATH_BIN/font or set SKY_PATH_FONT.

## Tools

### [create.sh](create.sh): Create an image based on layers

```
Usage: create <output> <layer1> [layer2 ...]

examples:
    create output.png input.svg
    create output.psd layer1.png layer2.png
```

### [create-size.sh](create-size.sh): Create an image with a given size based on layers

```
Usage: create-size <output> <size> <layer1> [layer2 ...]

examples:
    create-size output.png 128 input.svg
    create-size output.psd 256 layer1.png layer2.png
```

### [convert.sh](convert.sh): Convert an image to another format

```
Usage: convert <input> <output> [options...]

examples:
    convert input.png output.jpg -q:v 2
    convert input.png output.webp -c:v libwebp -lossless 1
```

### [resize.sh](resize.sh): Resize an image

```
Usage: resize <input> <output> <width> <height> [filter = bilinear]

filter: fast_bilinear, bilinear, bicubic, experimental, neighbor, area, bicublin, gauss
        sinc, lanczos, spline, print_info, accurate_rnd, full_chroma_int
        full_chroma_inp, bitexact, unstable

examples:
    resize input.png output.png 128 128
    resize input.png output.png 128 -1
```

### [expand.sh](expand.sh): Expand the image

```
Usage: expand <input> <output> <left | ratio> [top] [right = left] [bottom = top]
              [color = transparent]

examples:
    expand input.png output.png 128 128 white
    expand input.png output.png 32 64 48 56
    expand input.png output.png 0.3 0.2
    expand input.png output.png 16:9
    expand input.png output.png 2.39:1
```

### [crop.sh](crop.sh): Crop the image

```
Usage: crop <input> <output> <left | ratio> [top] [right = left] [bottom = top]

examples:
    crop input.png output.png 128 128
    crop input.png output.png 32 64 48 56
    crop input.png output.png 0.3 0.2
    crop input.png output.png 16:9
    crop input.png output.png 2.39:1
```

### [rotate.sh](rotate.sh): Rotate an image

```
Usage: rotate <input> <output> [angle = $angle] [options...]

examples:
    rotate input.png output.jpg  180
    rotate input.png output.webp -90 -c:v libwebp -lossless 1
```

### [flip.sh](flip.sh): Flip an image

```
Usage: flip <input> <output> [flip = $flip] [options...]

examples:
    flip input.png output.jpg horizontal -q:v 2
    flip input.png output.webp vertical -c:v libwebp -lossless 1
```

### [adjust.sh](adjust.sh): Adjust the image brightness and contrast

```
Usage: adjust <input> <output> <brightness> [contrast]

brightness: default = 0.0
contrast:   default = 1.0

example:
    adjust input.png output.jpg 0.5 1.2
```

### [balance.sh](balance.sh): Adjust the image color balance

```
Usage: color <input> <output> <red> <green> <blue>

red, green, blue: -1.0 to 1.0 (default = 0.0)

example:
    color input.png output.jpg 0.1 0 -0.1
```

### [colorize.sh](colorize.sh): Colorize an image with a given color

```
Usage: colorize <input> <output> [color = $color]

examples:
    colorize input.png output.png red
```

### [rectangle.sh](rectangle.sh): Create an image with a given size and color

```
Usage: rectangle <output> [width = $width] [height = $height] [color = $color]

examples:
    rectangle output.png 320
    rectangle output.png 320 200 white
```

### [border.sh](border.sh): Add a border around the image

```
Usage: border <input> <output> <size> [color = transparent]

example:
    border input.png output.png 32 white
```

### [text.sh](text.sh): Add text to an image

```
Usage: text <input> <output> <text> [size = $size] [position = $position]
            [color = $color] [color_background = $color_background] [font = $font]
            [ratio = $ratio]

position: left, top, bottom, right

examples:
    text input.png output.png "text"
    text input.png output.png "text" 128 left green white verdana.ttf
```

### [icon.sh](icon.sh): Add an icon to an image

```
Usage: icon <input> <output> <icon> [size = $size] [position = $position]
            [color_background = $color_background] [ratio = $ratio]

position: left, top, bottom, right

examples:
    icon input.png output.png icon.png
    icon input.png output.png icon.svg 128 left white 2.4
```

### [blur.sh](blur.sh): Blur an image

```
Usage: blur <input> <output> [strength = 10] [filter = gblur]

filter: gblur
        boxblur
        smartblur
```
