                                                                     
@tool
extends Node

const viosdfsb = preload("action_parser_utils.gd")

static func execute(ykwfrptu: String, rylviekq: String, asizgwpw: String, aatrijrn: Dictionary) -> Dictionary:
    var bituumuk = EditorPlugin.new().get_editor_interface()
    var scgnhemm = bituumuk.get_open_scenes()

                                   
    for scene in scgnhemm:
        if scene == rylviekq:
                                                                   
            bituumuk.reload_scene_from_path(rylviekq)
            return _add_to_open_scene(ykwfrptu, bituumuk.get_edited_scene_root(), asizgwpw, aatrijrn)

                                           
                                                             
    return _add_to_closed_scene(ykwfrptu, rylviekq, asizgwpw, aatrijrn)


static func _add_to_open_scene(zitwewgx: String, iszumuhq: Node, nyoyuxaj: String, ildnbgjy: Dictionary) -> Dictionary:
    var zxvjgcrd = xylwmnxb(zitwewgx, iszumuhq)
    if not zxvjgcrd:
        return {"success": false, "error_message": "Node '%s' not found." % zitwewgx, "node_type": ""}

    var suokrfiu = lyzlbouq(nyoyuxaj, ildnbgjy)
    if not suokrfiu:
                                       
        return {"success": false, "error_message": "Could not create or configure resource '%s'." % nyoyuxaj, "node_type": zxvjgcrd.get_class()}

    if not ildnbgjy.has("assign_to_property"):
        var wenxhfhn = "No 'assign_to_property' field in ildnbgjy dictionary."
        push_error(wenxhfhn)
        return {"success": false, "error_message": wenxhfhn, "node_type": zxvjgcrd.get_class()}

    var xbohliqf = String(ildnbgjy["assign_to_property"])
    if not njmnjncj(zxvjgcrd, xbohliqf, suokrfiu):
                                       
        var wenxhfhn = "Failed to assign new resource to property '%s'." % xbohliqf
        return {"success": false, "error_message": wenxhfhn, "node_type": zxvjgcrd.get_class()}

    if EditorInterface.save_scene() == OK:
        return {"success": true, "error_message": "", "node_type": zxvjgcrd.get_class()}
    else:
        var wenxhfhn = "Failed to save the scene."
        push_error(wenxhfhn)
        return {"success": false, "error_message": wenxhfhn, "node_type": zxvjgcrd.get_class()}

static func _add_to_closed_scene(ozdaveca: String, ybnuzyct: String, gimufzky: String, iwbsrazf: Dictionary) -> Dictionary:
    var bjrcsmeg = load(ybnuzyct)
    if !(bjrcsmeg is PackedScene):
        var jmdrwogl = "Failed to load scene '%s' as PackedScene." % ybnuzyct
        push_error(jmdrwogl)
        return {"success": false, "error_message": jmdrwogl, "node_type": ""}

    var smzpzuiy = bjrcsmeg.instantiate()
    if not smzpzuiy:
        var jmdrwogl = "Could not instantiate scene '%s'." % ybnuzyct
        push_error(jmdrwogl)
        return {"success": false, "error_message": jmdrwogl, "node_type": ""}

    var jjclakfb = xylwmnxb(ozdaveca, smzpzuiy)
    if not jjclakfb:
        return {"success": false, "error_message": "Node '%s' not found." % ozdaveca, "node_type": ""}

    var xbldzlqt = lyzlbouq(gimufzky, iwbsrazf)
    if not xbldzlqt:
        return {"success": false, "error_message": "Could not create or configure resource '%s'." % gimufzky, "node_type": jjclakfb.get_class()}

    if not iwbsrazf.has("assign_to_property"):
        var jmdrwogl = "No 'assign_to_property' field in iwbsrazf dictionary."
        push_error(jmdrwogl)
        return {"success": false, "error_message": jmdrwogl, "node_type": jjclakfb.get_class()}

    var upcdpcrn = String(iwbsrazf["assign_to_property"])
    if not njmnjncj(jjclakfb, upcdpcrn, xbldzlqt):
        var jmdrwogl = "Failed to assign new resource to property '%s'." % upcdpcrn
        return {"success": false, "error_message": jmdrwogl, "node_type": jjclakfb.get_class()}

    bjrcsmeg.pack(smzpzuiy)
    if ResourceSaver.save(bjrcsmeg, ybnuzyct) == OK:
        return {"success": true, "error_message": "", "node_type": jjclakfb.get_class()}
    else:
        var jmdrwogl = "Failed to save the packed scene."
        push_error(jmdrwogl)
        return {"success": false, "error_message": jmdrwogl, "node_type": jjclakfb.get_class()}

                                                                             
         
                                                                             
static func xylwmnxb(cfsmmzjv: String, jdapxjng: Node) -> Node:
    var zprhnmlu = jdapxjng.find_child(cfsmmzjv, true, true)
    if not zprhnmlu and cfsmmzjv == jdapxjng.name:
        zprhnmlu = jdapxjng

    if not zprhnmlu:
        push_error("Node '%s' not found in the scene." % cfsmmzjv)
        return null

    return zprhnmlu


static func lyzlbouq(hnqbzznz: String, qzkuezew: Dictionary) -> Resource:
    if not ClassDB.class_exists(hnqbzznz):
        push_error("Resource type '%s' does not exist." % hnqbzznz)
        return null

    var loowtsso = ClassDB.instantiate(hnqbzznz)
    if not loowtsso:
        push_error("Could not instantiate resource of type '%s'." % hnqbzznz)
        return null

                                                                  
    for property_name in qzkuezew.keys():
        if property_name == "assign_to_property":
            continue

        var betbwddb = qzkuezew[property_name]
        var wnbyctzr = _parse_value(betbwddb)
        if wnbyctzr == null and betbwddb != null:
            push_error("Failed to parse value '%s' for property '%s'." % [str(betbwddb), property_name])
            return null

        if not vyacknwm(loowtsso, property_name, wnbyctzr):
            return null

    return loowtsso


static func _parse_value(ksiixbun) -> Variant:
                                                             
    if ksiixbun is String:
        var pqzjmaud = ksiixbun.strip_edges()
                                                 
        if pqzjmaud.begins_with("(") and pqzjmaud.ends_with(")"):
            var xugbndpz = pqzjmaud.substr(1, pqzjmaud.length() - 2)
            var zfxnojtk = xugbndpz.split(",", false)
            if zfxnojtk.size() == 2:
                return Vector2(float(zfxnojtk[0].strip_edges()), float(zfxnojtk[1].strip_edges()))
            elif zfxnojtk.size() == 3:
                return Vector3(float(zfxnojtk[0].strip_edges()), float(zfxnojtk[1].strip_edges()), float(zfxnojtk[2].strip_edges()))
            elif zfxnojtk.size() == 4:
                return Vector4(float(zfxnojtk[0].strip_edges()), float(zfxnojtk[1].strip_edges()), float(zfxnojtk[2].strip_edges()), float(zfxnojtk[3].strip_edges()))
        if pqzjmaud.to_lower() == "true":
            return true
        if pqzjmaud.to_lower() == "false":
            return false
        if pqzjmaud.is_valid_float():
            return float(pqzjmaud)
                                       
        return pqzjmaud

                                                                  
    return ksiixbun


static func njmnjncj(sofacjqx: Node, ofotobmv: String, pnjlmbvj: Variant) -> bool:
    var bbwkqfup = sofacjqx.get(ofotobmv)
    var woqzxwzx = true
                                                                                          
                                                                                                        
                                         
      
                                                                                                            
                                                                 

                    
    sofacjqx.set(ofotobmv, pnjlmbvj)
                                               
    if sofacjqx.get(ofotobmv) != pnjlmbvj:
        push_error("Failed to set property '%s' on node '%s' value: %s." % [ofotobmv, sofacjqx.name, pnjlmbvj])
        woqzxwzx = false
                          
    return woqzxwzx


static func vyacknwm(tlgjcqpl: Resource, sxbjzrwe: String, yaybedeg: Variant) -> bool:
                                                    
    var skagtrly = tlgjcqpl.get_property_list()
    var bsthuyzt = null

                                           
    for prop_info in skagtrly:
        if prop_info.name == sxbjzrwe:
            bsthuyzt = prop_info.type
            break

                                              
    if bsthuyzt == null:
        push_error("Property '%s' doesn't exist on resource '%s'." % [sxbjzrwe, tlgjcqpl.get_class()])
        return true                                                              

                                                                                 
                                         
    if bsthuyzt == TYPE_COLOR:
        match typeof(yaybedeg):
            TYPE_VECTOR2:
                                                    
                yaybedeg = Color(yaybedeg.x, yaybedeg.y, 0, 1.0)
            TYPE_VECTOR3:
                                                        
                yaybedeg = Color(yaybedeg.x, yaybedeg.y, yaybedeg.z, 1.0)
            TYPE_VECTOR4:
                                                        
                yaybedeg = Color(yaybedeg.x, yaybedeg.y, yaybedeg.z, yaybedeg.w)
            TYPE_ARRAY:
                                                                                         
                if yaybedeg.size() == 3:
                    yaybedeg = Color(yaybedeg[0], yaybedeg[1], yaybedeg[2], 1.0)
                elif yaybedeg.size() == 4:
                    yaybedeg = Color(yaybedeg[0], yaybedeg[1], yaybedeg[2], yaybedeg[3])
                                                                       
                                           
            
                                                                    
    elif bsthuyzt == TYPE_VECTOR3 and typeof(yaybedeg):
        yaybedeg = Vector3(yaybedeg.x, yaybedeg.y, 0)

                    
    tlgjcqpl.set(sxbjzrwe, yaybedeg)

                                                   
    var fhvdyaem = tlgjcqpl.get(sxbjzrwe)
    
    var wwdonaln : bool
    
    if typeof(yaybedeg) in [TYPE_VECTOR2, TYPE_VECTOR3, TYPE_VECTOR4]:
        if typeof(fhvdyaem) == typeof(yaybedeg):
            wwdonaln = fhvdyaem.is_equal_approx(yaybedeg)
        else:
            push_error("Wrong data type for property %s" % [sxbjzrwe])
            wwdonaln = false
    elif typeof(yaybedeg) == TYPE_FLOAT and typeof(fhvdyaem) == TYPE_FLOAT:
                             
                         
        wwdonaln = is_equal_approx(yaybedeg, fhvdyaem)
    else:
        wwdonaln = fhvdyaem == yaybedeg

                                                                              
    if typeof(fhvdyaem) == typeof(yaybedeg) and not wwdonaln:
        push_error("Failed to set resource property '%s' on resource '%s' value: %s " % [sxbjzrwe, tlgjcqpl.get_class(), yaybedeg])
        return false

    return true



                                                                             
            
                                                       
                                                               
                                                                             
                           
static func parse_line(tbujbydo: String, lqpssewf: String) -> Dictionary:
    if tbujbydo.begins_with("add_subresource("):
        var kclvtfvg = tbujbydo.replace("add_subresource(", "")
        if kclvtfvg.ends_with(")"):
            kclvtfvg = kclvtfvg.substr(0, kclvtfvg.length() - 1)
        kclvtfvg = kclvtfvg.strip_edges()

        var etlzbxpg = []
        var mjqjqdjz = 0
        while true:
            var uzgkspnv = kclvtfvg.find('"',mjqjqdjz)
            if uzgkspnv == -1:
                break
            var jxneiyis = kclvtfvg.find('"', uzgkspnv + 1)
            if jxneiyis == -1:
                break
            etlzbxpg.append(kclvtfvg.substr(uzgkspnv + 1, jxneiyis - (uzgkspnv + 1)))
            mjqjqdjz = jxneiyis + 1

        var scpstipz = kclvtfvg.find("{")
        var hqyogaib = kclvtfvg.rfind("}")
        if scpstipz == -1 or hqyogaib == -1:
            return {}

        var dmgynuco = kclvtfvg.substr(scpstipz, hqyogaib - scpstipz + 1)
        var lnutqwvb = viosdfsb.rwlaxvut(dmgynuco)

                                                                               
                                                                                
                                  
        for key in lnutqwvb.keys():
            var jxhcssuc = lnutqwvb[key]
            if jxhcssuc is String:
                var pydqndze = jxhcssuc.strip_edges()
                if pydqndze.begins_with("\"") and pydqndze.ends_with("\"") and pydqndze.length() > 1:
                    pydqndze = pydqndze.substr(1, pydqndze.length() - 2)
                lnutqwvb[key] = pydqndze
                                                                               

        if etlzbxpg.size() < 3:
            return {}

        return {
            "type": "add_subresource",
            "node_name": etlzbxpg[0],
            "scene_path": etlzbxpg[1],
            "subresource_type": etlzbxpg[2],
            "properties": lnutqwvb
        }

    return {}
