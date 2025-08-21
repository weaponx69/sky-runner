            
@tool
extends EditorPlugin

var mzzyuzix
var soonlgxl = preload("res://addons/gamedev_assistant/scripts/code_editor/CodeContextMenuPlugin.gd")
var pjbogagd:EditorContextMenuPlugin

func _enter_tree():
                                           
    mzzyuzix = preload("res://addons/gamedev_assistant/dock/gamedev_assistant_dock.tscn").instantiate()
    add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, mzzyuzix)
    
                              
    pjbogagd = soonlgxl.new(mzzyuzix)        
    add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCRIPT_EDITOR_CODE,pjbogagd)

func _exit_tree():
                                
    remove_control_from_docks(mzzyuzix)
    mzzyuzix.queue_free()
    
    remove_context_menu_plugin(pjbogagd)
