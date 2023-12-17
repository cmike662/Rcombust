import asyncio
from uuid import UUID
from bitstring import Bits, BitArray, BitStream, pack
import time


from bleak import BleakScanner
from bleak.backends.device import BLEDevice
from bleak.backends.scanner import AdvertisementData
from bleak.exc import BleakError

def to_f(raw_value):
    return((((BitArray(bin=raw_value).uint) * 0.05)-20) * 9/5.0+32)

def device_found(
    device: BLEDevice, advertisement_data: AdvertisementData):

    #time.sleep(1)
    try:
        combustion_data = advertisement_data.manufacturer_data[0x09C7]
        print(device.address)
        if(device.address != "D6:73:D3:C6:99:B8"):
        a = BitStream(combustion_data)
        a.pos=0
        t = BitArray(combustion_data)

        print(f"Raw data :{t}")
        print(f"Type {a.read(8).hex}")
        print(f"ID Code : {a.read(32).hex}")

        #b = a.read(104)
        c = BitArray(a.read(104))
        c.byteswap()
        print(c)
        d = BitStream(c)

        t1 = d.read(13).bin
        print((t1))
        print(to_f(t1))

        t2 = d.read(13).bin
        print((t2))

        t3 = d.read(13).bin
        print((t3))
        
        t4 = d.read(13).bin
        print((t4))
        
        t5 = d.read(13).bin
        print((t5))
        
        t6 = d.read(13).bin
        print((t6))
        t7 = d.read(13).bin
        print((t7))
        
        t8 = d.read(13).bin
        print((t8))
        
        
        c = BitArray(a.read(32))
        c.byteswap()
        d = BitStream(c)
        mode = d.read(2)
        print(f"Mode : {mode}") 
        colorID = d.read(3)
        probeID = d.read(3)
        Battery = d.read(8)
        Reserved = d.read(16)

        #print(f"Temp1   : {to_f(t1)}")
        #print(f"Temp2   : {to_f(t2)}")        
        print(47 * "-")
    except KeyError:
        # Apple company ID (0x004c) not found
        pass


async def main():
	
    #try:       
    #    scanner = await BleakScanner.find_device_by_address("E9:87:39:C9:64:54", timeout=10.0)
    #    scanner.register_detection_callback(device_found)
    #    if not scanner:
    #        raise BleakError(f"A device with address {d} could not be found.")
    #except BleakError as e:
    #    print(e)
    """Scan for devices."""
    scanner = BleakScanner()
    #scanner = BleakScanner.find_device_by_address('E9:87:39:C9:64:54')
    #scanner = await BleakScanner.find_device_by_address('E9:87:39:C9:64:54', timeout=10.0)
    #if not scanner:
    #    raise BleakError(f"A device with address {ble_address} could not be found.")
    scanner.register_detection_callback(device_found)

    while True:
        await scanner.start()
        await asyncio.sleep(5.0)
        await scanner.stop()


asyncio.run(main())

        #t12 = a.read(5).bin
        #print(t12)
        #z = '0b000'+t12+t11
        #print(z)
        #z1 = Bits(z)
        #print(z1)
        #print(f"Temp1   : {to_f(z)}")
