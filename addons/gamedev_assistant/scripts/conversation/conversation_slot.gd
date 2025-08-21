@tool
extends Button

@onready var kgejqnrz : Label = $PromptLabel
@onready var ofqhvfrd : TextureButton = $FavouriteButton
@onready var ssjuwaiu : Button = $DeleteButton

@export var non_favourite_color : Color
@export var favourite_color : Color

var qnuhktkm : Conversation
var mgmzxyty

func _ready():
    ofqhvfrd.modulate = non_favourite_color
    
                                
    pressed.connect(aucyphca)
    ssjuwaiu.pressed.connect(gvfysbey)
    ofqhvfrd.pressed.connect(wkhioxoj)

                                                 
func hiflkbrw (dlytblhr : Conversation, ucsklwzx):
    qnuhktkm = dlytblhr
    mgmzxyty = ucsklwzx
    kgejqnrz.text = qnuhktkm.nfmpvjjt().replace("\n", "")                    
    xjcvcikx()

                                                
func aucyphca():
    mgmzxyty.sflrahsw(qnuhktkm)

                              
                                    
func gvfysbey():
    $"../../..".vgmppzxq(self)

func wkhioxoj():
                                                          
    var ykgatvjj = mgmzxyty.iehlhknv()
    ykgatvjj.aialdudf(qnuhktkm, not qnuhktkm.favorited)
    xjcvcikx()

func xjcvcikx ():
    if qnuhktkm.favorited:
        ofqhvfrd.modulate = favourite_color
    else:
        ofqhvfrd.modulate = non_favourite_color

func get_conversation():
    return qnuhktkm
