                                                                      
@tool
extends Node

const lgviphvi = preload("action_parser_utils.gd")

static func execute(udfpegge: String, vaafhiwy: int, bumfltmu: Button, jkzphwsp: Node) -> Dictionary:
                                      
    var zqzuvmpj = FileAccess.open(udfpegge, FileAccess.READ)
    if not zqzuvmpj:
        var ibeuyyki = FileAccess.get_open_error()
        var avovvpie = "Failed to load script: " + udfpegge + " (Error: " + error_string(ibeuyyki) + ")"
        push_error(avovvpie)
        return {"success": false, "error_message": avovvpie}
    
                                
    var kcexjnqe = zqzuvmpj.get_as_text()
    zqzuvmpj.close()
        
                           
    jkzphwsp.lcjghxmx(udfpegge, vaafhiwy, kcexjnqe, bumfltmu)
    return {"success": true, "error_message": ""}

static func parse_line(hfhylxrh: String, oiltmrmf: String) -> Dictionary:
    if hfhylxrh.begins_with("edit_script("):
        var nuxmevdf = lgviphvi.uwedigfe(hfhylxrh)
        if not nuxmevdf.is_empty():
            return {
                "type": "edit_script",
                "path": nuxmevdf.get("path", ""),
                "message_id": nuxmevdf.get("message_id", -1)
            }
    return {}
