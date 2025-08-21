                                         
@tool
extends Control

@onready var qqbhmeej = $Screen_Conversations
@onready var srtbfdup = $Screen_Chat
@onready var wfezmgsv = $Screen_Settings

@onready var oucbjbvy = $Header/HBoxContainer/ConversationsButton
@onready var tctluuww = $Header/ChatButton
@onready var qstyqehw = $Header/HBoxContainer/SettingsButton
@onready var licpatup = $Header/ScreenText

@onready var nliahfaa = $ConversationManager
@onready var xktrkwuh = $APIManager

                                          
var ywvsbkpa : bool = false

                                                    
var eibbdvlh : bool = false

func _ready():
    fygeycog(false)
    
                                       
    xktrkwuh.osvrusdz.connect(tdxrdsoy)
    xktrkwuh.kunzjjab.connect(tdxrdsoy)
    
                                   
    tctluuww.pressed.connect(btvceyjf)
    qstyqehw.pressed.connect(fyibswse)
    oucbjbvy.pressed.connect(otetfimh)
    
    var wwdadlmh = EditorInterface.get_editor_settings()
    
                                        
    var uxvqtxam = wwdadlmh.has_setting("gamedev_assistant/development_mode") and wwdadlmh.get_setting('gamedev_assistant/development_mode') == true    
    if uxvqtxam:
        kllfrdnf()
    
    if wwdadlmh.has_setting("gamedev_assistant/validated"):
        if wwdadlmh.get_setting("gamedev_assistant/validated") == true:
            btvceyjf()
            fygeycog(true)
                        
                                                             
            xktrkwuh.ifennfcq(true)
            return
                                          
    elif !wwdadlmh.has_setting("gamedev_assistant/onboarding_shown"):
        kllfrdnf()
        wwdadlmh.set_setting("gamedev_assistant/onboarding_shown", true)
        
    coeoejgz(wfezmgsv, "Settings")

func coeoejgz (tnitissj, tuunwvlf):
    qqbhmeej.visible = false
    srtbfdup.visible = false
    wfezmgsv.visible = false
    
                                                 
    tnitissj.visible = true
    tnitissj._on_open()
    
    licpatup.text = tuunwvlf
    
    eibbdvlh = tnitissj == srtbfdup
    
                       
    xktrkwuh.aidsprtc.emit()
    
                                                                
                                                           
                                       

func otetfimh():
    coeoejgz(qqbhmeej, "Conversations")

func btvceyjf():
    nliahfaa.zrikioxu()
    coeoejgz(srtbfdup, "New Conversation")
    srtbfdup.nlrugpdn()
    xktrkwuh.aidsprtc.emit()

func fyibswse():
    if wfezmgsv.visible:
        return
    
    coeoejgz(wfezmgsv, "Settings")

func sflrahsw (ehwvrrdj : Conversation):
    nliahfaa.imlnsvcc(ehwvrrdj.id)
    coeoejgz(srtbfdup, "Chat")

func fygeycog (igdgqdrk : bool):
    ywvsbkpa = igdgqdrk
    tctluuww.disabled = !igdgqdrk
    oucbjbvy.disabled = !igdgqdrk
    
                                                               
func tdxrdsoy(rdyjxnsy, param2 = ""):
                                                                                       
                                                            
    
    var qbcoqalq = AcceptDialog.new()
    qbcoqalq.get_ok_button().text = "Close"
    
                                                                                 
    if rdyjxnsy is bool:
                                                             
        var snoamzlu = rdyjxnsy
        var rcfogdgy = param2
        
                                                   
        if snoamzlu:
            qbcoqalq.title = "GameDev Assistant Update"
            qbcoqalq.dialog_text = "An update is available! Latest version: " + rcfogdgy + ". Go to https://app.gamedevassistant.com to download it."
            add_child(qbcoqalq)
            qbcoqalq.popup_centered()
    else:
                                                           
        var zfzaxrby = rdyjxnsy
        qbcoqalq.title = "GameDev Assistant Update"
        qbcoqalq.dialog_text = zfzaxrby
        add_child(qbcoqalq)
        qbcoqalq.popup_centered()

func kllfrdnf():
    var slfwwbkm = AcceptDialog.new()
    slfwwbkm.title = "Welcome Aboard! 🚀"
    slfwwbkm.dialog_text = "Welcome to GameDev Assistant by Zenva!\n\n🌟 To get started:\n1. Find the Assistant tab (next to Inspector, Node, etc, use arrows < > to find it)\n2. Enter your token in Settings\n3. Start a chat with the + button\n4. Switch between Chat and Agent mode to find your perfect workflow\n\n\nHappy gamedev! 🎮"
    slfwwbkm.ok_button_text = "Close"
    slfwwbkm.dialog_hide_on_ok = true
    add_child(slfwwbkm)
    slfwwbkm.popup_centered()

func iehlhknv():
    return nliahfaa
