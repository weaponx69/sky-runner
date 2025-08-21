                                                       
@tool
extends GDAScreenBase

signal ihpecchi

var treicxuz : RichTextLabel = null

@onready var prhsdnwh : TextEdit = $Footer/PromptInput
@onready var kbdryqza : Button = $Footer/SendPromptButton
@onready var yxbfwmej : Control = $Footer
@onready var fulfqimi : Control = $Body

@onready var tainxuxy = $"../APIManager"
@onready var zchztxmt = $"../ActionManager"

var hsyvofnz = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_UserPrompt.tscn")
var yrfgosez = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_ServerResponse.tscn")
var nrpdaugg = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_ErrorMessage.tscn")
const wvbdhspx = preload("res://addons/gamedev_assistant/scripts/chat/markdown_to_bbcode.gd")
var xbzlulvs = preload("res://addons/gamedev_assistant/scripts/chat/message_tagger.gd").new()
var dtotpork = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_CodeBlockResponse.tscn")
var rtffndns = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_CodeBlockUser.tscn")
var zlluskyk = preload("res://addons/gamedev_assistant/dock/scenes/chat/Chat_Spacing.tscn")

var ofyhllbi := false
var erxkofmw: String = ""

                                                   
var hxbasubj : String = ""
var dzzmmkqw : String = ""
var wjwzgspm  : String = ""
var isdcrlkp : String = ""
var heubwfeu  : String = ""

var gqwvmlmm : int = -1

@onready var divjumfh = $Body/MessagesContainer
@onready var nuhdcazl = $Body/MessagesContainer/ThinkingLabel
@onready var rqegwvvf = $Bottom/AddContext
@onready var nprxkjcl : CheckButton = $Bottom/ReasoningToggle
@onready var uwjqppgf = $Body/MessagesContainer/RatingContainer
@onready var yfkjewza = $Bottom/Mode

@onready var cknyhagz = preload("res://addons/gamedev_assistant/dock/icons/stop.png")  
@onready var cemnjuno = preload("res://addons/gamedev_assistant/dock/icons/arrowUp.png")  

var sydydhqs = [
    "",
    " @OpenScripts ",
    " @Output ",
    " @Docs ",
    " @GitDiff ",
    " @ProjectSettings"
]

@onready var dxwoxzjp = $"../ConversationManager"

var waiting_nonthinking = "Thinking ⚡"
var waiting_thinking = "Reasoning ⌛ This could take multiple minutes"

var notice_actions_nonthinking = "Generating one-click actions ⌛ To skip, press ■"
var notice_actions_thinking = "Generating one-click actions ⌛ To skip, press ■"


func _ready ():
    tainxuxy.gpqtpwqi.connect(fzrasuto)
    tainxuxy.mqvjtyaf.connect(dxckxqtp)
    
    dxwoxzjp.joqutmvz.connect(simmolbd)
    prhsdnwh.dmvljyql.connect(pwpsxbgi)
    
                       
    tainxuxy.crjdaiac.connect(zhodprpa)
    tainxuxy.jbpkaprt.connect(jhgbtskh)
    tainxuxy.cknxrash.connect(defgzpqh)
    tainxuxy.iwrsyugj.connect(dgeiogus)

    rqegwvvf.item_selected.connect(ifdfhkfb)    
    kbdryqza.pressed.connect(wcbawugy)   
    
    uwjqppgf.get_node("UpButton").pressed.connect(xnxqzkhc)
    uwjqppgf.get_node("DownButton").pressed.connect(wozmqzby)
    uwjqppgf.visible = false 

func _on_open ():
    prhsdnwh.text = ""
    nuhdcazl.visible = false
    uwjqppgf.visible = false 
    noczxydq(false)
    bpoknzod()
    rqegwvvf.selected = 0
    erxkofmw = ''
    

                                                            
func nlrugpdn ():
    ofyhllbi = true
    noczxydq(true)
    gqwvmlmm = -1
    uwjqppgf.visible = false
    xbzlulvs.mpqtylnh()
    
                    
    dzzmmkqw = ""
    wjwzgspm  = ""
    isdcrlkp = ""
    heubwfeu  = ""
    hxbasubj = ""

func zhodprpa(zryawufx: String, ufpdaior: int, heclbjjs: int) -> void:
    if treicxuz == null:
        treicxuz = yrfgosez.instantiate()
        treicxuz.bbcode_enabled = true
        divjumfh.add_child(treicxuz)
        var qspduizd = zlluskyk.instantiate()
        divjumfh.add_child(qspduizd)
        nuhdcazl.visible = false
        erxkofmw = zryawufx
        
        if heclbjjs != -1:
            gqwvmlmm = heclbjjs
    else:
        erxkofmw += zryawufx
        
                                                  
    treicxuz.text = wvbdhspx.harjtfal(erxkofmw)
    
                                                                     
    if not treicxuz.meta_clicked.is_connected(qdeehcgw):  
        treicxuz.meta_clicked.connect(qdeehcgw)  
    
    if ufpdaior > 0:
        dxwoxzjp.hfjermfx(ufpdaior)

func defgzpqh(jgtmradg: int, xpecxixc: int) -> void:
    if treicxuz:
        treicxuz.visible = false

                                                                
    ldzgpzps(erxkofmw, yrfgosez, divjumfh, dtotpork)
    
                              
    divjumfh.move_child(nuhdcazl, divjumfh.get_child_count() - 1)
    nuhdcazl.visible = true
    nuhdcazl.text = notice_actions_nonthinking

func jhgbtskh(gkbekysp: int, ryxocomi: int) -> void:
                                         
    if treicxuz:
        treicxuz.queue_free()
        treicxuz = null
        
    nuhdcazl.visible = false
    
                                                    
    divjumfh.move_child(uwjqppgf, divjumfh.get_child_count() - 1)
    uwjqppgf.visible = ryxocomi > 0
    
                          
    var aeolcqas = zchztxmt.tzihlygi(erxkofmw, ryxocomi)
    zchztxmt.tixshqxn(aeolcqas, divjumfh)

    erxkofmw = ""
    noczxydq(true)
    nuhdcazl.visible = false
    kbdryqza.icon = cemnjuno

func dgeiogus(frpkomsy: String):
    wustwtlr(frpkomsy)
    noczxydq(true)
    nuhdcazl.visible = false
    treicxuz = null
    kbdryqza.icon = cemnjuno

func wcbawugy():  
    if tainxuxy.fmvfcoxt():  
                                         
        tainxuxy.aidsprtc.emit()  
        
                                             
        if treicxuz:
            treicxuz.queue_free()
            treicxuz = null
        
        noczxydq(true)  
        kbdryqza.icon = cemnjuno  
        
        if not nuhdcazl.visible:
                                                                        
            ldzgpzps(erxkofmw, yrfgosez, divjumfh, dtotpork)
        
        nuhdcazl.visible = false  
        
                                                   
        divjumfh.move_child(uwjqppgf, divjumfh.get_child_count() - 1)
        uwjqppgf.visible = gqwvmlmm > 0

    else:  
                                             
        giqzuxae()  

func giqzuxae():
                                                        
    zchztxmt.fzmbqmkd()
    
    uwjqppgf.visible = false
    
    gqwvmlmm = -1
    
    if len(prhsdnwh.text) < 1:
        return
    
    var opwudcmn = prhsdnwh.text

                                                        
    var vmkvzrpf := false
    if ofyhllbi:
        var vvpdkbhv = Engine.get_singleton("EditorInterface") if Engine.is_editor_hint() else null
        isdcrlkp = xbzlulvs.ncropbjf("", vvpdkbhv)
        heubwfeu  = xbzlulvs.kmgbawzc("", vvpdkbhv)
        hxbasubj = "[gds_context]Current project context:[/gds_context]\n" \
            + isdcrlkp + "\n" + heubwfeu
        vmkvzrpf = true
    else:
        vmkvzrpf = mbveuhxj()

    if vmkvzrpf and hxbasubj != "":
        opwudcmn += hxbasubj
                          
        dzzmmkqw = isdcrlkp
        wjwzgspm  = heubwfeu

    ofyhllbi = false

    if Engine.is_editor_hint():
        var vvpdkbhv = Engine.get_singleton("EditorInterface")
        opwudcmn = xbzlulvs.htxjmdva(opwudcmn, vvpdkbhv)
        
    var lfgxoupp = nprxkjcl.button_pressed
    var asaauuvd : int = yfkjewza.selected
    var lfpjskho : String
    
    if asaauuvd == 0:
        lfpjskho = "CHAT"
    else:
        lfpjskho = "AGENT"        
    
    tainxuxy.vkevbvyi(opwudcmn, lfgxoupp, lfpjskho)
    gwgsxxjv(prhsdnwh.text)                               
    noczxydq(false)
    prhsdnwh.text = ""
    
    if lfgxoupp:
        nuhdcazl.text = waiting_thinking
    else:
        nuhdcazl.text = waiting_nonthinking
        
    nuhdcazl.visible = true
    divjumfh.move_child(nuhdcazl, divjumfh.get_child_count() - 1)
    
                                               
    ihpecchi.emit()
    
func noczxydq (ukgcljmy : bool):
    if ukgcljmy:  
        kbdryqza.icon = cemnjuno  
    else:  
        kbdryqza.icon = cknyhagz  

func fzrasuto (cmpvoirk : String, ylukechi : int):
    gtbomxoq(cmpvoirk)
    noczxydq(true)
    nuhdcazl.visible = false

func dxckxqtp (ylqvoytq : String):
    wustwtlr(ylqvoytq)
    noczxydq(true)
    nuhdcazl.visible = false

func gwgsxxjv(jjhtjjad: String):
                                                                               
    ldzgpzps(jjhtjjad, hsyvofnz, divjumfh, rtffndns)
    
    var xdauvnpb = zlluskyk.instantiate()
    divjumfh.add_child(xdauvnpb)


func gtbomxoq(cyfjeefv: String):
                                                                                
    ldzgpzps(cyfjeefv, yrfgosez, divjumfh, dtotpork)
    
    var grongbtg = zlluskyk.instantiate()
    divjumfh.add_child(grongbtg)

func wustwtlr (fmnwvosk : String):
    var nsayizit = nrpdaugg.instantiate()
    divjumfh.add_child(nsayizit)
    nsayizit.text = fmnwvosk

func bpoknzod ():
    for node in divjumfh.get_children():
        if node == nuhdcazl or node == uwjqppgf:
            continue
        node.queue_free()
    divjumfh.custom_minimum_size = Vector2.ZERO
    
    ihpecchi.emit()
    
                  
    xbzlulvs.mpqtylnh()
    
                            
    dzzmmkqw = ""
    wjwzgspm  = ""
    isdcrlkp = ""
    heubwfeu  = ""
    hxbasubj = ""

func simmolbd ():
    var ufhjqivg = dxwoxzjp.ixcssopl()
    bpoknzod()
    
    for msg in ufhjqivg.messages:
        if msg.role == "user":
            gwgsxxjv(msg.content)
        elif msg.role == "assistant":
            gtbomxoq(msg.content)
    
    noczxydq(true)

func ifdfhkfb(rmjyvbcu: int):
    if rmjyvbcu >= 0 and rmjyvbcu < sydydhqs.size():
        prhsdnwh.text += " " + sydydhqs[rmjyvbcu]
        rqegwvvf.select(0)

func qdeehcgw(hfyxvgfd):
    OS.shell_open(str(hfyxvgfd))

                                                
func bsqthili(sabozzvk: String) -> String:
    
    var qlznqvdu = RegEx.new()
                                 
    qlznqvdu.compile("\\[gds_context\\](.|\\n)*?\\[/gds_context\\]")
    sabozzvk = qlznqvdu.sub(sabozzvk, "", true)
    
                                       
    qlznqvdu.compile("<internal_tool_use>(.|\\n)*?</internal_tool_use>")
    return qlznqvdu.sub(sabozzvk, "", true)
    
                                                
func vattlcas(hgioslcn: String) -> String:
        
    var zfvkwvig = RegEx.new()
    zfvkwvig.compile("\\[gds_actions\\](.|\\n)*?\\[/gds_actions\\]")
    return zfvkwvig.sub(hgioslcn, "", true)

func dszqoloa(jjqpkvoj: String):
    jjqpkvoj = jjqpkvoj.replace(notice_actions_nonthinking, '').replace(notice_actions_thinking, '').strip_edges()
    return jjqpkvoj
    
func ldzgpzps(nxxzqbmk: String, jmlvzpdu: PackedScene, xmssbtfu: Node, fiidtdgx: PackedScene) -> void:
    
    nxxzqbmk = nxxzqbmk.strip_edges()
    nxxzqbmk = bsqthili(nxxzqbmk)
    
                       
    var vyvarxfs = wvbdhspx.ctwnmgjl(nxxzqbmk)

    for block in vyvarxfs:
        if block["type"] == "text":
            var vyfsjxuz = jmlvzpdu.instantiate()
            vyfsjxuz.bbcode_enabled = true
            xmssbtfu.add_child(vyfsjxuz)
            
            var wylisqxh = block["content"]
            
                                                      
            wylisqxh = wvbdhspx.krcqtowz(wylisqxh)
            wylisqxh = wvbdhspx.nxnuywxp(wylisqxh)
            wylisqxh = wylisqxh.strip_edges()
            
            vyfsjxuz.text = wylisqxh

                                 
            if not vyfsjxuz.meta_clicked.is_connected(qdeehcgw):
                vyfsjxuz.meta_clicked.connect(qdeehcgw)

        elif block["type"] == "code":
            var xorbsjlx = fiidtdgx.instantiate()
            xmssbtfu.add_child(xorbsjlx)
            xorbsjlx.text = block["content"]

                           
func mbveuhxj() -> bool:
    var qebvhrer = Engine.get_singleton("EditorInterface") if Engine.is_editor_hint() else null
    isdcrlkp = xbzlulvs.ncropbjf("", qebvhrer)
    heubwfeu  = xbzlulvs.kmgbawzc("", qebvhrer)

    var xttrxkky = isdcrlkp != dzzmmkqw
    var frvlkjie  = heubwfeu  != wjwzgspm

    var pzolmyft = []
    if xttrxkky:
        pzolmyft.append(isdcrlkp)
    if frvlkjie:
        pzolmyft.append(heubwfeu)

    hxbasubj = ""
    if pzolmyft.size() > 0:
        hxbasubj = "[gds_context]Current project context:[/gds_context]\n" + "\n".join(pzolmyft)

    return xttrxkky or frvlkjie

                               
func pwpsxbgi() -> void:
    var aigclpmq = not tainxuxy.fmvfcoxt()
    if aigclpmq:
        giqzuxae()
        
func xnxqzkhc():
    if gqwvmlmm > 0:
        tainxuxy.lkeykcxs(gqwvmlmm, 5)
        uwjqppgf.visible = false                     

func wozmqzby():
    if gqwvmlmm > 0:
        tainxuxy.lkeykcxs(gqwvmlmm, 1)
        uwjqppgf.visible = false
