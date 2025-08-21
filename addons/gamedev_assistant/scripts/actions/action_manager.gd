                                                                  
@tool
extends Node

signal xwkrpxjn(action_type: String, success: bool, error_message: String, node_name: String, subresource_name: String, button: Button)
signal lcnzplbc(action_type: String, disable: bool)

                                     
const zonqqclt = preload("res://addons/gamedev_assistant/scripts/actions/action_parser_utils.gd")
const djllhbiu = preload("res://addons/gamedev_assistant/scripts/actions/create_file_action.gd")
const wvppamcn = preload("res://addons/gamedev_assistant/scripts/actions/create_scene_action.gd")
const yswnczwy = preload("res://addons/gamedev_assistant/scripts/actions/create_node_action.gd")
const xxjifzeh = preload("res://addons/gamedev_assistant/scripts/actions/edit_node_action.gd")
const gxeocfgr = preload("res://addons/gamedev_assistant/scripts/actions/add_subresource_action.gd")
const jwkmujtl = preload("res://addons/gamedev_assistant/scripts/actions/edit_subresource_action.gd")
const nlraiztn = preload("res://addons/gamedev_assistant/scripts/actions/assign_script_action.gd")
const buzppzyr = preload("res://addons/gamedev_assistant/scripts/actions/add_existing_scene_action.gd")
const ravcqrsf = preload("res://addons/gamedev_assistant/scripts/actions/edit_script_action.gd")

const eskbuzml = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_ActionButton.tscn")
const elfiwzuc = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_ApplyAllButton.tscn")
const aeizptwu = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_ActionsContainer.tscn")
const hbjyxjrq = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_Spacing.tscn")

var fivsquoe: Control
var ofsvnptz : VBoxContainer
var yynmqtew: Array = []
var soqhydap : Button
var fdxmvxix : bool
var fgcsfhya : bool

                             
var mxnpkslu: Timer

func _ready():
    
    var zbbfeseg = EditorInterface.get_editor_settings()       
    fgcsfhya = zbbfeseg.has_setting("gamedev_assistant/development_mode") and zbbfeseg.get_setting('gamedev_assistant/development_mode') == true    

                                                           
    xwkrpxjn.connect(iuxvllcx)
    lcnzplbc.connect(tzqlvcsc)

                                    
    mxnpkslu = Timer.new()
    mxnpkslu.wait_time = 0.2
    mxnpkslu.one_shot = true
    add_child(mxnpkslu)

                            
func tzihlygi(rqexmjbd: String, tsvyihha: int) -> Array:
    var lsrssddy = []

    var wqxvyfae = "[gds_actions]"
    var zitzngul = "[/gds_actions]"

    var ejcvrgir = rqexmjbd.find(wqxvyfae)
    var xkhflssj = rqexmjbd.find(zitzngul)

    if ejcvrgir == -1 or xkhflssj == -1:
        return lsrssddy                                       

                                                                
    var evsglkrb = ejcvrgir + wqxvyfae.length()
    var yetdeoya = xkhflssj - evsglkrb
    var tgwkholz = rqexmjbd.substr(evsglkrb, yetdeoya).strip_edges()
    
    if fgcsfhya:
        print(tgwkholz)

                                        
    var jhrjoyjl = tgwkholz.split("\n")
    for line in jhrjoyjl:
        line = line.strip_edges()
        if line == "":
            continue

        var pgfjgupn = kbmpepvz(line, rqexmjbd)
        if pgfjgupn:
            pgfjgupn["message_id"] = tsvyihha
            lsrssddy.append(pgfjgupn)

    return lsrssddy


                    
func sqnnbqzs(gfewbtuf: String, ghxhvbvx: String, ncpzuytd: Button) -> bool:
    var cmkykbsw = djllhbiu.execute(gfewbtuf, ghxhvbvx)
    xwkrpxjn.emit("create_file", cmkykbsw.success, cmkykbsw.error_message, "", "", ncpzuytd)
    return cmkykbsw.success

                     
func ntnqbfir(dzqugvtj: String, vvnkvhaj: String, ucmcuysh: String, flsotbmk: Button) -> bool:
    var vhugpqlu = wvppamcn.execute(dzqugvtj, vvnkvhaj, ucmcuysh)
    xwkrpxjn.emit("create_scene", vhugpqlu.success, vhugpqlu.error_message, "", "", flsotbmk)
    return vhugpqlu.success

                    
func apnvnibq(fabntpea: String, smurrbwe: String, mzyjcqyw: String, cugfiyun: String, rnmmggxh: Dictionary, ipopzajw: Button) -> bool:
    var cvcskcyv = yswnczwy.execute(fabntpea, smurrbwe, mzyjcqyw, cugfiyun, rnmmggxh)
    xwkrpxjn.emit("create_node", cvcskcyv.success, cvcskcyv.error_message, smurrbwe, "", ipopzajw)
    return cvcskcyv.success
    
                  
func gxdqqkut(ngebwidp: String, zlszsqfa: String, tuycucwf: Dictionary, azgmhjkl: Button) -> bool:
    var vcfnditi = xxjifzeh.execute(ngebwidp, zlszsqfa, tuycucwf)
    xwkrpxjn.emit("edit_node", vcfnditi.success, vcfnditi.error_message, vcfnditi.node_type, "", azgmhjkl)
    return vcfnditi.success
    
func dihyovkx(bxotmrqm: String, pvoxaoqk: String, gpiqyoar: String, qykkgges: Dictionary, qwxfrmyx: Button) -> bool:
    var epkvqigm = gxeocfgr.execute(bxotmrqm, pvoxaoqk, gpiqyoar, qykkgges)
    xwkrpxjn.emit("add_subresource", epkvqigm.success, epkvqigm.error_message, epkvqigm.node_type, gpiqyoar, qwxfrmyx)
    return epkvqigm.success

                         
func puahckgm(jnuwswxf: String, akyhsqtc: String, hacebdmo: String, cqgefmks: Dictionary, gxuduuzg: Button) -> bool:
    var gekhgjsk = jwkmujtl.execute(jnuwswxf, akyhsqtc, hacebdmo, cqgefmks)
                                                                              
    xwkrpxjn.emit("edit_subresource", gekhgjsk.success, gekhgjsk.error_message, gekhgjsk.node_type, gekhgjsk.subresource_type, gxuduuzg)
    return gekhgjsk.success

func wrwyozxr(drxkzeyr: String, ccnqksvv: String, ckvhpfbi: String, odjssfiw: Button) -> bool:  
      var wixqcrut = nlraiztn.execute(drxkzeyr, ccnqksvv, ckvhpfbi)  
      xwkrpxjn.emit("assign_script", wixqcrut.success, wixqcrut.error_message, "", "", odjssfiw)  
      return wixqcrut.success  

func denvjtai(cavmobhr: String, thyxwhdn: String, wjvitrcq: String, nwaxgjnm: String, sspugwll: Dictionary, qeqhlxie: Button) -> bool:
    var kcfnealu = buzppzyr.execute(cavmobhr, thyxwhdn, wjvitrcq, nwaxgjnm, sspugwll)
    xwkrpxjn.emit("add_existing_scene", kcfnealu.success, kcfnealu.error_message, "", "", qeqhlxie)
    return kcfnealu.success  
    
func wtbobaza(zedxdnzz: String, emlvzvhg: int, vmwkupfy: Button) -> bool:
    var jsgpndte = $"../APIManager"
    var amxbqooq = ravcqrsf.execute(zedxdnzz, emlvzvhg, vmwkupfy, jsgpndte)
    xwkrpxjn.emit("edit_script", amxbqooq.success, amxbqooq.error_message, "", "", vmwkupfy)
    return amxbqooq.success  

                                 
func tixshqxn(wjldnfnl: Array, bfjwbwdv: Control) -> void:
    
    fivsquoe = bfjwbwdv    
    fzmbqmkd()
    
    ofsvnptz = aeizptwu.instantiate()
    var qxpbykcl = hbjyxjrq.instantiate()
    ofsvnptz.add_child(qxpbykcl)
    fivsquoe.add_child(ofsvnptz)
    
                                                        
    if wjldnfnl.size() > 1:
        soqhydap = elfiwzuc.instantiate()
        soqhydap.text = "Apply All"
        soqhydap.disabled = false
        soqhydap.pressed.connect(dabxznag.bind(yynmqtew))
        soqhydap.tooltip_text = "Apply the actions listed below from top to bottom"
        ofsvnptz.add_child(soqhydap)

    for action in wjldnfnl:
        var djlxotpq = eskbuzml.instantiate()

        var zrbkownn = ""
        var rwfkjzpx = []
        
        match action.type:
            "create_file":
                zrbkownn = "Create {path}".format({"path": action.path})
                rwfkjzpx.append("Create file")
            "create_scene":
                zrbkownn = "Create {path}".format({
                    "path": action.path,
                })
                rwfkjzpx.append("Create scene")
            "create_node":
                var fdkrritv = action.scene_path.get_file()
                var bilbnpnc = action.parent_path if action.parent_path != "" else "root"
                zrbkownn = "Create {type} \"{node_name}\"".format({
                    "type": action.node_type,
                    "node_name": action.name
                })
                rwfkjzpx.append("Create node")
                rwfkjzpx.append("Scene: %s" % fdkrritv)                
            "edit_node":
                var fdkrritv = action.scene_path.get_file()
                zrbkownn = "Edit %s" % [action.node_name]
                
                rwfkjzpx.append("Edit node")
                rwfkjzpx.append("Scene: %s" % fdkrritv)
            "add_subresource":
                var fdkrritv = action.scene_path.get_file()
                zrbkownn = "Add %s to %s" % [
                    action.subresource_type,
                    action.node_name
                ]                
                rwfkjzpx.append("Add subresource")
                rwfkjzpx.append("Scene: %s" % fdkrritv)
            "edit_subresource":
                var fdkrritv = action.scene_path.get_file()
                zrbkownn = "Edit %s on %s" % [
                    action.subresource_property_name,                                       
                    action.node_name                                                
                ]
                rwfkjzpx.append("Edit subresource")
                rwfkjzpx.append("Scene: %s" % fdkrritv)
                rwfkjzpx.append("Property: %s" % action.subresource_property_name)                
            "assign_script":  
                var fdkrritv = action.scene_path.get_file()  
                var rzxjmxfq = action.script_path.get_file()
                zrbkownn = "Attach %s to %s" % [  
                    rzxjmxfq,  
                    action.node_name  
                ]
                rwfkjzpx.append("Attach script")
                rwfkjzpx.append("File: %s" % rzxjmxfq)
                rwfkjzpx.append("Scene: %s" % fdkrritv)                
            "add_existing_scene":
                var cacggrpo = action.existing_scene_path.get_file()
                var uxorniin = action.target_scene_path.get_file()
                zrbkownn = "Add %s to %s" % [cacggrpo, uxorniin]
                
                rwfkjzpx.append("Add existing scene")
                rwfkjzpx.append("Source: %s" % cacggrpo)
                rwfkjzpx.append("Target: %s" % uxorniin)  
            "edit_script":
                zrbkownn = "Edit {path}".format({"path": action.path})
                rwfkjzpx.append("Edit script")
                rwfkjzpx.append("Path: %s" % action.path)
                                
                              
        if action.has("path"):
            rwfkjzpx.append("Path: %s" % action.path)
        
        if action.has("scene_name"):
            rwfkjzpx.append("Scene: %s" % action.scene_name)
        
        if action.has("node_type"):
            rwfkjzpx.append("Node type: %s" % action.node_type)
        
        if action.has("root_type"):
            rwfkjzpx.append("Root type: %s" % action.root_type)
            
        if action.has("subresource_type"):
            rwfkjzpx.append("Subresource type: %s" % action.subresource_type)
        
        if action.has("name"):
            rwfkjzpx.append("Name: %s" % action.name)
        
        if action.has("node_name"):
            rwfkjzpx.append("Node name: %s" % action.node_name)
       
        if action.has("parent_path"):      
            rwfkjzpx.append("Parent: %s" % (action.parent_path if action.parent_path else "root"))
            
        if action.has("modifications") or action.has("properties"):
            var ymcphudb = action.get("modifications", action.get("properties", {}))
            if ymcphudb.size() > 0:
                rwfkjzpx.append("\nProperties to apply:")
                for key in ymcphudb:
                    rwfkjzpx.append("• %s = %s" % [key, str(ymcphudb[key])])
                
        djlxotpq.tooltip_text = "\n".join(rwfkjzpx)

        djlxotpq.text = zrbkownn
        djlxotpq.set_meta("action", action)
        djlxotpq.pressed.connect(birnkvam.bind(djlxotpq))

        ofsvnptz.add_child(djlxotpq)
        yynmqtew.append(djlxotpq)


                          
func fzmbqmkd() -> void:
    if fivsquoe == null:
        return
        
                                                                     
    if is_instance_valid(ofsvnptz) and ofsvnptz.is_inside_tree():
                                                                     
        if fivsquoe.has_node(ofsvnptz.get_path()):
                                                                  
            fivsquoe.remove_child(ofsvnptz)
    
                                    
    yynmqtew.clear()

                                                  
func birnkvam(ulyqtgfx: Button) -> void:
        fdxmvxix = false
        iguwrlty(ulyqtgfx)

                                                  
func iguwrlty(dtukjvhz: Button) -> void:
    var vsgswrbe = dtukjvhz.get_meta("action") if dtukjvhz.has_meta("action") else {}
    
    dtukjvhz.disabled = true

    match vsgswrbe.type:
        "create_file":
            sqnnbqzs(vsgswrbe.path, vsgswrbe.content, dtukjvhz)
        "create_scene":
            ntnqbfir(vsgswrbe.path, vsgswrbe.root_name, vsgswrbe.root_type, dtukjvhz)
        "create_node":
            var bicbeexu = vsgswrbe.modifications if vsgswrbe.has("modifications") else {}
            apnvnibq(vsgswrbe.name, vsgswrbe.node_type, vsgswrbe.scene_path, vsgswrbe.parent_path, bicbeexu, dtukjvhz)
        "edit_node":
            gxdqqkut(vsgswrbe.node_name, vsgswrbe.scene_path, vsgswrbe.modifications, dtukjvhz)
        "add_subresource":
            dihyovkx(
                vsgswrbe.node_name,
                vsgswrbe.scene_path,
                vsgswrbe.subresource_type,
                vsgswrbe.properties,
                dtukjvhz
            )
        "edit_subresource":
             puahckgm(
                vsgswrbe.node_name,
                vsgswrbe.scene_path,
                vsgswrbe.subresource_property_name,
                vsgswrbe.properties,                                                    
                dtukjvhz
             )
        "assign_script":  
              wrwyozxr(vsgswrbe.node_name, vsgswrbe.scene_path, vsgswrbe.script_path, dtukjvhz)  
        "add_existing_scene":
            denvjtai(
                vsgswrbe.node_name,
                vsgswrbe.existing_scene_path,
                vsgswrbe.target_scene_path,
                vsgswrbe.parent_path,
                vsgswrbe.modifications,
                dtukjvhz
            )
        "edit_script":
            wtbobaza(vsgswrbe.path, vsgswrbe.message_id, dtukjvhz)
        _:
            push_warning("Unrecognized action type: %s" % vsgswrbe.type)


                                             
func iuxvllcx(ypodnoyw: String, jsavhdjo: bool, ityvmdhv: String, oohrtesb: String, ariudkrl: String, xgzlsxhj: Button) -> void:
    if not is_instance_valid(xgzlsxhj):
        return

                                                                         
    var neficeeu = xgzlsxhj.text
    var klysazht = xgzlsxhj.tooltip_text
    
                                                         
    if is_instance_valid(soqhydap):
        soqhydap.disabled = true

    var odjhjsei = xgzlsxhj.get_meta("action")
    var wlenetkj = odjhjsei.get("message_id", -1)

    if wlenetkj != -1:
        $"../APIManager".rbhioaqq(wlenetkj, jsavhdjo, ypodnoyw, oohrtesb, ariudkrl, ityvmdhv)

                                                                             
    if ypodnoyw == odjhjsei.type:
        var xdxlcwkk = "✓ " if jsavhdjo else "✗ "
        var mjfwwmzx = "\n\nACTION COMPLETED" if jsavhdjo else "\n\nACTION FAILED:\n%s\nClick to retry." % ityvmdhv
        var ubbwtrcz = ""                               

                                                                   
        match ypodnoyw:
            "create_file":
                ubbwtrcz = ("Created file {path}" if jsavhdjo else "Failed: file creation {path}").format({"path": odjhjsei.path})
            "create_scene":
                ubbwtrcz = ("Created scene {path}, root: {root_type}" if jsavhdjo else "Failed: scene creation {path}, root: {root_type}").format({
                    "path": odjhjsei.path,
                    "root_type": odjhjsei.root_type
                })
            "create_node":
                var wdzzoqea = odjhjsei.scene_path.get_file()
                var hvmmcpry = odjhjsei.parent_path if odjhjsei.parent_path != "" else "root"
                var gzbghxyc = ""
                if odjhjsei.has("modifications") and odjhjsei.modifications.size() > 0:
                    gzbghxyc = " with %s props" % odjhjsei.modifications.size()
                ubbwtrcz = ("Created node {name}, type {type}, parent {parent} in scene {scene}{props}" if jsavhdjo
                                else "Failed: creating node {name}, type {type}, parent {parent} in scene {scene}{props}"
                                ).format({
                                    "name": odjhjsei.name,
                                    "type": odjhjsei.node_type,
                                    "scene": wdzzoqea,
                                    "parent": hvmmcpry,
                                    "props": gzbghxyc
                                })
            "edit_node":
                ubbwtrcz = ("Edited node \"%s\" in scene %s" if jsavhdjo
                                else "Failed: editing node \"%s\", scene: %s"
                                ) % [odjhjsei.node_name, odjhjsei.scene_path.get_file()]

            "add_subresource":
                var wdzzoqea = odjhjsei.scene_path.get_file()
                var ewowyezo = str(odjhjsei.properties.size())
                ubbwtrcz = ("Added subresource %s to node %s in scene %s (%s properties)" if jsavhdjo
                                else "Failed: adding subresource %s to node %s, scene: %s (%s properties)"
                                ) % [odjhjsei.subresource_type, odjhjsei.node_name, wdzzoqea, ewowyezo]
                                
            "edit_subresource":
                 var wdzzoqea = odjhjsei.scene_path.get_file()
                 var ewowyezo = str(odjhjsei.properties.size())
                 ubbwtrcz = ("Edited subresource property '%s' on node '%s' in scene %s (%s properties changed)" if jsavhdjo
                                 else "Failed: editing subresource property '%s' on node '%s', scene: %s (%s properties attempted)"
                                 ) % [odjhjsei.subresource_property_name, odjhjsei.node_name, wdzzoqea, ewowyezo]

            "assign_script":
                ubbwtrcz = ("Assigned script to node \"%s\" in scene %s" if jsavhdjo
                                else "Failed: assigning script to node \"%s\", scene: %s"
                                ) % [odjhjsei.node_name, odjhjsei.scene_path.get_file()]

            "add_existing_scene":
                var lcibfdct = odjhjsei.target_scene_path.get_file()
                var wdzzoqea = odjhjsei.existing_scene_path.get_file()
                var ewowyezo = str(odjhjsei.modifications.size())
                ubbwtrcz = ("Added %s to %s" if jsavhdjo
                              else "Failed: adding %s to %s"
                              ) % [wdzzoqea, lcibfdct]
                if odjhjsei.modifications.size() > 0:
                    ubbwtrcz += " (%s props)" % ewowyezo
            "edit_script":
                ubbwtrcz = ("Edited script %s" if jsavhdjo else "Failed: editing script %s") % [odjhjsei.path]

                                                         
        xgzlsxhj.text = xdxlcwkk + neficeeu

                                                             
        xgzlsxhj.tooltip_text = klysazht + mjfwwmzx

                                               
                                                             
        print('[GameDev Assistant] ' + xdxlcwkk + ubbwtrcz) 

        if not jsavhdjo:
            xgzlsxhj.self_modulate = Color(1, 0, 0)                               
            
                                  
        xgzlsxhj.set_meta("completed", true)
        
                               
        if ypodnoyw == "edit_script":
            tzqlvcsc(ypodnoyw, false)
            
                                          
        if jsavhdjo:
            xgzlsxhj.disabled = true
        
                              
func kbmpepvz(iqmvadil: String, skztgexs: String) -> Dictionary:
    var dgctmqiq = [djllhbiu, wvppamcn, yswnczwy, xxjifzeh, gxeocfgr, jwkmujtl, nlraiztn, buzppzyr, ravcqrsf]
    for parser in dgctmqiq:
        var trxhbupa = parser.parse_line(iqmvadil, skztgexs)
        if not trxhbupa.is_empty():
            return trxhbupa
    return {}
    
func dabxznag(wgvshpob: Array) -> void:
    fdxmvxix = true
    soqhydap.disabled = true
    var evewdbsd = 0
    
                                       
    for button in yynmqtew:
        button.disabled = true
    
    bxthektb(evewdbsd, wgvshpob)                    

func bxthektb(mwtopbqe: int, ludsscdd: Array):
    if mwtopbqe >= ludsscdd.size():
        return                        

    var rdncteci = ludsscdd[mwtopbqe]
    if not is_instance_valid(rdncteci):
        mwtopbqe += 1
        bxthektb(mwtopbqe, ludsscdd)                       
        return

                                                                          
    var xxbmzaue = func(_action_type, _success, _error_message, _node_name, _subresource_name, received_button):
        if received_button == rdncteci:
            mwtopbqe += 1                       
            mxnpkslu.start()
            await mxnpkslu.timeout
            bxthektb(mwtopbqe, ludsscdd)

                                      
    xwkrpxjn.connect(xxbmzaue, CONNECT_ONE_SHOT)
    await get_tree().process_frame                                           
    
                            
    iguwrlty(rdncteci)
    
func tzqlvcsc(grkkxeev: String, ffamiawn: bool) -> void:

    if fdxmvxix:
        return
    
    for button in yynmqtew:
        var kuvoiwcl = button.get_meta("action") if button.has_meta("action") else {}
        if kuvoiwcl.get("type", "") == grkkxeev:
                                                
            if not button.get_meta("completed", false):
                button.disabled = ffamiawn
