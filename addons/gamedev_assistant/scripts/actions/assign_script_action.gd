                                                                 
@tool
extends Node

const apbywiua = preload("res://addons/gamedev_assistant/scripts/actions/action_parser_utils.gd")

static func execute(wixnceaj: String, jrdtbuav: String, aqaexdbf: String) -> Dictionary:
    var xpnfggmc = EditorPlugin.new().get_editor_interface()
    var rxwzelhm = xpnfggmc.get_open_scenes()

                                   
    for scene in rxwzelhm:
        if scene == jrdtbuav:
                                                                         
            xpnfggmc.reload_scene_from_path(jrdtbuav)
            return gcnepset(wixnceaj, xpnfggmc.get_edited_scene_root(), aqaexdbf)

                                                        
                                                                   
    return sbggjtie(wixnceaj, jrdtbuav, aqaexdbf)

static func gcnepset(guvluynd: String, mvvyxzhe: Node, zebnsioq: String) -> Dictionary:
    var vcwuumwl = mvvyxzhe.find_child(guvluynd, true, true)
    
    if not vcwuumwl and guvluynd == mvvyxzhe.name:
        vcwuumwl = mvvyxzhe

    if not vcwuumwl:
        var zqhtobfu = "Node '%s' not found in open scene root '%s'." % [guvluynd, mvvyxzhe.name]
        push_error(zqhtobfu)
        return {"success": false, "error_message": zqhtobfu}

                       
    var gzpniqpv = load(zebnsioq)
    if not gzpniqpv:
        var zqhtobfu = "Failed to load script at path: %s" % zebnsioq
        push_error(zqhtobfu)
        return {"success": false, "error_message": zqhtobfu}

    vcwuumwl.set_script(gzpniqpv)
    
                                                       
    if EditorInterface.save_scene() == OK:
        return {"success": true, "error_message": ""}
    else:
        var zqhtobfu = "Failed to save the scene."
        push_error(zqhtobfu)
        return {"success": false, "error_message": zqhtobfu}


static func sbggjtie(ldvvsnok: String, kohyydzs: String, uaitxjjl: String) -> Dictionary:
    var lubdtwkn = load(kohyydzs)
    if not (lubdtwkn is PackedScene):
        var jwwtdklb = "Failed to load scene '%s' as PackedScene." % kohyydzs
        push_error(jwwtdklb)
        return {"success": false, "error_message": jwwtdklb}

    var ngzkwrhj = lubdtwkn.instantiate()
    if not ngzkwrhj:
        var jwwtdklb = "Could not instantiate scene '%s'." % kohyydzs
        push_error(jwwtdklb)
        return {"success": false, "error_message": jwwtdklb}

    var quulmuke = ngzkwrhj.find_child(ldvvsnok, true, true)
    
    if not quulmuke and ldvvsnok == ngzkwrhj.name:
        quulmuke = ngzkwrhj

    if not quulmuke:
        var jwwtdklb = "Node '%s' not found in scene instance root '%s'." % [ldvvsnok, ngzkwrhj.name]
        push_error(jwwtdklb)
        return {"success": false, "error_message": jwwtdklb}

                       
    var sdxyukbv = load(uaitxjjl)
    if not sdxyukbv:
        var jwwtdklb = "Failed to load script at path: %s" % uaitxjjl
        push_error(jwwtdklb)
        return {"success": false, "error_message": jwwtdklb}

    quulmuke.set_script(sdxyukbv)

                                
    lubdtwkn.pack(ngzkwrhj)
    if ResourceSaver.save(lubdtwkn, kohyydzs) == OK:
        return {"success": true, "error_message": ""}
    else:
        var jwwtdklb = "Failed to save the packed scene."
        push_error(jwwtdklb)
        return {"success": false, "error_message": jwwtdklb}


                                                                             
                 
                                                                      
                                                                             
static func parse_line(qhzaelxq: String, ffjiybos: String) -> Dictionary:
                                                         
    if qhzaelxq.begins_with("assign_script("):
        var ovgqtdwg = qhzaelxq.replace("assign_script(", "").replace(")", "").strip_edges()
        var pjltarvv = []
        var trmkedke = 0
        while true:
            var pdqgslmq = ovgqtdwg.find('"',trmkedke)
            if pdqgslmq == -1:
                break
            var wwxqkdkg = ovgqtdwg.find('"', pdqgslmq + 1)
            if wwxqkdkg == -1:
                break
            pjltarvv.append(ovgqtdwg.substr(pdqgslmq + 1, wwxqkdkg - pdqgslmq - 1))
            trmkedke = wwxqkdkg + 1

                                                                                
        if pjltarvv.size() != 3:
            return {}

        return {
            "type": "assign_script",
            "node_name": pjltarvv[0],
            "scene_path": pjltarvv[1],
            "script_path": pjltarvv[2]
        }

    return {}
