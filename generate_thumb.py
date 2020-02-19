import os
import constants
import smile_detector
import subprocess


def generate_thumb(path, position_in_ms):
  """Generate Thumb using ffmpeg"""
  position_in_second=position_in_ms/1000
  output_path="temp/thumb_pos_{0}.png".format(position_in_ms)
  subprocess.check_call("ffmpeg -i {0} {1} -ss {2} -y -vframes 1 {3}".format(path,constants.LOG_LEVEL_FFMPEG, position_in_second,output_path),shell=True)      
  print(output_path)
  return output_path

def generate_friendly_thumb(path):
  found_friendly_thumb=False  
  
  current_time_in_ms=constants.START_TIME_FIND_FRIENDLY_THUMB_IN_MS
  output_path_friendly_thumb=""
  while not found_friendly_thumb:    
    output_path_friendly_thumb=generate_thumb(path,current_time_in_ms)
    found_friendly_thumb=False    
    current_time_in_ms+=constants.TIME_INCREMENT_IN_MS  
    if not smile_detector.has_smile(output_path_friendly_thumb):
      os.remove(output_path_friendly_thumb)
    else:
      print("I found a friendly image. Path {0}".format(output_path_friendly_thumb))  
  return True