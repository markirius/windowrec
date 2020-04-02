#!/bin/bash

function getmainwindow(){
  main="$(xrandr | grep -w connected  | awk -F'[ +]' '{print $5}')"
  xwin="$(xwininfo -root)"
  width=$(echo $xwin | awk -FWidth: '{ print $2 }' | cut -d ' ' -f2)
  height=$(echo $xwin | awk -FHeight: '{ print $2 }' | cut -d ' ' -f2)
}

function getarea(){
  getmainwindow
  xwin="$(xwininfo)"
  width=$(echo $xwin | awk -FWidth: '{ print $2 }' | cut -d ' ' -f2)
  height=$(echo $xwin | awk -FHeight: '{ print $2 }' | cut -d ' ' -f2)
  absx=$(echo $xwin | awk -F"Absolute upper-left X:" '{ print $2 }' | cut -d ' ' -f2)
  absy=$(echo $xwin | awk -F"Absolute upper-left Y:" '{ print $2 }' | cut -d ' ' -f2)
}

function help(){
  echo "usage: windowrec -commands"
  echo 
  echo "	-help      print this message"
  echo "	           by default recording at 60 fps and no mouse pointer with audio"
  echo "	-15        record only 15 minutes"
  echo "	-tutorial  record full screen at 30 fps and mouse pointer"
  echo "	-lossless  record with minimal compression"
}

if [ ! "$(man xwininfo)" ] || [ ! "$(man ffmpeg)" ] || [ ! "$(man pulseaudio)" ]; then
  echo "Please install the xwininfo and ffmpeg and pulseaudio..."
elif [[ ! $1 ]]; then
  getmainwindow
  ffmpeg -video_size $width'x'$height -framerate 60 -f x11grab -draw_mouse 0 -i $DISPLAY -f pulse -ac 2 -i $main -vcodec libx264 -crf 22 -preset ultrafast -threads 4 $HOME/output_`date +%H%M%Y%m%d`.mkv
  exit
elif [[ $1 = "-15" ]]; then
  getarea
  ffmpeg -video_size $width'x'$height -framerate 60 -f x11grab -draw_mouse 0 -i $DISPLAY.0'+'$absx','$absy -f pulse -ac 2 -i $main -preset veryfast -to 00:15:00 $HOME/output_`date +%H%M%Y%m%d`.mkv
  exit
elif [[ $1 = "-tutorial" ]]; then
  getmainwindow
  ffmpeg -video_size $width'x'$height -framerate 60 -f x11grab -draw_mouse 1 -i $DISPLAY -f pulse -ac 2 -i $main -vcodec libx264 -crf 22 -preset ultrafast -threads 4 $HOME/output_`date +%H%M%Y%m%d`.mp4
  exit
elif [[ $1 = "-lossless" ]]; then
  getarea
  ffmpeg -video_size $width'x'$height -framerate 60 -f x11grab -draw_mouse 0 -i $DISPLAY.0'+'$absx','$absy -f pulse -ac 2 -i $main -vcodec libx264 -crf 0 -preset ultrafast -threads 4 $HOME/output_`date +%H%M%Y%m%d`.mkv
  exit
elif [[ $1 = "-help" ]]; then
  help
  exit
else
  exit
fi
