import time
import pyautogui

print("Hello, World!")
count=0

while True: 
   print(count)
   count = count+1
   time.sleep(5)
   print(pyautogui.position())
#   pyautogui.click(100, 100)
#   pyautogui.moveTo(100, 150)
