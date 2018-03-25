import requests
from lxml import etree
from bs4 import BeautifulSoup
import pandas as pd
import re

initurl = "http://www.nuforc.org/webreports/ndxloc.html"
prefix = "http://www.nuforc.org/webreports/"

def getLinks(url):
	### Returns all links on page ###
	links = []
	page = requests.get(url)
	soup = BeautifulSoup(page.content, 'html.parser')
	for link in soup.findAll('a'):
		links.append(link.get('href'))
	return links

def removeNonAscii(s): 
	### Remove non-ascii character ###
	return "".join(filter(lambda x: ord(x)<128, s))

def concatLink(link):
	link = prefix + link
	return link

def makeTable(url):
	### Returns contents of table within UFO Page ###
	url = concatLink(url)
	page = requests.get(url)
	soup = BeautifulSoup(page.content, 'html.parser')
	data = soup.findAll('tr')[1:]
	values = [[removeNonAscii(td.getText()) for td in data[i].findAll('td')] 
	for i in range(len(data))]
	return values

f=open('output.txt','w')
for link in getLinks(initurl):
	for l in makeTable(link):
		s1 = '\t'.join(l)
		# s1 = '\t'.join(map(lambda x: "\"" + x + "\"", l))
		f.write(s1)
		f.write('\n')
f.close()