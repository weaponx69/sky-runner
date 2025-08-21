@tool
extends Node

                                        
                             
                               

signal vypwspum (conversation : Conversation)

                                                                    
signal kcedfhzv
signal joqutmvz

var enspclke : Array[Conversation]
var emslting : Conversation

@onready var tdsnlyil = $"../APIManager"
@onready var xvqgpzwg = $".."
@onready var xuhkhgca = $"../Screen_Conversations"

func _ready ():
    tdsnlyil.wwccjuee.connect(axtdpanu)
    tdsnlyil.gpqtpwqi.connect(_on_send_message_received)
    
    tdsnlyil.oyviquob.connect(sscjsxja)
    tdsnlyil.ozgsvjdc.connect(tqffeqwv)

func vsjrggtk () -> Conversation:
    zrikioxu()                                            

    var qnebfjbn = Conversation.new()
    qnebfjbn.id = -1                                       
    enspclke.append(qnebfjbn)
    emslting = qnebfjbn
    return qnebfjbn

func zrikioxu ():
    if emslting != null:
        if emslting.id == -1:                                    
            enspclke.erase(emslting)
    
    emslting = null

func hxphiyqr (kxnqchmk : Conversation):
    emslting = kxnqchmk
    joqutmvz.emit()

                                                                    
                                                                              
func sscjsxja (pfkevgfz):
    enspclke.clear()
    
    for conv_data in pfkevgfz:
        var qjtdmbbw = Conversation.new()
        qjtdmbbw.id = int(conv_data["id"])
        qjtdmbbw.title = conv_data["title"]
        qjtdmbbw.favorited = conv_data["isFavorite"]
        enspclke.append(qjtdmbbw)
    
    kcedfhzv.emit()

                                   
func axtdpanu(wtqluqye: String):
    if emslting == null:
                                           
        vsjrggtk()
    
                                                     
                                                    
                           
       
    emslting.wlxfbmcy(wtqluqye)

func _on_send_message_received(vzstpost: String, uzophmgs: int):
    print("Received assistant message: ", {
        "conversation_id": uzophmgs,
        "current_conv_id": emslting.id if emslting else "none",
        "content": vzstpost
    })
    if emslting:
        if emslting.id == -1:
                                                                    
            emslting.id = uzophmgs
        emslting.pxsgmieu(vzstpost)

                                                                                      
                                                                     
func imlnsvcc (cwgnfhya : int):
    tdsnlyil.get_conversation(cwgnfhya)

                                                            
                                                 
func tqffeqwv (qtpfdnxz):
    var egixgblt : Conversation
    var tgaaenaq = qtpfdnxz["id"]
    tgaaenaq = int(tgaaenaq)
    
                                                
    for c in enspclke:
        if c.id == tgaaenaq:
            egixgblt = c
            break
    
                                              
    if egixgblt == null:
        egixgblt = Conversation.new()
        egixgblt.id = tgaaenaq
        egixgblt.title = qtpfdnxz["title"]
        enspclke.append(egixgblt)
    
    egixgblt.messages.clear()
    
                                                    
    for message in qtpfdnxz["messages"]:
        if message["role"] == "user":
            egixgblt.wlxfbmcy(message["content"])
        elif message["role"] == "assistant":
            egixgblt.pxsgmieu(message["content"])
    
    egixgblt.has_been_fetched = true
    hxphiyqr(egixgblt)

func aialdudf (cfypyzwj : Conversation, puhaksfp : bool):
    tdsnlyil.lzqlwyzq(cfypyzwj.id)
    
    if puhaksfp:
        xuhkhgca.zthaqznq("Adding favorite...")
    else:
        xuhkhgca.zthaqznq("Removing favorite...")

func lvczcwqm():
    return enspclke
    
func ixcssopl():
    return emslting
    
func hfjermfx(itkqahmd: int):
    emslting.id = itkqahmd
