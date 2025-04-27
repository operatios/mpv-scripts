local ffi = require "ffi"

local Shell32 = ffi.load("Shell32") -- SHGetKnownFolderPath
local Ole32 = ffi.load("Ole32") -- CoTaskMemFree

ffi.cdef[[
    void* malloc(size_t);
    void free(void*);

    typedef struct {
        unsigned long Data1;
        unsigned short Data2;
        unsigned short Data3;
        unsigned char Data4[8];
    } GUID;
    void CoTaskMemFree(void*);
    long SHGetKnownFolderPath(GUID*, unsigned long, void*, wchar_t**);
    int WideCharToMultiByte(unsigned int, unsigned long, wchar_t const*, int, char*, int, char const*, bool*);
]]

FOLDERID_Screenshots = ffi.new("GUID", {0xb7bede81, 0xdf94, 0x4682, {0xa7, 0xd8, 0x57, 0xa5, 0x26, 0x20, 0xb8, 0x6f}})

function utf16_to_utf8(wstr)
    local size = ffi.C.WideCharToMultiByte(65001, 0, wstr[0], -1, nil, 0, nil, nil)
    local str = ffi.gc(ffi.C.malloc(size), ffi.C.free)
    ffi.C.WideCharToMultiByte(65001, 0, wstr[0], -1, str, size, nil, nil)

    return ffi.string(str)
end

function get_known_folder_path(guid)
    local path = ffi.new("wchar_t*[1]")
    local result = Shell32.SHGetKnownFolderPath(guid, 0, nil, path)

    if result ~= 0 then
        mp.msg.error("SHGetKnownFolderPath error: " .. result)
        mp.commandv("show-text", "set-screenshot-dir: SHGetKnownFolderPath error")

        Ole32.CoTaskMemFree(path[0])
        return nil
    end

    local utf8_path = utf16_to_utf8(path)
    Ole32.CoTaskMemFree(path[0])

    return utf8_path
end

function set_screenshot_dir()
    local path = get_known_folder_path(FOLDERID_Screenshots)
    if path then
        mp.set_property("screenshot-dir", path:gsub("\\", "/") .. "/mpv")
    end
end

mp.register_event("file-loaded", set_screenshot_dir)
