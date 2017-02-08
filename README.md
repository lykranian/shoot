## shoot

bash script for taking screenshots and sharing
on several different services (more to come)

#### usage

`shoot -h`

```
simple screenshot script
https image link is copied to clipboard

set $DESTINATION on line 13

  usage : shoot
        : shoot -s
        : shoot filename

   args : none        fullscreen
        : -s          select area
        : <filename>  upload file
        : -h          show this help

   deps : maim+slop OR scrot
        : pngcrush
        : libimage-exiftool-perl
        : xclip
        : jq
        : keybase (optional)
```