                                                       
@tool
extends Node

                                                 
                                      
                                   

signal xxmxbdja (validated : bool, error : String)

signal osvrusdz(update_available: bool, latest_version: String)
signal kunzjjab(error: String)

signal gpqtpwqi (message : String, conv_id : int)
signal mqvjtyaf (error : String)
signal wwccjuee (message : String)

signal oyviquob (data)
signal btonsrse (error : String)

signal ozgsvjdc (data)
signal geotvtey (error : String)

signal ffkrruao ()
signal mgjlxpyv (error : String)

signal unuyptbd ()
signal xyjrjgsd (error : String)

signal aidsprtc

const lszaszyg = 30
const xmcbhlvd = 60

var wqfinuvv : bool 

              
signal crjdaiac(content: String, conv_id: int, message_id: int)
signal jbpkaprt(conv_id: int, message_id: int)
signal cknxrash(conv_id: int, message_id: int)
signal iwrsyugj(error: String)
var dlssezvs : HTTPClient
var xsptawzc = false
var mbfmndic = ""

var tvlxezwb : String
var hwmpxguk : String
var qjtrjnnq : String
var giklvheq : String
var jvonmxoa : String
var pzkyzzlm : String
var nfiottdr : String
var hmahyggz : String

var vmwmbgsi : String:
    get:
        var nvfnjmnj = EditorInterface.get_editor_settings()
        var asnlhqxu = "null"
        wqfinuvv = nvfnjmnj.has_setting("gamedev_assistant/development_mode") and nvfnjmnj.get_setting('gamedev_assistant/development_mode') == true
        
        if not wqfinuvv and nvfnjmnj.has_setting("gamedev_assistant/token"):
            return nvfnjmnj.get_setting("gamedev_assistant/token")
        elif wqfinuvv and nvfnjmnj.has_setting("gamedev_assistant/token_dev"):        
            return nvfnjmnj.get_setting("gamedev_assistant/token_dev")
                    
        return asnlhqxu

var cftgdpck = ["Content-type: application/json", "Authorization: Bearer " + vmwmbgsi]

@onready var heolnoiq = $"../ConversationManager"

@onready var ikseaqdu : HTTPRequest = $ValidateToken
@onready var cyomfndo : HTTPRequest = $SendMessage
@onready var cqcttnen : HTTPRequest = $GetConversationsList
@onready var ebimulhm : HTTPRequest = $GetConversation
@onready var qrifrrkh : HTTPRequest = $DeleteConversation
@onready var bcwfrpbw : HTTPRequest = $ToggleFavorite
@onready var xizwtjej : HTTPRequest = $CheckUpdates
@onready var sjucgvng : HTTPRequest = $TrackAction
@onready var lxygwmla : HTTPRequest = $RatingAction
@onready var ubrlopwk : HTTPRequest = $EditScript

var zltywlfn = []

var jqneegtq : Button = null

func _ready ():
                                      
    dlssezvs = HTTPClient.new()
    
    ikseaqdu.timeout = lszaszyg                                         
    cyomfndo.timeout = lszaszyg                                           
    cqcttnen.timeout = lszaszyg                                 
    ebimulhm.timeout = lszaszyg                                       
    qrifrrkh.timeout = lszaszyg                                    
    bcwfrpbw.timeout = lszaszyg
    xizwtjej.timeout = lszaszyg
    ubrlopwk.timeout = xmcbhlvd
    
    ikseaqdu.request_completed.connect(pfonoiew)
    cyomfndo.request_completed.connect(muorshow)
    cqcttnen.request_completed.connect(rclwsord)
    ebimulhm.request_completed.connect(ukfvnhvo)
    qrifrrkh.request_completed.connect(ydolpnge)
    bcwfrpbw.request_completed.connect(laizhrsl)
    xizwtjej.request_completed.connect(qthogpmb)
    ubrlopwk.request_completed.connect(ckodwnzc)
    
    aidsprtc.connect(ayzhmnqi)  
    
    hecrklrb ()
    

func hecrklrb ():
    var dohejmtb = EditorInterface.get_editor_settings()            
    if dohejmtb.has_setting("gamedev_assistant/endpoint"):          
        tvlxezwb = dohejmtb.get_setting("gamedev_assistant/endpoint")    
        hwmpxguk = tvlxezwb + "/token/validate"                
        qjtrjnnq = tvlxezwb + "/chat/message"                         
        giklvheq = tvlxezwb + "/chat/conversations"        
        jvonmxoa = tvlxezwb + "/chat/conversation/"
        pzkyzzlm = tvlxezwb + "/chat/checkForUpdates"
        nfiottdr = tvlxezwb + "/chat/track-action"
        hmahyggz = tvlxezwb + "/chat/track-rating"

func uovnwkeu ():
    return ["Content-type: application/json", "Authorization: Bearer " + vmwmbgsi]

func fdkcwddt ():
    var ewxkiwgl = ikseaqdu.request(hwmpxguk, uovnwkeu(), HTTPClient.METHOD_GET)

func vkevbvyi(profwapx: String, cdjzepar: bool, veqijlko: String) -> void:
    
    cyomfndo.timeout = lszaszyg
    
                           
    xsptawzc = false
    mbfmndic = ""
    
                                
    var hygfxoqn = tvlxezwb.begins_with("https://")
    var sovnqukg = tvlxezwb.replace("http://", "").replace("https://", "")
    
                                       
    var gfxpwcup = -1
    if sovnqukg.begins_with("localhost:"):
        var jnewoshp = sovnqukg.split(":")
        sovnqukg = jnewoshp[0]
        gfxpwcup = int(jnewoshp[1])
        
    var mrkteqln: Error
    if hygfxoqn:
        mrkteqln = dlssezvs.connect_to_host(sovnqukg, gfxpwcup, TLSOptions.client())
    else:
        mrkteqln = dlssezvs.connect_to_host(sovnqukg, gfxpwcup)
        
    if mrkteqln != OK:
        iwrsyugj.emit("Failed to connect: " + str(mrkteqln))
        return

    xsptawzc = true
    
                             
    var xklesmtp = EditorInterface.get_editor_settings()
    var yxxaykwb = xklesmtp.get_setting("gamedev_assistant/version_identifier")
    
    var rcyvgfyu = Engine.get_version_info()
    var gtuzhfka = "%d.%d" % [rcyvgfyu.major, rcyvgfyu.minor]
    
                                           
    var xwkqijha = ""
    if xklesmtp.has_setting("gamedev_assistant/custom_instructions"):
        xwkqijha = xklesmtp.get_setting("gamedev_assistant/custom_instructions")
    
    
                              
    var zpevdoiz = { 
        "content": profwapx, 
        "useThinking": cdjzepar,
        "releaseUniqueIdentifier": yxxaykwb,
        "godotVersion": gtuzhfka,
        "mode": veqijlko,
        "customInstructions": xwkqijha
    }
    
    var defudego = heolnoiq.ixcssopl()
    
    if defudego and defudego.id > 0:
        zpevdoiz["conversationId"] = defudego.id
        
                                                            
    
                                                
    vrgbswuz(zpevdoiz)
    
    wwccjuee.emit(profwapx)

func clakmnxa ():
    var xselgjxt = cqcttnen.request(giklvheq, uovnwkeu(), HTTPClient.METHOD_GET)

func get_conversation (wmwyrcit : int):
    var mgfyilsy = jvonmxoa + str(wmwyrcit)
    var yncgnzfb = ebimulhm.request(mgfyilsy, uovnwkeu(), HTTPClient.METHOD_GET)

func jdvbjogk (jttmnsao : int):
    var xwgfpttz = jvonmxoa + str(jttmnsao)
    var vwofzemp = qrifrrkh.request(xwgfpttz, uovnwkeu(), HTTPClient.METHOD_DELETE)

func lzqlwyzq (qnazwuha : int):
    var ecradzhx = jvonmxoa + str(qnazwuha) + "/toggle-favorite"
    var lwfympdn = bcwfrpbw.request(ecradzhx, uovnwkeu(), HTTPClient.METHOD_POST)

func pfonoiew(idhwxxvu: int, migvrnus: int, rbqbmgxm: PackedStringArray, jiciynhg: PackedByteArray):
                                
    if idhwxxvu != HTTPRequest.RESULT_SUCCESS:
        xxmxbdja.emit(false, "Network error (Code: " + str(idhwxxvu) + ")")
        return
        
    var pktpthwk = lgouqsmt(jiciynhg)
    if not pktpthwk is Dictionary:
        xxmxbdja.emit(false, "Response error (Code: " + str(migvrnus) + ")")
        return
        
    var ukeoiits = pktpthwk.get("success", false)
    var ilwixngr = pktpthwk.get("error", "Response code: " + str(migvrnus))
    
    xxmxbdja.emit(ukeoiits, ilwixngr)

                                                     
func muorshow(kfuuiygp, fnrxxlur, qbburgza, bveuajqi):
    
    if kfuuiygp != HTTPRequest.RESULT_SUCCESS:
        mqvjtyaf.emit("Network error (Code: " + str(kfuuiygp) + ")")
        return
        
    var hwtkjqtu = lgouqsmt(bveuajqi)
    if not hwtkjqtu is Dictionary:
        mqvjtyaf.emit("Response error (Code: " + str(fnrxxlur) + ")")
        return
    
    if fnrxxlur == 201:
        var bvxlaryk = hwtkjqtu.get("content", "")
        var nncgywzx = int(hwtkjqtu.get("conversationId", -1))
        gpqtpwqi.emit(bvxlaryk, nncgywzx)
    else:
        mqvjtyaf.emit(hwtkjqtu.get("error", "Response code: " + str(fnrxxlur)))

                                                                    
func rclwsord(qkdpbzok, pxaohpur, wpavniey, isdhggmf):
    if qkdpbzok != HTTPRequest.RESULT_SUCCESS:
        btonsrse.emit("Network error (Code: " + str(qkdpbzok) + ")")
        return
        
    var nqjxdygw = lgouqsmt(isdhggmf)
    
    if pxaohpur == 200:
        oyviquob.emit(nqjxdygw)
    else:
        if nqjxdygw is Dictionary:
            btonsrse.emit(nqjxdygw.get("error", "Response code: " + str(pxaohpur)))
        else:
            btonsrse.emit("Response error (Code: " + str(pxaohpur) + ")")

                                                                
func ukfvnhvo(korqdedj, gltbspwq, okwfrevk, srmodsvv):
    if korqdedj != HTTPRequest.RESULT_SUCCESS:
                                                              
        printerr("[GameDev Assistant] Get conversation network error (Code: " + str(korqdedj) + ")")
        return
        
    var habwxrgx = lgouqsmt(srmodsvv)
    if not habwxrgx is Dictionary:
        printerr("[GameDev Assistant] Get conversation response error (Code: " + str(gltbspwq) + ")")
        return
        
    ozgsvjdc.emit(habwxrgx)

                                                                                         
func ydolpnge(hylmvnum, cxsuetgq, xapqvlfm, ghofabuh):
    if hylmvnum != HTTPRequest.RESULT_SUCCESS:
                                                                          
        printerr("[GameDev Assistant] Delete conversation network error (Code: " + str(hylmvnum) + ")")
        return
        
    if cxsuetgq == 204:
        ffkrruao.emit()
    else:
        var wqgchuaq = lgouqsmt(ghofabuh)
        var muifhuet = "[GameDev Assistant] Response code: " + str(cxsuetgq)
        if wqgchuaq is Dictionary:
            muifhuet = wqgchuaq.get("error", muifhuet)
        mgjlxpyv.emit(muifhuet)

                                                                                                       
func laizhrsl(flffpwvl, spknmaof, kzgpjmwy, rdwdpknv):
    if flffpwvl != HTTPRequest.RESULT_SUCCESS:
                                                                      
        printerr("[GameDev Assistant] Toggle favorite network error (Code: " + str(flffpwvl) + ")")
        return
        
    if spknmaof == 200:
        unuyptbd.emit()
    else:
        var msvotamj = lgouqsmt(rdwdpknv)
        var fznnfpky = "[GameDev Assistant] Response code: " + str(spknmaof)
        if msvotamj is Dictionary:
            fznnfpky = msvotamj.get("error", fznnfpky)
        xyjrjgsd.emit(fznnfpky)

func lgouqsmt (qbpxscid):
    var rxulpwji = JSON.new()
    var jtckjveu = rxulpwji.parse(qbpxscid.get_string_from_utf8())
    if jtckjveu != OK:
        return null
    return rxulpwji.get_data()

func vrgbswuz(jxbigbxp: Dictionary) -> void:
    while xsptawzc:
        dlssezvs.poll()
        
        match dlssezvs.get_status():
            HTTPClient.STATUS_CONNECTION_ERROR:
                iwrsyugj.emit("Connection error")
                ayzhmnqi()
                return
            HTTPClient.STATUS_DISCONNECTED:
                iwrsyugj.emit("Disconnected")
                ayzhmnqi()
                return
            
            HTTPClient.STATUS_CONNECTED:
                tululxrk(jxbigbxp)
                
            HTTPClient.STATUS_BODY:
                bhjzzrks()
        
        await get_tree().process_frame

func tululxrk(baetfeew: Dictionary) -> void:
    var qoeikjul = JSON.new()
    var xrpjdwqf = qoeikjul.stringify(baetfeew)
    var xnjoqunh = PackedStringArray([
        "Content-Type: application/json",
        "Authorization: Bearer " + vmwmbgsi
    ])
    
    var ugeridvn = dlssezvs.request(
        HTTPClient.METHOD_POST,
        qjtrjnnq.replace(tvlxezwb, ""),                                        
        xnjoqunh,
        xrpjdwqf
    )
    
    if ugeridvn != OK:
        iwrsyugj.emit("Failed to send request: " + str(ugeridvn))
        xsptawzc = false

func bhjzzrks() -> void:
    while dlssezvs.get_status() == HTTPClient.STATUS_BODY:
        var uaarhcrn = dlssezvs.read_response_body_chunk()
        if uaarhcrn.size() == 0:
            break
            
        mbfmndic += uaarhcrn.get_string_from_utf8()
        
        ocovapzg()

func ocovapzg() -> void:
    
    var xigzhlzt
    var aceftrrn
    var gzuukfft
    
    if dlssezvs.get_response_code() != 200:
        xsptawzc = false
        
        xigzhlzt = JSON.new()
        aceftrrn = xigzhlzt.parse(mbfmndic)
        
        if aceftrrn == OK:
            gzuukfft = xigzhlzt.get_data()
            if gzuukfft.has("error"):                
                iwrsyugj.emit(gzuukfft["error"])
            elif gzuukfft.has("message"):                
                iwrsyugj.emit(gzuukfft["message"])
            else:
                iwrsyugj.emit("Unknown server error, please try again later")
        else: 
            iwrsyugj.emit("Could not parse server response. Received from server: " + mbfmndic)
    
    var pvccpxke = mbfmndic.split("\n\n")
    
                                                                                 
    for i in range(pvccpxke.size() - 1):
        var ppeahsko: String = pvccpxke[i]
        if ppeahsko.find("data:") != -1:
            var pkdogtoh = ppeahsko.split("\n")
            for line in pkdogtoh:
                if line.begins_with("data:"):
                    var eitjsyqz = line.substr(5).strip_edges()
                                                               
                    
                    xigzhlzt = JSON.new()
                    aceftrrn = xigzhlzt.parse(eitjsyqz)
                    
                    if aceftrrn == OK:
                        gzuukfft = xigzhlzt.get_data()
                        
                        if gzuukfft is Dictionary:
                            if gzuukfft.has("error"):
                                printerr("Server error: ", gzuukfft["error"])
                                iwrsyugj.emit(gzuukfft["error"])
                                ayzhmnqi()
                                return
                            
                            if gzuukfft.has("done") and gzuukfft["done"] == true:
                                xsptawzc = false
                                                                
                                jbpkaprt.emit(
                                    int(gzuukfft.get("conversationId", -1)),
                                    int(gzuukfft.get("messageId", -1))
                                )
                                ayzhmnqi()
                                
                            elif gzuukfft.has("beforeActions"):
                                cknxrash.emit(
                                    int(gzuukfft.get("conversationId", -1)),
                                    int(gzuukfft.get("messageId", -1))
                                )
                                
                            elif gzuukfft.has("content"):
                                
                                if (typeof(gzuukfft.get("messageId")) != TYPE_INT and typeof(gzuukfft.get("messageId")) != TYPE_FLOAT) or (typeof(gzuukfft.get("messageId")) != TYPE_INT and typeof(gzuukfft.get("conversationId")) != TYPE_FLOAT):
                                    iwrsyugj.emit("Invalid data coming from the server")
                                    ayzhmnqi()
                                    return                                   
                            
                                crjdaiac.emit(
                                    str(gzuukfft["content"]),
                                    int(gzuukfft.get("conversationId", -1)),
                                    int(gzuukfft.get("messageId", -1))
                                )
                        
                                               
    mbfmndic = pvccpxke[pvccpxke.size() - 1]
    
func ayzhmnqi():  
    xsptawzc = false  
    dlssezvs.close()            

                                                                  
func ifennfcq(tifqqqaf: bool = false):
    var bgyiipun = EditorInterface.get_editor_settings()       
    var aaovmnck = bgyiipun.get_setting("gamedev_assistant/version_identifier")
    
    var afxepecb = {
        "releaseUniqueIdentifier": aaovmnck,
        "isInit": tifqqqaf
    }
    var lxeazvvi = JSON.new()
    var nmbrxmss = lxeazvvi.stringify(afxepecb)
    var wqzulblf = xizwtjej.request(pzkyzzlm, uovnwkeu(), HTTPClient.METHOD_POST, nmbrxmss)

                                            
func qthogpmb(yuqddjvx, xsharijj, riejgjzf, pdyuxbvu):
    if yuqddjvx != HTTPRequest.RESULT_SUCCESS:
        kunzjjab.emit("[GameDev Assistant] Network error when checking for updates (Code: " + str(yuqddjvx) + ")")
        return
        
    var pqyunarx = lgouqsmt(pdyuxbvu)
    if not pqyunarx is Dictionary:
        kunzjjab.emit("[GameDev Assistant] Response error when checking for updates (Code: " + str(xsharijj) + ")")
        return
    
    if xsharijj == 200:
        var xxkgrhyy = pqyunarx.get("updateAvailable", false)
        var ujktkclr = pqyunarx.get("latestVersion", "")
        
        osvrusdz.emit(xxkgrhyy, ujktkclr)
    else:
        kunzjjab.emit(pqyunarx.get("error", "Response code: " + str(xsharijj)))

func rbhioaqq(csnzryla: int, trhljrzn: bool, inmclenf: String, lmlczjjk: String, vigaipbv: String, awiefius: String):
    var dnjvkyev = {
        "messageId": csnzryla,
        "success": trhljrzn,
        "action_type": inmclenf,
        "node_type": lmlczjjk,
        "subresource_type": vigaipbv,
        "error_message": awiefius
    }
    zltywlfn.append(dnjvkyev)
    xmlvcvfm()

                             
func xmlvcvfm():
    var client_status = sjucgvng.get_http_client_status()
                                                                                      
    if (client_status == HTTPClient.STATUS_DISCONNECTED or 
        client_status == HTTPClient.STATUS_CANT_RESOLVE or 
        client_status == HTTPClient.STATUS_CANT_CONNECT or 
        client_status == HTTPClient.STATUS_CONNECTION_ERROR or 
        client_status == HTTPClient.STATUS_TLS_HANDSHAKE_ERROR) and zltywlfn.size() > 0:
        
        var vcdclpas = zltywlfn.pop_front()
        var gnnccgba = JSON.new()
        var lvnebexi = gnnccgba.stringify(vcdclpas)
        var jcuhzlmd = uovnwkeu()
        var uwnhcgtl = sjucgvng.request(nfiottdr, jcuhzlmd, HTTPClient.METHOD_POST, lvnebexi)
        if uwnhcgtl != OK:
            printerr("Failed to start track action request:", uwnhcgtl)
            xmlvcvfm()                                  

func ivfyozak(ahqkjezd, tmqwepyw, mdkiauee, eanyblnj):
    xmlvcvfm()                                      
    if ahqkjezd != HTTPRequest.RESULT_SUCCESS:
        printerr("[GameDev Assistant] Track action failed:", ahqkjezd)
        return
        
    var gqqjdyfg = lgouqsmt(eanyblnj)
    if not gqqjdyfg is Dictionary:
        printerr("[GameDev Assistant] Invalid track action response")

func lkeykcxs(ybxizmwh: int, jmbmormb: int) -> void:
    var qabnzfuk = {
        "messageId": ybxizmwh,
        "rating": jmbmormb
    }
    var gnvqpijj = JSON.new()
    var cjsuapeu = gnvqpijj.stringify(qabnzfuk)
    var vrbwsscm = uovnwkeu()
    var tizeyvwb = lxygwmla.request(hmahyggz, vrbwsscm, HTTPClient.METHOD_POST, cjsuapeu)
    if tizeyvwb != OK:
        printerr("[GameDev Assistant] Failed to track rating:", tizeyvwb)

                                          
func wabpnpnp(tkjdnsgv, rydmbueu, wrulahjx, khkhobxq):
    if tkjdnsgv != HTTPRequest.RESULT_SUCCESS:
        printerr("[GameDev Assistant] Rating action failed:", tkjdnsgv)
        return
        
    var tzjwgbsg = lgouqsmt(khkhobxq)
    if not tzjwgbsg is Dictionary:
        printerr("[GameDev Assistant] Invalid rating response")
        return

func fmvfcoxt():
    return xsptawzc
func vxuoxgbb(xjyyjjdk: Object) -> void:
    print("=== Methods ===")
    for method in xjyyjjdk.get_method_list():
        print(method["name"])
    
    print("\n=== Properties ===")
    for property in xjyyjjdk.get_property_list():
        print(property["name"])
    
    print("\n=== Signals ===")
    for signal_info in xjyyjjdk.get_signal_list():
        print(signal_info["name"])
        
func lcjghxmx(weusqkvc: String, nfkgjecq: int, nkadvnpj: String, fmgogyht: Button) -> void:
                                         
    jqneegtq = fmgogyht
    
                                                                  
    var lxwaqdxp = $"../ActionManager"
    lxwaqdxp.lcnzplbc.emit("edit_script", true)
    fmgogyht.text = "⌛Editing file %s" % weusqkvc

    var rptaqmen = {
        "path": weusqkvc,
        "message_id": nfkgjecq,
        "content": nkadvnpj
    }
    
    var pvlgjqqw = JSON.new()
    var gwftfkzc = pvlgjqqw.stringify(rptaqmen)
    var fovidvpy = uovnwkeu()
                                                     
    
    var mnjeftfr = tvlxezwb + "/editScript"
    var ncojtzwn = ubrlopwk.request(mnjeftfr, fovidvpy, HTTPClient.METHOD_POST, gwftfkzc)
    
    if ncojtzwn != OK:
        var kslcbblp = "Failed to start edit_script request: " + str(ncojtzwn)
        push_error(kslcbblp)
                                   
                                                      
        lxwaqdxp.xwkrpxjn.emit("edit_script", weusqkvc, false,kslcbblp, "", "", fmgogyht)
        
func ckodwnzc(flylvgck: int, dbwzffxz: int, kujgdomr: PackedStringArray, qfhxggzg: PackedByteArray) -> void:
    var vjbkxpcj = $"../ActionManager"
    var cxiwrbgj = jqneegtq

                                                                
    if flylvgck != HTTPRequest.RESULT_SUCCESS:
        var libzamoq = "EditScript network request failed. Code: " + str(flylvgck)
        push_error(libzamoq)
        vjbkxpcj.xwkrpxjn.emit("edit_script", false, libzamoq, "", "", cxiwrbgj)
        return

                                                      
    var qufmnnyp = lgouqsmt(qfhxggzg)
    if not qufmnnyp is Dictionary:
        var libzamoq = "Invalid response from server (not valid JSON)."
        push_error(libzamoq)
        vjbkxpcj.xwkrpxjn.emit("edit_script", false, libzamoq, "", "", cxiwrbgj)
        return

                                                         
    if qufmnnyp.has("error"):
        var libzamoq = "Server returned an error: " + str(qufmnnyp["error"])
        push_error(libzamoq)
        vjbkxpcj.xwkrpxjn.emit("edit_script", false, libzamoq, "", "", cxiwrbgj)
        return

    var mqhjepff = qufmnnyp.get("path", "")
    var nmmvhnwy = qufmnnyp.get("content", "")

                                                  
    if mqhjepff.is_empty():
        var libzamoq = "Incomplete data in EditScript response (path or content missing)."
        push_error(libzamoq)
        vjbkxpcj.xwkrpxjn.emit("edit_script", false, libzamoq, "", "", cxiwrbgj)
        return

                                                         
    var pvvekclg = FileAccess.open(mqhjepff, FileAccess.WRITE)
    if pvvekclg:
        pvvekclg.store_string(nmmvhnwy)
        pvvekclg.close()

                                                        
        var yruzncgs = ResourceLoader.load(mqhjepff, "Script", ResourceLoader.CACHE_MODE_IGNORE)
        await get_tree().process_frame
        
                                                                          
                                                                                 
        var ornpgdwo = cxiwrbgj.get_meta("action")
        cxiwrbgj.text = "Edit {path}".format({"path": ornpgdwo.path})

        var hzfqmgjx = Engine.get_singleton("EditorInterface")
        var kewiarkp = hzfqmgjx.get_script_editor()
        var voogkxpk = false
        for i in range(kewiarkp.get_open_scripts().size()):
            var szxliokp = kewiarkp.get_open_scripts()[i]
            if szxliokp.resource_path == mqhjepff:
                kewiarkp.get_open_script_editors()[i].get_base_editor().set_text(nmmvhnwy)
                push_warning("[GameDev Assistant] File updated: " + mqhjepff + " (due to a Godot API limitation, it will appear as unsaved, but it has been saved to disk!)")
                voogkxpk = true
                break

        if not voogkxpk:
            print("[GameDev Assistant] File updated: " + mqhjepff)

        hzfqmgjx.get_resource_filesystem().scan()
        await get_tree().process_frame
        hzfqmgjx.edit_script(yruzncgs)                           

                                 
        vjbkxpcj.xwkrpxjn.emit("edit_script", true, "", "", "", cxiwrbgj)
    else:
                                                         
        var mconrqxw = FileAccess.get_open_error()
        var libzamoq = "Failed to write to script '%s'. Error: %s" % [mqhjepff, error_string(mconrqxw)]
        push_error("[GameDev Assistant] " + libzamoq)
        vjbkxpcj.xwkrpxjn.emit("edit_script", false, libzamoq, "", "", cxiwrbgj)
