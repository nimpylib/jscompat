
const wasip1_decl* = """
__attribute__((__import_module__("wasi_snapshot_preview1"), __import_name__("$2")))
$1 $2$3
"""
type Errno* = int32
type charp* = ptr uint8
type Size* = int32