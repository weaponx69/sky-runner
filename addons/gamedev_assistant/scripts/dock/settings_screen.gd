                                  
@tool
extends GDAScreenBase

var ietqagab : Label
var oqbklwpw : LineEdit
var dyxjgnto : CheckButton
var qquhevlc : Button
var sclyqezs : RichTextLabel
var dgmlrlqq : RichTextLabel
var yunauayp : RichTextLabel
var ugqwdxiv : Button
var alrzkjra : LineEdit
var ohxjsoaq : Button
var agghnmsd : Button
var utortqss : String

const ymmbsgrp : String = "gamedev_assistant/hide_token"
const jptsrafm : String = "gamedev_assistant/validated"
const uctmvsjj : String = "gamedev_assistant/custom_instructions"

@onready var zhyayfrt = $".."
@onready var xrcomgel = $"../APIManager"
@onready var jqqciuvq = $"VBoxContainer/CustomInput"

var ydenvqvm : bool

func _ready ():
    xrcomgel.xxmxbdja.connect(_on_validate_token_received)
    xrcomgel.osvrusdz.connect(_on_check_updates_received)
    xrcomgel.kunzjjab.connect(znxwbxbk)
    
    xbqfoasu()
    
                                             
    dyxjgnto.toggled.connect(ttplrfcz)
    qquhevlc.pressed.connect(tyshnqwz)
    ohxjsoaq.pressed.connect(ybskvktp)
    agghnmsd.pressed.connect(zovxvlhz)
    oqbklwpw.text_changed.connect(iqjyfkcs)
    
    sclyqezs.visible = false
    dgmlrlqq.visible = false
    yunauayp.visible = false
    
    var fhdapnev = EditorInterface.get_editor_settings()       
    
    fhdapnev.set_setting("gamedev_assistant/version_identifier", "0O3JDKN5J9")
    
    ydenvqvm = fhdapnev.has_setting("gamedev_assistant/development_mode") and fhdapnev.get_setting('gamedev_assistant/development_mode') == true    
    if not ydenvqvm:
        fhdapnev.set_setting("gamedev_assistant/endpoint", "https://app.gamedevassistant.com")
        utortqss = "gamedev_assistant/token"
    else:
        fhdapnev.set_setting("gamedev_assistant/endpoint", "http://localhost:3000")
        utortqss = "gamedev_assistant/token_dev"
        print("Development mode")
        
    xrcomgel.hecrklrb()
    
                                                                         
                                                  
func xbqfoasu ():
    ietqagab = $VBoxContainer/EnterTokenPrompt
    oqbklwpw = $VBoxContainer/Token_Input
    dyxjgnto = $VBoxContainer/HideToken
    qquhevlc = $VBoxContainer/ValidateButton
    sclyqezs = $VBoxContainer/TokenValidationSuccess
    dgmlrlqq = $VBoxContainer/TokenValidationError
    yunauayp = $VBoxContainer/TokenValidationProgress
    ohxjsoaq = $VBoxContainer/AccountButton
    agghnmsd = $VBoxContainer/UpdatesButton

func ttplrfcz (xbkkwveo):
    oqbklwpw.secret = xbkkwveo
    
    var tjrggtbi = EditorInterface.get_editor_settings()
    tjrggtbi.set_setting(ymmbsgrp, dyxjgnto.button_pressed)

func iqjyfkcs (wfnjkkcc):
    if len(oqbklwpw.text) == 0:
        ietqagab.visible = true
    else:
        ietqagab.visible = false
    
    zhyayfrt.fygeycog(false)
    
    sclyqezs.visible = false
    dgmlrlqq.visible = false
    yunauayp.visible = false
    
    var ehzxttdv = EditorInterface.get_editor_settings()
    ehzxttdv.set_setting(utortqss, oqbklwpw.text)

func tyshnqwz ():
    qquhevlc.disabled = true
    sclyqezs.visible = false
    dgmlrlqq.visible = false
    yunauayp.visible = true
    xrcomgel.fdkcwddt()

                                                        
func _on_validate_token_received (gvojfhcl : bool, zzzpyplp : String):
    yunauayp.visible = false
    qquhevlc.disabled = false
    
    if gvojfhcl:
        sclyqezs.visible = true
        sclyqezs.text = "Token has been validated!"
        
        var lwxhjqyn = EditorInterface.get_editor_settings()
        lwxhjqyn.set_setting(jptsrafm, true)
        
        zhyayfrt.fygeycog(true)
    else:
        dgmlrlqq.visible = true
        dgmlrlqq.text = zzzpyplp

                                                  
                                                  
func _on_open ():
    xbqfoasu()
    var rycpigzp = EditorInterface.get_editor_settings()
    
    if rycpigzp.has_setting(utortqss):
        oqbklwpw.text = rycpigzp.get_setting(utortqss)
    
    if rycpigzp.has_setting(ymmbsgrp):
        dyxjgnto.button_pressed = rycpigzp.get_setting(ymmbsgrp)
    
    oqbklwpw.secret = dyxjgnto.button_pressed
    
    if len(oqbklwpw.text) == 0:
        ietqagab.visible = true
    else:
        ietqagab.visible = false
        
    if rycpigzp.has_setting(uctmvsjj):
        jqqciuvq.text = rycpigzp.get_setting(uctmvsjj)

func ybskvktp():
    OS.shell_open("https://app.gamedevassistant.com/profile")
    
func zovxvlhz():
    sclyqezs.visible = false
    dgmlrlqq.visible = false
    yunauayp.visible = true
    
    xrcomgel.ifennfcq()

func _on_check_updates_received(txucxguq: bool, abfbzxhk: String):
    yunauayp.visible = false
    
    if txucxguq:
        sclyqezs.visible = true
        sclyqezs.text = "An update is available! Latest version: " + abfbzxhk + ". Click 'Manage Account' to download it."
    else:
        sclyqezs.visible = true
        sclyqezs.text = "You are already in the latest version"

func znxwbxbk(qpcwfsjw: String):
    yunauayp.visible = false
    dgmlrlqq.visible = true
    dgmlrlqq.text = qpcwfsjw
    
