#!/usr/bin/env python3
"""Differential fuzz of where the command guard ends a heredoc body, against bash (AMH ledger DD-057).

Frozen: the measurement behind DD-057, retired whole with the owner-queue-closure plan's Unit 3.
Replay, from a scratch directory outside the repository:

    mkdir -p headrepo/scripts
    git -C <repo> show 35608d2:scripts/command-guard.sh > headrepo/scripts/command-guard.sh
    cp <repo>/amh.conf headrepo/
    python3 <repo>/docs/history/2026-11-02-unit3-heredoc-fuzz.py \\
        headrepo/scripts/command-guard.sh <repo>/scripts/command-guard.sh 20261103 30000 10000 full.tsv

Structured cases put one to three heredoc operators (and arithmetic shifts and here-strings that
open none) on a first line, then body lines built from terminators spelled every way bash does
and does not accept — indented, tab-led, trailing blank, split by a backslash-newline, an even
or odd backslash run — and a tail with the `printenv` stand-in. Fragment cases join tokens at
random. As in the Unit 2 harness: `printenv` resolves on PATH to a stub that creates a file in
a fresh temporary directory, and running it is the observation; advisory state goes to
/dev/null; a guard that times out counts as allowing.
"""
import random, subprocess, sys, os, tempfile, shutil, concurrent.futures as cf
H,N,seed,ns,nf,outp=sys.argv[1],sys.argv[2],int(sys.argv[3]),int(sys.argv[4]),int(sys.argv[5]),sys.argv[6]
R=random.Random(seed)
LEAD=['cat ','cat ','echo a; cat ','(cat ','x=$(cat ','git commit -F - ','cat >f ','{ cat ',
      '((true ','(( x = $(cat ','echo $(( $(cat ','echo $(( 1 + $(( 2 ))<<n )) ']
OPS=['<<EOF','<<-EOF',"<<'EOF'",'<<"EOF"','<<\\EOF','<< EOF','<<A','<<-A','<<B',"<<'B'",'<<-  B',
     '$(( 1 << n ))','$((1<<n))','$((a<<b))','$((1 << 8))','<<<x','<<<"$v"','(( x = 1 << n ))',
     '<<E"O"F','<<A<<B','"<<EOF"',"'<<A'",'# <<B','#x']
SEP=[' ',' ','; cat ',' && cat ',' | cat ','; ',' >g ']
END=['','',' )',')',' }',' ;',' &&',' ) )',' ) ))',' )) )']
BL=['EOF','A','B','  EOF','\tEOF','EOF ',' A','\tA','\tB','\t\tEOF','foo\\','\\','EO\\','F','E\\','OF',
    '\\\\','x\\\\\\','EOF\\',"'",'"','`','text','printenv','','#x',"don't",'$(',')','cat <<EOF','<<A',
    '\t\\','\t \tEOF','A ','B\\','"; printenv']
T=['printenv','; printenv','printenv)','"; printenv',"'; printenv",'`; printenv','); printenv',
   'print"env"','"printenv"','printenv\nEOF','EOF\nprintenv',"'\nEOF\nprintenv",'A\nprintenv',
   'B\nprintenv','printenv\nA\nB','\'\nB\nprintenv','EOF\nA\nB\nprintenv']
TOK=['cat','echo','printenv',' ','\n','\n','\t',';','|','&&','(',')','$(','`','"',"'",'#',
     '\\','\\\n','<<EOF','<<-EOF',"<<'EOF'",'<<A','<<B','<<','<<<','EOF','A','B','  EOF','\tEOF',
     '$((','))','1 << n','<<-','{','}','print"env"']
cases=[]
for _ in range(ns):
    first=R.choice(LEAD)+R.choice(OPS)
    for _ in range(R.randint(0,2)): first+=R.choice(SEP)+R.choice(OPS)
    first+=R.choice(END)
    body=[R.choice(BL) for _ in range(R.randint(0,6))]
    cases.append('\n'.join([first]+body+[R.choice(T)]))
for _ in range(nf):
    cases.append(''.join(R.choice(TOK) for _ in range(R.randint(4,14)))+R.choice(['printenv','\nprintenv','; printenv','']))
cases=list(dict.fromkeys(c for c in cases if 'printenv' in c or 'print"env"' in c))
ENV=dict(os.environ)
for k in ['DESTRUCTIVE','INTERPRETER','HOOKFILE','DOTENV','KEYMATERIAL','SUBAGENT']: ENV[k+'_ADVISORY_STATE']='/dev/null'
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
print('ACCEPT new allows, HEAD refuses, bash runs:', sum(1 for c,h,n,b in res if n==0 and h!=0 and b))
print('newly allowed, bash does not run (refusals removed):', sum(1 for c,h,n,b in res if n==0 and h!=0 and not b))
print('closed (HEAD allows, bash runs, new refuses):', sum(1 for c,h,n,b in res if h==0 and n!=0 and b))
print('still open (both allow, bash runs):', sum(1 for c,h,n,b in res if h==0 and n==0 and b))
print('false refusals added (HEAD allows, bash does not run, new refuses):', sum(1 for c,h,n,b in res if h==0 and n!=0 and not b))

def parses(c): return subprocess.run(['bash','-n','-c',c],capture_output=True).returncode==0
added=[c for c,h,n,b in res if h==0 and n!=0 and not b]
print('of the false refusals added, bash parses:', sum(1 for c in added if parses(c)))
