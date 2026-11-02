#!/usr/bin/env python3
"""Differential fuzz of the command guard's two comment readings against bash (AMH ledger DD-056).

Frozen: the measurement behind DD-056, retired whole with the owner-queue-closure plan's Unit 2.
Replay, from a scratch directory outside the repository:

    mkdir -p headrepo/scripts
    git -C <repo> show 4d7d716:scripts/command-guard.sh > headrepo/scripts/command-guard.sh
    cp <repo>/amh.conf headrepo/
    python3 <repo>/docs/history/2026-11-02-unit2-comment-fuzz.py \\
        headrepo/scripts/command-guard.sh <repo>/scripts/command-guard.sh 20261102 30000 15000 full.tsv

The recorded run (bash 5.2.21, aarch64 Linux, 2026-11-02) printed 42,569 cases after
de-duplication; its counts are in DD-056. Every generated token is harmless: `printenv` is
resolved on PATH to a stub that creates a file in a fresh temporary directory, and running the
stub is the observation, so echoed text cannot forge a run and an exit status cannot hide one.
Advisory state goes to /dev/null, so no one-time tier is spent. A guard that times out counts
as allowing. The last block splits the added refusals by whether `bash -n` parses the text.
"""
import random, subprocess, sys, os, tempfile, shutil, concurrent.futures as cf
H,N,seed,ns,nf,outp=sys.argv[1],sys.argv[2],int(sys.argv[3]),int(sys.argv[4]),int(sys.argv[5]),sys.argv[6]
R=random.Random(seed)
PRE=['echo a','x=1','(echo a)','( (echo a)','echo $(echo a)','echo `echo a`','case a in a)','case a in (a)',
     '{ echo a','echo "$(printf "x")"','echo "$(printf "fix ','echo <(echo a)','echo >(cat)','if true; then echo a',
     '((1))','(( 1','echo $((1+2))','echo ${x:-a}',"echo 'q'",'echo "q"','f() { :','a=(1','echo [a]','a=',
     'cat <<EOF','cat <<<x','echo a >x','echo $(','echo `','cat <(','echo ${x:- ','[[ x =~ (','echo @(a',
     'echo $(case a in a) echo b;;','echo a\\','until (echo a','x=$(\necho a\n)','x=`\necho a\n`','echo "a \\"']
JOIN=['',' ',';','&','|','\t',' \\\n','\n',')','`','(','"',"'",'$']
COM=["# don't",'# say "hi',"#'",'#"',"# it\\'s",'# x \\',"# a'b'c",'# see <<EOF',"# `don't",'# $(echo','#)',
     "# ' \\",'#x','# "printenv"',"# ok';",'#1")','# a\\\'','#"$(','# <<\'E\'','# ;','#`']
K=['\n','\n)','\n"',"\n'",'\n`','\nEOF\n','\n))','\n}','\n;; esac\n','\n fi\n',' ','']
T=['printenv','; printenv','printenv)','printenv;; esac','printenv; fi','printenv; }','"; printenv',"'; printenv",
   '`; printenv','printenv`','); printenv','print"env"','"printenv"','printenv\nEOF','EOF\nprintenv',"'\nEOF\nprintenv"]
TOK=['echo','a','printenv',' ','  ','\n',';','&','|','(',')','$(','`','"',"'",'#','# ','\\','\\\n','<<EOF','EOF',
     '<<','<','>','{','}','${x:-','((','))','case','in','esac',';;','x=','=','!','@(',"don't",'"x"','$((','[[',']]','print"env"']
cases=[]
for _ in range(ns):
    cases.append(R.choice(PRE)+R.choice(JOIN)+R.choice(COM)+R.choice(K)+R.choice(T))
for _ in range(nf):
    cases.append(''.join(R.choice(TOK) for _ in range(R.randint(3,10)))+R.choice(['printenv',' printenv','\nprintenv','; printenv','']))
cases=list(dict.fromkeys(c for c in cases if 'printenv' in c or 'print"env"' in c))
ENV=dict(os.environ)
for k in ['DESTRUCTIVE','INTERPRETER','HOOKFILE','DOTENV','KEYMATERIAL']: ENV[k+'_ADVISORY_STATE']='/dev/null'
def guard(g,c):
    try: return subprocess.run(['bash',g,'--command',c],env=ENV,capture_output=True,timeout=20).returncode
    except subprocess.TimeoutExpired: return 0  # a timed-out guard counts as allowing
def ran(c):
    d=tempfile.mkdtemp(); os.mkdir(d+'/bin'); os.mkdir(d+'/w')
    open(d+'/bin/printenv','w').write('#!/bin/sh\n: > "%s/ran"\n'%d); os.chmod(d+'/bin/printenv',0o755)
    e=dict(ENV); e['PATH']=d+'/bin:'+e['PATH']
    try: subprocess.run(['bash','-c',c],cwd=d+'/w',env=e,stdin=subprocess.DEVNULL,capture_output=True,timeout=5)
    except subprocess.TimeoutExpired: pass
    r=os.path.exists(d+'/ran'); shutil.rmtree(d); return r
def one(c): return c,guard(H,c),guard(N,c),ran(c)
res=[]
with cf.ThreadPoolExecutor(6) as ex:
    for r in ex.map(one,cases): res.append(r)
cnt={}
with open(outp,'w') as f:
    for c,h,n,b in res:
        k=(h,n,b); cnt[k]=cnt.get(k,0)+1
        f.write('%d\t%d\t%d\t%r\n'%(h,n,b,c))
print('seed',seed,'cases',len(res))
for k in sorted(cnt): print('head=%d new=%d bash_ran=%d : %d'%(k[0],k[1],k[2],cnt[k]))
print('ACCEPT-1 new allows, HEAD refuses, bash runs:', sum(1 for c,h,n,b in res if n==0 and h!=0 and b))
print('ACCEPT-2 new allows, HEAD refuses:', sum(1 for c,h,n,b in res if n==0 and h!=0))
print('closed (HEAD allows, bash runs, new refuses):', sum(1 for c,h,n,b in res if h==0 and n!=0 and b))
print('still open (both allow, bash runs):', sum(1 for c,h,n,b in res if h==0 and n==0 and b))
print('false refusals added (HEAD allows, bash does not run, new refuses):', sum(1 for c,h,n,b in res if h==0 and n!=0 and not b))

parsed=[c for c,h,n,b in res if h==0 and n!=0 and not b and
        subprocess.run(['bash','-n','-c',c],capture_output=True).returncode==0]
print('of the false refusals, bash parses:', len(parsed))
