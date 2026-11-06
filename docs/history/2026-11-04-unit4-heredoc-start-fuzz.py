#!/usr/bin/env python3
"""Differential fuzz of where the command guard STARTS a heredoc body, against bash (AMH ledger DD-059).

Frozen: the measurement behind DD-059, retired whole with the owner-queue-closure plan's Unit 4.
Replay, from a scratch directory outside the repository:

    mkdir -p headrepo/scripts
    git -C <repo> show 95c52a0:scripts/command-guard.sh > headrepo/scripts/command-guard.sh
    cp <repo>/amh.conf headrepo/
    python3 <repo>/docs/history/2026-11-04-unit4-heredoc-start-fuzz.py \\
        headrepo/scripts/command-guard.sh <repo>/scripts/command-guard.sh 20261104 24000 6000 full.tsv

Structured cases build a logical line that bash may continue past its first newline: an operator
whose delimiter word is spelled every way bash removes quotes from it (inside the word, around a
blank, `$'…'`, `$"…"`, an escaped quote, a backslash-newline inside the word or the operator),
followed by a quoted string that spans lines, a backslash-newline carrying a command onto the next
line, a comment with a quote or a `<<` in it, a here-string, or a `<<` inside a one-line
substitution. Before it may come a multi-line string that mentions `<<EOF`. Body lines are drawn
from every spelling of every delimiter, quotes and the `printenv` stand-in, and a tail follows.
Fragment cases join tokens at random. As in the Unit 3 harness: `printenv` resolves on PATH to a
stub that creates a file in a fresh temporary directory, and running it is the observation;
advisory state goes to /dev/null; a guard that times out counts as allowing.
"""
import random, subprocess, sys, os, tempfile, shutil, concurrent.futures as cf
H,N,seed,ns,nf,outp=sys.argv[1],sys.argv[2],int(sys.argv[3]),int(sys.argv[4]),int(sys.argv[5]),sys.argv[6]
R=random.Random(seed)
PRE=['','','','echo "subject\nsee <<EOF in docs"\n',"echo 'a <<A\nb'\n",'echo hi # see <<EOF\n',
     'git commit -m "x\n\n<<B"\n','echo a # don\'t\n','x=$((\n1 << n\n))\n']
LEAD=['cat ','cat ','echo a; cat ','(cat ','x=$(cat ','cat >f ','{ cat ','grep x <<<"$v"; cat ',
      'echo `date`; cat ','git commit -F - ']
OPS=['<<EOF','<<-EOF',"<<'EOF'",'<<"EOF"','<<\\EOF','<< EOF','<<E"O"F',"<<'E'OF",'<<"E O F"',
     "<<$'EOF'",'<<$"EOF"','<<EO\\\nF','<\\\n<EOF','<< \\\nEOF','<<-\\\nEOF','<<"E\\"F"',
     "<<'E'\"O\"F",'<<E\\OF','<<A','<<"A B"',"<<$'E\\x4fF'",'<<E`x`F','<<EOF)']
MID=['','','',' "x\ny"'," 'a\nb'",' \\\n&& printenv',' \\\n; echo z',' \\\n> g',' # it\'s',' # <<B',
     ' "<<A"',' <<<"$v"',' $(cat <<A)',' `cat <<A`',' "a\n<<A\nb"',' \\\n<<A',' <<A "q\nq"',
     ' # note \\',' "$(printf "fix #1")\n"']
BL=['EOF','E"O"F','E O F','"E O F"','E','EO','EO\\','F','E"F','E\\x4fF','E`x`F','A','A B','B',
    "'",'"','`','printenv','"; printenv',"'; printenv",'text','','#x',"don't",'y"',"b'",'q"',
    '\tEOF','  EOF','EOF ','\\','foo\\','cat <<EOF',')','`','EOF)']
T=['printenv','; printenv','"; printenv',"'; printenv",'`; printenv','); printenv','"printenv"',
   'printenv\nEOF','EOF\nprintenv',"'\nEOF\nprintenv",'A\nprintenv','B\nprintenv',
   '"\nEOF\nprintenv','E O F\nprintenv','EOF\nA\nprintenv',"'\nA\nB\nprintenv"]
TOK=['cat','echo','printenv',' ','\n','\n','\t',';','|','&&','(',')','$(','`','"',"'",'#',
     '\\','\\\n','<<EOF','<<-EOF',"<<'EOF'",'<<E"O"F',"<<$'EOF'",'<<"E O F"','<<A','<<','<<<',
     '<','EOF','E O F','A','$((','))','1 << n','{','}','$"','$\'']
cases=[]
for _ in range(ns):
    first=R.choice(PRE)+R.choice(LEAD)+R.choice(OPS)+R.choice(MID)
    if R.random()<0.3: first+=R.choice(MID)
    body=[R.choice(BL) for _ in range(R.randint(0,6))]
    cases.append('\n'.join([first]+body+[R.choice(T)]))
for _ in range(nf):
    cases.append(''.join(R.choice(TOK) for _ in range(R.randint(4,14)))+R.choice(['printenv','\nprintenv','; printenv','']))
cases=list(dict.fromkeys(c for c in cases if 'printenv' in c))
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
