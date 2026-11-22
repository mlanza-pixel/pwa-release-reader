#!/usr/bin/env python3
# PWA Release Toolkit 2.5: safe, offline-first validation.
import argparse, datetime, json, os, pathlib, re, shutil, subprocess, sys
VERSION='2.5.0-RC5'
SECRET_SUFFIXES={'.p12','.p8','.jks','.keystore','.key','.mobileprovision'}
BLOCKED_NAMES={'p12_base64.txt','profile_base64.txt','p8_base64.txt','android_keystore_base64.txt'}
IGNORE_RULES='''# PWA toolkit 2.5 - NEVER COMMIT CREDENTIALS
*.key
*.p12
*.p8
*.jks
*.keystore
*.mobileprovision
*_base64.txt
.env
.env.*
credentials/
secrets/
node_modules/
.DS_Store
'''
def target_dir(s):
    p=pathlib.Path(s).expanduser().resolve()
    if not p.is_dir():raise ValueError('Project folder does not exist: '+str(p))
    return p

def checks(project, progress=None):
    project=target_dir(project)
    rows=[]
    def add(code,name,ok,detail,level='FAIL'):
        row={'id':code,'check':name,'status':'PASS' if ok else level,'detail':detail}
        rows.append(row)
        if progress is not None: progress(row, len(rows))
    for n in ('python','node','npm','npx','git','openssl','java','keytool'):
        cmd=shutil.which(n)
        add('tool_'+n,n+' installed',bool(cmd),cmd or 'Not found in PATH', 'WARN' if n in ('java','keytool','openssl') else 'FAIL')
    add('package','package.json present',(project/'package.json').is_file(),'Needed for a Capacitor project')
    add('dist','web output dist/index.html present',(project/'dist'/'index.html').is_file(),'Build web assets before sync')
    add('gitignore','.gitignore exists',(project/'.gitignore').is_file(),'Credentials must never be uploaded')
    if (project/'.gitignore').exists():
        contents=(project/'.gitignore').read_text(errors='replace')
        for pattern in ('*.key','*.p12','*.p8','*.jks','*.mobileprovision','*_base64.txt'):
            add('ignore_'+pattern,'Ignore '+pattern,pattern in contents,'Required safety pattern')
    config=project/'capacitor.config.json'
    if config.exists():
        try:
            c=json.loads(config.read_text(encoding='utf-8-sig'))
            appid=c.get('appId','')
            add('appid','Valid unique appId',bool(re.fullmatch(r'[A-Za-z][\w]*(\.[A-Za-z][\w]*){2,}',appid)) and not appid.startswith('com.example.'),appid or 'missing')
            add('appname','App name configured',bool(c.get('appName')) and c.get('appName')!='My PWA App',str(c.get('appName','missing')))
        except (ValueError,OSError) as e:add('config','Capacitor config JSON valid',False,str(e))
    else:add('config','Capacitor config present',False,'Create from template')
    git=project/'.git'
    add('git','Git repo initialized',git.exists(),'A local Git repository is required for deployment')
    risky=[]
    for p in project.rglob('*'):
        if '.git' in p.parts or 'node_modules' in p.parts:continue
        if p.is_file() and (p.suffix.lower() in SECRET_SUFFIXES or p.name.lower() in BLOCKED_NAMES):risky.append(str(p.relative_to(project)))
    add('credentials','Credential files require manual review',not risky,'Found '+str(len(risky))+' sensitive files; check Git ignore and never commit them', 'WARN')
    return rows

def report(project,logfile=None,progress=None):
    rows=checks(project,progress)
    out={'version':VERSION,'project':str(target_dir(project)),'generated_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks':rows,'summary':{st:sum(x['status']==st for x in rows) for st in ('PASS','WARN','FAIL')}}
    if logfile:
        logfile=pathlib.Path(logfile);logfile.parent.mkdir(parents=True,exist_ok=True); logfile.write_text(json.dumps(out,indent=2),encoding='utf-8')
    return out

def prepare(project):
    project=target_dir(project)
    dest=project/'.gitignore'
    if dest.exists():
        old=dest.read_text(encoding='utf-8-sig',errors='replace')
        missing=[s for s in IGNORE_RULES.splitlines() if s and not s.startswith('#') and s not in old.splitlines()]
        if missing:
            with dest.open('a',encoding='utf-8',newline='\n') as f:f.write('\n# Added by PWA Toolkit 2.5\n'+'\n'.join(missing)+'\n')
            return 'Added missing safety patterns to existing .gitignore'
        return 'Existing .gitignore already covers required patterns'
    dest.write_text(IGNORE_RULES,encoding='utf-8')
    return 'Created .gitignore with private-key exclusions'

def atomic_text(path, content):
    path=pathlib.Path(path)
    path.parent.mkdir(parents=True,exist_ok=True)
    tmp=path.with_name(path.name+'.tmp')
    tmp.write_text(content+'\n',encoding='utf-8')
    tmp.replace(path)

def write_status_tsv(path,rows):
    path=pathlib.Path(path)
    path.parent.mkdir(parents=True,exist_ok=True)
    tmp=path.with_name(path.name+'.tmp')
    with tmp.open('w',encoding='utf-8',newline='') as f:
        f.write('ID\tCHECK\tSTATUS\tDETAIL\n')
        for row in rows:
            fields=[row[k] for k in ('id','check','status','detail')]
            fields=[re.sub(r'[\t\r\n]+',' ',str(v)) for v in fields]
            f.write('\t'.join(fields)+'\n')
    tmp.replace(path)

def main(argv=None):
    parser=argparse.ArgumentParser(description='PWA Toolkit v2.5: offline checks and safe project preparation')
    parser.add_argument('command',choices=['doctor','prepare','status'])
    parser.add_argument('--project',required=True,help='Path to YOUR actual Capacitor project')
    parser.add_argument('--output',help='Write results as JSON to this local file')
    parser.add_argument('--status-tsv',help='Write tab-separated check results for Excel')
    parser.add_argument('--progress',help='Write live progress to this local file')
    parser.add_argument('--console-log',help='Write each printed progress line to this file')
    args=parser.parse_args(argv)
    def emit(message):
        print(message,flush=True)
        if args.console_log:
            lp=pathlib.Path(args.console_log)
            lp.parent.mkdir(parents=True,exist_ok=True)
            with lp.open('a',encoding='utf-8') as lf: lf.write(message+'\n')
    if args.console_log:
        atomic_text(args.console_log,'PWA Toolkit '+VERSION+' | '+args.command)
    try:
        if args.command=='prepare':
            msg=prepare(args.project)
            emit('[100%] '+msg)
            if args.progress: atomic_text(args.progress, '100|PREPARE|PASS|'+msg)
            if args.status_tsv: write_status_tsv(args.status_tsv, [{'id':'prepare','check':'Protect credentials using .gitignore','status':'PASS','detail':msg}])
            return 0
        if args.progress: atomic_text(args.progress,'0|START|RUNNING|Starting preflight checks')
        def cb(row,num):
            line=f'{num}|{row["id"]}|{row["status"]}|{row["check"]}: {row["detail"]}'
            emit(f'[{num:02d}] [{row["status"]}] {row["check"]}: {row["detail"]}')
            if args.progress:atomic_text(args.progress,line)
        data=report(args.project,args.output,cb)
        if args.status_tsv: write_status_tsv(args.status_tsv,data['checks'])
        if args.progress:atomic_text(args.progress,f'100|FINISH|{"FAIL" if data["summary"]["FAIL"] else "PASS"}|PASS {data["summary"]["PASS"]}, WARN {data["summary"]["WARN"]}, FAIL {data["summary"]["FAIL"]}')
        emit('PWA Toolkit '+VERSION+' | Project: '+data['project'])
        # Progress was printed as each check completed.
        emit('TOTAL '+str(data['summary']))
        return 1 if data['summary']['FAIL'] else 0
    except (OSError,ValueError) as e:
        emit('ERROR: '+str(e))
        return 2
if __name__=='__main__':sys.exit(main())
