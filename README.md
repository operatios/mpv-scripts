# mpv-scripts

### [set-screenshot-dir](set-screenshot-dir.lua)
Sets `screenshot-dir` to the standard Windows folder (`%USERPROFILE%/Pictures/Screenshots/mpv`) using [`SHGetKnownFolderPath`](https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shgetknownfolderpath). Useful if `Pictures` or `Screenshots` folder location has been changed.
