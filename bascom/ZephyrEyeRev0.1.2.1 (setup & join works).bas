
'(
      Filename : Zephyreye.bas
      Author : Brad Nelson
      Revision : 0.1.2
      Rev. Date : 29 October 2007
      Revision Reason : To Create At Least A Demo Of King Of The Hill Setup
')


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
Declare Sub Join_game()
Declare Sub Show_options()
Declare Sub Show_settings()
  'Game Setups
Declare Sub Setup_capture_the_flag()
Declare Sub Setup_king_of_the_hill()
Declare Sub Setup_team_slayer()
Declare Sub Setup_tick_tactics()
Declare Sub Setup_elimination()
Declare Sub Countdown(byval Countdown As Byte)
Declare Function Check_start_points() As Byte
  'Games
Declare Sub Capture_the_flag()
Declare Sub King_of_the_hill()
Declare Sub Team_slayer()
Declare Sub Tick_tactics()
Declare Sub Elimination()
  'GPS
'Declare Sub Gps2ecef(lat As single , Lng As single)
Declare Sub Config_gps()
Declare Sub Get_gps()
'*******************************************************************************

'*******************************************************************************
  'Dimension Variables
  'General
Dim B As Byte , B1 As Byte , B2 As Byte , B3 As Byte , B4 As Byte , B5 As Byte
Dim I As Integer , I1 As Integer , I2 As Integer
Dim Sng1 As Single , Sng2 As Single
Dim W1 As Word , W2 As Word
Dim Strs(16) As String * 25
Dim S1 As String * 20
Dim Astr As String * 120
Dim Astr_b(121) As Byte At Astr Overlay
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
Dim My_team As Byte

Dim Unit_name_e As Eram String * 10
Dim Unit_version_e As Eram String * 7

Dim Unit_name As String * 10
Dim Unit_version As String * 7

Dim His_x As Long
Dim His_y As Long
Dim His_heading As Word

Dim Cur_x As Long
Dim Cur_y As Long
Dim Old_x As Byte
Dim Old_y As Byte

Dim Friendly_x(10) As Long
Dim Friendly_y(10) As Long
Dim Friendly_headings(10) As Word
Dim Friendlies_firing As Word

Dim Enemy_x(10) As Long
Dim Enemy_y(10) As Long
Dim Enemy_headings(10) As Word
Dim Enemies_firing As Word

Dim Return_x As Long
Dim Return_y As Long
Dim Return_heading As Long
Dim Return_valid As Bit

Dim Game_names(5) As String * 20
Dim Cur_game As Byte

  'KING OF THE HILL
Dim Loc_radius As Byte                                      'Radius around locations
Dim View_friendly As Bit                                    'Determines if players can view friendly players
Dim View_enemy As Bit                                       'Determines if players can view enemy players
Dim Game_length As Word                                     'Contains game length in seconds
Dim Timeout_length As Word                                  'Contains timeout length in seconds
Dim Teama_start_loc_x As Long                               'X coordinate of Team A's starting location
Dim Teama_start_loc_y As Long                               'Y coordinate of Team A's starting location
Dim Teamb_start_loc_x As Long                               'X coordinate of Team B's starting location
Dim Teamb_start_loc_y As Long                               'Y coordinate of Team B's starting location
Dim Hill_loc_x As Long                                      'X coordinate of hill's location
Dim Hill_loc_y As Long                                      'Y coordinate of hill's location
Dim Teama_count As Byte                                     'Number of Team A players
Dim Teamb_count As Byte                                     'Number of Team B players


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
  'Unit Info
'Unit_name_e = "Proto2"
Unit_name = Unit_name_e
Unit_version = "V0.1.2"
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

Gps_en = 1

Clear Serialin
Clear Serialin1

Dim New_gps_data As Bit
Dim New_remote_data As Bit
Dim Needs_redraw As Bit


Cls
Setfont Color8x8

'Display Picture
W1 = 0
For Y = 2 To 80
  For X = 0 To 127
    B1 = Lookup(w1 , Splash)
    Pset X , Y , B1
    Incr W1
  Next X
Next Y

Setfont Color8x8

Lcdat 88 , 20 , "Start Game" , Black , Gray
Lcdat 96 , 20 , "Join Game" , Black , White
Lcdat 104 , 20 , "Options" , Black , White
Lcdat 112 , 20 , "Settings" , Black , White
Lcdat 120 , 20 , Unit_name , Gray , White

Cur_sel = 1
Do
  If Sw_up = 0 Then
    If Cur_sel <= 1 Then Cur_sel = 4 Else Decr Cur_sel
    Has_changed = 1
    Waitms 250
  Elseif Sw_down = 0 Then
    If Cur_sel >= 4 Then Cur_sel = 1 Else Incr Cur_sel
    Has_changed = 1
    Waitms 250
  Elseif Sw_ok = 0 Then
    Waitms 250
    Exit Do
  End If

  If Has_changed = 1 Then
    Select Case Cur_sel
      Case 1
        Lcdat 88 , 20 , "Start Game" , Black , Gray
        Lcdat 96 , 20 , "Join Game" , Black , White
        Lcdat 104 , 20 , "Options" , Black , White
        Lcdat 112 , 20 , "Settings" , Black , White
      Case 2
        Lcdat 88 , 20 , "Start Game" , Black , White
        Lcdat 96 , 20 , "Join Game" , Black , Gray
        Lcdat 104 , 20 , "Options" , Black , White
        Lcdat 112 , 20 , "Settings" , Black , White
      Case 3
        Lcdat 88 , 20 , "Start Game" , Black , White
        Lcdat 96 , 20 , "Join Game" , Black , White
        Lcdat 104 , 20 , "Options" , Black , Gray
        Lcdat 112 , 20 , "Settings" , Black , White
      Case 4
        Lcdat 88 , 20 , "Start Game" , Black , White
        Lcdat 96 , 20 , "Join Game" , Black , White
        Lcdat 104 , 20 , "Options" , Black , White
        Lcdat 112 , 20 , "Settings" , Black , Gray
    End Select
    Has_changed = 0
  End If
Loop

Select Case Cur_sel
  Case 1                                                    'Start Game
    Select_game
  Case 2                                                    'Join Game
    Join_game
  Case 3                                                    'Options
    Show_options
  Case 4                                                    'Settings
    Show_settings
End Select

'Bitwait Sw_ok , Reset

Cls

Lcdat 3 , 1 , "500" , Black , White
Lcdat 11 , 1 , "yds" , Black , White

Lcdat 114 , 1 , "182" , Black , White
Lcdat 122 , 1 , "rnds" , Black , White

Lcdat 118 , 98 , "1043a" , Black , White

Circle(64 , 64) , 16 , Black
Circle(64 , 64) , 32 , Black
Circle(64 , 64) , 48 , Black
Circle(64 , 64) , 63 , Black

Lcdat 3 , 105 , "A:4" , Green , White
Lcdat 11 , 105 , "B:3" , Red , White

Circle(64 , 64) , 1 , Green
Circle(64 , 64) , 2 , Green
Pset 64 , 64 , Green
Circle(85 , 24) , 1 , Red
Pset 85 , 24 , Red

Draw_arrow 70 , 70 , Green , North

Draw_arrow 64 , 32 , Red , South

Circle(56 , 59) , 1 , Green
Pset 56 , 59 , Green

Bitwait Sw_ok , Reset

Goto Main                                                   'Catch it in case the process gets loose



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
      Setup_king_of_the_hill
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
Sub Join_game()
  Dim Join As Bit
  Local Game_type As String * 10

  Cls

  'Print screen title
  Lcdat 2 , 0 , "    Find Game    " , White , Green
  Line(0 , 9) -(128 , 9) , Black

  Lcdat 19 , 2 , "Searching..." , Black , White

  Zig_slp = 0
  Do
    If New_remote_data = 1 Then                             'Unit_version + ":KOTH:" + Unit_name + "*" ;
'      Toggle Led
      New_remote_data = 0
      Astr = ""
      B2 = 1
      Do
        B1 = Waitkey(#1)
        Astr_b(b2) = B1
        Incr B2
      Loop Until B1 = 42
      Astr_b(b2) = 0


      Clear Serialin
      B5 = Split(astr , Strs(1) , ":")
      If Strs(1) = Unit_version Then                        'Found a compatible game
        Box(0 , 30) -(128 , 80) , White
        Lcdat 37 , 20 , "Game Found!" , Blue , White
        Game_type = Strs(2)
        S1 = "Name:" + Strs(3)
        Lcdat 46 , 2 , S1 , Black , White
        S1 = "Type:" + Game_type
        Lcdat 55 , 2 , S1 , Black , White

        Lcdat 64 , 2 , " Do you wish to" , Black , White    'Ask the player if he/she wants to join this game
        Lcdat 73 , 2 , "join this game?" , Black , White

        Lcdat 91 , 42 , "Join" , Red , White
        Join = 1
        Do
          If Sw_up = 0 Or Sw_down = 0 Then
            Toggle Join
            If Join = 0 Then
              Lcdat 91 , 42 , "Exit" , Red , White
            Else
              Lcdat 91 , 42 , "Join" , Red , White
            End If
            Waitms 300
          Elseif Sw_ok = 0 Then
            Bitwait Sw_ok , Set
            Waitms 50
            If Join = 1 Then Exit Do Else Exit Sub
          End If
        Loop

        'Select a team
        Lcdat 109 , 18 , "Which Team?" , Black , White
        Lcdat 118 , 36 , "Team A" , Red , White
        My_team = 0
        Do
          If Sw_up = 0 Or Sw_down = 0 Then
            Toggle My_team.0
            If My_team = 0 Then
              Lcdat 118 , 36 , "Team A" , Red , White
            Else
              Lcdat 118 , 36 , "Team B" , Red , White
            End If
            Waitms 300
          Elseif Sw_ok = 0 Then
            Bitwait Sw_ok , Set
            Waitms 50
            Exit Do
          End If
        Loop

        'Reply to unit broadcasting game to join
        If My_team.0 = 0 Then
          Print #1 , "A:" ; Unit_name ; ":*"
        Else
          Print #1 , "B:" ; Unit_name ; ":*"
        End If

        Cls
        Lcdat 60 , 2 , "  Waiting for" , Blue , White
        Lcdat 69 , 2 , " game to start!" , Blue , White

'Expect "START:[Loc_radius]:[View_friendly]:[View_enemy]:[Game_len]:[TO_len]:[AStrt_x]:[AStrt_y]:[BStrt_x]:[BStrt_y]:[Hill_x]:[Hill_y]:[TeamA_cnt]:[TeamB_cnt]:*"
'    or "CANCEL:*"
'Ex: START:10:1:0:1200:120:1234567:1234567:1234567:1234567:1234567:1234567:3:3:*

'V0.1.2:KOTH:Proto2:*
        Wait_for_start:
        Do
          If New_remote_data = 1 Then
'            Toggle Led
            New_remote_data = 0
            Astr = ""
            B2 = 1
            Do
              B1 = Waitkey(#1)
              Astr_b(b2) = B1
              Incr B2
            Loop Until B1 = 42
            Astr_b(b2) = 0
            B4 = Split(astr , Strs(1) , ":")
            Lcdat 100 , 1 , Strs(1) , Green , Black
            If Strs(1) = "START" Then
              Loc_radius = Val(strs(2))
              B1 = Val(strs(3))
              View_friendly = B1.0
              B1 = Val(strs(4))
              View_enemy = B1.0
              Game_length = Val(strs(5))
              Timeout_length = Val(strs(6))
              Teama_start_loc_x = Val(strs(7))
              Teama_start_loc_y = Val(strs(8))
              Teamb_start_loc_x = Val(strs(9))
              Teamb_start_loc_x = Val(strs(10))
              Hill_loc_x = Val(strs(11))
              Hill_loc_y = Val(strs(12))
              Teama_count = Val(strs(13))
              Teamb_count = Val(strs(14))

              Countdown 3

              Do
                Get_gps
                My_x = Return_x
                My_y = Return_y
              Loop Until Return_valid = 1

              Print #1 , Unit_name ; ":" ; My_x ; ":" ; My_y ; ":*"
              Do
                If New_remote_data = 1 Then
                  New_remote_data = 0
                  Astr = ""
                  B2 = 1
                  Do
                    B1 = Waitkey(#1)
                    Astr_b(b2) = B1
                    Incr B2
                  Loop Until B1 = 42
                  Astr_b(b2) = 0
                  B4 = Split(astr , Strs(1) , ":")
                End If
                Select Case Strs(1)
                  Case "GO"
                    Exit Do
                  Case "RESTART"
                    Goto Wait_for_start
                End Select
              Loop

              Select Case Game_type
                Case "CTF"
                Case "KOTH"
                  Goto Koth
                Case "TACT"
                Case "SLAYR"
                Case "ELIM"
              End Select
            Elseif Strs(1) = "CANCEL" Then
              Cls
              Lcdat 32 , 2 , "Game Canceled!" , Red , Yellow
              Wait 3
              Exit Sub
            End If
          End If
        Loop
        Goto Main
      End If
    End If
  Loop
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
'************************* GAME SETUP SUBROUTINES ******************************
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
  Dim Confirm As Bit

  Dim Teama_names(10) As String * 10                        'Team A player names
  Dim Teamb_names(10) As String * 10                        'Team B player names

  Cls

  'Print game name
  Lcdat 2 , 0 , "King of the Hill " , White , Green
  Line(0 , 9) -(128 , 9) , Black

  'Determine location radius
  Lcdat 12 , 2 , "Location Radius:" , Black , White
  Loc_radius = 10

  Lcdat 21 , 76 , "10 yds" , Red , White

  Do
    If Sw_up = 0 Then
      If Loc_radius < 50 Then Incr Loc_radius
      S1 = Str(loc_radius) + " yds "
      Lcdat 21 , 76 , S1 , Red , White
      Waitms 300
    Elseif Sw_down = 0 Then
      If Loc_radius > 5 Then Decr Loc_radius
      S1 = Str(loc_radius) + " yds "
      Lcdat 21 , 76 , S1 , Red , White
      Waitms 300
    Elseif Sw_ok = 0 Then
      Bitwait Sw_ok , Set
      Waitms 50
      Exit Do
    End If
  Loop

  'View friendlies?
  Lcdat 30 , 2 , "View Friendly?" , Black , White

  View_friendly = 1
  Lcdat 39 , 102 , "Yes" , Red , White
  Do
    If Sw_up = 0 Or Sw_down = 0 Then
      Toggle View_friendly
      If View_friendly = 0 Then
        Lcdat 39 , 102 , "No " , Red , White
      Else
        Lcdat 39 , 102 , "Yes" , Red , White
      End If
      Waitms 300
    Elseif Sw_ok = 0 Then
      Bitwait Sw_ok , Set
      Waitms 50
      Exit Do
    End If
  Loop

  'View enemies?
  Lcdat 48 , 2 , "View Enemy?" , Black , White

  Lcdat 57 , 102 , "No" , Red , White
  Do
    If Sw_up = 0 Or Sw_down = 0 Then
      Toggle View_enemy
      If View_enemy = 0 Then
        Lcdat 57 , 102 , "No " , Red , White
      Else
        Lcdat 57 , 102 , "Yes" , Red , White
      End If
      Waitms 300
    Elseif Sw_ok = 0 Then
      Bitwait Sw_ok , Set
      Waitms 50
      Exit Do
    End If
  Loop

  'Determine game length
  Lcdat 66 , 2 , "Game Length:" , Black , White
  Game_length = 20

  Lcdat 75 , 76 , "20 min" , Red , White

  Do
    If Sw_up = 0 Then                                       'Get the number of minutes the game should last for
      If Game_length < 60 Then Incr Game_length             'Increase by one when up is pushed
      S1 = Str(game_length) + " min "
      Lcdat 75 , 76 , S1 , Red , White
      Waitms 300
    Elseif Sw_down = 0 Then                                 'Decrease by one when down button is pushed
      If Game_length > 5 Then Decr Game_length
      S1 = Str(game_length) + " min "
      Lcdat 75 , 76 , S1 , Red , White
      Waitms 300
    Elseif Sw_ok = 0 Then                                   'When OK is pushed, we're done
      Bitwait Sw_ok , Set
      Waitms 50
      Exit Do
    End If
  Loop
  Game_length = Game_length * 60                            'Convert the minutes entered into seconds


  'Determine timeout length
  Lcdat 84 , 2 , "Timeout Length:" , Black , White
  Timeout_length = 2

  Lcdat 93 , 76 , "2 min" , Red , White

  Do                                                        'Get the number of minutes the game should last for
    If Sw_up = 0 Then                                       'Increase by one when up is pushed
      If Timeout_length < Game_length Then Incr Timeout_length
      S1 = Str(timeout_length) + " min "
      Lcdat 93 , 76 , S1 , Red , White
      Waitms 300
    Elseif Sw_down = 0 Then                                 'Decrease by one when down button is pushed
      If Timeout_length > 0 Then Decr Timeout_length
      S1 = Str(timeout_length) + " min "
      Lcdat 93 , 76 , S1 , Red , White
      Waitms 300
    Elseif Sw_ok = 0 Then                                   'When OK is pushed, we're done
      Bitwait Sw_ok , Set
      Waitms 50
      Exit Do
    End If
  Loop
  Timeout_length = Timeout_length * 60                      'Convert the minutes entered into seconds

  'Get confirmation that these settings are OK
  Lcdat 110 , 2 , "Config OK?" , Black , White
  Lcdat 119 , 33 , "Continue" , Red , White
  Confirm = 1

  Do
    If Sw_up = 0 Or Sw_down = 0 Then
      Toggle Confirm
      If Confirm = 0 Then
        Lcdat 119 , 33 , "  Exit  " , Red , White
      Else
        Lcdat 119 , 33 , "Continue" , Red , White
      End If
      Waitms 300
    Elseif Sw_ok = 0 Then
      Bitwait Sw_ok , Set
      Waitms 50
      Exit Do
    End If
  Loop

  Cls

  'Print game name
  Lcdat 2 , 1 , "King of the Hill " , White , Green
  Line(0 , 9) -(127 , 9) , Black

  'Get Team A's starting location.
  Lcdat 12 , 2 , "Team A Start:" , Black , White
  Lcdat 31 , 2 , "Walk to Team A's" , Black , White
  Lcdat 39 , 2 , " start location" , Black , White
  Lcdat 48 , 2 , "  and push OK." , Black , White

  Bitwait Sw_ok , Set
  Waitms 250
  Bitwait Sw_ok , Reset

  B1 = 6                                                    'Valid GPS countdown
  Clear Serialin1
  Do
    If New_gps_data = 1 Then
      Get_gps
      If Return_valid = 1 Then
        Decr B1
        Friendly_x(b1) = Return_x
        Friendly_y(b1) = Return_y
        S1 = Str(b1)
        Lcdat 57 , 60 , S1 , Red , White
      Else
        Lcdat 65 , 2 , "Acquiring GPS..." , Black , White
      End If
      New_gps_data = 0
    End If
  Loop Until B1 = 1

  For B1 = 1 To 5
    Teama_start_loc_x = Teama_start_loc_x + Friendly_x(b1)
    Teama_start_loc_y = Teama_start_loc_y + Friendly_y(b1)
  Next B1
  Teama_start_loc_x = Teama_start_loc_x / 5
  Teama_start_loc_y = Teama_start_loc_y / 5

  Lcdat 21 , 88 , "Done." , Red , White

  'Clear the fluff
  Wait 3
  Box(0 , 30) -(128 , 80) , White

  'Get Team B's starting location
  Lcdat 30 , 2 , "Team B Start:" , Black , White
  Lcdat 48 , 2 , "Walk to Team B's" , Black , White
  Lcdat 57 , 2 , " start location" , Black , White
  Lcdat 66 , 2 , "  and push OK." , Black , White

  Bitwait Sw_ok , Set
  Waitms 250
  Bitwait Sw_ok , Reset

  B1 = 6                                                    'Valid GPS countdown
  Clear Serialin1
  Do
    If New_gps_data = 1 Then
      Get_gps
      If Return_valid = 1 Then
        Decr B1
        Friendly_x(b1) = Return_x
        Friendly_y(b1) = Return_y
        S1 = Str(b1)
        Lcdat 75 , 60 , S1 , Red , White
      Else
        Lcdat 84 , 2 , "Acquiring GPS..." , Black , White
      End If
      New_gps_data = 0
    End If
  Loop Until B1 = 1

  For B1 = 1 To 5
    Teamb_start_loc_x = Teamb_start_loc_x + Friendly_x(b1)
    Teamb_start_loc_y = Teamb_start_loc_y + Friendly_y(b1)
  Next B1
  Teamb_start_loc_x = Teamb_start_loc_x / 5
  Teamb_start_loc_y = Teamb_start_loc_y / 5

  Lcdat 39 , 88 , "Done." , Red , White

  'Clear the fluff
  Wait 3
  Box(0 , 48) -(128 , 128) , White

  'Get the hill location
  Lcdat 48 , 2 , "Hill Location:" , Black , White
  Lcdat 66 , 2 , " Walk to hill" , Black , White
  Lcdat 75 , 2 , " location and" , Black , White
  Lcdat 84 , 2 , "   push OK." , Black , White

  Bitwait Sw_ok , Set
  Waitms 250
  Bitwait Sw_ok , Reset

  B1 = 6                                                    'Valid GPS count
  Clear Serialin1
  Do
    If New_gps_data = 1 Then
      Get_gps
      If Return_valid = 1 Then
        Decr B1
        Friendly_x(b1) = Return_x
        Friendly_y(b1) = Return_y
        S1 = Str(b1)
        Lcdat 93 , 60 , S1 , Red , White
      Else
        Lcdat 102 , 2 , "Acquiring GPS..." , Black , White
      End If
      New_gps_data = 0
    End If
  Loop Until B1 = 1

  For B1 = 1 To 5
    Hill_loc_x = Hill_loc_x + Friendly_x(b1)
    Hill_loc_y = Hill_loc_y + Friendly_y(b1)
  Next B1
  Hill_loc_x = Hill_loc_x / 5
  Hill_loc_y = Hill_loc_y / 5

  'Get confirmation
  Lcdat 110 , 2 , "Locations OK?" , Black , White
  Lcdat 119 , 33 , " Continue" , Red , White
  Confirm = 1

  Do
    If Sw_up = 0 Or Sw_down = 0 Then
      Toggle Confirm
      If Confirm = 0 Then
        Lcdat 119 , 33 , "  Exit  " , Red , White
      Else
        Lcdat 119 , 33 , "Continue" , Red , White
      End If
      Waitms 300
    Elseif Sw_ok = 0 Then
      Bitwait Sw_ok , Set
      Waitms 50
      Exit Do
    End If
  Loop

  My_team = 0
  Teama_names(1) = Unit_name

  Cls

  Lcdat 2 , 1 , "King of the Hill " , White , Green
  Line(0 , 9) -(128 , 9) , Black

  Y = 12
  Lcdat Y , 2 , Unit_name , Green , White

  'Broadcast the game once every 2 seconds, allow players to join
  Teama_count = 1                                           'B3 is Team A player count
  Teamb_count = 0                                           'B4 is Team B player count
  Zig_slp = 0
  Waitms 13
  Wait_for_start_conf:
  Do
    Print #1 , Unit_version ; ":KOTH:" ; Unit_name ; ":*" ;
    If New_remote_data = 1 Then                             'Will look like: "A:Proto2:*" or "B:thezephyr:*"
      Astr = ""
      B2 = 1
      Do
        B1 = Waitkey(#2)
        Astr_b(b2) = B1
        Incr B2
      Loop Until B1 = 42
      Astr_b(b2) = 0

      Clear Serialin1
      B5 = Split(astr , Strs(1) , ":")

      'Determine team and reply with teammate number
      If Strs(1) = "A" Then
        Incr Teama_count
        Teama_names(teama_count) = Strs(2)
        Print #1 , Strs(2) ; ":" ; Str(teama_count) ; ":*"
      Elseif Strs(1) = "B" Then
        Incr Teamb_count
        Teamb_names(teamb_count) = Strs(2)
        Print #1 , Strs(2) ; ":" ; Str(teamb_count) ; ":*"
      End If


      'Clear the screen, redraw title
      Cls
      Lcdat 2 , 1 , "King of the Hill " , White , Green
      Line(0 , 9) -(128 , 9) , Black

      For B5 = 1 To Teama_count
        Y = Y + 9
        Lcdat Y , 2 , Teama_names(b5) , Green , White
      Next

      For B5 = 1 To Teamb_count
        Y = Y + 9
        Lcdat Y , 2 , Teamb_names(b5) , Red , White
      Next
    End If

    For B1 = 1 To 8
      If Sw_ok = 0 Then Exit Do
        'Clear the screen, redraw title
'        Cls
'        Lcdat 2 , 1 , "King of the Hill " , White , Green
'        Line(0 , 9) -(128 , 9) , Black

        Lcdat 110 , 1 , "Push OK to start" , Red , White    'Wait for confirmation to begin game
        Lcdat 119 , 1 , "or PWR to cancel." , Red , White
        Do
          If Sw_ok = 0 Then
            Goto Outloop1
          Elseif Sw_onoff = 0 Then
            Goto Main
          End If
        Loop
      Waitms 250
    Next B1
  Loop
  Outloop1:

  Astr = ""
  Astr = "START:" + Str(loc_radius) + ":" + Str(view_friendly) + ":" + Str(view_enemy) + ":" + Str(game_length) + ":" + Str(timeout_length) + ":"
  Astr = Astr + Str(teama_start_loc_x) + ":" + Str(teama_start_loc_y) + ":" + Str(teamb_start_loc_x) + ":" + Str(teamb_start_loc_y) + ":"
  Astr = Astr + Str(hill_loc_x) + ":" + Str(hill_loc_y) + ":" + Str(teama_count) + ":" + Str(teamb_count) + ":*"
  'Sample: "START:[Loc_radius]:[View_friendly]:[View_enemy]:[Game_len]:[TO_len]:[AStrt_x]:[AStrt_y]:[BStrt_x]:[BStrt_y]:[Hill_x]:[Hill_y]:[TeamA_cnt]:[TeamB_cnt]:*"

  Print #1 , Astr ;

  Countdown 3

  B1 = Check_start_points()
  If B1 = 1 Then                                            'If 1 was returned, we're clear to start the game
    Print #1 , "GO:*" ;
    Goto Koth
  Else
    Print #1 , "RESTART:*" ;
    Lcdat 110 , 1 , "Can't start game." , Red , White       'Wait for confirmation to begin game
    Lcdat 119 , 1 , "    Retrying...  " , Red , White
    Wait 1
    Goto Wait_for_start_conf                                'Otherwise, we have to try again
  End If
  Goto Main                                                 'Catch in case something fails
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
Sub Countdown(byval Countdown As Byte)
  Local Ls1 As String * 3
  Local Lb1 As Byte
  Cls

  Setfont Color16x16                                        'Use large fonts

  Lb1 = Countdown
  Do
    Select Case Lb1                                         'Display with different colors depending on how much countdown remains
      Case Is > 2
        Color = Blue
      Case 2
        Color = Red
      Case 1
        Color = Orange
    End Select

    Ls1 = Str(lb1)                                          'Convert the countdown number into a string

    Lcdat 56 , 56 , Ls1 , Color , White                     'Display the countdown number using the color determined above
    Wait 1
    Decr Lb1
  Loop Until Lb1 = 0

  Lcdat 56 , 48 , "GO!" , Green , White                     'Ready, set, now GO!

  Setfont Color8x8                                          'Set the font back to the right size for everything else
  Waitms 350
End Sub
'*******************************************************************************

'*******************************************************************************
Function Check_start_points() As Byte                       'If we return 1, it's ok, if zero, someone isn't at their starting location
  Local Teama_ans As Byte                                   'Counts number of TeamA answers
  Local Teamb_ans As Byte                                   'Counts number of TeamB answers
  Local Player_num As Byte                                  'Holds the current player's number
  Local Lb1 As Byte , Lb2 As Byte
  Local Llng As Long

  Get_gps
  Friendly_x(1) = Return_x
  Friendly_y(1) = Return_y

  Teama_ans = 1
  Teamb_ans = 0
  Lb1 = 1
  Lb2 = Teama_count + Teamb_count
  Do                                                        'Get coordinates from each player
    If New_remote_data = 1 Then                             'Will look like: "B:1:1234567:1234567:*"
      Astr = ""
      B2 = 1
      Do
        B1 = Waitkey(#2)
        Astr_b(b2) = B1
        Incr B2
      Loop Until B1 = 42
      Astr_b(b2) = 0

      B5 = Split(astr , Strs(1) , ":")

      'Determine team and add to count
      If Strs(1) = "A" Then
        Incr Teama_ans
        Incr Lb1
        Player_num = Val(strs(2))
        Friendly_x(player_num) = Val(strs(3))
        Friendly_y(player_num) = Val(strs(4))
      Elseif Strs(1) = "B" Then
        Incr Teamb_ans
        Incr Lb1
        Player_num = Val(strs(2))
        Enemy_x(player_num) = Val(strs(3))
        Enemy_y(player_num) = Val(strs(4))
      End If
    End If
  Loop Until Lb1 >= Lb2

'Dim Loc_radius As Byte                                      'Radius around locations
'Dim View_friendly As Bit                                    'Determines if players can view friendly players
'Dim View_enemy As Bit                                       'Determines if players can view enemy players
'Dim Game_length As Word                                     'Contains game length in seconds
'Dim Timeout_length As Word                                  'Contains timeout length in seconds
'Dim Teama_start_loc_x As Long                               'X coordinate of Team A's starting location
'Dim Teama_start_loc_y As Long                               'Y coordinate of Team A's starting location
'Dim Teamb_start_loc_x As Long                               'X coordinate of Team B's starting location
'Dim Teamb_start_loc_y As Long                               'Y coordinate of Team B's starting location
'Dim Hill_loc_x As Long                                      'X coordinate of hill's location
'Dim Hill_loc_y As Long                                      'Y coordinate of hill's location
'Dim Teama_count As Byte                                     'Number of Team A players
'Dim Teamb_count As Byte                                     'Number of Team B players

  For Lb1 = 1 To Teama_count
    Llng = Teama_start_loc_x - Friendly_x(1)
    Llng = Abs(llng)
    If Llng > Loc_radius Then
      Check_start_points = 0
      Return
    End If

    Llng = Teama_start_loc_y - Friendly_y(1)
    Llng = Abs(llng)
    If Llng > Loc_radius Then
      Check_start_points = 0
      Return
    End If
  Next Lb1

  For Lb1 = 1 To Teamb_count
    Llng = Teamb_start_loc_x - Enemy_x(1)
    Llng = Abs(llng)
    If Llng > Loc_radius Then
      Check_start_points = 0
      Return
    End If

    Llng = Teamb_start_loc_y = Enemy_y(1)
    Llng = Abs(llng)
    If Llng > Loc_radius Then
      Check_start_points = 0
      Return
    End If
  Next Lb1

  Check_start_points = 1
  Return
End Function
'*******************************************************************************

'*******************************************************************************
'***************************** GAME SUBROUTINES ********************************
'*******************************************************************************
Sub Capture_the_flag()

End Sub
'*******************************************************************************

'*******************************************************************************
Sub King_of_the_hill()
Koth:
  Cls
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
  '  '    Print #1 , Astr
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
        Waitms 13
    '    Print #1 , My_x ; "," ; My_y ; "," ; My_heading ; ",*"
        Print #1 , Str(my_x) ; "," ; Str(my_y) ; "," ; Str(my_heading) ; ",*" ;
    '    Print #1 , Strs(6) ; "," ; Strs(4) ; "," ; Strs(9) ; ",*"
        Waitms 13
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
  '  '  Circle(64 , 64) , 16 , Dark_gray
  '  '  Circle(64 , 64) , 32 , Dark_gray
  '  '  Circle(64 , 64) , 48 , Dark_gray
  '  '  Circle(64 , 64) , 63 , Dark_gray

      'Clear your marker
      Box(58 , 58) -(70 , 70) , White

      'Clear his marker
      If Old_x <> 0 Then
        B1 = Old_x + 6                                      'Make a 10x10 box to ensure complete clearage
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
End Sub
'*******************************************************************************

'*******************************************************************************
Sub Team_slayer()

End Sub
'*******************************************************************************

'*******************************************************************************
Sub Tick_tactics()

End Sub
'*******************************************************************************

'*******************************************************************************
Sub Elimination()

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

'*******************************************************************************
Sub Get_gps()
  Local Lb1 As Byte , Lb2 As Byte , Lb3 As Byte , Lb4 As Byte
  Local Lsng1 As Single , Lsng2 As Single

  Return_valid = 0
  Astr = ""
  Lb2 = 1
  Do
    Lb1 = Waitkey(#2)
    Astr_b(lb2) = Lb1
    Incr Lb2
  Loop Until Lb1 = 42
  Astr_b(lb2) = 0

  If Len(astr) > 20 And Instr(1 , Astr , "RMC") <> 0 Then
    Clear Serialin1
    Lb4 = Split(astr , Strs(1) , ",")

    If Strs(3) = "A" Then
      Return_valid = 1
      'Get Longitude
      If Strs(4) <> "" Then
        S1 = Left(strs(4) , 3)
        Lsng1 = Val(s1)
        Lb2 = Len(s1) - 3
        S1 = Mid(strs(4) , 4 , Lb2)
        Lsng2 = Val(s1)
        Lsng1 = Lsng1 * 78857.856
        Lsng2 = Lsng2 * 1314.2976
        Lsng1 = Lsng1 + Lsng2
        Return_x = Lsng1
      Else
        Return_x = 0
        Return_valid = 0
      End If

      'Get Latitude
      If Strs(6) <> "" Then
        S1 = Left(strs(6) , 2)
        Lsng1 = Val(s1)
        Lb2 = Len(s1) - 2
        S1 = Mid(strs(6) , 3 , B2)
        Lsng2 = Val(s1)
        Lsng1 = Lsng1 * 111044.736
        Lsng2 = Lsng2 * 1851.9648
        Lsng1 = Lsng1 + Lsng2
        Return_y = Lsng1
      Else
        Return_y = 0
        Return_valid = 0
      End If

      'Get Heading
      Return_heading = Val(strs(9))
    Else
      Return_x = 0
      Return_y = 0
      Return_heading = 0
      Return_valid = 0
    End If

    Zig_slp = 0
    Waitms 13
'    Print #1 , My_x ; "," ; My_y ; "," ; My_heading ; ",*"
'    Print #1 , Str(my_x) ; "," ; Str(my_y) ; "," ; Str(my_heading) ; ",*" ;
'    Print #1 , Strs(6) ; "," ; Strs(4) ; "," ; Strs(9) ; ",*"
    Waitms 13
    Zig_slp = 1
    New_gps_data = 0
    Needs_redraw = 1
  Else
    If _rs_bufcountr1 < 50 Then New_gps_data = 0
  End If
End Sub
'*******************************************************************************

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
$include "color16x16.font"
$include "color8x8.font"
$include "smallfont.font"

$include "zephyreyepic.txt"