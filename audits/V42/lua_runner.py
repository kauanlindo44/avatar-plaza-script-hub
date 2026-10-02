"""Run Lua-compatible regression cases with the system liblua5.4, not Roblox."""
import ctypes
import ctypes.util

lib = ctypes.CDLL(ctypes.util.find_library("lua5.4"))
lib.luaL_newstate.restype = ctypes.c_void_p
lib.luaL_openlibs.argtypes = [ctypes.c_void_p]
lib.luaL_loadbufferx.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t, ctypes.c_char_p, ctypes.c_char_p]
lib.luaL_loadbufferx.restype = ctypes.c_int
lib.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_longlong, ctypes.c_void_p]
lib.lua_pcallk.restype = ctypes.c_int
lib.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.POINTER(ctypes.c_size_t)]
lib.lua_tolstring.restype = ctypes.c_char_p
lib.lua_settop.argtypes = [ctypes.c_void_p, ctypes.c_int]
lib.lua_close.argtypes = [ctypes.c_void_p]

class Lua:
    def __init__(self):
        self.state = lib.luaL_newstate()
        lib.luaL_openlibs(self.state)

    def run(self, source, name="test", execute=True):
        b = source.encode()
        status = lib.luaL_loadbufferx(self.state, b, len(b), name.encode(), None)
        if not status and execute:
            status = lib.lua_pcallk(self.state, 0, -1, 0, 0, None)
        if status:
            raw = lib.lua_tolstring(self.state, -1, None)
            message = raw.decode() if raw else 'Lua raised a non-string error'
            lib.lua_settop(self.state, 0)
            raise RuntimeError(message)
        value = lib.lua_tolstring(self.state, -1, None)
        lib.lua_settop(self.state, 0)
        return value.decode() if value else None

    def close(self):
        lib.lua_close(self.state)
