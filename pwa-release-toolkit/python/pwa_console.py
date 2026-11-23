#!/usr/bin/env python3
# PWA Release Toolkit 2.5: safe, offline-first validation.
import argparse, csv, datetime, json, os, pathlib, re, shutil, subprocess, sys
VERSION='2.5.0-RC13'
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

def github_readiness(project, progress=None):
    """Read-only pre-upload checks. Never changes repository history or uploads files."""
    project=target_dir(project)
    rows=[]
    def add(code,name,passed,detail,level='WARN'):
        row={'id':code,'check':name,'status':'PASS' if passed else level,'detail':detail}
        rows.append(row)
        if progress: progress(row,len(rows))
    rootindex=(project/'index.html').is_file()
    distindex=(project/'dist'/'index.html').is_file()
    add('website','Website entry point found',rootindex or distindex,'index.html in root' if rootindex else ('dist/index.html' if distindex else 'Select the actual website folder; no files were moved'),'FAIL')
    add('git','Git available',bool(shutil.which('git')),'Required for Git-based upload; browser upload is an alternative')
    add('ignore','.gitignore present',(project/'.gitignore').is_file(),'Run Prepare Safety before Git upload')
    if (project/'.gitignore').is_file():
        content=(project/'.gitignore').read_text(encoding='utf-8-sig',errors='replace')
        for rule in ('*.key','*.p12','*.p8','*.jks','*.mobileprovision','*_base64.txt','.env','node_modules/'):
            add('rule_'+rule,'Ignore rule '+rule,rule in content.splitlines(),'Safety rule is missing; review the file')
    risky=[]; oversized=[]; count=0
    ignoreparts={'.git','node_modules','.venv','__pycache__'}
    for f in project.rglob('*'):
        if any(part in ignoreparts for part in f.relative_to(project).parts):continue
        if not f.is_file():continue
        count+=1
        if f.suffix.lower() in SECRET_SUFFIXES or f.name.lower() in BLOCKED_NAMES or f.name.lower().startswith('.env'):
            risky.append(str(f.relative_to(project)))
        try:
            if f.stat().st_size>25*1024*1024:oversized.append(str(f.relative_to(project)))
        except OSError:pass
    add('sensitive','No obvious credential filenames found',not risky,f'{len(risky)} possible credential files identified; inspection remains necessary'+(': '+', '.join(risky[:4]) if risky else ''),'FAIL')
    add('count','Browser upload batch size',count<=100,f'{count} files (excluding common tool folders); browser upload supports up to 100 files at once. Use multiple batches or Git.')
    add('size','Browser upload size',not oversized,f'{len(oversized)} files exceed browser 25 MiB per-file limit'+(': '+', '.join(oversized[:3]) if oversized else ''))
    add('repo','Git repository not mandatory for browser upload',True,'A local .git directory is required only for Git-based push; GitHub repository creation is a manual step')
    add('approval','Manual upload approval required',False,'This diagnostic never uploads anything. Review every proposed file and confirm in Excel.')
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
    parser.add_argument('command',choices=['doctor','prepare','status','github-check'])
    parser.add_argument('--project',required=True,help='Path to YOUR PWA website or prepared app project')
    parser.add_argument('--output',help='Write results as JSON to this local file')
    parser.add_argument('--status-tsv',help='Write tab-separated check results for Excel')
    parser.add_argument('--progress',help='Write live progress to this local file')
    parser.add_argument('--console-log',help='Write each printed progress line to this file')
    parser.add_argument('--history-dir',help='Append run history and archive individual run files')
    args=parser.parse_args(argv)
    def emit(message):
        print(message,flush=True)
        if args.console_log:
            lp=pathlib.Path(args.console_log)
            lp.parent.mkdir(parents=True,exist_ok=True)
            with lp.open('a',encoding='utf-8') as lf: lf.write(message+'\n')
    run_started=datetime.datetime.now(datetime.timezone.utc)
    run_id=run_started.strftime('%Y%m%d_%H%M%S_%f')+'_'+args.command
    if args.console_log:
        atomic_text(args.console_log,'PWA Toolkit '+VERSION+' | '+args.command+' | Run '+run_id)
    def archive(rc):
        if not args.history_dir:return rc
        try:
            history=pathlib.Path(args.history_dir)
            history.mkdir(parents=True,exist_ok=True)
            run=history/'runs'/run_id
            run.mkdir(parents=True,exist_ok=False)
            # Each run has a dedicated copy, so subsequent commands cannot erase it.
            names=[(args.output,'results.json'),(args.status_tsv,'checks.tsv'),(args.console_log,'console.txt'),(args.progress,'progress.txt')]
            for f,name in names:
                if f and pathlib.Path(f).is_file(): shutil.copy2(f,run/name)
            data=None
            if args.output and pathlib.Path(args.output).is_file():
                try:data=json.loads(pathlib.Path(args.output).read_text(encoding='utf-8-sig'))
                except (ValueError,OSError):pass
            if not isinstance(data,dict) or (data.get('mode') not in (None,args.command) and args.command!='doctor'):
                data=None
            summary=(data or {}).get('summary') or {'PASS':0,'WARN':0,'FAIL':0}
            if args.status_tsv and pathlib.Path(args.status_tsv).is_file():
                try:
                    with pathlib.Path(args.status_tsv).open(encoding='utf-8-sig') as f:
                        rr=list(csv.DictReader(f,delimiter='\t'))
                    summary={k:sum(row.get('STATUS')==k for row in rr) for k in ('PASS','WARN','FAIL')}
                except (ValueError,OSError):pass
            meta={'run_id':run_id,'started_utc':run_started.isoformat(),'finished_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'mode':args.command,'project':args.project,'exit_code':rc,'summary':summary,'archive':str(run)}
            (run/'run.json').write_text(json.dumps(meta,indent=2),encoding='utf-8')
            history_file=history/'run_history.tsv'
            new=not history_file.exists()
            with history_file.open('a',encoding='utf-8',newline='') as f:
                writer=csv.writer(f,delimiter='\t',lineterminator='\n')
                if new:writer.writerow(['RUN ID','UTC START','MODE','PASS','WARN','FAIL','EXIT','PROJECT','ARCHIVE'])
                writer.writerow([run_id,run_started.isoformat(),args.command,summary.get('PASS',0),summary.get('WARN',0),summary.get('FAIL',0),rc,args.project,str(run)])
        except (OSError,ValueError) as err:
            print('WARNING: Could not archive run: '+str(err),flush=True)
        return rc
    try:
        if args.command=='github-check':
            if args.progress: atomic_text(args.progress,'0|GITHUB|RUNNING|Checking upload safety')
            def cb(row,num):
                emit(f'[{num:02d}] [{row["status"]}] {row["check"]}: {row["detail"]}')
                if args.progress: atomic_text(args.progress,f'{num}|{row["id"]}|{row["status"]}|{row["check"]}')
            rows=github_readiness(args.project,cb)
            data={'version':VERSION,'mode':'github-check','project':str(target_dir(args.project)),'checks':rows,'summary':{st:sum(x['status']==st for x in rows) for st in ('PASS','WARN','FAIL')}}
            if args.output: atomic_text(args.output,json.dumps(data,indent=2))
            if args.status_tsv: write_status_tsv(args.status_tsv,rows)
            if args.progress: atomic_text(args.progress,'100|GITHUB|REVIEW|No upload performed; manual approval required')
            emit('GITHUB READINESS '+str(data['summary'])+'; no files uploaded')
            return archive(1 if data['summary']['FAIL'] else 0)
        if args.command=='prepare':
            msg=prepare(args.project)
            emit('[100%] '+msg)
            if args.progress: atomic_text(args.progress, '100|PREPARE|PASS|'+msg)
            if args.output: atomic_text(args.output,json.dumps({'version':VERSION,'mode':'prepare','project':str(target_dir(args.project)),'summary':{'PASS':1,'WARN':0,'FAIL':0},'checks':[{'id':'prepare','check':'Protect credentials using .gitignore','status':'PASS','detail':msg}]},indent=2))
            if args.status_tsv: write_status_tsv(args.status_tsv, [{'id':'prepare','check':'Protect credentials using .gitignore','status':'PASS','detail':msg}])
            return archive(0)
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
        return archive(1 if data['summary']['FAIL'] else 0)
    except (OSError,ValueError) as e:
        emit('ERROR: '+str(e))
        return archive(2)
if __name__=='__main__':sys.exit(main())
