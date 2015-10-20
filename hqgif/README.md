# High Quality GIF

Encodes GIF using custom palette generated for a whole video stream

### Usage
```
turbo run turbo/hqgif <frame rate> <input file pattern> <output file>
turbo run turbo/hqgif 2.5 screenshot_%d.bmp c:\output\screencast.gif
```

### Build
```
turbo build turbo.me --mount="%~dp0=c:\temp" --no-base --overwrite
```