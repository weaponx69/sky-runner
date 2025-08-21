@tool
class_name Conversation
extends Node

                                                                             

var messages : Array[Message] = []
var title : String
var id : int = -1
var favorited : bool = false
var has_been_fetched : bool = false

class Message:
    var role : String
    var content : String

                                           
                                                                    
func nfmpvjjt () -> String:
    if len(title) > 0:
        return title
    
    if len(messages) == 0:
        return "Empty chat..."
    
    return messages[0].content

func wlxfbmcy (skteeisa : String):
    var ckslvgbb = Message.new()
    ckslvgbb.role = "user"
    ckslvgbb.content = skteeisa
    messages.append(ckslvgbb)

func pxsgmieu (ekahroen : String):
    var mvfibuad = Message.new()
    mvfibuad.role = "assistant"
    mvfibuad.content = ekahroen
    messages.append(mvfibuad)
