import struct
import numpy as np

def decodef16(a):
	array = []
	for x in a:
		mybuf = struct.pack("<H",x)
		a = np.frombuffer(mybuf, dtype=np.float16)[0]
		array.append(a)
	return array


a = [0xBC00,0x4400,0x0000]

print(decodef16(a))

