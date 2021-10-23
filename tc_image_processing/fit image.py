import sys, winsound
from PIL import Image

if __name__ == "__main__":
	if len(sys.argv) > 1:
		nw, nh = 1080, 1920
		for img in sys.argv[1:]:
			temp = img.split('\\')
			path = '\\'.join(temp[:-1])
			f_name, f_format = temp[-1].split('.')
			try:
				orig = Image.open(f"{path}\\{f_name}.{f_format}")
			except:
				continue
			s_format = orig.format
			w, h = orig.size
			if nh/h > nw/w:
				tw = int(w*(nh/h))
				residue = (tw - nw) % 2
				crop = int((tw - nw) / 2)
				orig = orig.resize((tw, nh))
				resized = orig.crop((crop,0,tw-crop-residue,nh))
			elif nh/h < nw/w:
				th = int(h*(nw/w))
				residue = (th - nh) % 2
				crop = int((th - nh) / 2)
				orig = orig.resize((nw, th))
				resized = orig.crop((0,crop,nw,th-crop-residue))
			else:
				resized = orig.resize((nw,nh))

			if s_format == 'JPEG':
				quantization = getattr(orig, 'quantization', None)
				quality = 100 if quantization is None else -1
				resized.save(f"{path}\\{f_name}.{f_format}", format=s_format, quality=quality, subsampling=-1, qtables=quantization)
			else:
				resized.save(f"{path}\\{f_name}.{f_format}", format=s_format, quality=100)

		if len(sys.argv) > 10:
			winsound.Beep(1500, 150)