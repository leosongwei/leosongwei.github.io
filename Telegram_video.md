ffmpeg压制微信和Telegram能看的视频
-----------------------------------

`ffmpeg -i 'b.gif' -c:v libx264 -crf 30 -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" output.mp4`
