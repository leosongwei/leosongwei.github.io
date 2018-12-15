ffmpeg
-----------------------------------

ffmpeg压制微信和Telegram能看的视频

`ffmpeg -i 'b.gif' -c:v libx264 -crf 30 -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" output.mp4`

两遍压制：

```
$ ffmpeg -y -i 【ガルパン】隊長十色-Ql1yRt6ADj4.mkv -c:v libx264 -b:v 200k -preset veryslow -crf 30 -pix_fmt yuv420p -vf scale=720:400 -pass 1 -an -f mp4 /dev/null
$ ffmpeg -y -i 【ガルパン】隊長十色-Ql1yRt6ADj4.mkv -c:v libx264 -b:v 200k -preset veryslow -crf 30 -pix_fmt yuv420p -vf scale=720:400 -pass 2 -f mp4 -c:a aac -b:a 128k output.mp4
```

从图片制作gif动画：

`ffmpeg -f image2 -r 4 -i '%d.jpg' -vf scale=640x360 a.gif`
