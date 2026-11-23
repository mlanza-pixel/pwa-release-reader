import json,re,unittest
from pathlib import Path
from bs4 import BeautifulSoup
ROOT=Path(__file__).resolve().parents[2]
class CookbookTests(unittest.TestCase):
 def test_toolkit_before_appendices(self):
  names=[c['id'] for c in self.book['chapters']]
  self.assertLess(names.index('part-viii-the-windows-toolkit-cookbook'), names.index('appendices'))
  self.assertGreater(names.index('part-viii-the-windows-toolkit-cookbook'),names.index('chapter-38-the-12-tester-testing-requirement-demystified'))
 @classmethod
 def setUpClass(cls):
  cls.book=json.loads((ROOT/'content'/'book.json').read_text(encoding='utf-8'))
  cls.ids={c['id'] for c in cls.book['chapters']}
 def test_42_recipes(self):
  ch=[c for c in self.book['chapters'] if re.match(r'chapter-\d+-',c['id'])]
  self.assertEqual(len(ch),42)
  for c in ch:
   s=BeautifulSoup(c['html'],'html.parser')
   main=s.select_one('article.friendly-chapter');self.assertIsNotNone(main,c['id'])
   self.assertGreaterEqual(len(main.select('ol > li')),4,c['id'])
   self.assertTrue(main.select_one('img') or main.select_one('.howto-box table'),c['id'])
   self.assertIsNotNone(main.find(string=re.compile('One example to compare with your screen')),c['id'])
 def test_nine_appendices(self):
  a=[c for c in self.book['chapters'] if c['id'].startswith('appendix-')]
  self.assertEqual(len(a),9)
 def test_images_exist(self):
  for c in self.book['chapters']:
   for x in BeautifulSoup(c.get('html',''),'html.parser').select('img[src]'):
    src=x.get('src')
    if not src.startswith(('http:','https:','data:')):self.assertTrue((ROOT/src).exists(),src)
 def test_internal_links(self):
  for c in self.book['chapters']:
   for x in BeautifulSoup(c.get('html',''),'html.parser').select('a[href^="#/"]'):
    target=x['href'][2:]
    self.assertTrue(target in self.ids or target=='cover',target)
 def test_search_excludes_archived_material(self):
  self.assertEqual(len(self.book['search_index']),58)
  for e in self.book['search_index']:
   self.assertNotIn('Optional historical technical reference',e['text'])
 def test_version(self): self.assertEqual(self.book['metadata']['version'],'v2.5.0-RC18')
if __name__=='__main__':unittest.main()
