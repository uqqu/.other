import sys
from PIL import Image

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
			orig = orig.crop((1,1,w-1,h-1))

			if s_format == 'JPEG':
				quantization = getattr(orig, 'quantization', None)
				quality = 100 if quantization is None else -1
				orig.save(f"{path}\\{f_name}.{f_format}", format=s_format, quality=quality, subsampling=-1, qtables=quantization)
			else:
				orig.save(f"{path}\\{f_name}.{f_format}", format=s_format, quality=100)