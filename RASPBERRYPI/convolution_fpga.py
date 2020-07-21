import matplotlib.image as mpimg
from matplotlib import cm
import numpy as np
import codecs
import spidev
import sys
import struct

def convolution2d(image, kernel, bias):
	m, n = kernel.shape
	if (m == n):
		y, x = image.shape
		y = y - m + 1
		x = x - m + 1
		new_image = np.zeros((y,x))
		for i in range(y):
			for j in range(x):
				new_image[i][j] = np.sum(image[i:i+m, j:j+m]*kernel) + bias
	return new_image


def tospi(a):
	array = []
	for x in a.flatten():
		#value = int.from_bytes(np.float16(x).tobytes(),"little")
		value=int(codecs.encode(np.float16(x).tostring(),'hex'), 16)
		array.append(int(value%256))
		array.append(int(value/256))
	return array

def decodef16(a):
	array = []
	for x in a:
		mybuf = struct.pack("<H",x)
		a = np.frombuffer(mybuf, dtype=np.float16)[0]
		array.append(a)
        return array


def xspixfer(code,array):
	res = []
	l = len(array)
	for i in range(0,l,256):
		b = i + 256
		if b > l:
			b = l
		a = [code]
		a.extend(array[i:b])
		response=spi.xfer2(a)
		response.pop(0)
		res.extend(response)
	return res

def to16(array):
	res = []
	for i in range(len(array)):
		if i%2 == 0:
			msb = array[i]
		else:
			res.append(msb * 256 + array[i])
	return res
			
		

		
spi = spidev.SpiDev()
spi.open(0, 0)
spi.mode=0b00 
spi.lsbfirst=False 
#spi.max_speed_hz=31200000
#spi.max_speed_hz=15000000
#spi.max_speed_hz=7629
spi.max_speed_hz=7800000

# address set 0
response=spi.xfer2([0x00,0x00,0x00])

img = mpimg.imread("lena.png")
print(img.shape)
# set shape
response=spi.xfer2([0x02,img.shape[0],img.shape[1]]) 

img = (img * 256)
img = img.astype(np.float16)

print("Load Image")
#print(tospi(img))
# address set 0
response=spi.xfer2([0x00,0x00,0x00])
aimg = tospi(img)
print(len(aimg))

save = [] # copy
for v in aimg:
	save.append(v)

response=xspixfer(0x04,aimg)

# check memory
# address set 0
response=spi.xfer2([0x00,0x00,0x00])
response=xspixfer(0x40,aimg)
for i in range(len(response)):
	if (response[i] != save[i]):
		print("{}: recv {} - send {}".format(i,response[i],save[i]))




k = np.array([[0,-1,0],[-1,4,-1],[0,-1,0]],dtype=np.float16)
#k = np.array([[-1,0,-1],[0,4,0],[-1,0,-1]],dtype=np.float16)
#k = np.array([[-1,0,1],[-1,0,1],[-1,0,1]],dtype=np.float16)
#k = np.array([[-1,-1,-1],[0,0,0],[1,1,1]],dtype=np.float16)
#k = np.array([[-2,-1,0],[-1,0,1],[0,1,2]],dtype=np.float16)
#k = np.array([[0,0,0],[0,1,0],[0,0,0]],dtype=np.float16)
#k = np.array([[0,0,0],[0,-1,0],[0,0,0]],dtype=np.float16)

#print(tospi(k))
print("Load Kernel")
# address set 0
response=spi.xfer2([0x00,0x00,0x00])
ak = tospi(k)
ak.insert(0,0x06)
print(ak)
print(type(ak[0]))
response=spi.xfer2(ak)

# address set 0
response=spi.xfer2([0x00,0x00,0x00])
# read back
alist = [0] * 19
alist[0] = 0x60
response =spi.xfer2(alist)
print(response) 
print(type(response[0]))


img2 = convolution2d(img,k,0)

print("Execute")
# address set 0
response=spi.xfer2([0x00,0x00,0x00])
# start
response =spi.xfer2([0x01,0x01])
#
while True:
	response = spi.xfer2([0x10,0x00])
	sys.stdout.write(".")
	if response[1] == 1:
		break

print("")


print("Read output")
# address set 0
response=spi.xfer2([0x00,0x00,0x00])
s = (img.shape[0]-2)*(img.shape[1]-2)*2 
alist = [0] * s
response = xspixfer(0x50,alist)
r = []
for v in response:
	r.append(int(v))
	
#words = to16(response)
words = to16(r)
print(len(words))
words =  decodef16(words)
img_fpga = np.array(words, dtype=np.float32)
img_fpga = img_fpga.reshape((img.shape[0]-2,img.shape[1]-2))
print(img_fpga.shape)
img_fpga=(img_fpga/256)
mpimg.imsave("out_fpga.png",img_fpga,cmap=cm.gray)

 
img2 = img2.astype(np.float32)
print(img2.shape)

img2=(img2 / 256)
mpimg.imsave("out.png",img2,cmap=cm.gray)


spi.close()
