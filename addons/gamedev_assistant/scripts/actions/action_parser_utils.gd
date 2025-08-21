                                                                  
@tool
extends Node

static func rdrajrpf(xxpmzuve: String) -> String:
    var axxesqov = xxpmzuve.find('"')
    if axxesqov == -1:
        return ""
    var hlzxafzw = xxpmzuve.find('"', axxesqov + 1)
    if hlzxafzw == -1:
        return ""
    return xxpmzuve.substr(axxesqov + 1, hlzxafzw - (axxesqov + 1))


static func fcjqztit(qnwfdtkf: String, ofcizlec: String) -> String:
    var ydwrtmro = RegEx.new()
    ydwrtmro.compile("```.*\\n# New file: " + qnwfdtkf + "\\n([\\s\\S]*?)```")
    var nknxkvho = ydwrtmro.search(ofcizlec)
    return nknxkvho.get_string(1).strip_edges() if nknxkvho else ""


static func oshoyugi(ebwvaaho: String) -> Array:
    var habwlmqb = ebwvaaho.replace("create_scene(", "").replace(")", "").strip_edges()
    var mjaxdefj = []
    var irbvumeu = 0
    while true:
        var ydulizjv = habwlmqb.find('"',irbvumeu)
        if ydulizjv == -1:
            break
        var iwlllezv = habwlmqb.find('"', ydulizjv + 1)
        if iwlllezv == -1:
            break
        mjaxdefj.append(habwlmqb.substr(ydulizjv + 1, iwlllezv - ydulizjv - 1))
        irbvumeu = iwlllezv + 1
    return mjaxdefj


                                                     
static func eqynktzq(bwmmsmrg: String) -> Array:
    var hbrqhewn = bwmmsmrg.replace("create_node(", "")
    
                                                                                                    
    var afpytfri = hbrqhewn.rfind(")")
    if afpytfri != -1:
        hbrqhewn = hbrqhewn.substr(0, afpytfri)
    
    hbrqhewn = hbrqhewn.strip_edges()
    
                                                   
    var rrnbtabp = hbrqhewn.find("{")
    if rrnbtabp != -1:
        hbrqhewn = hbrqhewn.substr(0, rrnbtabp).strip_edges()
    
    var bdktehqx = []
    var myznqgdk = 0
    while true:
        var mydbxcau = hbrqhewn.find('"',myznqgdk)
        if mydbxcau == -1:
            break
        var frmhfhva = hbrqhewn.find('"', mydbxcau + 1)
        if frmhfhva == -1:
            break
        bdktehqx.append(hbrqhewn.substr(mydbxcau + 1, frmhfhva - mydbxcau - 1))
        myznqgdk = frmhfhva + 1
    return bdktehqx


                                                                             
                   
                                                                             
static func ifabcoem(bmlwxvba: String) -> Dictionary:
                                 
    var tcyscpyz = bmlwxvba.replace("edit_node(", "")

                                    
    if tcyscpyz.ends_with(")"):
        tcyscpyz = tcyscpyz.substr(0, tcyscpyz.length() - 1)

                     
    tcyscpyz = tcyscpyz.strip_edges()

                                                                  
    var pjgoxlpq = []
    var gupfbtca = 0
    while true:
        var xuicyxrz = tcyscpyz.find('"',gupfbtca)
        if xuicyxrz == -1:
            break
        var tgylbkdz = tcyscpyz.find('"', xuicyxrz + 1)
        if tgylbkdz == -1:
            break

        pjgoxlpq.append(tcyscpyz.substr(xuicyxrz + 1, tgylbkdz - xuicyxrz - 1))
        gupfbtca = tgylbkdz + 1

                              
    var gjizrbng = tcyscpyz.find("{")
    var irbdutny = tcyscpyz.rfind("}")
    if gjizrbng == -1 or irbdutny == -1:
                                           
        return {}

    var fckpqgiw = tcyscpyz.substr(gjizrbng, irbdutny - gjizrbng + 1)

                                             
    var azpnrdye = ""
    if pjgoxlpq.size() > 0:
        azpnrdye = pjgoxlpq[0]

    var jpnijdxy = ""
    if pjgoxlpq.size() > 1:
        jpnijdxy = pjgoxlpq[1]

    return {
        "node_name": azpnrdye,
        "scene_path": jpnijdxy,
        "modifications": rwlaxvut(fckpqgiw)
    }


static func rwlaxvut(fyhnlgmm: String) -> Dictionary:
                                                          
    var feexgret = fyhnlgmm.strip_edges()

                                    
    if feexgret.begins_with("{"):
        feexgret = feexgret.substr(1, feexgret.length() - 1)
                                     
    if feexgret.ends_with("}"):
        feexgret = feexgret.substr(0, feexgret.length() - 1)

                                      
    feexgret = feexgret.strip_edges()

                                                              
    var nwgzmpsl = []
    var jixkejpg = ""
    var eiwwxviu = 0

    for i in range(feexgret.length()):
        var ecylaodd = feexgret[i]
        if ecylaodd == "(":
            eiwwxviu += 1
        elif ecylaodd == ")":
            eiwwxviu -= 1

        if ecylaodd == "," and eiwwxviu == 0:
            nwgzmpsl.append(jixkejpg.strip_edges())
            jixkejpg = ""
        else:
            jixkejpg += ecylaodd

    if jixkejpg != "":
        nwgzmpsl.append(jixkejpg.strip_edges())

                                 
    var augtmrsc = {}
    for entry in nwgzmpsl:
        var hrsictau = entry.find(":")
        if hrsictau == -1:
            continue

        var gcolbvtl = entry.substr(0, hrsictau).strip_edges()
        var shgwtbli = entry.substr(hrsictau + 1).strip_edges()

                                                                        
        if gcolbvtl.begins_with("\"") and gcolbvtl.ends_with("\"") and gcolbvtl.length() >= 2:
            gcolbvtl = gcolbvtl.substr(1, gcolbvtl.length() - 2)

        augtmrsc[gcolbvtl] = shgwtbli

    return augtmrsc

static func uwedigfe(rec_line: String) -> Dictionary:
    var edahttti = rec_line.replace("edit_script(", "")
    var emvwsfdz = edahttti.length()
    if edahttti.ends_with(")"):
        edahttti = edahttti.substr(0, emvwsfdz - 1)
    
    emvwsfdz = edahttti.length()
    
    var nzfacgqh = []
    var mbyulicd = 0
    var fzuajeke = false
    var opfzynmp = ""
    
    for i in range(emvwsfdz):
        var muqvscou = edahttti[i]
        var futfxtsu = edahttti[i-1]
        if muqvscou == '"' and (i == 0 or futfxtsu != '\\'):
            fzuajeke = !fzuajeke
            continue
            
        if !fzuajeke and muqvscou == ',':
            nzfacgqh.append(opfzynmp.strip_edges())
            opfzynmp = ""
            continue
            
        opfzynmp += muqvscou
    
    if opfzynmp != "":
        nzfacgqh.append(opfzynmp.strip_edges())
    
    if nzfacgqh.size() < 2:
        return {}
    
    return {
        "path": nzfacgqh[0].strip_edges().trim_prefix('"').trim_suffix('"'),
        "message_id": nzfacgqh[1].to_int()
    }
