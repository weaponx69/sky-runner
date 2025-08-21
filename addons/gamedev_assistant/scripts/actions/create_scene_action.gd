                                                                  
@tool
extends Node

const oyuqwmha = preload("action_parser_utils.gd")

static func execute(nzzfxnga: String, rhfdfxvf: String, ckcxwdrt: String) -> Dictionary:
    var wahxnmcq = nzzfxnga.get_base_dir()
    if not DirAccess.dir_exists_absolute(wahxnmcq):
        var pcbyfkuu = DirAccess.make_dir_recursive_absolute(wahxnmcq)
        if pcbyfkuu != OK:
            var gkdekehc = "Failed to create directory: %s" % wahxnmcq
            push_error(gkdekehc)
            return {"success": false, "error_message": gkdekehc}
    
    if !ClassDB.class_exists(ckcxwdrt):
        var gkdekehc = "Root node type '%s' does not exist." % ckcxwdrt
        push_error(gkdekehc)
        return {"success": false, "error_message": gkdekehc}
    
    var mctmyfqm = PackedScene.new()
    var wenaprqo = ClassDB.instantiate(ckcxwdrt)
    wenaprqo.name = rhfdfxvf
    mctmyfqm.pack(wenaprqo)
    
    var mtdbsbhu = ResourceSaver.save(mctmyfqm, nzzfxnga)
    if mtdbsbhu == OK:
        if Engine.is_editor_hint():
            EditorPlugin.new().get_editor_interface().get_resource_filesystem().scan()
        return {"success": true, "error_message": ""}
    else:
        var gkdekehc = "Failed to save scene to path: %s" % nzzfxnga
        push_error(gkdekehc)
        return {"success": false, "error_message": gkdekehc}

static func parse_line(czuucgzn: String, bboyjpmv: String) -> Dictionary:
    if czuucgzn.begins_with("create_scene("):
        var gnlggavc = oyuqwmha.oshoyugi(czuucgzn)
        if gnlggavc.size() >= 3:
            return {
                "type": "create_scene",
                "path": gnlggavc[0],
                "root_name": gnlggavc[1],
                "root_type": gnlggavc[2]
            }
    return {}
