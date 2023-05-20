import This
import Graphics
import System
import Softwares

# - Global variables

var Software = This.Get_This()
var Window = This.Get_Window()
var Display_Text_Area = Graphics.Text_Area_Type()
var Keyboard = Graphics.Keyboard_Type() 
var Input_Text_Area = Graphics.Text_Area_Type()
var Input_String = ""

var Execute = true

# - Functions

def Set_Interface()
    Window.Set_Title("Berry")

    Window_Body = Window.Get_Body()
    Window_Body.Set_Flex_Flow(Graphics.Flex_Flow_Column)
    Window_Body.Set_Flex_Alignment(Graphics.Flex_Alignment_Space_Evenly, Graphics.Flex_Alignment_Center, Graphics.Flex_Alignment_Center)

    Keyboard.Create(Window_Body)
    Keyboard.Add_Flag(Graphics.Flag_Floating)
    Keyboard.Add_Flag(Graphics.Flag_Hidden)
    Keyboard.Add_Event(Software, Graphics.Event_Code_Ready)
    
    Input_Text_Area.Create(Window_Body)
    Input_Text_Area.Set_Width(Graphics.Get_Percentage(100))
    Input_Text_Area.Set_Placeholder_Text("> Enter command here")
    Input_Text_Area.Set_One_Line(true)
    Input_Text_Area.Add_Event(Software, Graphics.Event_Code_Focused)
    Input_Text_Area.Add_Event(Software, Graphics.Event_Code_Defocused)

    Display_Text_Area.Create(Window_Body)
    Display_Text_Area.Set_Flex_Grow(1)
    Display_Text_Area.Set_Width(Graphics.Get_Percentage(100))

end

def Execute_Instruction(Instruction)
    if Instruction.Get_Sender() == Graphics.Get_Pointer()
        Current_Target = Instruction.Graphics_Get_Current_Target()
        if Instruction.Graphics_Get_Code() == Graphics.Event_Code_Ready
            Input_String = Input_Text_Area.Get_Text()
            Input_Text_Area.Set_Text("")
        elif Instruction.Graphics_Get_Code() == Graphics.Event_Code_Focused
            Keyboard.Set_Text_Area(Input_Text_Area)
            Keyboard.Move_Foreground()
            Keyboard.Clear_Flag(Graphics.Flag_Hidden)
        elif Instruction.Graphics_Get_Code() == Graphics.Event_Code_Defocused
            Keyboard.Add_Flag(Graphics.Flag_Hidden)
            Keyboard.Remove_Text_Area()
        end
    elif Instruction.Get_Sender() == Softwares.Get_Pointer()
        if Instruction.Softwares_Get_Code() == Softwares.Event_Code_Close
            print("Closing")
            Execute = false
        end
    end
end

def Print(Message)
    if type(Message) != "string"
        Message = str(Message)
    end
    Display_Text_Area.Add_Text(Message)
end

def Print_Line(Message)
    Print(Message + "\n")
end

def Input(Message)
    #Input_Text_Area.Set_Placeholder_Text(Message)
    Input_String = ""

    Print(Message)

    while (Input_String == "") && Execute
        if This.Instruction_Available() > 0
            Execute_Instruction(This.Get_Instruction())
        end

        This.Delay(50)
    end

    Print_Line(Input_String)

    return Input_String
end

def ismult(msg)
    import string
    return string.split(msg, -5)[1] == '\'EOS\''
end

def multline(src, msg)
    if !ismult(msg)
        Print("Syntax error: " + msg)
        return
    end
    while Execute
        try
            src += '\n' + Input('>> ')
            return compile(src)
        except 'syntax_error' as e, m
            if !ismult(m)
                Print_Line("Syntax error : " + m)
                return
            end
        end
    end
end

def parse()
    var fun, src = Input('> ')
    try
        fun = compile('return (' + src + ')')
    except 'syntax_error' as e, m
        try
            fun = compile(src)
        except 'syntax_error' as e, m
            fun = multline(src, m)
        end
    end
    return fun
end

def run(fun)
    try
        var res = fun()
        if res Print(res) end
    except .. as e, m
        import debug
        Print_Line(e .. ': ' .. m)
        debug.traceback()
    end
end

def repl() 
    while Execute
        var fun = parse()
        if fun != nil
            run(fun)
        end
    end
end

# - Main program

Set_Interface()

while Execute
    Print_Line("Berry REPL")
    repl()
end