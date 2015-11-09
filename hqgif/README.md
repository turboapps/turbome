# High Quality GIF

Encodes GIF using custom palette generated for a whole video stream

### Usage
```
turbo run turbo/hqgif <frame rate> <input file pattern> <output file> [<scale>]
turbo run turbo/hqgif 2.5 screenshot_%d.bmp c:\output\screencast.gif
turbo run turbo/hqgif 1.0 screenshot_%d.bmp c:\output\screencast.gif 340x256
```

### Build
```
turbo build turbo.me --mount="%~dp0=c:\temp" --no-base --overwrite
```