video_path=$1
video_duration=$2
clean_temp_folder=true
name_video_path=$(basename $video_path)
square_version_path="temp/square_$name_video_path"
square_version_with_timer_path="temp/square_version_with_timer_$name_video_path"
final_video_path="stage/final_$name_video_path"

log_level_ffmpeg="-loglevel panic"
if [ ! -z $VERBOSE] && [ $VERBOSE == "true" ]; then
  log_level_ffmpeg=""
fi

error_output() {
  echo 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
  echo "ERROR! ==> $1";
  echo 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
  exit 1;
}

check_error() {
  if [ $? != 0 ]; then
    error_output "Erro ao renderizar video..."
    exit 1;
  fi
}

spinner(){
  chars="/-\|"

  while :; do
    for (( i=0; i<${#chars}; i++ )); do
      sleep 0.5
      echo -en "${chars:$i:1}" "\r"
    done
  done
}

load_input_file_header_text() {
  #Load input text to headline  
  if [ -z "$1" ]; then
    echo 'ERROR: Please, inform a input file path with variables header_text and bottom_text'
    exit 1;    
  else
    source $1
  fi
}

video_input_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $video_path)

if [ -z "$video_duration" ] || [ "$video_duration" == 0 ] || (( $(echo "$video_duration > $video_input_duration" |bc -l) )); then
  video_duration=$video_input_duration    
fi





video_duration_cmd="-t $video_duration"
if [ ! -z $VERBOSE] && [ $VERBOSE == "true" ]; then
  echo "Video duration is: $video_input_duration" 
  echo "Desired Video duration ouput: $video_duration"
fi

height_original_video=$(ffprobe -v error -show_entries stream=height -of csv=p=0:s=x $video_path)
width_original_video=$(ffprobe -v error -show_entries stream=width -of csv=p=0:s=x $video_path)

width="1080"
height="1080"
resolucao="scale=iw*min($width/iw\,$height/ih):ih*min($width/iw\,$height/ih), pad=$width:$height:($width-iw*min($width/iw\,$height/ih))/2:($height-ih*min($width/iw\,$height/ih))/2"



##Extrair Video Quadrado
if [ $PREVIEW != true ]; then
  printf '1/4: Extracting square video: '
  ffmpeg -i $video_path $video_duration_cmd $log_level_ffmpeg -filter_complex "$resolucao" -c:a copy $square_version_path -y
  check_error
  printf 'OK\n'
  printf '2/4: Recovering total video frames: '
  total_frames_video=$(ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 $square_version_path)
  printf 'OK\n'
fi

load_input_file_header_text $3

#TEXTO MAIOR NO TOPO E NO RODAPÉ CENTRALIZADO
height_box="(($width_original_video-$height_original_video)*9/16)/2"
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

#ffmpeg -i video.mp4 -t 1 -filter_complex "$box_topo,$box_rodape,drawtext=text='$header_text':$centralizar_horizontal:$centralizar_vertical_topo:fontsize=56:box=1:boxcolor=white:fontcolor=black@0.9,drawtext=text='$bottom_text':y=1024:fontsize=56:box=1:boxcolor=white:fontcolor=black@0.9:$centralizar_horizontal:$centralizar_vertical_rodape" -c:a copy output.mp4 -y

##Extrair somente imagem
#ffmpeg -i video.mp4 -t 1 -filter_complex "$box_topo,$box_rodape,drawtext=text='$header_text':$centralizar_horizontal:$centralizar_vertical_topo:fontsize=56:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9,drawtext=text='$bottom_text':y=1024:fontsize=56:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9:$centralizar_horizontal:$centralizar_vertical_rodape,$resolucao" -vframes 1  -y xdg-open output.jpg

#ffplay $video_path -vf "$resolucao, drawtext=text='$header_text':$centralizar_horizontal:$centralizar_vertical_topo:fontsize=56:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9"
#exit;

##ESSE AQUI GERA BACANA, SÓ NÃO ANIMA O TIMER DO PROGRESSO
#ffmpeg -i output_quadrado.mp4 -t 1 -filter_complex "$box_topo,$box_timer,$box_rodape,drawtext=text='$header_text':$centralizar_horizontal:$centralizar_vertical_topo:fontsize=56:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9,drawtext=text='$bottom_text':y=1024:fontsize=56:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9:$centralizar_horizontal:$centralizar_vertical_rodape,$resolucao" -c:a copy output.mp4 -y
#ffmpeg -i output_quadrado.mp4  -filter_complex "$box_topo,$box_timer,$box_rodape,drawtext=text='$header_text':$centralizar_horizontal:$centralizar_vertical_topo:fontsize=56:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9,drawtext=text='Percentual\: %{eif\:n*100/$total_frames_video \:d}  Tempo\: %{eif\:t\:d}s':y=1024:x=w/1*mod(10\,1):fontsize=32:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9,$resolucao" -c:a copy output.mp4 -y

#ESSE AQUI É PRA TENTAR ADICIONAR A LINHA DO TIMER
if [ $PREVIEW != true ]; then
  printf '3/4: Adding progress animation: '
  ffmpeg -i  $square_version_path $video_duration_cmd $log_level_ffmpeg -f lavfi -i "color=$box_timer_color:size=1080x1080" \
  -t $video_duration -filter_complex "[0:v]setsar=sar=1/1[saida_video_0];[saida_video_0][1:v]overlay=-(main_w-(n/$total_frames_video)*main_w):main_w-$height_box-$height_linha_timer[out]" \
  -map [out] -map 0:a $square_version_with_timer_path -y
  check_error
  printf 'OK\n'
  
  printf '4/4: Adding headline and box-color: '
  ffmpeg -i $square_version_with_timer_path $log_level_ffmpeg  -filter_complex "$box_topo,$box_rodape,drawtext=text='$header_text':$centralizar_horizontal:$centralizar_vertical_topo:fontsize=56:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9,drawtext=text='Percentual\: %{eif\:n*100/$total_frames_video \:d}  Tempo\: %{eif\:t\:d}s':y=1024:x=w/1*mod(10\,1):fontsize=32:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9,drawtext=text='$bottom_text':y=1024:fontsize=56:box=1:boxcolor=$backgroud_color:fontcolor=black@0.9:$centralizar_horizontal:$centralizar_vertical_rodape,$resolucao" -c:a copy $final_video_path -y
  check_error
  printf 'OK\n'
fi
if [ $clean_temp_folder = true ]; then
  printf 'Cleaning temp folder: '
  rm -f temp/*.mp4
  rm -f temp/*.jpg
  printf 'OK\n'
fi
printf 'Finish!\n'

ffplay $final_video_path