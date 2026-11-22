import importlib.util
from pathlib import Path
p=Path(__file__).resolve().parents[1]/"python/pwa_console.py"
s=importlib.util.spec_from_file_location("pwa_console_git",p); m=importlib.util.module_from_spec(s); s.loader.exec_module(m)
def test_static_website_is_valid(tmp_path):
 (tmp_path/'index.html').write_text('<h1>hello</h1>')
 d={x['id']:x for x in m.github_readiness(tmp_path)}
 assert d['website']['status']=='PASS'
 assert d['git']['status']=='PASS'
 assert d['approval']['status']=='WARN'
def test_missing_site_fails(tmp_path):
 assert next(x for x in m.github_readiness(tmp_path) if x['id']=='website')['status']=='FAIL'
def test_sensitive_file_blocks(tmp_path):
 (tmp_path/'index.html').write_text('hi')
 (tmp_path/'token.p8').write_text('fake')
 assert next(x for x in m.github_readiness(tmp_path) if x['id']=='sensitive')['status']=='FAIL'
def test_cli_emits_outputs(tmp_path):
 (tmp_path/'index.html').write_text('ok')
 assert m.main(['github-check','--project',str(tmp_path),'--output',str(tmp_path/'report.json'),'--status-tsv',str(tmp_path/'checks.tsv'),'--progress',str(tmp_path/'progress.txt')])==0
 assert (tmp_path/'report.json').is_file() and (tmp_path/'checks.tsv').is_file()
def test_browser_limit_warn(tmp_path):
 (tmp_path/'index.html').write_text('ok')
 for i in range(101): (tmp_path/f'f{i}.txt').write_text('x')
 assert next(x for x in m.github_readiness(tmp_path) if x['id']=='count')['status']=='WARN'
