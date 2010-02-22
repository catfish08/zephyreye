
'*******************************************************************************
  'Compiler directives
$regfile = "m128def.dat"
$crystal = 8000000
$hwstack = 256
$swstack = 256
$framesize = 256
'*******************************************************************************

'*******************************************************************************
  'Configure Communications
$baud = 38400
$baud1 = 4800

Echo Off

Open "COM1:" For Binary As #1                               'Zigbee
Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0
Open "COM2:" For Binary As #2                               'GPS
Config Com2 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0

Config Serialin = Buffered , Size = 128 , Bytematch = 42
Config Serialin1 = Buffered , Size = 128 , Bytematch = All
'Config Serialout1 = Buffered , Size = 128
Enable Interrupts
'*******************************************************************************

'*******************************************************************************
  'Alias
  'General
Led Alias Portd.5
  'LCD
Lcd_cs Alias Porte.5
Lcd_sck Alias Porte.3
Lcd_dio Alias Porte.4
Lcd_rst Alias Porte.6
Lcd_ven Alias Porte.7
  'Tact Switches
Sw_up Alias Pinb.1
Sw_left Alias Pinb.3
Sw_right Alias Pinb.2
Sw_down Alias Pinb.0
Sw_in Alias Pinb.5
Sw_out Alias Pinb.6
Sw_onoff Alias Pinb.7
Sw_ok Alias Pinb.4
  'GPS
Gps_en Alias Portd.4
  'ZigBee
Zig_slp Alias Porte.2
'*******************************************************************************

'*******************************************************************************
  'Data Direction Registers
  'General
Config Led = Output
  'LCD
Config Lcd_cs = Output
Config Lcd_sck = Output
Config Lcd_dio = Output
Config Lcd_rst = Output
Config Lcd_ven = Output
  'Switches
Config Portb = Input
  'GPS
Config Gps_en = Output
  'ZigBee
Config Zig_slp = Output
'*******************************************************************************

'*******************************************************************************
  'Pullups/Initial States
  'LCD
Lcd_ven = 1
Lcd_sck = 1
Lcd_rst = 0
Waitms 1
Lcd_rst = 1
  'Switches
Portb = &HFF                                                'Enable pullups on all tact switches
  'ZigBee
Zig_slp = 1
  'Give it a sec
Waitms 20
'*******************************************************************************

'*******************************************************************************
  'Configure Display
$lib "LCD-epson.LBX"                                        'Library for LCD screen
Config Graphlcd = Color , Controlport = Porte , Cs = 5 , Rs = 6 , Scl = 3 , Sda = 4
'*******************************************************************************

'*******************************************************************************
  'Constants
  'MP3
Const Vs_rd = &B0000_0011                                   'Read command
Const Vs_wr = &B0000_0010                                   'Write command
Const Start_vol = &H24
  'Colors
Const Blue = &B00000011                                     'Predefined color constants for the LCD screen
Const Yellow = &B11111100
Const Red = &B11100000
Const Green = &B00011100
Const Black = &B00000000
Const White = &B11111111
Const Brightgreen = &B00111110
Const Darkgreen = &B00010100
Const Darkred = &B10100000
Const Darkblue = &B00000010
Const Brightblue = &B00011111
Const Orange = &B11111000
Const Bg_blue = &H2A
Const Gray = &HDB
Const Dark_gray = &B10010010
  'LCD Configs
Const Dison = &HAF                                          'Constants used in setting up the display
Const Disoff = &HAE
Const Disnor = &HA6
Const Disinv = &HA7
Const Comscn = &HBB
Const Disctl = &HCA
Const Slpin = &H95
Const Slpout = &H94
Const Paset = &H75
Const Caset = &H15
Const Datctl = &HBC
Const Rgbset8 = &HCE
Const Ramwr = &H5C
Const Ramrd = &H5D
Const Ptlin = &HA8
Const Ptlout = &HA9
Const Rmwin = &HE0
Const Rmwout = &HEE
Const Ascset = &HAA
Const Scstart = &HAB
Const Oscon = &HD1
Const Oscoff = &HD2
Const Pwrctr = &H20
Const Volctr = &H81
Const Volup = &HD6
Const Voldown = &HD7
Const Tmpgrd = &H82
Const Epctin = &HCD
Const Epcout = &HCC
Const Epmwr = &HFC
Const Epmrd = &HFD
Const Epsrrd1 = &H7C
Const Epsrrd2 = &H7D
Const No_op = &H25
  'General
Const True = 1
Const False = 0
  'Menus
Const Mnu_pickdir = 1
Const Mnu_options = 2
Const Mnu_playlist = 3
  'System
Const State_on = 1
Const State_off = 2
  'Radar Drawing
Const North = 0
Const Nneast = 1
Const Neast = 2
Const Eneast = 3
Const East = 4
Const Eseast = 5
Const Seast = 6
Const Sseast = 7
Const South = 8
Const Sswest = 9
Const Swest = 10
Const Wswest = 11
Const West = 12
Const Wnwest = 13
Const Nwest = 14
Const Nnwest = 15
  'GPS
Const Earth_radius = 6378137.0
Const F = 0.0033528106647474807198455286185206
Const E2 = 0.0066943799901413169961372335400483

'*******************************************************************************

'*******************************************************************************
  'Declare Subroutines
  'System
Declare Sub Mid_sleep()
Declare Sub Deep_sleep()
  'LCD
Declare Sub Shiftbits(byval Dab As Byte)
Declare Sub Put_pix()
Declare Sub Snd_data(byval Lcddata As Byte)
Declare Sub Snd_cmd(byval Lcdcmd As Byte)
Declare Sub Init_lcd()
Declare Sub Clr_scr(byval Bg As Byte )
Declare Sub Scr_off()
Declare Sub Scr_on()
Declare Sub Loadpic(byval Filename As String , Byval Startx As Byte , Byval Starty As Byte )
Declare Sub Draw_fort(byval X As Byte , Byval Y As Byte , Byval Color As Byte)
Declare Sub Draw_flag(byval X As Byte , Byval Y As Byte , Byval Color As Byte)
Declare Sub Draw_arrow(byval X As Byte , Byval Y As Byte , Byval Color As Byte , Byval Heading As Word)
  'Menus
Declare Sub Select_game()
Declare Sub Find_game()
Declare Sub Show_options()
Declare Sub Show_settings()
  'Games
Declare Sub Setup_capture_the_flag()
Declare Sub Setup_king_of_the_hill()
Declare Sub Setup_team_slayer()
Declare Sub Setup_tick_tactics()
Declare Sub Setup_elimination()
  'GPS
'Declare Sub Gps2ecef(lat As single , Lng As single)
Declare Sub Config_gps()
'*******************************************************************************

'*******************************************************************************
  'Dimension Variables
  'General
Dim B As Byte , B1 As Byte , B2 As Byte , B3 As Byte
Dim I As Integer , I1 As Integer , I2 As Integer
Dim Sng1 As Single , Sng2 As Single
Dim W1 As Word , W2 As Word
Dim Strs(12) As String * 25
Dim S1 As String * 20
Dim Astr As String * 100
Dim Astr_b(101) As Byte At Astr Overlay
Dim Bstr As String * 100
  'LCD
Dim X As Byte , Y As Byte , Color As Byte , J As Word
Dim Picfile As String * 12
Dim Picbytes(510) As Byte
Dim Arrow As String * 4
Dim Arrow_b(5) As Byte At Arrow Overlay
  'Menus
Dim Curmenu As Byte                                         'Currently selected menu
Dim Cur_sel As Byte                                         'Currently selected item in a menu
Dim Has_changed As Bit                                      '
  'Games
Dim My_x As Long
Dim My_y As Long
Dim My_heading As Word

Dim His_x As Long
Dim His_y As Long
Dim His_heading As Word

Dim Cur_x As Long
Dim Cur_y As Long
Dim Old_x As Byte
Dim Old_y As Byte

'Dim Teammate_lats(10) As Double
'Dim Teammate_longs(10) As Double
'Dim Teammate_headings(10) as word
'Dim Teammates_firing As Word

'Dim Enemy_lats(10) As Double
'Dim Enemy_longs(10) As Double
'Dim Enemy_headings(10) as word
'Dim Enemies_firing As Word

Dim Game_names(5) As String * 20
Dim Cur_game As Byte

'Dim Chi As Double
'Dim Ecef_x As Double
'Dim Ecef_y As Double
'Dim Alt As Double
'Dim Lat1 As Double
'Dim Lng1 As Double
'Dim D1 As Double

'*******************************************************************************
  'Timers
'Config Timer1 = Timer , Prescale = 1024
'On Timer1 Checkaction
'Enable Timer1
'Start Timer1

'*******************************************************************************
  'Initializations
  'LCD
Init_lcd
  'Game Names
Game_names(1) = "Capture the Flag"
Game_names(2) = "King of the Hill"
Game_names(3) = "Team Slayer"
Game_names(4) = "Tick Tactics"
Game_names(5) = "Elimination"
Const Capture_the_flag = 1
Const King_of_the_hill = 2
Const Team_slayer = 3
Const Tick_tactics = 4
Const Elimination = 5
'*******************************************************************************

'*******************************************************************************
'**************************** MAIN PROGRAM *************************************
'*******************************************************************************
Main:

Draw_arrow 64 , 64 , Green , North

Draw_flag 64 , 128 , Red
Draw_flag 64 , 5 , Green

Draw_fort 32 , 32 , Red
Draw_fort , 96 , 32 , Green


Gps_en = 1

'Config_gps

Clear Serialin
Clear Serialin1

'Do
'  If Ischarwaiting(#1) = 1 Then
'    B1 = Waitkey(#1)
'    Printbin #2 , B1
'    Toggle Led
'  End If
'  If _rs_bufcountr1 > 50 Then
'    Zig_slp = 0
'    Waitms 15
'    Do
'      B1 = Waitkey(#2)
'      Printbin #1 , B1
'      Toggle Led
'    Loop Until Ischarwaiting(#2) = 0
'    Led = 0
'    Waitms 15
'    Zig_slp = 1
'  End If

'  If Sw_onoff = 0 Then
'    Lcd_ven = 0
'    Gps_en = 0
'    Zig_slp = 0
'    Waitms 25
'    Goto &HFC00
'  End If
'Loop



Print #1 , "Test"
Dim New_gps_data As Bit
Dim New_remote_data As Bit
Dim Needs_redraw As Bit
Dim B4 As Byte

Setfont Color8x8

Do
  If New_gps_data = 1 Then
    Toggle Led
    Astr = ""
    B2 = 1
    Do
      B1 = Waitkey(#2)
      Astr_b(b2) = B1
      Incr B2
    Loop Until B1 = 42
    Astr_b(b2) = 0

    If Len(astr) > 10 And Instr(1 , Astr , "RMC") <> 0 Then
'      Print #1 , Astr
      Clear Serialin1
      B4 = Split(astr , Strs(1) , ",")

      If Strs(3) = "A" Then
        'Get Longitude
        If Strs(4) <> "" Then
          S1 = Left(strs(4) , 3)
          Sng1 = Val(s1)
          B2 = Len(s1) - 3
          S1 = Mid(strs(4) , 4 , B2)
          Sng2 = Val(s1)
          Sng1 = Sng1 * 78857.856
          Sng2 = Sng2 * 1314.2976
          Sng1 = Sng1 + Sng2
          My_x = Sng1
        Else
          My_x = 0
        End If

        'Get Latitude
        If Strs(6) <> "" Then
          S1 = Left(strs(6) , 2)
          Sng1 = Val(s1)
          B2 = Len(s1) - 2
          S1 = Mid(strs(6) , 3 , B2)
          Sng2 = Val(s1)
          Sng1 = Sng1 * 111044.736
          Sng2 = Sng2 * 1851.9648
          Sng1 = Sng1 + Sng2
          My_y = Sng1
        Else
          My_y = 0
        End If

        'Get Heading
        My_heading = Val(strs(9))
      Else
        My_x = 0
        My_y = 0
        My_heading = 0
      End If

      Zig_slp = 0
      Waitms 3
  '    Print #1 , My_x ; "," ; My_y ; "," ; My_heading ; ",*"
      Print #1 , Str(my_x) ; "," ; Str(my_y) ; "," ; Str(my_heading) ; ",*" ;
  '    Print #1 , Strs(6) ; "," ; Strs(4) ; "," ; Strs(9) ; ",*"
      Waitms 3
      Zig_slp = 1
      New_gps_data = 0
      Needs_redraw = 1
    Else
      If _rs_bufcountr1 < 50 Then New_gps_data = 0
    End If
  End If

  If New_remote_data = 1 Then
    Toggle Led
    Astr = ""
    B2 = 1
    Do
      B1 = Waitkey(#1)
      Astr_b(b2) = B1
      Incr B2
    Loop Until B1 = 42
    Astr_b(b2) = 0
    Clear Serialin

    B4 = Split(astr , Strs(1) , ",")

    His_x = Val(strs(1))
    His_y = Val(strs(2))
    His_heading = Val(strs(3))

    Lcdat 2 , 1 , Str(his_x) + "  " , Orange , White

    New_remote_data = 0
  End If

  If Needs_redraw = 1 Then

    'Retrace range lines
'    Circle(64 , 64) , 16 , Dark_gray
'    Circle(64 , 64) , 32 , Dark_gray
'    Circle(64 , 64) , 48 , Dark_gray
'    Circle(64 , 64) , 63 , Dark_gray

    'Clear your marker
    Box(58 , 58) -(70 , 70) , White

    'Clear his marker
    If Old_x <> 0 Then
      B1 = Old_x + 6                                        'Make a 10x10 box to ensure complete clearage
      B2 = Old_y + 6
      X = Old_x - 6
      Y = Old_y - 6
      Box(y , X) -(b2 , B1) , White
    End If

    'Put out a new marker for him
    Cur_x = His_x - My_x
    Cur_y = His_y - My_y

    Cur_x = Cur_x * -1
    Cur_y = Cur_y * -1

    Cur_x = Cur_x + 64
    Cur_y = Cur_y + 64

    Lcdat 2 , 1 , Str(my_x) + "  " , Orange , White
    Lcdat 10 , 1 , Str(my_y) + "  " , Blue , White

    If Cur_x > 125 Then Cur_x = 125
    If Cur_y > 125 Then Cur_y = 125
    If Cur_x < 5 Then Cur_x = 5
    If Cur_y < 5 Then Cur_y = 5

    X = Cur_x
    Y = Cur_y

    Lcdat 112 , 1 , Str(his_x) + "  " , Orange , White
    Lcdat 120 , 1 , Str(his_y) + "  " , Blue , White

    Old_x = X
    Old_y = Y

    'New marker for him
    If His_x <> 0 Then
      Draw_arrow Y , X , Red , His_heading
    End If

    'New marker for you
    Draw_arrow 64 , 64 , Green , My_heading

    'Retrace range lines (again)
    Circle(64 , 64) , 16 , Dark_gray
    Circle(64 , 64) , 32 , Dark_gray
    Circle(64 , 64) , 48 , Dark_gray
    Circle(64 , 64) , 63 , Dark_gray

    New_remote_data = 0
    Needs_redraw = 0
  End If

  If Sw_onoff = 0 Then
    Lcd_ven = 0
    Gps_en = 0
    Zig_slp = 0
    Waitms 25
    Goto &HFC00
  End If
  End_of_loop:
Loop

'Zig_slp = 0
'Waitms 3
'Print #1 , "GPS Test"
'Waitms 3
'Zig_slp = 1


'Do
'  If Ischarwaiting(#1) = 1 Then
'    B1 = Waitkey(#1)
'    Printbin #2 , B1
'    Toggle Led
'  End If
'  If _rs_bufcountr1 > 50 Then
'    Zig_slp = 0
'    Waitms 15
'    Do
'      B1 = Waitkey(#2)
'      Printbin #1 , B1
'      Toggle Led
'    Loop Until Ischarwaiting(#2) = 0
'    Led = 0
'    Waitms 15
'    Zig_slp = 1
'  End If

'  If Sw_onoff = 0 Then
'    Lcd_ven = 0
'    Gps_en = 0
'    Zig_slp = 0
'    Waitms 25
'    Goto &HFC00
'  End If
'Loop


'Display Picture
'W1 = 0
'For Y = 2 To 80
'  For X = 0 To 127
'    B1 = Lookup(w1 , Splash)
'    Pset X , Y , B1
'    Incr W1
'  Next X
'Next Y

'Setfont Color8x8

'Lcdat 88 , 20 , "Start Game" , Black , Gray
'Lcdat 96 , 20 , "Join Game" , Black , White
'Lcdat 104 , 20 , "Options" , Black , White
'Lcdat 112 , 20 , "Settings" , Black , White

'Cur_sel = 1
'Do
'  If Sw_up = 0 Then
'    If Cur_sel <= 1 Then Cur_sel = 4 Else Decr Cur_sel
'    Has_changed = 1
'    Waitms 250
'  Elseif Sw_down = 0 Then
'    If Cur_sel >= 4 Then Cur_sel = 1 Else Incr Cur_sel
'    Has_changed = 1
'    Waitms 250
'  Elseif Sw_ok = 0 Then
'    Waitms 250
'    Exit Do
'  End If

'  If Has_changed = 1 Then
'    Select Case Cur_sel
'      Case 1
'        Lcdat 88 , 20 , "Start Game" , Black , Gray
'        Lcdat 96 , 20 , "Join Game" , Black , White
'        Lcdat 104 , 20 , "Options" , Black , White
'        Lcdat 112 , 20 , "Settings" , Black , White
'      Case 2
'        Lcdat 88 , 20 , "Start Game" , Black , White
'        Lcdat 96 , 20 , "Join Game" , Black , Gray
'        Lcdat 104 , 20 , "Options" , Black , White
'        Lcdat 112 , 20 , "Settings" , Black , White
'      Case 3
'        Lcdat 88 , 20 , "Start Game" , Black , White
'        Lcdat 96 , 20 , "Join Game" , Black , White
'        Lcdat 104 , 20 , "Options" , Black , Gray
'        Lcdat 112 , 20 , "Settings" , Black , White
'      Case 4
'        Lcdat 88 , 20 , "Start Game" , Black , White
'        Lcdat 96 , 20 , "Join Game" , Black , White
'        Lcdat 104 , 20 , "Options" , Black , White
'        Lcdat 112 , 20 , "Settings" , Black , Gray
'    End Select
'    Has_changed = 0
'  End If
'Loop

'Select Case Cur_sel
'  Case 1                                                    'Start Game
'    Select_game
'  Case 2                                                    'Join Game
'    Find_game
'  Case 3                                                    'Options
'    Show_options
'  Case 4                                                    'Settings
'    Show_settings
'End Select

'Bitwait Sw_ok , Reset

'Cls

'Lcdat 3 , 1 , "500" , Black , White
'Lcdat 11 , 1 , "yds" , Black , White

'Lcdat 114 , 1 , "182" , Black , White
'Lcdat 122 , 1 , "rnds" , Black , White

'Lcdat 118 , 98 , "1043a" , Black , White

'Circle(64 , 64) , 16 , Black
'Circle(64 , 64) , 32 , Black
'Circle(64 , 64) , 48 , Black
'Circle(64 , 64) , 63 , Black

'Lcdat 3 , 105 , "A:4" , Green , White
'Lcdat 11 , 105 , "B:3" , Red , White

'Circle(64 , 64) , 1 , Green
'Circle(64 , 64) , 2 , Green
'Pset 64 , 64 , Green
'Circle(85 , 24) , 1 , Red
'Pset 85 , 24 , Red

Draw_arrow 70 , 70 , Green , North

Draw_arrow 64 , 32 , Red , South

'Circle(56 , 59) , 1 , Green
'Pset 56 , 59 , Green

Do
'  Toggle Led
  Waitms 500
Loop

'*******************************************************************************
'***************************** MENU SUBROUTINES ********************************
'*******************************************************************************
Sub Select_game()
  Cls
  Lcdat 8 , 20 , "Select Game:" , Black , White

  Cur_sel = 1
  Has_changed = 1
  Do
    If Sw_up = 0 Then
      If Cur_sel <= 1 Then Cur_sel = 5 Else Decr Cur_sel
      Has_changed = 1
      Waitms 250
    Elseif Sw_down = 0 Then
      If Cur_sel >= 5 Then Cur_sel = 1 Else Incr Cur_sel
      Has_changed = 1
      Waitms 250
    Elseif Sw_ok = 0 Then
      Waitms 250
      Exit Do
    End If

    If Has_changed = 1 Then
      Y = 20
      X = 2
      For B1 = 1 To 5
        If Cur_sel = B1 Then
          Lcdat Y , X , Game_names(b1) , Black , Gray
        Else
          Lcdat Y , X , Game_names(b1) , Black , White
        End If
        Y = Y + 8
      Next B1
    End If
  Loop

  Select Case Cur_sel
    Case Capture_the_flag
'      Setup_capture_the_flag
    Case King_of_the_hill
'      Setup_king_of_the_hill
    Case Team_slayer
'      Setup_team_slayer
    Case Tick_tactics
'      Setup_tick_tactics
    Case Elimination
'      Setup_elimination
  End Select
End Sub
'*******************************************************************************

'*******************************************************************************
Sub Find_game()

End Sub
'*******************************************************************************

'*******************************************************************************
Sub Show_options()

End Sub
'*******************************************************************************

'*******************************************************************************
Sub Show_settings()

End Sub
'*******************************************************************************

'*******************************************************************************
'***************************** GAME SUBROUTINES ********************************
'*******************************************************************************
Sub Setup_capture_the_flag()
  Cls

  Lcdat 2 , 2 , Game_names(capture_the_flag) , Black , White

  Lcdat 20 , 20 , "STEP 1:" , White , Black

'  Lcdat 20,

End Sub
'*******************************************************************************

'*******************************************************************************
Sub Setup_king_of_the_hill()

End Sub
'*******************************************************************************

'*******************************************************************************
Sub Setup_team_slayer()

End Sub
'*******************************************************************************

'*******************************************************************************
Sub Setup_tick_tactics()

End Sub
'*******************************************************************************

'*******************************************************************************
Sub Setup_elimination()

End Sub
'*******************************************************************************

'*******************************************************************************
'***************************** LCD SUBROUTINES *********************************
'*******************************************************************************
Sub Scr_on()
'  Snd_cmd Dison
  Lcd_ven = 1
End Sub
'*******************************************************************************

'*******************************************************************************
Sub Scr_off()
'  Cs = 0
'  Waitus 1
'  Snd_cmd Slpin
'  Waitus 1
'  Snd_cmd Pwrctr
'  Snd_data &H00

'  Snd_cmd Disctl
'  Snd_data &H03
'  Snd_data 32
'  Snd_data 12
'  Snd_data &H00
'  Waitus 1
'  Snd_cmd Disoff
'  Waitus 1
'  Cs = 1

  Lcd_ven = 0
End Sub
'*******************************************************************************

'*******************************************************************************
Sub Shiftbits(byval Dab As Byte)
   Lcd_sck = 0
   Lcd_dio = Dab.7
   Lcd_sck = 1
   Lcd_sck = 0
   Lcd_dio = Dab.6
   Lcd_sck = 1
   Lcd_sck = 0
   Lcd_dio = Dab.5
   Lcd_sck = 1
   Lcd_sck = 0
   Lcd_dio = Dab.4
   Lcd_sck = 1
   Lcd_sck = 0
   Lcd_dio = Dab.3
   Lcd_sck = 1
   Lcd_sck = 0
   Lcd_dio = Dab.2
   Lcd_sck = 1
   Lcd_sck = 0
   Lcd_dio = Dab.1
   Lcd_sck = 1
   Lcd_sck = 0
   Lcd_dio = Dab.0
   Lcd_sck = 1
End Sub
'************************************************************

'*******************************************************************************
Sub Put_pix()
  Snd_cmd Paset
  Snd_data X
  Snd_data 131
  Snd_cmd Caset
  Snd_data Y
  Snd_data 131
  Snd_cmd Ramwr
  Snd_data Color
End Sub
'************************************************************

'*******************************************************************************
Sub Snd_data(byval Lcddata As Byte)
  Lcd_sck = 0
  Lcd_dio = 1                                               'Data = 1
  Lcd_sck = 1

  Shiftbits Lcddata
End Sub
'************************************************************

'*******************************************************************************
Sub Snd_cmd(byval Lcdcmd As Byte)
  Lcd_sck = 0
  Lcd_dio = 0                                               'Commands = 0
  Lcd_sck = 1

  Shiftbits Lcdcmd
End Sub
'*******************************************************************************

'************************************************************
'Sends initialization data to LCD screen
Sub Init_lcd()
   Lcd_cs = 0

   Waitms 10

   Snd_cmd Disctl
   Snd_data &H03
   Snd_data 32
   Snd_data 12
   Snd_data &H00

   Waitms 10

   Snd_cmd Comscn
   Snd_data &H01

   Snd_cmd Oscon
   Snd_cmd Slpout

   Snd_cmd Volctr
   Snd_data 5
   Snd_data &H01

   Snd_cmd Pwrctr
   Snd_data &H0F

   Waitms 100

   Snd_cmd Disinv

   Snd_cmd Datctl
   Snd_data &H00
   Snd_data 0
   Snd_data &H01
   Snd_data &H00

   Snd_cmd Rgbset8                                          'Set up the color pallette
   'RED
   Snd_data 0
   Snd_data 2
   Snd_data 4
   Snd_data 6
   Snd_data 8
   Snd_data 10
   Snd_data 12
   Snd_data 15
   'GREEN
   Snd_data 0
   Snd_data 2
   Snd_data 4
   Snd_data 6
   Snd_data 8
   Snd_data 10
   Snd_data 12
   Snd_data 15
   'BLUE
   Snd_data 0
   Snd_data 4
   Snd_data 9
   Snd_data 15

   Snd_cmd No_op

   Snd_cmd Paset
   Snd_data 2
   Snd_data 131

   Snd_cmd Caset
   Snd_data 0
   Snd_data 131

   Snd_cmd Ramwr

   Clr_scr 255

   Snd_cmd Dison

   Waitms 200

   For B = 0 To 140
     Snd_cmd Volup
     Waitms 2
   Next I
End Sub
'*******************************************************************************

'*******************************************************************************
Sub Clr_scr(byval Bg As Byte )
  'Clears the screen, giving it a background color of BG
  For I = 0 To 18000
    Snd_data Bg
  Next I
End Sub
'*******************************************************************************

'*******************************************************************************
Sub Loadpic(byval Picfile As String , Byval Startx As Byte , Byval Starty As Byte )
  'Dim some local variables
  Local Picwidth As Byte
  Local Picheight As Byte
  Local Curx As Byte , Cury As Byte
  Local Picmod As Byte
  Local Lp_b1 As Byte


  W1 = 0
  For Y = 1 To 128
  '  Y = 128 - B1
    For X = 1 To 128
      B1 = Lookup(w1 , Splash)
      Pset X , Y , B1
      Incr W1
    Next X
  Next Y
End Sub
'*******************************************************************************

'*******************************************************************************
Sub Draw_fort(byval X As Byte , Byval Y As Byte , Byval Color As Byte)
  Pset X , Y , Color
  Circle(x , Y) , 3 , Color
End Sub
'*******************************************************************************

'*******************************************************************************
Sub Draw_flag(byval X As Byte , Byval Y As Byte , Byval Color As Byte)
  Local X1 As Byte , X2 As Byte , Y1 As Byte , Y2 As Byte

  X1 = X
  Y1 = Y - 5
  X2 = X
  Y2 = Y
  Line(x1 , Y1) -(x2 , Y2) , Dark_gray

  Decr X1
  Incr Y1
  Pset X1 , Y1 , Color
  Incr Y1
  Pset X1 , Y1 , Color
  Decr X1
  Pset X1 , Y1 , Color
  Incr Y1
  Pset X1 , Y1 , Color
End Sub
'*******************************************************************************

'*******************************************************************************
Sub Draw_arrow(byval X As Byte , Byval Y As Byte , Byval Color As Byte , Byval Heading As Word)
  Local Da_b1 As Byte , X1 As Byte , X2 As Byte , Y1 As Byte , Y2 As Byte , Direction As Byte

  Direction = 0

  Select Case Heading
    Case Is < 11 : Direction = North
    Case Is < 33 : Direction = Nneast
    Case Is < 56 : Direction = Neast
    Case Is < 78 : Direction = Eneast
    Case Is < 101 : Direction = East
    Case Is < 123 : Direction = Eseast
    Case Is < 146 : Direction = Seast
    Case Is < 168 : Direction = Sseast
    Case Is < 191 : Direction = South
    Case Is < 213 : Direction = Sswest
    Case Is < 236 : Direction = Swest
    Case Is < 258 : Direction = Wswest
    Case Is < 281 : Direction = West
    Case Is < 303 : Direction = Wnwest
    Case Is < 326 : Direction = Nwest
    Case Is < 248 : Direction = Nnwest
    Case Is < 361 : Direction = North
    Case Else : Direction = North
  End Select

  Select Case Direction
    Case North
      X1 = X
      Y1 = Y
      X2 = X
      Y2 = Y + 5
      Line(x1 , Y1) -(x2 , Y2) , Color

      Decr X1
      Incr Y1
      Pset X1 , Y1 , Color
      Decr X1
      Incr Y1
      Pset X1 , Y1 , Color

      X1 = X
      Y1 = Y
      Incr X1
      Incr Y1
      Pset X1 , Y1 , Color
      Incr X1
      Incr Y1
      Pset X1 , Y1 , Color
    Case Nneast
      X1 = X
      Y1 = Y
      X2 = X - 4
      Y2 = Y + 5
      Line(x1 , Y1) -(x2 , Y2) , Color

      Decr X1
      Pset X1 , Y1 , Color
      Decr X1
      Pset X1 , Y1 , Color

      X1 = X
      Y1 = Y
      Incr Y1
      Pset X1 , Y1 , Color
      Incr Y1
      Pset X1 , Y1 , Color
    Case Neast
      X1 = X
      Y1 = Y
      X2 = X - 4
      Y2 = Y + 4
      Line(x1 , Y1) -(x2 , Y2) , Color

      Decr X1
      Pset X1 , Y1 , Color
      Decr X1
      Pset X1 , Y1 , Color

      X1 = X
      Y1 = Y
      Incr Y1
      Pset X1 , Y1 , Color
      Incr Y1
      Pset X1 , Y1 , Color
    Case Eneast
      X1 = X
      Y1 = Y
      X2 = X - 5
      Y2 = Y + 4
      Line(x2 , Y2) -(x1 , Y1) , Color

      Decr X1
      Pset X1 , Y1 , Color
      Decr X1
      Pset X1 , Y1 , Color

      X1 = X
      Y1 = Y
      Incr Y1
      Pset X1 , Y1 , Color
      Incr Y1
      Pset X1 , Y1 , Color
    Case East
      X1 = X
      Y1 = Y
      X2 = X - 4
      Y2 = Y
      Line(x1 , Y1) -(x2 , Y2) , Color

      Decr Y1
      Decr X1
      Pset X1 , Y1 , Color
      Decr Y1
      Decr X1
      Pset X1 , Y1 , Color

      X1 = X
      Y1 = Y
      Incr Y1
      Decr X1
      Pset X1 , Y1 , Color
      Incr Y1
      Decr X1
      Pset X1 , Y1 , Color
    Case Eseast
      X1 = X
      Y1 = Y
      X2 = X - 5
      Y2 = Y - 4
      Line(x2 , Y2) -(x1 , Y1) , Color

      Decr Y1
      Pset X1 , Y1 , Color
      Decr Y1
      Pset X1 , Y1 , Color

      X1 = X
      Y1 = Y
      Decr X1
      Pset X1 , Y1 , Color
      Decr X1
      Pset X1 , Y1 , Color
    Case Seast
      X1 = X
      Y1 = Y
      X2 = X - 4
      Y2 = Y - 4
      Line(x2 , Y2) -(x1 , Y1) , Color

      Decr Y1
      Pset X1 , Y1 , Color
      Decr Y1
      Pset X1 , Y1 , Color

      X1 = X
      Y1 = Y
      Decr X1
      Pset X1 , Y1 , Color
      Decr X1
      Pset X1 , Y1 , Color
    Case Sseast
      X1 = X
      Y1 = Y
      X2 = X - 4
      Y2 = Y - 5
      Line(x2 , Y2) -(x1 , Y1) , Color

      Decr Y1
      Pset X1 , Y1 , Color
      Decr Y1
      Pset X1 , Y1 , Color

      X1 = X
      Y1 = Y
      Decr X1
      Pset X1 , Y1 , Color
      Decr X1
      Pset X1 , Y1 , Color
    Case South
      X1 = X
      Y1 = Y
      X2 = X
      Y2 = Y - 5
      Line(x1 , Y1) -(x2 , Y2) , Color

      Decr X1
      Decr Y1
      Pset X1 , Y1 , Color
      Decr X1
      Decr Y1
      Pset X1 , Y1 , Color

      X1 = X
      Y1 = Y
      Incr X1
      Decr Y1
      Pset X1 , Y1 , Color
      Incr X1
      Decr Y1
      Pset X1 , Y1 , Color
    Case Sswest
      X1 = X
      Y1 = Y
      X2 = X + 4
      Y2 = Y - 5
      Line(x2 , Y2) -(x1 , Y1) , Color

      Incr X1
      Pset X1 , Y1 , Color
      Incr X1
      Pset X1 , Y1 , Color

      X1 = X
      Y1 = Y
      Decr Y1
      Pset X1 , Y1 , Color
      Decr Y1
      Pset X1 , Y1 , Color
    Case Swest
      X1 = X
      Y1 = Y
      X2 = X + 4
      Y2 = Y - 4
      Line(x2 , Y2) -(x1 , Y1) , Color

      Incr X1
      Pset X1 , Y1 , Color
      Incr X1
      Pset X1 , Y1 , Color

      X1 = X
      Y1 = Y
      Decr Y1
      Pset X1 , Y1 , Color
      Decr Y1
      Pset X1 , Y1 , Color
    Case Wswest
      X1 = X
      Y1 = Y
      X2 = X + 5
      Y2 = Y - 4
      Line(x2 , Y2) -(x1 , Y1) , Color

      Incr X1
      Pset X1 , Y1 , Color
      Incr X1
      Pset X1 , Y1 , Color

      X1 = X
      Y1 = Y
      Decr Y1
      Pset X1 , Y1 , Color
      Decr Y1
      Pset X1 , Y1 , Color
    Case West
      X1 = X
      Y1 = Y
      X2 = X + 4
      Y2 = Y
      Line(x1 , Y1) -(x2 , Y2) , Color

      Decr Y1
      Incr X1
      Pset X1 , Y1 , Color
      Decr Y1
      Incr X1
      Pset X1 , Y1 , Color

      X1 = X
      Y1 = Y
      Incr Y1
      Incr X1
      Pset X1 , Y1 , Color
      Incr Y1
      Incr X1
      Pset X1 , Y1 , Color
    Case Wnwest
      X1 = X
      Y1 = Y
      X2 = X + 5
      Y2 = Y + 4
      Line(x2 , Y2) -(x1 , Y1) , Color

      Incr X1
      Pset X1 , Y1 , Color
      Incr X1
      Pset X1 , Y1 , Color

      X1 = X
      Y1 = Y
      Incr Y1
      Pset X1 , Y1 , Color
      Incr Y1
      Pset X1 , Y1 , Color
    Case Nwest
      X1 = X
      Y1 = Y
      X2 = X + 4
      Y2 = Y + 4
      Line(x2 , Y2) -(x1 , Y1) , Color

      Incr X1
      Pset X1 , Y1 , Color
      Incr X1
      Pset X1 , Y1 , Color

      X1 = X
      Y1 = Y
      Incr Y1
      Pset X1 , Y1 , Color
      Incr Y1
      Pset X1 , Y1 , Color
    Case Nnwest
      X1 = X
      Y1 = Y
      X2 = X + 4
      Y2 = Y + 5
      Line(x2 , Y2) -(x1 , Y1) , Color

      Incr X1
      Pset X1 , Y1 , Color
      Incr X1
      Pset X1 , Y1 , Color

      X1 = X
      Y1 = Y
      Incr Y1
      Pset X1 , Y1 , Color
      Incr Y1
      Pset X1 , Y1 , Color
  End Select


'  X = X - 3
'  Y = Y - 3
'  Da_b3 = 0
'  For Da_b1 = 1 To 5
'    Incr Y
'    For Da_b2 = 1 To 5
'      Incr X
'      If Arrow.da_b3 = 1 Then Pset X , Y , Color
'    Next Da_b2
'    X = X - 5
'  Next

End Sub
'*******************************************************************************

Sub Config_gps()
  Baud1 = 4800
  Wait 3
'  Print #2 , "$PSRF100,1,9600,8,1,0*65" ;
'  Baud1 = 9600
  Waitms 100
  Print #2 , "$PSRF103,0,0,0,1*64" ;
  Waitms 100
  Print #2 , "$PSRF103,02,00,00,01*02" ;
  Waitms 100
  Print #2 , "$PSRF103,4,0,1,1*69" ;
  Waitms 100
End Sub

'Sub Gps2ecef(lat As Double , Lng As Double)
'  Local L_b1 As Byte

'  'Function [x , Y , Z] = Llh2xyztest(lat , Long , H)
'  '% Convert lat, long, height in WGS84 to ECEF X,Y,Z
'  'a = 6378137.0; % earth semimajor axis in meters
'  'f = 1/298.257223563; % reciprocal flattening
'  'e2 = 2*f -f^2; % eccentricity squared
'  'chi = sqrt(1-e2*(sin(lat)).^2);
'  'X = (a./chi +h).*cos(lat).*cos(long);
'  'Y = (a./chi +h).*cos(lat).*sin(long);
'  'Z = (a*(1-e2)./chi + h).*sin(lat);

'  If Alt = 0 Then
'    Alt = 1000
'  '    Print #2 , "$PSRF103,00,01,00,01*25"
'  '    Do
'  '    Loop Until New_gps_data = 1
'  '
'  '    Do
'  '      L_b1 = Inkey(#2)
'  '      Astr = Astr + Chr(l_b1)
'  '    Loop Until L_b1 = 42
'  '
'  '    L_b1 = Split(astr , Strs(1) , ",")
'  '    Alt = Val(strs(12))
'  '    If Alt = 0 Then Exit Sub
'  End If

'  Ecef_x = 0
'  Ecef_y = 0
'  Chi = 0
'  D1 = 0

'  Chi = Sin(lat)
'  Chi = Chi * Chi
'  Chi = E2 * Chi
'  Chi = 1 - Chi
'  Chi = Sqr(chi)

'  Ecef_x = Earth_radius / Chi
'  Ecef_x = Ecef_x + Alt
'  D1 = Cos(lat)
'  Ecef_x = Ecef_x * D1
'  Ecef_y = Ecef_x
'  D1 = Cos(lng)
'  Ecef_x = Ecef_x * D1
'  D1 = Sin(lng)
'  Ecef_y = Ecef_y * D1
'End Sub

'*******************************************************************************
'***************** INTERRUPT SERVICE ROUTINES **********************************
'*******************************************************************************
'Called from interrupt when the "*" character is found in the GPS stream
Serial1charmatch:
  New_gps_data = 1
Return
'*******************************************************************************

'*******************************************************************************
Serial0charmatch:
  New_remote_data = 1
Return
'*******************************************************************************

Serial1bytereceived:
  New_gps_data = 1
Return

'*******************************************************************************

'Extra include files - Fonts
'$include "color16x16.font"
$include "color8x8.font"
$include "smallfont.font"

$include "zephyreyepic.txt"