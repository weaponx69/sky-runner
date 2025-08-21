                                                                 
@tool
extends Node

const ethwtdia = preload("action_parser_utils.gd")
const qwzlykfh = preload("edit_node_action.gd")

static func execute(uwvwkzvs: String, vygvuqxq: String, byggbilg: String, cgtseujy: String, ikmbagka: Dictionary = {}) -> Dictionary:
    var zntnmogx = EditorPlugin.new().get_editor_interface()
    var ylnqoqls = zntnmogx.get_open_scenes()
    
                                                             
    for scene in ylnqoqls:
        if scene == byggbilg:
            print("Adding to open scene: ", scene)
            zntnmogx.reload_scene_from_path(byggbilg)
            return rgcffgxj(uwvwkzvs, vygvuqxq, zntnmogx.get_edited_scene_root(), cgtseujy, ikmbagka)

                                                                                                     
    print("Adding to closed scene: ", byggbilg)
    return waasltua(uwvwkzvs, vygvuqxq, byggbilg, cgtseujy, ikmbagka)

static func rgcffgxj(vjsjhaew: String, eptcbupg: String, dttcqkla: Node, dwporwyx: String, zbnxickb: Dictionary = {}) -> Dictionary:
    if !ClassDB.class_exists(eptcbupg):
        var rdcdhxzy = "Node type '%s' does not exist." % eptcbupg
        push_error(rdcdhxzy)
        return {"success": false, "error_message": rdcdhxzy}
    var bybolttw = ClassDB.instantiate(eptcbupg)
    bybolttw.name = vjsjhaew
    
                                                         
    var rkuzoxnb = dttcqkla if (dwporwyx.is_empty() or dwporwyx == dttcqkla.name) else dttcqkla.find_child(dwporwyx, true, true)
    if not rkuzoxnb:
        var rdcdhxzy = "Parent node '%s' not found in scene." % dwporwyx
        push_error(rdcdhxzy)
        return {"success": false, "error_message": rdcdhxzy}
    
    rkuzoxnb.add_child(bybolttw)
    bybolttw.set_owner(dttcqkla)
    
                                
    if not zbnxickb.is_empty():
        var lfpmxdfh = qwzlykfh.rcxoyamh(bybolttw, zbnxickb, dttcqkla)
        if not lfpmxdfh.success:
            return lfpmxdfh                                       
    
                                                  
    if EditorInterface.save_scene() == OK:
        return {"success": true, "error_message": ""}
    else:
        var rdcdhxzy = "Failed to save the scene."
        push_error(rdcdhxzy)
        return {"success": false, "error_message": rdcdhxzy}


static func waasltua(kbbfabug: String, sjyqnorl: String, akkxsmem: String, rnncsgpn: String, rnmadnsy: Dictionary = {}) -> Dictionary:
    var ajvzwiqf = load(akkxsmem)
    if !ajvzwiqf is PackedScene:
        var bjytxloh = "Failed to load scene '%s' as PackedScene." % akkxsmem
        push_error(bjytxloh)
        return {"success": false, "error_message": bjytxloh}
    
    var gfiuelje = ajvzwiqf.instantiate()
    if !ClassDB.class_exists(sjyqnorl):
        var bjytxloh = "Node type '%s' does not exist." % sjyqnorl
        push_error(bjytxloh)
        return {"success": false, "error_message": bjytxloh}
    var ggjshowg = ClassDB.instantiate(sjyqnorl)
    ggjshowg.name = kbbfabug
    
                                                         
    var vwoktmwy = gfiuelje if (rnncsgpn.is_empty() or rnncsgpn == gfiuelje.name) else gfiuelje.find_child(rnncsgpn, true, true)
    if not vwoktmwy:
        var bjytxloh = "Parent node '%s' not found in ajvzwiqf." % rnncsgpn
        push_error(bjytxloh)
        return {"success": false, "error_message": bjytxloh}
    
    vwoktmwy.add_child(ggjshowg)
    ggjshowg.set_owner(gfiuelje)
    
                                
    if not rnmadnsy.is_empty():
        var oubcdanz = qwzlykfh.rcxoyamh(ggjshowg, rnmadnsy, gfiuelje)
        if not oubcdanz.success:
            return oubcdanz                                       
    
                                                          
    ajvzwiqf.pack(gfiuelje)

    if ResourceSaver.save(ajvzwiqf, akkxsmem) == OK:
        return {"success": true, "error_message": ""}
    else:
        var bjytxloh = "Failed to save the packed scene."
        push_error(bjytxloh)
        return {"success": false, "error_message": bjytxloh}

static func parse_line(qcsljdlq: String, inhgefrk: String) -> Dictionary:
    if qcsljdlq.begins_with("create_node("):
                                                                              
        var zfvnaqpq = ethwtdia.eqynktzq(qcsljdlq)
        if zfvnaqpq.size() < 3:
            return {}
        
                                                                 
        var pstadbea = {}
        var ugtpjtxb = qcsljdlq.find("{")
        var dqqzoyza = qcsljdlq.rfind("}")
        
        if ugtpjtxb != -1 and dqqzoyza != -1:
            var oljvjehj = qcsljdlq.substr(ugtpjtxb, dqqzoyza - ugtpjtxb + 1)
            pstadbea = ethwtdia.rwlaxvut(oljvjehj)
        
        return {
            "type": "create_node",
            "name": zfvnaqpq[0],
            "node_type": zfvnaqpq[1],
            "scene_path": zfvnaqpq[2],
            "parent_path": zfvnaqpq[3] if zfvnaqpq.size() > 3 else "",
            "modifications": pstadbea
        }
    return {}
