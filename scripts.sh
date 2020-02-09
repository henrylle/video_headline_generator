video_path=$1
video_duration=$2

video_input_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $video_path)

if [ -z "$video_duration" ] || (( $(echo "$video_duration > $video_input_duration" |bc -l) )); then
  video_duration=$video_input_duration   
fi
video_duration_cmd="-t $video_duration"
echo "Video duration is: $video_input_duration" 
echo "Desired Video duration ouput: $video_duration"

exit;

height_video_original=$(ffprobe -v error -show_entries stream=height -of csv=p=0:s=x $video_path)
width_video_original=$(ffprobe -v error -show_entries stream=width -of csv=p=0:s=x $video_path)
printf 'Recovering total video frames: '
total_video_frames=$(ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 $video_path)
printf 'OK\n'
##TEXTO COM FADE NO TOPO
#ffmpeg -i video.mp4 -t 5 -filter_complex "drawtext=text='TUSTAS VIDEO':enable='between(t,0,5)',fade=t=in:start_time=0:d=0.5:alpha=1,fade=t=out:start_time=3.5:d=0.5:alpha=1[fg];[0][fg]overlay=format=auto,format=yuv420p" -c:a copy output.mp4 -y

##BOX BRANCO
#ffmpeg -i video.mp4 -t 1 -filter_complex "drawbox=x=0:y=0:h=250:color=white:thickness=max, drawtext=text='TUSTAS VIDEO':enable='between(t,0,0)',fade=t=in:start_time=0:d=0.5:alpha=1,fade=t=out:start_time=3.5:d=0.5:alpha=1[fg];[0][fg]overlay=format=auto,format=yuv420p" -c:a copy output.mp4 -y

#TEXTO MAIOR NO TOPO
#ffmpeg -i video.mp4 -t 1 -filter_complex "drawtext=text='VOCÊ QUER SE TORNAR UM ESPECIALISTA AWS':fontsize=56:box=1:boxcolor=white:fontcolor=black@0.9" -c:a copy output.mp4 -y

#TEXTO MAIOR NO TOPO E NO RODAPÉ CENTRALIZADO
texto_topo="VOCÊ QUER SE TORNAR UM ESPECIALISTA AWS"
texto_rodape="ASSISTA O VÍDEO ATÉ O FIM"
height_box="(($width_video_original-$height_video_original)*9/16)/2"
height_linha_timer=8
cor_linha_timer=white
centralizar_horizontal="x=(w-text_w)/2"

centralizar_vertical_topo="y=($height_box-text_h)/2"
centralizar_vertical_rodape="y=h-($height_box+text_h)/2"
backgroud_color="yellow"
box_topo="drawbox=x=0:y=0:h=$height_box:color=$backgroud_color:thickness=max"
#box_timer="drawbox=x=0:y=ih-$height_box-$height_linha_timer:h=$height_linha_timer:w=t/8:color=$cor_linha_timer:thickness=max"
box_timer_color="black"
box_rodape="drawbox=x=0:y=ih-$height_box:h=$height_box:color=$backgroud_color:thickness=max"
#resolucao="scale=iw:iw,pad=600:600:(ow-iw)/2:(oh-ih)/2"
width="1080"
height="1080"
resolucao="scale=iw*min($width/iw\,$height/ih):ih*min($width/iw\,$height/ih), pad=$width:$height:($width-iw*min($width/iw\,$height/ih))/2:($height-ih*min($width/iw\,$height/ih))/2"

#ffmpeg -i video.mp4 -t 1 -filter_complex "$box_topo,$box_rodape,drawtext=text='$texto_topo':$centralizar_horizontal:$centralizar_vertical_topo:fontsize=56:box=1:boxcolor=white:fontcolor=black@0.9,drawtext=text='$texto_rodape':y=1024:fontsize=56:box=1:boxcolor=white:fontcolor=black@0.9:$centralizar_horizontal:$centralizar_vertical_rodape" -c:a copy output.mp4 -y

##Extrair somente imagem
#ffmpeg -i video.mp4 -t 1 -filter_complex "$box_topo,$box_rodape,drawtext=text='$texto_topo':$centralizar_horizontal:$centralizar_vertical_topo:fontsize=56:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9,drawtext=text='$texto_rodape':y=1024:fontsize=56:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9:$centralizar_horizontal:$centralizar_vertical_rodape,$resolucao" -vframes 1  -y xdg-open output.jpg

##Extrair Video Quadrado
ffmpeg -i $video_path $video_duration_cmd -filter_complex "$resolucao" -c:a copy output_quadrado.mp4 -y

##ESSE AQUI GERA BACANA, SÓ NÃO ANIMA O TIMER DO PROGRESSO
#ffmpeg -i output_quadrado.mp4 -t 1 -filter_complex "$box_topo,$box_timer,$box_rodape,drawtext=text='$texto_topo':$centralizar_horizontal:$centralizar_vertical_topo:fontsize=56:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9,drawtext=text='$texto_rodape':y=1024:fontsize=56:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9:$centralizar_horizontal:$centralizar_vertical_rodape,$resolucao" -c:a copy output.mp4 -y
#ffmpeg -i output_quadrado.mp4  -filter_complex "$box_topo,$box_timer,$box_rodape,drawtext=text='$texto_topo':$centralizar_horizontal:$centralizar_vertical_topo:fontsize=56:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9,drawtext=text='Percentual\: %{eif\:n*100/$total_video_frames \:d}  Tempo\: %{eif\:t\:d}s':y=1024:x=w/1*mod(10\,1):fontsize=32:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9,$resolucao" -c:a copy output.mp4 -y

#ESSE AQUI É PRA TENTAR ADICIONAR A LINHA DO TIMER
ffmpeg -i  output_quadrado.mp4 $video_duration_cmd -f lavfi -i "color=$box_timer_color:size=1080x1080" \
-t $video_duration -filter_complex "[0:v]setsar=sar=1/1[saida_video_0];[saida_video_0][1:v]overlay=-(main_w-(n/$total_video_frames)*main_w):main_w-$height_box-$height_linha_timer[out]" \
-map [out] -map 0:a output_timer.mp4 -y

ffmpeg -i output_timer.mp4  -filter_complex "$box_topo,$box_rodape,drawtext=text='$texto_topo':$centralizar_horizontal:$centralizar_vertical_topo:fontsize=56:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9,drawtext=text='Percentual\: %{eif\:n*100/$total_video_frames \:d}  Tempo\: %{eif\:t\:d}s':y=1024:x=w/1*mod(10\,1):fontsize=32:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9,drawtext=text='$texto_rodape':y=1024:fontsize=56:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9:$centralizar_horizontal:$centralizar_vertical_rodape,$resolucao" -c:a copy output_final.mp4 -y

ffplay output_final.mp4

#ffprobe -i output.mp4
echo  $height_box | bc