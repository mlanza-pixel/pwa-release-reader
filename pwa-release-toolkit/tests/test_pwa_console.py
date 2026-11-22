import importlib.util, json, pathlib, subprocess, sys
from unittest.mock import patch
P=pathlib.Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('pwa_console',P/'python/pwa_console.py');mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)

def good(tmp_path):
    (tmp_path/'package.json').write_text('{"name":"demo"}')
    (tmp_path/'dist').mkdir();(tmp_path/'dist/index.html').write_text('<h1>ok</h1>')
    (tmp_path/'capacitor.config.json').write_text('{"appId":"org.sample.demo","appName":"Demo"}')
    (tmp_path/'.git').mkdir()
    mod.prepare(tmp_path)
    return tmp_path

def test_missing_project(tmp_path):
    assert mod.main(['doctor','--project',str(tmp_path/'absent')])==2

def test_prepare_creates_ignores(tmp_path):
    mod.prepare(tmp_path)
    t=(tmp_path/'.gitignore').read_text()
    assert '*.p12' in t and '*.jks' in t and '*_base64.txt' in t

def test_prepare_preserves_existing(tmp_path):
    (tmp_path/'.gitignore').write_text('my_custom_rule\n')
    mod.prepare(tmp_path)
    assert 'my_custom_rule' in (tmp_path/'.gitignore').read_text()

def test_prepare_idempotent(tmp_path):
    mod.prepare(tmp_path);a=(tmp_path/'.gitignore').read_text();mod.prepare(tmp_path)
    assert a==(tmp_path/'.gitignore').read_text()

def test_valid_project_passes_structural_checks(tmp_path):
    r=mod.report(good(tmp_path));d={x['id']:x for x in r['checks']}
    for k in ['package','dist','gitignore','appid','appname','git']:assert d[k]['status']=='PASS'

def test_placeholder_bundle_fails(tmp_path):
    good(tmp_path);(tmp_path/'capacitor.config.json').write_text('{"appId":"com.example.myapp","appName":"Demo"}')
    assert next(x for x in mod.checks(tmp_path) if x['id']=='appid')['status']=='FAIL'

def test_corrupt_config_fails(tmp_path):
    good(tmp_path);(tmp_path/'capacitor.config.json').write_text('{')
    assert next(x for x in mod.checks(tmp_path) if x['id']=='config')['status']=='FAIL'

def test_missing_ignore_fails(tmp_path):
    good(tmp_path);(tmp_path/'.gitignore').unlink()
    assert next(x for x in mod.checks(tmp_path) if x['id']=='gitignore')['status']=='FAIL'

def test_missing_ignore_pattern_fails(tmp_path):
    good(tmp_path);(tmp_path/'.gitignore').write_text('*.key\n')
    assert next(x for x in mod.checks(tmp_path) if x['id']=='ignore_*.p12')['status']=='FAIL'

def test_secret_detection(tmp_path):
    good(tmp_path);(tmp_path/'example.p12').write_bytes(b'not-real-secret')
    assert next(x for x in mod.checks(tmp_path) if x['id']=='credentials')['status']=='WARN'

def test_report_logs_json(tmp_path):
    good(tmp_path);out=tmp_path/'logs/check.json';x=mod.report(tmp_path,out)
    assert json.loads(out.read_text())['version']==x['version']

def test_cli_nonzero_on_failed_checks(tmp_path):
    assert mod.main(['doctor','--project',str(tmp_path)])==1

def test_cli_prepare(tmp_path):
    assert mod.main(['prepare','--project',str(tmp_path)])==0

def test_cli_status(tmp_path):
    good(tmp_path);assert mod.main(['status','--project',str(tmp_path)]) in (0,1)

def test_python_has_no_upload_or_git_mutation_calls():
    s=(P/'python/pwa_console.py').read_text()
    for phrase in ('git push','git add','git commit','curl ','requests.post','subprocess.run('):assert phrase not in s
