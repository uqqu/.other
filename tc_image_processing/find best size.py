import json
import os
import re
import requests
import sys
import winsound
from bs4 import BeautifulSoup
from PIL import Image

if __name__ == "__main__":
	if len(sys.argv) > 1:
		f = False
		path = sys.argv[1]
		searchUrl = 'https://yandex.ru/images/search'
		params = {'rpt': 'imageview', 'format': 'json', 'request': '{"blocks":[{"block":"b-page_type_search-by-image__link"}]}'}
		if len(sys.argv) > 3:
			counter = [0, 0, 0] # replaced, best, unique
			f = open(f"{path}\\image_search.log", "w")
		for img in sys.argv[2:]:
			i_path = '\\'.join(img.split('\\')[:-1])
			i_name, i_format = img.split('\\')[-1].split('.')
			current = f"{i_path}\\{i_name}.{i_format}"
			try:
				pil_img = Image.open(current)
			except:
				continue
			b_width, b_height = pil_img.size
			pil_img.close()
			open_image = open(current, 'rb')
			files = {'upfile': ('blob', open_image, 'image/jpeg')}
			try:
				response = requests.post(searchUrl, params=params, files=files)
			except Exception as e:
				if f:
					f.write(f"{e}\n{e.with_traceback}\n")
				winsound.Beep(3000, 500)
				break
			query_string = json.loads(response.content)['blocks'][0]['params']['url']
			img_search_url= searchUrl + '?' + query_string
			open_image.close()
			soup = BeautifulSoup(requests.get(img_search_url).text, "html.parser")
			try:
				search = soup.find_all("div", class_="CbirOtherSizes")[0].div.find_next_sibling("div").div.div.div.a
			except:
				if f:
					counter[2] += 1
					f.write(f"{current} ({b_width}x{b_height}) have no other sizes\n")
				continue
			while True:
				if requests.get(search.get('href'), allow_redirects=True).status_code == 200:
					break
				else:
					search = search.find_next_sibling("a")
					if search is None:
						break
			if search is None:
				if f:
					counter[2] += 1
					f.write(f"{current} ({b_width}x{b_height}) have no other sizes\n")
				continue
			size = [int(x) for x in search.span.string.split("×")]
			if size[0] > b_width and size[1] > b_height or size[0] * size[1] > b_width * b_height:
				os.rename(current, f"{i_path}\\.old.{i_name}.{i_format}")
				open(current[:-len(current.split('.')[-1])] + search.get('href').split('.')[-1].split('?')[0], 'wb').write(requests.get(search.get('href'), allow_redirects=True).content)
				if f:
					counter[0] += 1
					f.write(f"{current} ({b_width}x{b_height}) was replaced by {size[0]}x{size[1]}\n")
			else:
				if f:
					counter[1] += 1
					f.write(f"{current} ({b_width}x{b_height}) is the best size. The best alternate is {size[0]}x{size[1]}\n")
		if f:
			f.write(f"{counter[0]} images have been replaced; {counter[1]} have the best possible sizes; {counter[2]} is unique.")
			f.close()
		winsound.Beep(1500, 150)