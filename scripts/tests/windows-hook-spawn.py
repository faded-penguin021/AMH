"""Run the Antigravity hook commands the way Antigravity runs them on Windows: through cmd.exe.

Repo-local, Windows only, run by CI's portability job (`python -I scripts/tests/windows-hook-spawn.py`
from the repository root). The vendor's hooks page says a hook's `command` runs under `cmd /c`
on Windows with the folder holding hooks.json as its working directory, and does not say which
argument escaping its spawner uses, so each command is spawned both ways a runtime does it:
verbatim (`cmd.exe /d /s /c "..."`, as Node's `shell: true` builds it) and with the C runtime's
quoting (`subprocess.list2cmdline`, as Go and Python list arguments build it). PATH is cut to
what a native process on a stock desktop has: the Windows directories and Git for Windows'
`cmd` folder, with System32 (where WSL puts its own `bash.exe`) ahead of it. Every case also
runs with a folder put first on PATH that holds an extensionless `python3` shell script running
this Python and touching a marker file, since the guard looks up `python3` and a Windows Python
folder may hold only `python.exe`; the guard's answering cases there require the marker, so the
guard's Python reader is shown to run as well as its fallback (DD-123, DD-124).

What this cannot show: what the Antigravity App itself does with the answer. That stays the
owner's live probe (docs/STATE.md, Owner queue).
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile

ROOT = os.getcwd()
FAILED = []


def say(ok, name, detail=""):
    print(("  ok   " if ok else "  FAIL ") + name + (("\n" + detail) if detail and not ok else ""))
    if not ok:
        FAILED.append(name)


def git_root():
    out = subprocess.run(["git", "--exec-path"], capture_output=True, text=True, check=True).stdout.strip()
    # e.g. C:/Program Files/Git/mingw64/libexec/git-core -> C:\Program Files\Git
    path = os.path.normpath(out)
    for _ in range(3):
        path = os.path.dirname(path)
    return path


def snapshot(dest):
    files = subprocess.run(["git", "ls-files", "-co", "--exclude-standard", "-z"], capture_output=True,
                           check=True).stdout.decode().split("\0")
    for rel in filter(None, files):
        src = os.path.join(ROOT, rel)
        if not os.path.isfile(src):
            continue
        dst = os.path.join(dest, rel)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy2(src, dst)
    ident = ["-c", "user.name=fixture", "-c", "user.email=fixture@example.invalid"]
    for args in (["init", "-q", "-b", "main"], ["add", "-A"], ident + ["commit", "-qm", "fixture"]):
        subprocess.run(["git"] + args, cwd=dest, check=True, capture_output=True)


def spawn(cmdline, cwd, env, style, stdin):
    if style == "verbatim":
        full = 'cmd.exe /d /s /c "' + cmdline + '"'
    else:
        full = subprocess.list2cmdline(["cmd.exe", "/c", cmdline])
    p = subprocess.run(full, cwd=cwd, env=env, input=stdin.encode(), capture_output=True, timeout=120)
    return p.returncode, p.stdout.decode(errors="replace"), p.stderr.decode(errors="replace")


def msys(path):
    # C:\a\b -> /c/a/b, the form Git Bash reads in a shell script
    drive, rest = os.path.splitdrive(os.path.abspath(path))
    return "/" + drive.rstrip(":").lower() + rest.replace("\\", "/")


def main():
    if os.name != "nt":
        print("windows-hook-spawn: not Windows, nothing to run")
        return 0
    # A Windows console or CI log is cp1252 by default, and a failure's detail can hold any text.
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    hooks = json.load(open(os.path.join(ROOT, ".agents", "hooks.json"), encoding="utf-8"))
    session_cmd = hooks["amh-session-start"]["SessionStart"][0]["command"]
    guard_cmd = hooks["amh-command-guard"]["PreToolUse"][0]["hooks"][0]["command"]
    windir = os.environ.get("SystemRoot", r"C:\Windows")
    base = [os.path.join(windir, "system32"), windir, os.path.join(windir, "System32", "WindowsPowerShell", "v1.0"),
            os.path.join(git_root(), "cmd")]
    env0 = {k: v for k, v in os.environ.items()
            if k.upper() not in ("MSYSTEM", "BASH", "SHELL", "EXEPATH", "MINGW_PREFIX", "PYTHONPATH")}

    work = tempfile.mkdtemp(prefix="amh-hook-spawn-")
    empty_config = os.path.join(work, "empty.gitconfig")
    open(empty_config, "w").close()
    # The guard runs `command -v python3`, and a Windows Python folder may hold only python.exe,
    # so the python leg gets an extensionless `python3` that runs this Python and leaves a
    # marker: without the marker, that leg would be the fallback's again, silently.
    py_dir = os.path.join(work, "python3-bin")
    os.makedirs(py_dir)
    marker = os.path.join(work, "python3-ran")
    with open(os.path.join(py_dir, "python3"), "w", encoding="utf-8", newline="\n") as f:
        f.write('#!/bin/sh\n: >>"%s"\nexec "%s" "$@"\n' % (msys(marker), msys(sys.executable)))
    envs = {"no-python": dict(env0, PATH=";".join(base)),
            "python": dict(env0, PATH=";".join([py_dir] + base))}

    def guard_spawn(env_name, env, style, stdin):
        # In the python leg the answer only counts if the guard's python3 reader ran.
        if env_name == "python" and os.path.exists(marker):
            os.remove(marker)
        rc, out, err = spawn(guard_cmd, agents, env, style, stdin)
        if env_name == "python" and not os.path.exists(marker):
            return rc, out, err, "the guard's python3 reader did not run"
        return rc, out, err, ""

    repo = os.path.join(work, "repo with space")
    snapshot(repo)
    agents = os.path.join(repo, ".agents")
    outside = os.path.join(work, "not-a-repo", ".agents")
    os.makedirs(outside)

    def payload(command):
        return json.dumps({"conversationId": "c", "hookEventName": "PreToolUse", "stepIdx": 1,
                           "toolCall": {"id": "t", "name": "run_command", "args": {"CommandLine": command, "Cwd": repo}}})

    for env_name, env in envs.items():
        for style in ("verbatim", "crt-escaped"):
            tag = "[%s, %s]" % (style, env_name)
            rc, out, err, miss = guard_spawn(env_name, env, style, payload("git status"))
            say(not miss and rc == 0 and out.strip() == '{"decision":"allow"}', tag + " an ordinary command is answered allow",
                miss or "rc=%d out=%r err=%r" % (rc, out, err[:600]))
            rc, out, err, miss = guard_spawn(env_name, env, style, payload("Remove-Item -Recurse -Force C:\\"))
            try:
                ans = json.loads(out)
            except ValueError:
                ans = {}
            say(not miss and rc == 0 and ans.get("decision") == "deny" and "the root of a Windows drive" in ans.get("reason", ""),
                tag + " a PowerShell deletion of a drive root is denied by the PowerShell reader",
                miss or "rc=%d out=%r err=%r" % (rc, out[:600], err[:600]))
            rc, out, err = spawn(session_cmd, agents, env, style, "{}")
            try:
                steps = json.loads(out).get("injectSteps")
            except ValueError:
                steps = None
            say(rc == 0 and isinstance(steps, list) and steps, tag + " the session hook answers injectSteps",
                "rc=%d out=%r err=%r" % (rc, out[:600], err[:600]))
            # The refusal case reads no system or global git config: a runner image that sets
            # `safe.directory=*` there would otherwise allow the repository and test nothing.
            no_config = {"GIT_TEST_ASSUME_DIFFERENT_OWNER": "1", "GIT_CONFIG_NOSYSTEM": "1",
                         "GIT_CONFIG_GLOBAL": empty_config}
            for where, cwd, extra in (("outside a work tree", outside, {}),
                                      ("under a safe.directory refusal", agents, no_config)):
                for name, cmd, stdin in (("guard", guard_cmd, payload("git status")), ("session", session_cmd, "{}")):
                    rc, out, err = spawn(cmd, cwd, dict(env, **extra), style, stdin)
                    say(rc != 0 and out.strip() == "", "%s the %s hook fails closed %s" % (tag, name, where),
                        "rc=%d out=%r err=%r" % (rc, out[:600], err[:600]))
    shutil.rmtree(work, ignore_errors=True)
    if FAILED:
        print("windows-hook-spawn: %d case(s) failed" % len(FAILED))
        return 1
    print("windows-hook-spawn: every case passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
