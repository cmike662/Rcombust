import asyncio
from bitstring import Bits, BitArray, BitStream
import time


from bleak import BleakScanner
from bleak.backends.device import BLEDevice
from bleak.backends.scanner import AdvertisementData
from bleak.exc import BleakError

validResponse = bool(True)
lastWrite =time.time()
initialTime = time.time()

def to_f(raw_value):
    return((((BitArray(bin=raw_value).uint) * 0.05)-20) * 9/5.0+32)

def device_found(
    device: BLEDevice, advertisement_data: AdvertisementData):
	
	global validResponse, lastWrite
	validResponse = True
    #time.sleep(1)
    #E9:87:39:C9:64:54
    #C2:71:0D:46:63:F0
	try:
	    combustion_data = advertisement_data.manufacturer_data[0x09C7]
	    print(device.address)
	    if(device.address == "E9:87:39:C9:64:54"):
	        a = BitStream(combustion_data)
	        a.pos=0
	        t = BitArray(combustion_data)
	
	        print(f"Raw data :{t}")
	        print(f"Type {a.read(8).hex}")
	        print(f"ID Code : {a.read(32).hex}")
	
	        c = BitArray(a.read(104))
	        c.byteswap()
	        print(c)
	        d = BitStream(c)
	        
	        b=f'{(time.time() - initialTime):.3f}'+" "
	        for i in range(8):
	            t1 = d.read(13).bin
	            if(t1 == "0000000000000"):
	                validResponse = False
	            b = b+f'{to_f(t1):.1f} '
	        print(b)
	        if (validResponse == False):
	            print("Invalid")
	                       
	        c = BitArray(a.read(32))
	        c.byteswap()
	        d = BitStream(c)
	        mode = d.read(2)
	        print(f"Mode : {mode}") 
	        colorID = d.read(3)
	        probeID = d.read(3)
	        Battery = d.read(8)
	        Reserved = d.read(16)
	        
	        print(47 * "-")
	        if (validResponse):
	            if (time.time() - lastWrite > 5):
	               print("Go")
	               lastWrite = time.time()  
	               f = open("demofile2.csv", "a")
	               f.write(b+"\n")
	               f.close()
	               #time.sleep(5)
	except KeyError:
        # Apple company ID (0x004c) not found
	    pass


async def main():
    """Scan for devices."""
    scanner = BleakScanner()
    scanner.register_detection_callback(device_found)

    while True:
        await scanner.start()
        await asyncio.sleep(5)
        await scanner.stop()


asyncio.run(main())

        #t12 = a.read(5).bin
        #print(t12)
        #z = '0b000'+t12+t11
        #print(z)
        #z1 = Bits(z)
        #print(z1)
        #print(f"Temp1   : {to_f(z)}")
