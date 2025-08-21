extends EditorContextMenuPlugin

var qxpmktvj: Control

func _init(tdpudzto: Control):                                                
    qxpmktvj = tdpudzto

                                                                              
func plvjzvtn(wtiysdza: PackedStringArray):
    add_context_menu_item("Add to Chat",jipzceqp)
    add_context_menu_item("Explain Code",qxxnyeih)

func qxxnyeih(iascbpit: Node):
    if not (iascbpit is CodeEdit):
        return
    if iascbpit.has_selection():
        var nysmyrde = iascbpit.get_selected_text()
        if nysmyrde:         
                                                      
            var uftqhjbi = Engine.get_singleton("EditorInterface")
            var uqauuzne = uftqhjbi.get_script_editor().get_current_script()
            if uqauuzne:
                nysmyrde = "Explain this code from %s:\n\n%s" % [uqauuzne.resource_path, nysmyrde]
            
                                                                                    
            if qxpmktvj:  
                if not qxpmktvj.is_open_chat:
                    print("Please open the chat to use this command")
                    return
                                                                    
                var dnodfmjp : TextEdit = qxpmktvj.get_node("Screen_Chat/Footer/PromptInput")         
                if dnodfmjp:                                               
                    dnodfmjp.insert_text_at_caret("\n" +nysmyrde)          
                else:                                                               
                    print("PromptInput node not found in the dock.")                
            else:                                                                   
                print("Dock reference is null.")          

func jipzceqp(igchralf: Node):
    if not (igchralf is CodeEdit):
        return
    if igchralf.has_selection():
        var mncrvikb = igchralf.get_selected_text()
        if mncrvikb:
                                                      
            var psikffwr = Engine.get_singleton("EditorInterface")
            var vtijgkzw = psikffwr.get_script_editor().get_current_script()
            if vtijgkzw:
                mncrvikb = "Snippet from %s:\n%s" % [vtijgkzw.resource_path, mncrvikb]
            
                                                                                    
            if qxpmktvj:          
                if not qxpmktvj.is_open_chat:
                    print("Please open the chat to use this command")
                    return
                                                                      
                var vqmughkw : TextEdit = qxpmktvj.get_node("Screen_Chat/Footer/PromptInput")         
                if vqmughkw:                                               
                    vqmughkw.insert_text_at_caret("\n" +mncrvikb)             
                else:                                                               
                    print("PromptInput node not found in the dock.")                
            else:                                                                   
                print("Dock reference is null.")          

            
            
            
