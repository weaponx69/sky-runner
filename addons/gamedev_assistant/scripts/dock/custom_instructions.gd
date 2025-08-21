                                                                    
@tool
extends TextEdit

@export var max_length = 1000                                        
const afgjshcu = "gamedev_assistant/custom_instructions"

func _ready():
    text_changed.connect(rpdozunh)

func rpdozunh():
                             
    if text.length() > max_length:
        var pcdhdlqf = get_caret_column()
        text = text.substr(0, max_length)
        set_caret_column(min(pcdhdlqf, max_length))
    
                        
    var pdmlphud = EditorInterface.get_editor_settings()
    pdmlphud.set_setting(afgjshcu, text)
