import requests
headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.3; WOW64; rv:41.0) Gecko/20100101 Firefox/41.0'}
response = requests.get("https://data.services.jetbrains.com/products/releases?code=IIU%2CIIC&latest=true&type=release", headers=headers, timeout=10)
response.raise_for_status()
json = response.json()
print(json['IIC'][0]['downloads']['windows']['link'])