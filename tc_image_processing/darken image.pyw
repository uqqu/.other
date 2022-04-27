import sys, winsound
from PIL import Image, ImageStat

# 1/30 ↑
# 1/6  ↓

if __name__ == "__main__":
	if len(sys.argv) > 1:
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

			top = orig.crop((0,0,w,int(h/30)))
			bot = orig.crop((0,h-int(h/6),w,h))

			if sum(ImageStat.Stat(top).mean) > 400:
				for i in range(0, 100, 2):
					for x in range(w):
						for t in (0,1):
							r, g, b, *_ = orig.getpixel((x, i+t))
							orig.putpixel((x, i+t), (int(r*(i/200+.5)), int(g*(i/200+.5)), int(b*(i/200+.5))))

			if sum(ImageStat.Stat(bot).mean) > 750:
				for i in range(0, 320):
					for x in range(w):
						r, g, b, *_ = orig.getpixel((x, h-i-1))
						orig.putpixel((x, h-i-1), (int(r*(i/320)), int(g*(i/320)), int(b*(i/320))))

			if s_format == 'JPEG':
				quantization = getattr(orig, 'quantization', None)
				quality = 100 if quantization is None else -1
				orig.save(f"{path}\\{f_name}.{f_format}", format=s_format, quality=quality, subsampling=-1, qtables=quantization)
			else:
				orig.save(f"{path}\\{f_name}.{f_format}", format=s_format, quality=100)
		
		if len(sys.argv) > 10:
			winsound.Beep(1500, 150)