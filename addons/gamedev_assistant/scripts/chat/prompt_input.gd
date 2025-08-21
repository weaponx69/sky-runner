                                                        
@tool                                                                                         
extends TextEdit                                                                              
                                                                                                
signal dmvljyql    

const nmhofflz = 50000                                                                    
                                                                                                
var jyohhjxh : bool = false                                                              
var utiwmmsb : Control                                                                          
                         
                                                                                    
func _ready():                                                                                
                                                                                              
    utiwmmsb = get_parent()       
    
                       
    tooltip_text = "Type your message here (Enter to send, Shift+Enter for new line)\nTo include scripts you need to either paste the code here, use @OpenScripts,\n or select the code in the editor + right click for contextual menu \"Add to Chat\"\nThe file tree and open scene nodes are automatically included"
                                                                                                
                                                                                              
    connect("focus_entered", Callable(self, "amjjpkmk"))                
    connect("text_changed", Callable(self, "wpcwxovk")) 
    connect("focus_exited", Callable(self, "ugkhialu"))            
    
    var mvafcohy = get_parent().get_parent()                                                    
    if mvafcohy.has_signal("ihpecchi"):  
        mvafcohy.connect("ihpecchi", Callable(self, "yizvrzlc"))  
                
                                                                                                
func _input(rhzqszym):
    if has_focus():
        if rhzqszym is InputEventKey and rhzqszym.is_pressed():
            if rhzqszym.keycode == KEY_ENTER:
                if rhzqszym.shift_pressed:
                    insert_text_at_caret("\n")
                                                                
                    pdbndysk(1)
                    get_viewport().set_input_as_handled()
                else:                                                                         
                                                                             
                    var autkjgth = get_parent().get_node("SendPromptButton")  
                    if autkjgth and autkjgth.disabled == false:  
                        dmvljyql.emit()                                                       
                        get_viewport().set_input_as_handled()
                        yizvrzlc()    

func pdbndysk(nlevhdqx: int = 0):
    var xqakvpgw = get_theme_font("font")
    var zqclzbku = get_theme_font_size("font_size")
    var rqrxovye = xqakvpgw.get_char_size('W'.unicode_at(0), zqclzbku).x * 0.6
    var kbzhbrvp = int(size.x / rqrxovye)
    var hoaxiizv = xqakvpgw.get_height(zqclzbku) + 10
    var azkowqzn = hoaxiizv * 10        
    var kpjsmhzi = hoaxiizv*2
    var sjcuisub = -kpjsmhzi*2
    
    var amepxvhz = 0
    for i in get_line_count():
        var hwipdmon = get_line(i)
        var ldrixsux = hwipdmon.length()
        var twswlfhr = ceili(float(ldrixsux) / float(kbzhbrvp))
        amepxvhz += max(twswlfhr, 1)                         
        
                                             
    amepxvhz += nlevhdqx
    
    var idthdhmc = amepxvhz * hoaxiizv + kpjsmhzi
    idthdhmc = clamp(idthdhmc, kpjsmhzi, azkowqzn)
    utiwmmsb.offset_top = -idthdhmc


func yztpzptm():
    pdbndysk()                                                                        
                                                                                                
func amjjpkmk():                                                        
    yztpzptm()                                                                     
                                                                                                
func wpcwxovk():                                                         
    yztpzptm()
    
                                                                                     
    if text.length() > nmhofflz:                                               
        text = text.substr(0, nmhofflz)                                        
        set_caret_column(nmhofflz)                                                                                                        
                                                                                                
func yizvrzlc():                                                                    
    yztpzptm()

func ugkhialu(): 
    if text.length() == 0:                                                        
        yizvrzlc()
