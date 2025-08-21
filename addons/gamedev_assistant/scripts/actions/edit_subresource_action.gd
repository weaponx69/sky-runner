                                                                      
@tool
extends Node

const txflazde = preload("action_parser_utils.gd")
                                                                            
                                                   
const tbmtppps = preload("add_subresource_action.gd")

static func execute(cgveupyx: String, avfmhuxp: String, hilksgrg: String, wxjngoit: Dictionary) -> Dictionary:
    var hfdfzbsc = EditorPlugin.new().get_editor_interface()
    var rdvsbowh = hfdfzbsc.get_open_scenes()

                                   
    for scene in rdvsbowh:
        if scene == avfmhuxp:
                                                                    
            hfdfzbsc.reload_scene_from_path(avfmhuxp)
            return _edit_in_open_scene(cgveupyx, hfdfzbsc.get_edited_scene_root(), hilksgrg, wxjngoit)

                                           
                                                              
    return _edit_in_closed_scene(cgveupyx, avfmhuxp, hilksgrg, wxjngoit)


static func _edit_in_open_scene(iafjwyxu: String, gweeznng: Node, qkikjari: String, pqfijcyw: Dictionary) -> Dictionary:
    var meeteycf = tbmtppps.xylwmnxb(iafjwyxu, gweeznng)               
    if not meeteycf:
                                              
        return {"success": false, "error_message": "Node '%s' not found." % iafjwyxu, "node_type": "", "subresource_type": ""}

    var ldiilzya = meeteycf.get(qkikjari)
    if not (ldiilzya is Resource):
        var vnlatrck = "Property '%s' on node '%s' is not a Resource or doesn't exist." % [qkikjari, iafjwyxu]
        push_error(vnlatrck)
        return {"success": false, "error_message": vnlatrck, "node_type": meeteycf.get_class(), "subresource_type": ""}

    var sjpnexte = nyddgfij(ldiilzya, pqfijcyw)
    if not sjpnexte.success:
        return {"success": false, "error_message": sjpnexte.error_message, "node_type": meeteycf.get_class(), "subresource_type": ldiilzya.get_class()}

                         
    EditorInterface.edit_resource(ldiilzya)                                 
    if EditorInterface.save_scene() == OK:
        return {"success": true, "error_message": "", "node_type": meeteycf.get_class(), "subresource_type": ldiilzya.get_class()}
    else:
        var vnlatrck = "Failed to save the scene."
        push_error(vnlatrck)
        return {"success": false, "error_message": vnlatrck, "node_type": meeteycf.get_class(), "subresource_type": ldiilzya.get_class()}

static func _edit_in_closed_scene(llxahcxa: String, ugrtcecd: String, mrkzprny: String, ocvzsptv: Dictionary) -> Dictionary:
    var zfpbqbzm = load(ugrtcecd)
    if !(zfpbqbzm is PackedScene):
        var yaazuhvh = "Failed to load scene '%s' as PackedScene." % ugrtcecd
        push_error(yaazuhvh)
        return {"success": false, "error_message": yaazuhvh, "node_type": "", "subresource_type": ""}

    var hchtixet = zfpbqbzm.instantiate()
    if not hchtixet:
        var yaazuhvh = "Could not instantiate scene '%s'." % ugrtcecd
        push_error(yaazuhvh)
        return {"success": false, "error_message": yaazuhvh, "node_type": "", "subresource_type": ""}

    var lxoftjkp = tbmtppps.xylwmnxb(llxahcxa, hchtixet)               
    if not lxoftjkp:
        hchtixet.free()
        return {"success": false, "error_message": "Node '%s' not found." % llxahcxa, "node_type": "", "subresource_type": ""}

    var sbavttrj = lxoftjkp.get(mrkzprny)
    if not (sbavttrj is Resource):
        var yaazuhvh = "Property '%s' on node '%s' is not a Resource or doesn't exist." % [mrkzprny, llxahcxa]
        push_error(yaazuhvh)
        hchtixet.free()
        return {"success": false, "error_message": yaazuhvh, "node_type": lxoftjkp.get_class(), "subresource_type": ""}

    var rfgrbgou = nyddgfij(sbavttrj, ocvzsptv)
    if not rfgrbgou.success:
        hchtixet.free()
        return {"success": false, "error_message": rfgrbgou.error_message, "node_type": lxoftjkp.get_class(), "subresource_type": sbavttrj.get_class()}

    zfpbqbzm.pack(hchtixet)
    var xbqxkdta = ResourceSaver.save(zfpbqbzm, ugrtcecd)
    hchtixet.free()

    if xbqxkdta == OK:
        return {"success": true, "error_message": "", "node_type": lxoftjkp.get_class(), "subresource_type": sbavttrj.get_class()}
    else:
        var yaazuhvh = "Failed to save the packed scene."
        push_error(yaazuhvh)
        return {"success": false, "error_message": yaazuhvh, "node_type": lxoftjkp.get_class(), "subresource_type": sbavttrj.get_class()}


                                                                             
         
                                                                             
static func nyddgfij(negcgivn: Resource, axilbtsv: Dictionary) -> Dictionary:
    for property_name in axilbtsv.keys():
        var apkzhabw = axilbtsv[property_name]
        var hzennjyz = tbmtppps._parse_value(apkzhabw)
        if hzennjyz == null and apkzhabw != null:
            var cqtrimrk = "Failed to parse value '%s' for property '%s'." % [str(apkzhabw), property_name]
            push_error(cqtrimrk)
            return {"success": false, "error_message": cqtrimrk}

        if not tbmtppps.vyacknwm(negcgivn, property_name, hzennjyz):
                                               
            var cqtrimrk = "Failed to set property '%s' on resource '%s'." % [property_name, negcgivn.get_class()]
            return {"success": false, "error_message": cqtrimrk}

    return {"success": true, "error_message": ""}

                                                                             
            
                                                       
                                                                
                                                                                                                     
                                                                             
static func parse_line(rrifhsqn: String, kmvxwnwv: String) -> Dictionary:
    if rrifhsqn.begins_with("edit_subresource("):
        var lvszcxuk = rrifhsqn.replace("edit_subresource(", "")
        if lvszcxuk.ends_with(")"):
            lvszcxuk = lvszcxuk.substr(0, lvszcxuk.length() - 1)             
        lvszcxuk = lvszcxuk.strip_edges()

                                                                                                
        var hghcrdrw = []
        var ukgbuunq = 0
        var fymgrucz = 0
        while fymgrucz < 3:                             
            var qfrknyvb = lvszcxuk.find('"',ukgbuunq)
            if qfrknyvb == -1:
                break                         
            var mlxjafmc = lvszcxuk.find('"', qfrknyvb + 1)
            if mlxjafmc == -1:
                break                       
            hghcrdrw.append(lvszcxuk.substr(qfrknyvb + 1, mlxjafmc - (qfrknyvb + 1)))             
            ukgbuunq = mlxjafmc + 1
            fymgrucz += 1
                                                                         
            var wpqaluya = lvszcxuk.find(",", ukgbuunq)
            if wpqaluya != -1:
                ukgbuunq = wpqaluya + 1
            else:
                                                                                                    
                if fymgrucz < 3: break                                               

        if hghcrdrw.size() < 3:
            push_error("Edit Subresource: Failed to parse required string arguments (node_name, scene_path, subresource_property_name). Line: " + rrifhsqn)
            return {}

                                                                        
        var uhtpoqid = lvszcxuk.find("{", ukgbuunq)                                 
        var dwscelfh = lvszcxuk.rfind("}")
        if uhtpoqid == -1 or dwscelfh == -1 or dwscelfh < uhtpoqid:
            push_error("Edit Subresource: Failed to find or parse properties dictionary. Line: " + rrifhsqn)
            return {}

        var lfnxyjjl = lvszcxuk.substr(uhtpoqid, dwscelfh - uhtpoqid + 1)             
                                                                           
        var lwrylusw = txflazde.rwlaxvut(lfnxyjjl)                                 

                                                                           
                                                                                   

        return {
            "type": "edit_subresource",
            "node_name": hghcrdrw[0],
            "scene_path": hghcrdrw[1],
            "subresource_property_name": hghcrdrw[2],
            "properties": lwrylusw                                         
        }

    return {}
