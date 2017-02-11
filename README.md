## shoot

bash script for taking screenshots and sharing
on several different services (more to come)

#### usage

`shoot -h`

```
simple screenshot script
https image link is copied to clipboard

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

deletion url for teknik uploads is saved to the $TMP directory, for example `/tmp/shoot/df2Gz.png.deletionKey`