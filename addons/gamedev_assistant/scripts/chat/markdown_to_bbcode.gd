                                                              
@tool
class_name MarkdownToBBCode
extends RefCounted

const slclkeuu = [
    "b", "i", "u", "s", "code", "char", "p", "center", "left", "right", "fill",
    "indent", "url", "hint", "img", "font", "font_size", "dropcap",
    "opentype_features", "lang", "color", "bgcolor", "fgcolor", "outline_size",
    "outline_color", "table", "cell", "ul", "ol", "lb", "rb", "lrm", "rlm",
    "lre", "rle", "lro", "rlo", "pdf", "alm", "lri", "rli", "fsi", "pdi",
    "zwj", "zwnj", "wj", "shy"
]


                                                                    
                              
                                                                
                                                                    
static func sfqphfwo(jxbevnva: Array, hvmmybzg: String) -> String:
    var nopfwyya = ""
    for i in range(jxbevnva.size()):
        if i > 0:
            nopfwyya += hvmmybzg
        nopfwyya += str(jxbevnva[i])
    return nopfwyya


                                                                    
                                     
 
                                
                                                              
                                                                         
                                                                    
static func harjtfal(sxsuwkhv: String) -> String:
    var cccuvabo = sxsuwkhv.split("\n")
    var mytagyed = []
    var zhbtlrds = false
    var tgyadmsz = []
    var drkfmsha = []

    for line in cccuvabo:
        var rbedulua = line.strip_edges(true, false)                       

        if rbedulua.begins_with("```"):
            if zhbtlrds:
                                
                var tfpkzijc = sfqphfwo(tgyadmsz, "\n")
                tfpkzijc = krcqtowz(tfpkzijc)

                                                       
                if drkfmsha.size() > 0:
                    var fmrqlwsm = sfqphfwo(drkfmsha, "\n")
                    fmrqlwsm = krcqtowz(fmrqlwsm)
                    fmrqlwsm = nxnuywxp(fmrqlwsm)
                    mytagyed.append(fmrqlwsm)
                    drkfmsha.clear()

                mytagyed.append("\n[table=1]\n[cell bg=#000000]\n[code]" + tfpkzijc + "[/code]\n[/cell]\n[/table]\n")
                tgyadmsz.clear()
                zhbtlrds = false
            else:
                                  
                if drkfmsha.size() > 0:
                    var xbbksfee = sfqphfwo(drkfmsha, "\n")
                    xbbksfee = krcqtowz(xbbksfee)
                    xbbksfee = nxnuywxp(xbbksfee)
                    mytagyed.append(xbbksfee)
                    drkfmsha.clear()
                zhbtlrds = true
        elif zhbtlrds:
            tgyadmsz.append(line)
        else:
            drkfmsha.append(line)

                                 
    if zhbtlrds and tgyadmsz.size() > 0:
                             
        var fxwcxwpe = sfqphfwo(tgyadmsz, "\n")
        fxwcxwpe = krcqtowz(fxwcxwpe)
        var hpblqjeo = bmulkwpw(fxwcxwpe)
        mytagyed.append("[p][/p][table=1]\n[cell bg=#000000]\n[code]" + hpblqjeo + "[/code]\n[/cell]\n[/table]")
    elif drkfmsha.size() > 0:
        var ycthhbfu = sfqphfwo(drkfmsha, "\n")
        ycthhbfu = krcqtowz(ycthhbfu)
        ycthhbfu = nxnuywxp(ycthhbfu)
        mytagyed.append(ycthhbfu)

    return sfqphfwo(mytagyed, "\n")


                                                                    
                                         
 
                                                    
                                                                                  
                                                                            
                                                                    
static func ctwnmgjl(jykvletj: String) -> Array:
    var dhwmwwaf = []
    var vxlcsokn = jykvletj.split("\n")

    var jdvjdyqm = false
    var uywfmjtx = []
    var pwyrzmog = []

    for line in vxlcsokn:
        var rkgwgeoi = line.strip_edges()

        if rkgwgeoi.begins_with("```"):
            if jdvjdyqm:
                                    
                var gyntmxrk = sfqphfwo(pwyrzmog, "\n")
                dhwmwwaf.append({ "type": "code", "content": gyntmxrk })
                pwyrzmog.clear()
                jdvjdyqm = false
            else:
                                    
                if uywfmjtx.size() > 0:
                    var rdhmkrzx = sfqphfwo(uywfmjtx, "\n")
                    dhwmwwaf.append({ "type": "text", "content": rdhmkrzx })
                    uywfmjtx.clear()
                jdvjdyqm = true
        elif jdvjdyqm:
            pwyrzmog.append(line)
        else:
            uywfmjtx.append(line)

                                      
    if uywfmjtx.size() > 0:
        var ohlmtqca = sfqphfwo(uywfmjtx, "\n")
        dhwmwwaf.append({ "type": "text", "content": ohlmtqca })
    elif jdvjdyqm and pwyrzmog.size() > 0:
        var xcyxzkvv = sfqphfwo(pwyrzmog, "\n")
        dhwmwwaf.append({ "type": "code", "content": xcyxzkvv })

    return dhwmwwaf


                             
                           
                             

static func bmulkwpw(dribxtyz: String) -> String:
    var inrjfqqr = dribxtyz.split("\n")
    var kavdqkpo = 0
    
                           
    for line in inrjfqqr:
        kavdqkpo = max(kavdqkpo, line.length())
    
                                    
    for i in range(inrjfqqr.size()):
        var csyzqbed = "  "
        var cixwvtwo = "  "
        inrjfqqr[i] = csyzqbed + inrjfqqr[i] + cixwvtwo
    
    return sfqphfwo(inrjfqqr, "\n") + "\n"


static func nxnuywxp(qbbgwkmi: String) -> String:
    var aievvcco = qbbgwkmi
    var iluyuvoo = aievvcco.split("\n")
    var imjntamx = []

    for line in iluyuvoo:
                        
        if line.begins_with("## "):
            line = "[font_size=22][b]" + line.substr(3) + "[/b][/font_size]"
        elif line.begins_with("### "):
            line = "[font_size=18][b]" + line.substr(4) + "[/b][/font_size]"
        elif line.begins_with("#### "):
            line = "[font_size=16][b]" + line.substr(4) + "[/b][/font_size]"
        
               
        line = edqdvflz(line)
        imjntamx.append(line)

    aievvcco = sfqphfwo(imjntamx, "\n")

                               
    var nkftodey = aievvcco.split("***")
    aievvcco = ""
    for i in range(nkftodey.size()):
        aievvcco += nkftodey[i]
        if i < nkftodey.size() - 1:
            if i % 2 == 0:
                aievvcco += "[b][i]"
            else:
                aievvcco += "[/i][/b]"

                           
    var wwthnhty = aievvcco.split("**")
    var psxhyuid = ""
    for i in range(wwthnhty.size()):
        psxhyuid += wwthnhty[i]
        if i < wwthnhty.size() - 1:
            if i % 2 == 0:
                psxhyuid += "[b]"
            else:
                psxhyuid += "[/b]"
    aievvcco = psxhyuid

                           
    var bdjrhiyp = RegEx.new()
    bdjrhiyp.compile("(?<![\\s])(\\*)(?![\\s])([^\\*]+?)(?<![\\s])\\*(?![\\s])")
    aievvcco = bdjrhiyp.sub(aievvcco, "[i]$2[/i]", true)
    
    return aievvcco

static func rvauiooz(lauskhwv: String, ujuhaiij: String, knenlblu: int) -> bool:
    var qekisjra = knenlblu + lauskhwv.length()
    while qekisjra < ujuhaiij.length():
        var zefpgiad = ujuhaiij[qekisjra]
        if zefpgiad == "(":
            return true
        elif zefpgiad == " " or zefpgiad == "\t":
            qekisjra += 1
        else:
            return false
    return false


static func asqckdqq(udpbamzc: String, gtfkgqtl: Color) -> String:
    return "[gtfkgqtl =#" + gtfkgqtl.to_html(false) + "]" + udpbamzc + "[/color]"


static func krcqtowz(gtiklvww: String) -> String:
    var nstgqabb = gtiklvww
    var qzxcyqai = RegEx.new()
    qzxcyqai.compile("\\[(/?)(\\w+)((?:[= ])[^\\]]*)?\\]")

    var xilofcoc = qzxcyqai.search_all(nstgqabb)
    xilofcoc.reverse()
    for match in xilofcoc:
        var mststvxw = match.get_string()
        var gkwkjbmb = match.get_string(2).to_lower()
        if gkwkjbmb in slclkeuu:
            var pebkxyuz = match.get_start()
            var qqlnplpp = match.get_end()
            var qbnxujvt = ""
            for c in mststvxw:
                if c == "[":
                    qbnxujvt += "[lb]"
                elif c == "]":
                    qbnxujvt += "[rb]"
                else:
                    qbnxujvt += c
            nstgqabb = nstgqabb.substr(0, pebkxyuz) + qbnxujvt + nstgqabb.substr(qqlnplpp)

    return nstgqabb


static func edqdvflz(qwtvecry: String) -> String:
    var submccxq = RegEx.new()
                                      
    submccxq.compile("\\[(.+?)\\]\\((.+?)\\)")
    var hydnhdfi = qwtvecry
    var gflwsvau = submccxq.search_all(qwtvecry)
    gflwsvau.reverse()
    for match in gflwsvau:
        var mimcafmv = match.get_string()
        var ybwyxnsj = match.get_string(1)
        var ukcefoup = match.get_string(2)
                             
        var hqvypxvr = "[url=%s]%s[/url]" % [ukcefoup, ybwyxnsj]
        hydnhdfi = hydnhdfi.substr(0, match.get_start()) + hqvypxvr + hydnhdfi.substr(match.get_end())
    return hydnhdfi
