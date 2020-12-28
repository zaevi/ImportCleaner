tool
extends EditorPlugin

var available_files : Array = []
var clean_files : Array = []


func _enter_tree():
    add_tool_menu_item("Cleanup Import Folder", self, "_plugin_pressed")


func _exit_tree():
    remove_tool_menu_item("Cleanup Import Folder")


func _plugin_pressed(ud):
    scan_available()
    scan_clean()
    
    var d = Directory.new()
    for name in clean_files:
        print("Removing " + name)
        d.remove("res://.import/" + name)
    print("%d file(s) removed" % len(clean_files))


func scan_available():
    available_files.clear()
    var root = get_editor_interface().get_resource_filesystem().get_filesystem()
    _scan(root)


func _scan(dir : EditorFileSystemDirectory):
    var f = File.new()
    for i in range(dir.get_subdir_count()):
        _scan(dir.get_subdir(i))
    for i in range(dir.get_file_count()):
        if dir.get_file_import_is_valid(i) and f.file_exists(dir.get_file_path(i) + ".import"):
            available_files.append(dir.get_file(i) + "-" + dir.get_file_path(i).md5_text())


func scan_clean():
    clean_files.clear()
    var dir = Directory.new()
    dir.open("res://.import")
    
    dir.list_dir_begin()
    var name = dir.get_next()
    while name != "":
        if not dir.current_is_dir() and not name.get_basename() in available_files:
            clean_files.append(name)
        name = dir.get_next()
