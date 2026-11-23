from pathlib import Path
import json,sys,re
from html.parser import HTMLParser
root=Path(__file__).resolve().parent.parent
errors=[]
def req(rel):
 p=root/rel
 if not p.is_file(): errors.append('Missing: '+rel)
 return p
for rel in ['index.html','manifest.json','sw.js','content/book.json','css/styles.css','js/app.js','js/search.js']:
 req(rel)
manifest=json.loads(req('manifest.json').read_text(encoding='utf-8'))
for icon in manifest.get('icons',[]):req(icon['src'])
b=json.loads(req('content/book.json').read_text(encoding='utf-8'))
ids={c['id'] for c in b['chapters']}
class Links(HTMLParser):
 def __init__(self): super().__init__(); self.a=[];self.img=[]
 def handle_starttag(self,tag,attrs):
  d=dict(attrs)
  if tag=='a' and d.get('href','').startswith('#/'):self.a.append(d['href'][2:])
  if tag=='img' and d.get('src','').startswith('images/'):self.img.append(d['src'])
for c in b['chapters']:
 h=Links();h.feed(c.get('html',''))
 for a in h.a:
  if a not in ids and a!='cover':errors.append(f'Broken chapter link: {a}')
 for im in h.img:req(im)
print('Reader source check: '+('PASS' if not errors else 'FAIL'))
print('Chapters:',len(b['chapters']),'Icons:',len(manifest.get('icons',[])),'Errors:',len(errors))
for e in errors:print(' -',e)
print('Not a browser, offline, signing, or store approval test.')
sys.exit(bool(errors))
