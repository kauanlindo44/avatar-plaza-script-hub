"""Constrain simulated Lua suites: deny network/exec syscalls, limit resources and Lua I/O."""
import ctypes, errno, platform, resource
from pathlib import Path
_ready=False

def install():
 global _ready
 if _ready:return
 machine=platform.machine()
 calls={'x86_64':[41,42,44,46,49,50,53,59,322], 'aarch64':[198,203,206,211,200,201,199,221,281]}.get(machine)
 if calls is None:raise RuntimeError('No reviewed syscall map for '+machine)
 class Filter(ctypes.Structure):_fields_=[('code',ctypes.c_ushort),('jt',ctypes.c_ubyte),('jf',ctypes.c_ubyte),('k',ctypes.c_uint)]
 class Program(ctypes.Structure):_fields_=[('len',ctypes.c_ushort),('filter',ctypes.POINTER(Filter))]
 instructions=[Filter(0x20,0,0,0)]
 for n in calls:instructions.extend([Filter(0x15,0,1,n),Filter(0x06,0,0,0x00050000|errno.EPERM)])
 instructions.append(Filter(0x06,0,0,0x7fff0000));array=(Filter*len(instructions))(*instructions);program=Program(len(instructions),array)
 libc=ctypes.CDLL(None,use_errno=True)
 if libc.prctl(38,1,0,0,0)!=0 or libc.prctl(22,2,ctypes.byref(program),0,0)!=0:raise OSError(ctypes.get_errno(),'seccomp setup failed')
 resource.setrlimit(resource.RLIMIT_CPU,(60,60));resource.setrlimit(resource.RLIMIT_AS,(1024**3,1024**3));resource.setrlimit(resource.RLIMIT_FSIZE,(20*1024**2,20*1024**2))
 _ready=True

LUA_GUARD=r'''
os.execute=nil;os.exit=nil;os.getenv=nil;os.remove=nil;os.rename=nil;os.tmpname=nil
io.popen=nil;io.input=nil;io.output=nil;io.lines=nil;io.read=nil;io.write=nil;io.tmpfile=nil
local native_open=io.open;local root='__LAYOUT_ROOT__'
io.open=function(path,mode)
 if type(path)~='string' or path:sub(1,#root+1)~=root..'/'or not path:sub(#root+2):match('^[%w_%-]+%.json$')or path:find('..',1,true)then error('Sandbox file access denied')end
 if mode~='w'then error('Sandbox only allows reviewed layout JSON exports')end
 return native_open(path,mode)
end
dofile=nil;loadfile=nil;package=nil;debug={traceback=debug.traceback}
'''

LUA_GUARD=LUA_GUARD.replace('__LAYOUT_ROOT__',str(Path(__file__).resolve().parent/'layouts'))

LUA_GUARD="do\n"+LUA_GUARD+"\nend\n"
