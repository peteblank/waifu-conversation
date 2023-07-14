import pyftdi.serialext
from pyftdi.ftdi import Ftdi

#replace ftdi with what your port.py says
ser = pyftdi.serialext.serial_for_url("ftdi://ftdi:232:A50285BI/1")
ser.baudrate =  115200
ser.write_timeout = 0.1


while True:
    try:
            data = ser.read(1)
            #print(data)
            if data != ' ':
                print("It works!")
    except KeyboardInterrupt:
         break

ser.close()

