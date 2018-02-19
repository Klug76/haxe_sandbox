@if exist .\lib rmdir .\lib
mklink /J .\lib "..\haxe_swc_lib\bin"

@pause