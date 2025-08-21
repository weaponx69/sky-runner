@tool
extends GDAScreenBase

@onready var evrmockw : ConfirmationDialog = $DeleteConfirmation
@onready var nmgsyqwh = $ScrollContainer/VBoxContainer
@onready var pbbkjipn = $"../ConversationManager"

@onready var fdkkhkzu = $ScrollContainer/VBoxContainer/ErrorMessage
@onready var wyqdkjsg = $ScrollContainer/VBoxContainer/ProcessMessage
@onready var cfiloeim = $ScrollContainer/VBoxContainer/AllConversationsHeader
@onready var ylvgkrgd = $ScrollContainer/VBoxContainer/FavouritesHeader

var ccadlafn = preload("res://addons/gamedev_assistant/dock/scenes/ConversationSlot.tscn")

var qvoeiaeu
@onready var iflnreaw = $".."

@onready var ehxgveey = $"../APIManager"

var jgberwvl : bool = false

func _ready ():
    pbbkjipn.kcedfhzv.connect(sbnfkvtw)
    ehxgveey.btonsrse.connect(ixabywrv)
    ehxgveey.ffkrruao.connect(_on_delete_conversation_received)
    ehxgveey.mgjlxpyv.connect(ixabywrv)
    ehxgveey.xyjrjgsd.connect(ixabywrv)
    ehxgveey.unuyptbd.connect(_on_toggle_favorite_received)
    evrmockw.confirmed.connect(bvtmypsu)
    
func _on_open ():
    oopehdke()
    ehxgveey.clakmnxa()
    
                               
    
                                      
                                         
                                     

func oopehdke ():
    for node in nmgsyqwh.get_children():
        if node is RichTextLabel:
            continue
        
        node.queue_free()
    
    fdkkhkzu.visible = false
    wyqdkjsg.visible = false

func sbnfkvtw ():
    oopehdke()
    
    var ibtosgzc = pbbkjipn.lvczcwqm()
    
    var rcugvwkk : Array[Conversation] = []
    var susvqome : Array[Conversation] = []
    
    for conv in ibtosgzc:
        if conv.favorited:
            rcugvwkk.append(conv)
        else:
            susvqome.append(conv)
    
    var mgmnuglq = 2
    nmgsyqwh.move_child(ylvgkrgd, 1)
    
    for fav in rcugvwkk:
        var cvidfbim = gmesvbly(fav, iflnreaw)
        nmgsyqwh.move_child(cvidfbim, mgmnuglq)
        mgmnuglq += 1
    
    nmgsyqwh.move_child(cfiloeim, mgmnuglq)
    mgmnuglq += 1
    
    for other in susvqome:
        var cvidfbim = gmesvbly(other, iflnreaw)
        nmgsyqwh.move_child(cvidfbim, mgmnuglq)
        mgmnuglq += 1

func gmesvbly (nyujvaye, gdrjuxer) -> Control:
    var ehlrgmnw = ccadlafn.instantiate()
    nmgsyqwh.add_child(ehlrgmnw)
    ehlrgmnw.hiflkbrw(nyujvaye, gdrjuxer)
    return ehlrgmnw

                                            
                                        
func vgmppzxq (zzokmkup):
    qvoeiaeu = zzokmkup
    evrmockw.popup()

                                                        
func bvtmypsu():
    if qvoeiaeu == null or qvoeiaeu.get_conversation() == null:
        return
    
    var xaxzinas = qvoeiaeu.get_conversation()
    ehxgveey.jdvbjogk(xaxzinas.id)
    
    zthaqznq("Deleting conversation...")

func _on_toggle_favorite_received ():
    ehxgveey.clakmnxa()

func _on_delete_conversation_received ():
    ehxgveey.clakmnxa()

func zthaqznq (znftmoex : String):
    return
    
    nmgsyqwh.move_child(wyqdkjsg, 1)
    fdkkhkzu.visible = false
    wyqdkjsg.visible = true
    wyqdkjsg.text = znftmoex

func ixabywrv (obweunkm : String):
    nmgsyqwh.move_child(fdkkhkzu, 0)
    wyqdkjsg.visible = false
    fdkkhkzu.visible = true
    fdkkhkzu.text = obweunkm
