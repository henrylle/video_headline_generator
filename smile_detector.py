import cv2
import sys

face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml') 
eye_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_eye.xml') 
smile_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_smile.xml') 

def has_smile (path_image):
  img=cv2.imread(path_image)
  gray=cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)  
  faces = face_cascade.detectMultiScale(gray,1.3,5)
  smile_detected=False
  for (x, y, w, h) in faces:
      cv2.rectangle(img, (x,y), ((x+w), (y+h)), (255,0,0),2)
      roi_gray=gray[y:y+h, x:x+w]
      roi_color=img[y:y+h, x:x +w]
      smiles=smile_cascade.detectMultiScale(roi_gray,scaleFactor=1.8,minNeighbors=30)        
      if len(smiles):        
        smile_detected=True 
        break     
  return smile_detected


#print(has_smile(sys.argv[1]))