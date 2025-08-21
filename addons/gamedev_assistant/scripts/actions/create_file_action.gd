                                                                 
@tool
extends Node

const ipoizsou = preload("action_parser_utils.gd")

static func execute(uxjzfttj: String, uauwxike: String) -> Dictionary:
    var rqqwpaqy = uxjzfttj.get_base_dir()
    if not DirAccess.dir_exists_absolute(rqqwpaqy):
        var dsajzmwk = DirAccess.make_dir_recursive_absolute(rqqwpaqy)
        if dsajzmwk != OK:
            var zpgfuljh = "Failed to create directory: %s" % rqqwpaqy
            push_error(zpgfuljh)
            return {"success": false, "error_message": zpgfuljh}
    
    var cixhhbrg = FileAccess.open(uxjzfttj, FileAccess.WRITE)
    if cixhhbrg:
        cixhhbrg.store_string(uauwxike)
        cixhhbrg.close()
        if Engine.is_editor_hint():
            EditorPlugin.new().get_editor_interface().get_resource_filesystem().scan()
        return {"success": true, "error_message": ""}
    else:
        var xeqxmklw = FileAccess.get_open_error()
        var zpgfuljh = "Failed to create file at path '%s'. Error: %s" % [uxjzfttj, error_string(xeqxmklw)]
        push_error(zpgfuljh)
        return {"success": false, "error_message": zpgfuljh}


static func parse_line(hzskmvtb: String, iasnydjy: String) -> Dictionary:
    if hzskmvtb.begins_with("create_file("):
        var vlsmxuvg = ipoizsou.rdrajrpf(hzskmvtb)
        return {
            "type": "create_file",
            "path": vlsmxuvg,
            "content": ipoizsou.fcjqztit(vlsmxuvg, iasnydjy)
        }
    return {}
