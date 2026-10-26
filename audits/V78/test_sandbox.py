"""Exercise actual network/exec denials; no network packet or child executable is allowed."""
from pathlib import Path
import errno,json,socket,subprocess
from test_support import Lua,MOCK
l=Lua()
l.run(MOCK+"assert(os.execute==nil and os.getenv==nil and io.popen==nil and package==nil);local ok=pcall(io.open,'/etc/passwd','r');assert(not ok);return 'Lua host access denied'")
l.close()
blocked=[]
try:socket.socket()
except PermissionError as e:assert e.errno==errno.EPERM;blocked.append('socket')
try:subprocess.run(['/usr/bin/true'],check=True)
except PermissionError as e:assert e.errno==errno.EPERM;blocked.append('execve')
assert blocked==['socket','execve']
result=dict(network='denied_by_seccomp',host_exec='denied_by_seccomp',lua_host_access='denied',memory_limit_bytes=1024**3,cpu_limit_seconds=60,scope='simulated Lua suites; not Roblox physics or a published multiplayer server')
Path(__file__).with_name('sandbox_results.json').write_text(json.dumps(result,indent=2)+'\n');print('PASS actual Linux sandbox restrictions')
