                                                               
@tool
extends RefCounted

const uutyxmwo = "@OpenScripts"
const lxcwqzij = "@SceneTree"
const syvpfrha = "@OpenScenes"
const pgpfcgsw = "@FileTree"
const qnivnvfv = "@Output"
const vkcjogfl = "@GitDiff"
const oebcjrkh = "@Docs"
const lwxlqdah = "ProjectSettings"
const xbjxmlks = 10000
const khgsgbdh = 5000
const inwwyepe = 75000

var iindorrx = {}                                  
var gywrxtiq = []                                     

                              
func mpqtylnh() -> void:
    iindorrx.clear()
    gywrxtiq.clear()

func htxjmdva(qorqrnfc: String, zbdznivr: EditorInterface) -> String:
                                                         
    if not ioogtiqi(qorqrnfc):
        return qorqrnfc
        
                            
    var qmiwllkl = qorqrnfc
    
    if uutyxmwo in qorqrnfc:
                                      
        qmiwllkl = wqlpfhce(qmiwllkl, zbdznivr)
        
    if lxcwqzij in qorqrnfc:
                                     
        qmiwllkl = lqjwtxmv(qmiwllkl, zbdznivr)

    if syvpfrha in qorqrnfc:
        qmiwllkl = ncropbjf(qmiwllkl, zbdznivr)

    if pgpfcgsw in qorqrnfc:
                                     
        qmiwllkl = kmgbawzc(qmiwllkl, zbdznivr)

    if qnivnvfv in qorqrnfc:
                                        
        qmiwllkl = kcpmqwxu(qmiwllkl, zbdznivr)
    
    if vkcjogfl in qorqrnfc:                                                             
        qmiwllkl = ajpjxkdl(qmiwllkl, zbdznivr)      
    
    if lwxlqdah in qmiwllkl:
        qmiwllkl = spyhyaaz(qmiwllkl)
    
    return qmiwllkl

func ioogtiqi(ydpcpksk: String) -> bool:
                                  
    return uutyxmwo in ydpcpksk or lxcwqzij in ydpcpksk or pgpfcgsw in ydpcpksk or qnivnvfv in ydpcpksk or lwxlqdah in ydpcpksk or syvpfrha in ydpcpksk

func wqlpfhce(brqspkel: String, dciutsvt: EditorInterface) -> String:
    var uqdwemah = brqspkel.replace(uutyxmwo, uutyxmwo.substr(1)).strip_edges()
    
    var hcmruvkk = ybmcfqmf(dciutsvt)
    gywrxtiq.clear()
    
                         
    var nlrwcbdn = "\n[gds_context]\nScripts for context:\n"
    
    for file_path in hcmruvkk:
        var vcyeoezk = hcmruvkk[file_path]

        if iindorrx.has(file_path):
            if iindorrx[file_path] == vcyeoezk:
                gywrxtiq.append(file_path)
                continue                        
                
                                
        iindorrx[file_path] = vcyeoezk
        
        nlrwcbdn += "File: %s\nContent:\n```%s\n```\n" % [file_path, vcyeoezk]
    
                               
    if gywrxtiq.size() > 0:
        nlrwcbdn += "The following scripts remain the same: %s\n" % [gywrxtiq]
    
                                
    if nlrwcbdn.length() > inwwyepe:
        nlrwcbdn = nlrwcbdn.substr(0, inwwyepe) + "..."
    
    return uqdwemah + nlrwcbdn + "\n[/gds_context]"

func ybmcfqmf(hcxjhqkb: EditorInterface) -> Dictionary:
    var ykviwsrb = hcxjhqkb.get_script_editor()
    var dytavlgg: Array = ykviwsrb.get_open_scripts()
    
    var bpzyipnz: Dictionary = {}
    
    for script in dytavlgg:
        var jbyxgzah: String = script.get_source_code()
        var bhwomzkr: String = script.get_path()
                                            
        bpzyipnz[bhwomzkr] = jbyxgzah
        
    return bpzyipnz

func lqjwtxmv(trrooqmz: String, vagurfcn: EditorInterface) -> String:
                                                                                                                          
    var sxfwdako = trrooqmz.replace(lxcwqzij, lxcwqzij.substr(1)).strip_edges()
    
                               
    var ibhwsbei = vagurfcn.get_edited_scene_root()
    if not ibhwsbei:
        return sxfwdako + "\n[gds_context]Node tree: No scene is currently being edited.[/gds_context]"
    
                                
    var rhrrgwgz = "\n[gds_context]Node tree:\n"
    rhrrgwgz += nwpqouel(ibhwsbei)
    rhrrgwgz += "--\n"

    if rhrrgwgz.length() > xbjxmlks:                                                            
        rhrrgwgz = rhrrgwgz.substr(0, xbjxmlks) + "..."
        
    rhrrgwgz += "\n[/gds_context]"
        
    return sxfwdako + rhrrgwgz

func nwpqouel(fhmlddpu: Node, yhcyapeq: String = "") -> String:
    var sagxvars = yhcyapeq + "- " + fhmlddpu.name
    sagxvars += " (" + fhmlddpu.get_class() + ")"
    
                                                 
    if fhmlddpu is Node2D:
        sagxvars += " position " + str(fhmlddpu.position)
    elif fhmlddpu is Control:                      
        sagxvars += " position " + str(fhmlddpu.position)
    elif fhmlddpu is Node3D:
        sagxvars += " position " + str(fhmlddpu.position)

                                                                              
    if fhmlddpu.owner and fhmlddpu.owner != fhmlddpu:
        sagxvars += " [owner: " + fhmlddpu.owner.name + "]"
    
    sagxvars += "\n"
    var bsuvtwxm = yhcyapeq + "  "
    
                                                  
    if fhmlddpu is CollisionObject2D or fhmlddpu is CollisionObject3D:
        var fokcsbei = []
        var ondnpiki = []
        
                            
        for i in range(1, 33):                                
            if fhmlddpu.get_collision_layer_value(i):
                fokcsbei.append(str(i))
            if fhmlddpu.get_collision_mask_value(i):
                ondnpiki.append(str(i))
        
        if fokcsbei.size() > 0 or ondnpiki.size() > 0:
            sagxvars += bsuvtwxm + "Collision: layer: " + ",".join(fokcsbei)
            sagxvars += " mask: " + ",".join(ondnpiki) + "\n"
    
                                                                          
                                                                 
    if fhmlddpu.is_inside_tree():
                                
        var hwsidpqg = []
        for prop in fhmlddpu.get_property_list():
            var yeiufnnn = prop["name"]
            var tbxxilyg = fhmlddpu.get(yeiufnnn)
            if tbxxilyg is Resource and tbxxilyg != null:
                var crauxlsy = tbxxilyg.get_class()
                if tbxxilyg.resource_name != "":
                    crauxlsy = tbxxilyg.resource_name
                hwsidpqg.append("%s (%s)" % [yeiufnnn, crauxlsy])
            
        if not hwsidpqg.is_empty():
            sagxvars += bsuvtwxm + "Assigned subresources: " + ", ".join(hwsidpqg) + "\n"
        
                                       
    if fhmlddpu.get_script():
        sagxvars += bsuvtwxm + "Script: " + fhmlddpu.get_script().resource_path + "\n"
    
                            
    if fhmlddpu.unique_name_in_owner:
        sagxvars += bsuvtwxm + "Unique name: %" + fhmlddpu.name + "\n"
    
                
    var kdchoagh = fhmlddpu.get_groups()
    if not kdchoagh.is_empty():
                                                              
        kdchoagh = kdchoagh.filter(func(group): return not group.begins_with("_"))
        if not kdchoagh.is_empty():
            sagxvars += bsuvtwxm + "Groups: " + ", ".join(kdchoagh) + "\n"
    
                                           
    if fhmlddpu.scene_file_path:
        sagxvars += bsuvtwxm + "Instanced from: " + fhmlddpu.scene_file_path + "\n"
    
                      
    for child in fhmlddpu.get_children():
        sagxvars += nwpqouel(child, bsuvtwxm)
    return sagxvars

func ncropbjf(ktwewnef: String, gztqjatt: EditorInterface) -> String:
    var opdtdzod = ktwewnef.replace(syvpfrha, syvpfrha.substr(1)).strip_edges()

    var ccycxdct: Array = Array(gztqjatt.get_open_scenes())
    if ccycxdct.is_empty():
        return opdtdzod + "\n[gds_context]Node tree:\n No scenes are currently open.[/gds_context]"

    var uxeoxdot = "\n[gds_context]Node tree:\n"
    
    for scene_path in ccycxdct:
        var daerezgs: PackedScene = load(scene_path)
        if not daerezgs:
            uxeoxdot += "Could not load scene: %s\n" % scene_path
            continue

        var mtaswlkk: Node = daerezgs.instantiate()
        if not mtaswlkk:
            continue

        var sczqxcbo = nwpqouel(mtaswlkk)

        uxeoxdot += "Scene: %s\n" % scene_path
        uxeoxdot += sczqxcbo
        uxeoxdot += "--\n"
        
                                
        mtaswlkk.free()

    if uxeoxdot.length() > xbjxmlks:
        uxeoxdot = uxeoxdot.substr(0, xbjxmlks) + "..."

    uxeoxdot += "\n[/gds_context]"

    return opdtdzod + uxeoxdot

func kmgbawzc(hjrfnkuu: String, pbnrgejd: EditorInterface) -> String:
                                                                                                                          
    var cwedsacu = hjrfnkuu.replace(pgpfcgsw, pgpfcgsw.substr(1)).strip_edges()

    var xwfsdnsy = pbnrgejd.get_resource_filesystem()
    var tnqtsdum = "res://"
    
                                
    var ffhyzaga = "\n[gds_context]\nFile Tree:\n"
    ffhyzaga += msoioygz(xwfsdnsy.get_filesystem_path(tnqtsdum))
    ffhyzaga += "--\n"
    
    if ffhyzaga.length() > xbjxmlks:                                                            
        ffhyzaga = ffhyzaga.substr(0, xbjxmlks) + "..."
            
    ffhyzaga += "\n[/gds_context]"
    
    return cwedsacu + ffhyzaga

func msoioygz(fsmqtgqr: EditorFileSystemDirectory, pexsdzan: String = "") -> String:
    var whcdhnsm = ""
    
                                                          
    var mtbasvou = fsmqtgqr.get_path()
    if mtbasvou == "res://addons/gamedev_assistant/":
                                
        var hzhhlnbb = EditorInterface.get_editor_settings()
        var xpnoeubr = hzhhlnbb.has_setting("gamedev_assistant/development_mode") and hzhhlnbb.get_setting("gamedev_assistant/development_mode") == true
        if not xpnoeubr:
            return pexsdzan + "+ gamedev_assistant/\n"                                            
    
                                                   
    if fsmqtgqr.get_path() != "res://":
        whcdhnsm += pexsdzan + "+ " + fsmqtgqr.get_name() + "/\n"
        pexsdzan += "  "
    
                                      
    for i in fsmqtgqr.get_subdir_count():
        var mlgkgjip = fsmqtgqr.get_subdir(i)
        whcdhnsm += msoioygz(mlgkgjip, pexsdzan)
    
    for i in fsmqtgqr.get_file_count():
        var xfscdhwh = fsmqtgqr.get_file(i)
        whcdhnsm += pexsdzan + "- " + xfscdhwh + "\n"
    
    return whcdhnsm

func kcpmqwxu(nahjxcvd: String, gdxbclei: EditorInterface) -> String:
                                                                                                                          
    var rxrvrtlk = nahjxcvd.replace(qnivnvfv, qnivnvfv.substr(1)).strip_edges()

                                                                                                       
    var qinlllbd: Node = gdxbclei.get_base_control()
    var dezttlnc: RichTextLabel = rksdlyow(qinlllbd)

    if dezttlnc:
        var oddunmre = dezttlnc.get_parsed_text()
        
        if oddunmre.length() > khgsgbdh:                     
                                                                                            
            oddunmre = oddunmre.substr(-khgsgbdh) + "..."
        
        if oddunmre.length() > 0:
            return rxrvrtlk + "\n[gds_context]\nOutput Panel:\n" + oddunmre + "\n[/gds_context]"
        else:
            return rxrvrtlk + "\n[gds_context]No contents in the Output Panel.[/gds_context]"
    else:
        print("No RichTextLabel under @EditorLog was found.")
        return rxrvrtlk + "\n--\nOutput Panel: Could not find the label.\n--\n"

func rksdlyow(fxjizegs: Node) -> RichTextLabel:
                                              
    if fxjizegs is RichTextLabel:
        var rsbkmivt: Node = fxjizegs.get_parent()
        if rsbkmivt:
            var dcfjqntn: Node = rsbkmivt.get_parent()
                                                           
            if dcfjqntn and dcfjqntn.name.begins_with("@EditorLog"):
                return fxjizegs

                              
    for child in fxjizegs.get_children():
        var eofvzabd: RichTextLabel = rksdlyow(child)
        if eofvzabd:
            return eofvzabd

    return null

func ajpjxkdl(mdwqmplj: String, ovsqilat: EditorInterface) -> String:         
                                                                                                                          
    var hqnvsmvz = mdwqmplj.replace(vkcjogfl, vkcjogfl.substr(1)).strip_edges()
                                                                                                    
                                                                                                  
    var kjyvepvs = []                                                                              
    var mzdaumql = OS.execute("git", ["diff"], kjyvepvs, true)                                    
                                                                                                    
    if mzdaumql == 0:                                                                            
        var kaemkskl = "\n[gds_context]\nGit Diff:\n" + "\n".join(kjyvepvs) + "\n"  
        
        if kaemkskl.length() > xbjxmlks:                                                            
            kaemkskl = kaemkskl.substr(0, xbjxmlks) + "..."
        
        kaemkskl += "[/gds_context]"
        
        return hqnvsmvz + kaemkskl                                                
    else:                                                                                         
        return hqnvsmvz + "\n--\nGit Diff: Failed to execute git diff command.\n--\n"

func aamovrpe(cpxexapi: String, kzgmbmzi: EditorInterface) -> String:
                                                                                                                          
    var mmotvhbs = cpxexapi.replace(oebcjrkh, oebcjrkh.substr(1)).strip_edges()
    return mmotvhbs

func spyhyaaz(hsmwbavs: String) -> String:
    var kaijbalm = hsmwbavs.replace(lwxlqdah, lwxlqdah.substr(1)).strip_edges()
    
    var tpbfgosq = []
    var dbtxxumc = ProjectSettings.get_property_list()
    
    for prop in dbtxxumc:
        var upyshwus: String = prop["name"]
        var pvmhfpkp = ProjectSettings.get(upyshwus)
        
                                             
        if upyshwus.begins_with("input/"):
            if pvmhfpkp is Dictionary or pvmhfpkp is Array:
                tpbfgosq.append("%s = %s" % [upyshwus, str(pvmhfpkp)])
            elif pvmhfpkp == null or (pvmhfpkp is String and pvmhfpkp.is_empty()):
                continue
            else:
                tpbfgosq.append("%s = %s" % [upyshwus, pvmhfpkp])
            continue
        
                                         
        if pvmhfpkp is Dictionary or pvmhfpkp is Array:
            continue
            
                                                      
        if pvmhfpkp == null or (pvmhfpkp is String and pvmhfpkp.is_empty()):
            continue
            
        tpbfgosq.append("%s = %s" % [upyshwus, pvmhfpkp])
    
    tpbfgosq.sort()
    var ymebothl = "Unassigned project settings have been omitted from this list:\n" + "\n".join(tpbfgosq)
    
    kaijbalm = kaijbalm + "\n" + ymebothl
    return kaijbalm
