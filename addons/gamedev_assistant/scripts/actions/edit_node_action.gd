                                                               
@tool
extends Node

const kpmprxlx = preload("action_parser_utils.gd")

static func execute(iqgvetbw: String, iepxaous: String, ejyqvnpt: Dictionary) -> Dictionary:
    var fnxszzpa = EditorPlugin.new().get_editor_interface()
    var udjikxme = fnxszzpa.get_open_scenes()

                                   
    for scene in udjikxme:
        if scene == iepxaous:
                                                     
            fnxszzpa.reload_scene_from_path(iepxaous)
                                                             
            return icdkknyf(iqgvetbw, fnxszzpa.get_edited_scene_root(), ejyqvnpt)

                                                        
                                               
    return fsjqdsvv(iqgvetbw, iepxaous, ejyqvnpt)


static func icdkknyf(nzhyruzb: String, mgwjslju: Node, egibjvvb: Dictionary) -> Dictionary:
    var xypvpzoh = mgwjslju.find_child(nzhyruzb, true, true)
    
    if not xypvpzoh and nzhyruzb == mgwjslju.name:
        xypvpzoh = mgwjslju

    if not xypvpzoh:
        var axhhssqt = "Node '%s' not found in open scene root '%s'." % [nzhyruzb, mgwjslju.name]
        push_error(axhhssqt)
        return {"success": false, "error_message": axhhssqt, "node_type": ""}

                                                 
    var tuefyffx = rcxoyamh(xypvpzoh, egibjvvb, mgwjslju)
    if not tuefyffx.success:
        return {"success": false, "error_message": tuefyffx.error_message, "node_type": xypvpzoh.get_class()}
        
                                                  
    if EditorInterface.save_scene() == OK:
        return {"success": true, "error_message": "", "node_type": xypvpzoh.get_class()}
    else:
        var axhhssqt = "Failed to save the scene."
        push_error(axhhssqt)
        return {"success": false, "error_message": axhhssqt, "node_type": xypvpzoh.get_class()}


static func fsjqdsvv(bqivgcav: String, rhihifgd: String, zjpexbiy: Dictionary) -> Dictionary:
    var skvkcxla = load(rhihifgd)
    if !(skvkcxla is PackedScene):
        var wmfgvoyt = "Failed to load scene '%s' as PackedScene." % rhihifgd
        push_error(wmfgvoyt)
        return {"success": false, "error_message": wmfgvoyt, "node_type": ""}

    var enavtmgo = skvkcxla.instantiate()
    if not enavtmgo:
        var wmfgvoyt = "Could not instantiate scene '%s'." % rhihifgd
        push_error(wmfgvoyt)
        return {"success": false, "error_message": wmfgvoyt, "node_type": ""}

    var gxbbbgcj = enavtmgo.find_child(bqivgcav, true, true)
    
    if not gxbbbgcj and bqivgcav == enavtmgo.name:
        gxbbbgcj = enavtmgo

    if not gxbbbgcj:
        var wmfgvoyt = "Node '%s' not found in scene instance root '%s'." % [bqivgcav, enavtmgo.name]
        push_error(wmfgvoyt)
        return {"success": false, "error_message": wmfgvoyt, "node_type": ""}

                                                        
    var baxwsblr = rcxoyamh(gxbbbgcj, zjpexbiy, enavtmgo)
    if not baxwsblr.success:
        return {"success": false, "error_message": baxwsblr.error_message, "node_type": gxbbbgcj.get_class()}

                                
    skvkcxla.pack(enavtmgo)
    if ResourceSaver.save(skvkcxla, rhihifgd) == OK:
        return {"success": true, "error_message": "", "node_type": gxbbbgcj.get_class()}
    else:
        var wmfgvoyt = "Failed to save the packed scene."
        push_error(wmfgvoyt)
        return {"success": false, "error_message": wmfgvoyt, "node_type": gxbbbgcj.get_class()}


static func rcxoyamh(iohvefqa: Node, idgiglnx: Dictionary, ycwicwxp: Node = null) -> Dictionary:
    for property_name in idgiglnx.keys():
        var igqiuttc = idgiglnx[property_name]
        var levkpgxf = _parse_value(igqiuttc)
        if levkpgxf == null and igqiuttc != null:
            var xdwzrxty = "Failed to parse value '%s' for property '%s'." % [str(igqiuttc), property_name]
            push_error(xdwzrxty)
            return {"success": false, "error_message": xdwzrxty}
            
                                     
                                                                                                           
                                                             
        var bmhdlurc = _try_set_property(iohvefqa, property_name, levkpgxf, ycwicwxp)
        if not bmhdlurc:
                                                                       
            var xdwzrxty = "Failed to set property '%s' on node '%s'." % [property_name, iohvefqa.name]
            return {"success": false, "error_message": xdwzrxty}

    return {"success": true, "error_message": ""}

static func _parse_value(rhkwucuh) -> Variant:
                                                                                            
    if rhkwucuh is String:
        var kgyrnaxa = rhkwucuh.strip_edges()
        
                                                        
        if kgyrnaxa.length() >= 2 and kgyrnaxa.begins_with('"') and kgyrnaxa.ends_with('"'):
            kgyrnaxa = kgyrnaxa.substr(1, kgyrnaxa.length() - 2)
        elif kgyrnaxa.length() >= 2 and kgyrnaxa.begins_with("'") and kgyrnaxa.ends_with("'"):
            kgyrnaxa = kgyrnaxa.substr(1, kgyrnaxa.length() - 2)
        
        if kgyrnaxa.begins_with("(") and kgyrnaxa.ends_with(")"):
            var ytpeampx = kgyrnaxa.substr(1, kgyrnaxa.length() - 2)
            var zgxfnyuq = ytpeampx.split(",", false)
                                                  
            if zgxfnyuq.size() == 2:
                var fobdaqbr = float(zgxfnyuq[0].strip_edges())
                var muaynzby = float(zgxfnyuq[1].strip_edges())
                return Vector2(fobdaqbr, muaynzby)
                                                  
            if zgxfnyuq.size() == 3:
                var obtkxxjz = float(zgxfnyuq[0].strip_edges())
                var ibevbdch = float(zgxfnyuq[1].strip_edges())
                var btrysirj = float(zgxfnyuq[2].strip_edges())
                return Vector3(obtkxxjz, ibevbdch, btrysirj)
                                                  
            if zgxfnyuq.size() == 4:
                var lpjkoarw = float(zgxfnyuq[0].strip_edges())
                var hnfoqrez = float(zgxfnyuq[1].strip_edges())
                var ynhrphjj = float(zgxfnyuq[2].strip_edges())
                var nftpescd = float(zgxfnyuq[3].strip_edges())
                return Vector4(lpjkoarw, hnfoqrez, ynhrphjj, nftpescd)
                               
        if kgyrnaxa.to_lower() == "true":
            return true
        if kgyrnaxa.to_lower() == "false":
            return false
                                
        if kgyrnaxa.is_valid_float():
            return float(kgyrnaxa)
                                                
        return kgyrnaxa

                                                             
    return rhkwucuh

static func jtwfisjs(mjqfhypp: String, ynhnzxoj: String) -> String:
    var psrpuvey = ""
    var awqgijbr = mjqfhypp.length()
    var sfcedvjq = ynhnzxoj.length()
    var zmebwvnp = min(awqgijbr, sfcedvjq)

    for i in range(zmebwvnp):
        if mjqfhypp[i] != ynhnzxoj[i]:
            psrpuvey += "Difference at index: " + str(i) + ", String1: " + mjqfhypp[i] + ", String2: " + ynhnzxoj[i]
            break

    return psrpuvey


static func _try_set_property(srjytegc: Node, glbfpwpw: String, dcmjmlxy: Variant, mmpnfszt: Node = null) -> bool:  
                                      
    if glbfpwpw == "parent":
        if not dcmjmlxy is String:
            push_error("Parent value must be a string (name of the new parent)")
            return false

        if mmpnfszt == null:
            push_error("Cannot re-parent without a valid scene root.")
            return false

        var dymrlvzm = dcmjmlxy.strip_edges()
        var qdaimyim: Node

                                                 
                                                                          
        if dymrlvzm == "" or dymrlvzm == mmpnfszt.name:
            qdaimyim = mmpnfszt
        else:
            qdaimyim = mmpnfszt.find_child(dymrlvzm, true, true)
            if not qdaimyim:
                push_error("Failed to find parent node with name: %s" % dymrlvzm)
                return false
        
                   
        if srjytegc.get_parent():
            srjytegc.get_parent().remove_child(srjytegc)
        qdaimyim.add_child(srjytegc)

                                                                          
        srjytegc.set_owner(mmpnfszt)

        return true

                                      
    var djxwdoxk = srjytegc.get_property_list()
    for prop in djxwdoxk:
        if prop.name == glbfpwpw:
                        
            if prop.type == TYPE_COLOR:
                match typeof(dcmjmlxy):
                    TYPE_VECTOR2:
                                                            
                        dcmjmlxy = Color(dcmjmlxy.x, dcmjmlxy.y, 0, 1.0)
                    TYPE_VECTOR3:
                                                                
                        dcmjmlxy = Color(dcmjmlxy.x, dcmjmlxy.y, dcmjmlxy.z, 1.0)
                    TYPE_VECTOR4:
                        dcmjmlxy = Color(dcmjmlxy.x, dcmjmlxy.y, dcmjmlxy.z, dcmjmlxy.w)
                    TYPE_ARRAY:
                                                                                                  
                        if dcmjmlxy.size() == 3:
                            dcmjmlxy = Color(dcmjmlxy[0], dcmjmlxy[1], dcmjmlxy[2], 1.0)
                        elif dcmjmlxy.size() == 4:
                            dcmjmlxy = Color(dcmjmlxy[0], dcmjmlxy[1], dcmjmlxy[2], dcmjmlxy[3])

                                                                       
            elif prop.type == TYPE_OBJECT and prop.hint == PROPERTY_HINT_RESOURCE_TYPE:
                var gntggatd = prop.hint_string
                
                                           
                if gntggatd == "Texture2D" or gntggatd.contains("Texture2D"):
                    var fxtqyybv = load(dcmjmlxy)

                                                                                        
                    if "_" in glbfpwpw:
                        var yyairmcb = glbfpwpw.split("_")
                        if yyairmcb.size() > 1:
                            var vcqcamsn = yyairmcb[1]
                            var xmzamvef = "set_texture_" + vcqcamsn
                            if srjytegc.has_method(xmzamvef):
                                srjytegc.call(xmzamvef, fxtqyybv)
                                return true

                                                                           
                    if srjytegc.has_method("set_texture"):
                        srjytegc.set_texture(fxtqyybv)
                        return true
                        
                                             
                elif gntggatd == "Mesh" or gntggatd.contains("Mesh"):
                    var quoaslcz = load(dcmjmlxy)
                    if not quoaslcz:
                        push_error("Failed to load mesh at path: %s" % dcmjmlxy)
                        return false
                    
                    if "_" in glbfpwpw:
                        var yyairmcb = glbfpwpw.split("_")
                        if yyairmcb.size() > 1:
                            var vcqcamsn = yyairmcb[1]
                            var xmzamvef = "set_mesh_" + vcqcamsn
                            if srjytegc.has_method(xmzamvef):
                                srjytegc.call(xmzamvef, quoaslcz)
                                return true
                    
                    srjytegc.set(glbfpwpw, quoaslcz)
                    return true
                
                                                
                elif gntggatd == "AudioStream" or gntggatd.contains("AudioStream"):
                    var lmldgvaz = load(dcmjmlxy)
                    if not lmldgvaz:
                        push_error("Failed to load audio stream at path: %s" % dcmjmlxy)
                        return false
                    srjytegc.set(glbfpwpw, lmldgvaz)
                    return true



                                                                 
    if not srjytegc.has_method("get") or srjytegc.get(glbfpwpw) == null:
        push_error("Property '%s' doesn't exist on node '%s'." % [glbfpwpw, srjytegc.name])
        return false

                                    
    srjytegc.set(glbfpwpw, dcmjmlxy)

                                                               
                                                          
    return true


                                                                             
                 
                                                                      
                                                                             
static func parse_line(ymeaxmhm: String, qgmapygo: String) -> Dictionary:
                                                     
    if ymeaxmhm.begins_with("edit_node("):
        var wkgcepjb = kpmprxlx.ifabcoem(ymeaxmhm)
                                                            
        if wkgcepjb.size() == 0:
            return {}
        if not wkgcepjb.has("node_name") \
            or not wkgcepjb.has("scene_path") \
            or not wkgcepjb.has("modifications"):
            return {}

        return {
            "type": "edit_node",
            "node_name": wkgcepjb.node_name,
            "scene_path": wkgcepjb.scene_path,
            "modifications": wkgcepjb.modifications
        }

    return {}
