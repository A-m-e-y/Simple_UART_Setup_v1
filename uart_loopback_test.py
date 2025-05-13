import serial

ser = serial.Serial("COMx", 115200)
ser.write(b"ABCD")
print(ser.read(4))  # Should print: b'ABCD'
