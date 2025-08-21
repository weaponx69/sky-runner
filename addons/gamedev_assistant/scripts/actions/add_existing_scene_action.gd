                                                                 
@tool
extends Node

const njejqaeg = preload("action_parser_utils.gd")
const mtwcnedv = preload("edit_node_action.gd")

static func execute(vnhtswsb: String, cvfbqtyz: String, tfwpekfb: String, xjmdtjnf: String, hjsypbrr: Dictionary) -> Dictionary:
    var nxbjrkks = EditorPlugin.new().get_editor_interface()
    var qgrrgwum = nxbjrkks.get_open_scenes()
    
    var jvpgtipt = load(cvfbqtyz)
    if not jvpgtipt is PackedScene:
        var pxbkffsm = "Invalid or non-existent scene file: " + cvfbqtyz
        push_error(pxbkffsm)
        return {"success": false, "error_message": pxbkffsm}
    
    if tfwpekfb in qgrrgwum:
        return rkbhuuzv(vnhtswsb, jvpgtipt, tfwpekfb, xjmdtjnf, hjsypbrr)
    else:
        return vkupfhhm(vnhtswsb, jvpgtipt, tfwpekfb, xjmdtjnf, hjsypbrr)

static func rkbhuuzv(dgyywdpy: String, drjpdyah: PackedScene, ditwfcfl: String, rinyzxwt: String, vkpyqwoa: Dictionary) -> Dictionary:
    var ajmngugn = EditorPlugin.new().get_editor_interface()
    ajmngugn.reload_scene_from_path(ditwfcfl)
    var uxxbviii = ajmngugn.get_edited_scene_root()
    
    var jqnxztaw = uxxbviii if (rinyzxwt.is_empty() or rinyzxwt == uxxbviii.name) else uxxbviii.find_child(rinyzxwt, true, true)
    if not jqnxztaw:
        var qhehbxas = "Parent node '%s' not found in scene '%s'." % [rinyzxwt, ditwfcfl]
        push_error(qhehbxas)
        return {"success": false, "error_message": qhehbxas}
    
    var ogqsbejv = drjpdyah.instantiate()
    ogqsbejv.name = dgyywdpy
    jqnxztaw.add_child(ogqsbejv)
    ogqsbejv.set_owner(uxxbviii)
    
    if not vkpyqwoa.is_empty():
        var admywduh = mtwcnedv.rcxoyamh(ogqsbejv, vkpyqwoa, uxxbviii)
        if not admywduh.success:
            return admywduh                                       
    
    if EditorPlugin.new().get_editor_interface().save_scene() == OK:
        return {"success": true, "error_message": ""}
    else:
        var qhehbxas = "Failed to save scene '%s'." % ditwfcfl
        push_error(qhehbxas)
        return {"success": false, "error_message": qhehbxas}


static func vkupfhhm(bfnxlsxv: String, fybajaix: PackedScene, jlzwyqzv: String, ggutlitu: String, feyqgcue: Dictionary) -> Dictionary:
    var jegoprbh = load(jlzwyqzv)
    if not jegoprbh is PackedScene:
        var sbkbnafs = "Invalid or non-existent target scene: " + jlzwyqzv
        push_error(sbkbnafs)
        return {"success": false, "error_message": sbkbnafs}
    
    var ncblgxsp = jegoprbh.instantiate()
    var qxtouigo = ncblgxsp if (ggutlitu.is_empty() or ggutlitu == ncblgxsp.name) else ncblgxsp.find_child(ggutlitu, true, true)
    if not qxtouigo:
        var sbkbnafs = "Parent node '%s' not found in scene '%s'." % [ggutlitu, jlzwyqzv]
        push_error(sbkbnafs)
        return {"success": false, "error_message": sbkbnafs}
    
    var dkthwbih = fybajaix.instantiate()
    dkthwbih.name = bfnxlsxv
    qxtouigo.add_child(dkthwbih)
    dkthwbih.set_owner(ncblgxsp)
    
    if not feyqgcue.is_empty():
        var fojghadq = mtwcnedv.rcxoyamh(dkthwbih, feyqgcue, ncblgxsp)
        if not fojghadq.success:
            return fojghadq                                       
    
    jegoprbh.pack(ncblgxsp)
    if ResourceSaver.save(jegoprbh, jlzwyqzv) == OK:
        return {"success": true, "error_message": ""}
    else:
        var sbkbnafs = "Failed to save packed scene '%s'." % jlzwyqzv
        push_error(sbkbnafs)
        return {"success": false, "error_message": sbkbnafs}

static func parse_line(vuxgswsc: String, yhtkurbx: String) -> Dictionary:
    if vuxgswsc.begins_with("add_existing_scene("):
        var tufiierf = vuxgswsc.replace("add_existing_scene(", "").strip_edges()
        if tufiierf.ends_with(")"):
            tufiierf = tufiierf.substr(0, tufiierf.length() - 1).strip_edges()
        
        var ifbewefn = []
        var megzmtry = 0
                                             
        for _i in range(4):
            var sctmrqvw = tufiierf.find('"',megzmtry)
            if sctmrqvw == -1: return {}
            var oafafgio = tufiierf.find('"', sctmrqvw + 1)
            if oafafgio == -1: return {}
            ifbewefn.append(tufiierf.substr(sctmrqvw + 1, oafafgio - sctmrqvw - 1))
            megzmtry = oafafgio + 1
        
                                        
        var szdbthes = {}
        var ruoqdlkw = tufiierf.substr(megzmtry).strip_edges()
        if ruoqdlkw.begins_with("{"):
            szdbthes = njejqaeg.rwlaxvut(ruoqdlkw)
        
        return {
            "type": "add_existing_scene",
            "node_name": ifbewefn[0],
            "existing_scene_path": ifbewefn[1],
            "target_scene_path": ifbewefn[2],
            "parent_path": ifbewefn[3],
            "modifications": szdbthes
        }
    return {}
