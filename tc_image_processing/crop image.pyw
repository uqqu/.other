import re, sys, winsound
from PIL import Image

if __name__ == "__main__":
	if len(sys.argv) > 1:
		coord = [x for x in sys.argv if re.search('^[0-9]+$', x)]
		images = set(sys.argv[1:]) - set(coord)
		coord = [int(coord[x]) if len(coord) > x else 0 for x in range(4)]
		for img in images:
			temp = img.split('\\')
			path = '\\'.join(temp[:-1])
			f_name, f_format = temp[-1].split('.')
			try:
				orig = Image.open(f"{path}\\{f_name}.{f_format}")
			except:
				continue
			s_format = orig.format
			w, h = orig.size
			cropped = orig.crop((coord[0],coord[1],w-coord[2],h-coord[3]))

			if s_format == 'JPEG':
				quantization = getattr(orig, 'quantization', None)
				quality = 100 if quantization is None else -1
				cropped.save(f"{path}\\{f_name}.{f_format}", format=s_format, quality=quality, subsampling=-1, qtables=quantization)
			else:
				cropped.save(f"{path}\\{f_name}.{f_format}", format=s_format, quality=100)

		if len(sys.argv) > 27:
			winsound.Beep(1500, 150)