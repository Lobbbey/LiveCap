from ultralytics import YOLO
import cv2
import numpy as np

#Model
MODEL_PATH = "yolov8m.pt"
model = YOLO(MODEL_PATH)

#Inference
img = ('image.jpg')
results = model(img)

#Load image
img2 = cv2.imread('image.jpg')

#Get result and filter out all classes besides person
for r in results:
    for box in r.boxes:

        class_id = int(box.cls[0])
        class_name = model.names[class_id]

        #Filter out all classes
        if class_id != 0:
            continue
        
        #Send (x2,y1) top right corner to Unity via socket
        x1,y1,x2,y2 = map(int, box.xyxy[0])

        cv2.rectangle(img2, (x1,y1), (x2,y2), (0,255,0), 2)
        # Put label
        label = f"{class_name} ({box.conf[0]:.2f})"
        cv2.putText(img2, label, (x1, y1 - 10), cv2.FONT_HERSHEY_COMPLEX, 0.5, (0, 255, 0), 2)

        

cv2.imwrite("testing_image.jpg", img2)
print("Saved")
#exported_model = model.export(format='onnx', dynamic=True, simplify=True, opset=12)
#print(f"ONNX model saved to: {exported_model}")
print(model.device)

    