
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
$lib "double.lbx"
'$lib "fp_trig.lbx"
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
Const Yds_per_div = 121616                                  'Yards per longitude (or latitude)

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
Declare Sub Factor_zoom()
  'Menus
Declare Sub Select_game()
Declare Sub Join_game()
Declare Sub Edit_options()
Declare Sub Edit_settings()
  'Game Setups
Declare Sub Setup_capture_the_flag()
Declare Sub Setup_king_of_the_hill()
Declare Sub Setup_team_slayer()
Declare Sub Setup_tick_tactics()
Declare Sub Setup_elimination()
Declare Sub Countdown(byval Countdown As Byte)
Declare Function Check_start_points() As Byte
  'Games
  'CTF
Declare Sub Capture_the_flag()
  'KOTH
Declare Sub King_of_the_hill()
Declare Sub Koth_redraw()
Declare Sub Koth_update_score()
Declare Sub Koth_sw_scan()
Declare Sub Draw_hill()
  'Slayer
Declare Sub Team_slayer()
  'Battlefront
Declare Sub Tick_tactics()
  'Elimination
Declare Sub Elimination()
  'GPS
Declare Sub Config_gps()
Declare Sub Get_gps()
Declare Function Coord2dbl(coord_str As String , Byval Is_lat As Byte) As Double
Declare Function Lat2lng(lat_str As String) As Long
Declare Function Lng2lng(lng_str As String) As Long
'*******************************************************************************

'*******************************************************************************
  'Dimension Variables
  'General
Dim B As Byte , B1 As Byte , B2 As Byte , B3 As Byte , B4 As Byte , B5 As Byte
Dim I As Integer , I1 As Integer , I2 As Integer
Dim Lng1 As Long , Lng2 As Long
Dim Sng1 As Single , Sng2 As Single
Dim W1 As Word , W2 As Word
Dim Strs(16) As String * 25
Dim S1 As String * 20
Dim S1_b(21) As Byte At S1 Overlay
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
Dim Has_changed As Bit
Dim Can_scan As Word                                        'Use a clock-cycle based timeout to avoid blocking statements during debounce
  'Games
Dim My_x As Long
Dim My_y As Long
Dim My_heading As Word
Dim My_team As String * 3
Dim My_number As Byte
Dim My_hit_count As Byte
Dim My_old_x As Long
Dim My_old_y As Long
Dim My_old_heading As Word

Dim Unit_name_e As Eram String * 10
Dim Unit_version_e As Eram String * 7

Dim Unit_name As String * 10
Dim Unit_name_b(11) As Byte At Unit_name Overlay
Dim Unit_version As String * 7

Dim Cur_x As Long
Dim Cur_y As Long

Dim Friendly_x(10) As Long
Dim Friendly_y(10) As Long
Dim Friendly_headings(10) As Word
Dim Friendlies_firing As Word
Dim Friendlies_on_hill As Word
Dim Friendlies_hit As Word
Dim Friendly_hit_count As Word

Dim Enemy_x(10) As Long
Dim Enemy_y(10) As Long
Dim Enemy_headings(10) As Word
Dim Enemies_firing As Word
Dim Enemies_on_hill As Word
Dim Enemies_hit As Word
Dim Enemy_hit_count As Word

Dim Friendly_count As Byte
Dim Enemy_count As Byte
Dim Old_friendly_x(10) As Byte
Dim Old_friendly_y(10) As Byte
Dim Old_friendly_headings(10) As Word
Dim Old_enemy_x(10) As Byte
Dim Old_enemy_y(10) As Byte
Dim Old_enemy_headings(10) As Word
Dim Old_hill_x As Byte
Dim Old_hill_y As Byte
Dim Old_enemy_start_x As Byte
Dim Old_enemy_start_y As Byte
Dim Old_friendly_start_x As Byte
Dim Old_friendly_start_y As Byte

Dim Return_x As Long
Dim Return_y As Long
Dim Return_heading As Long
Dim Return_valid As Bit

Dim Game_names(5) As String * 20
Dim Cur_game As Byte

  'KING OF THE HILL
Dim Ref_lat As Double                                       'Latitude used as a reference point for ENU coordinates
Dim Have_ref_lat As Bit                                     'High if a reference latitude has been determined
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
Dim Am_on_hill As Bit                                       'If you are on hill, will be 1
Dim Am_hit As Bit                                           'If you're hit and in timeout, will be 1
Dim Am_on_base As Bit                                       'If you are hit and at base, will be 1
Dim Timeout_remaining As Word                               'Contains remaining time until you can return to game.
Dim Game_remaining As Word                                  'Contains remaining time until game is over

Dim Friendly_time_on_hill As Word                           'Holds number of seconds friendly team is on hill
Dim Enemy_time_on_hill As Word                              'Holds number of seconds enemy team is on hill

Dim Zoom_factor As Byte                                     'Holds the level of zoom


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
Unit_version = "V0.1.4"
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

Ref_lat = 45.3105333333333
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
    Edit_options
  Case 4                                                    'Settings
    Edit_settings
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

Do
  If New_gps_data = 1 Then
    New_gps_data = 0
    Get_gps
    If Return_valid = 1 Then
      Print #1 , "Lng: " ; Strs(6) ; "Lat: " ; Strs(4)
      Print #1 , "My_x: " ; Return_x ; "  My_y: " ; Return_y
    End If
  End If
Loop

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
  Lcdat 2 , 0 , "    Join Game    " , White , Green
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

'      Clear Serialin
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
        B1 = 0
        Do
          If Sw_up = 0 Or Sw_down = 0 Then
            Toggle B1.0
            If B1 = 0 Then
              Lcdat 118 , 36 , "Team A" , Red , White
            Else
              My_team = "B"
              Lcdat 118 , 36 , "Team B" , Red , White
            End If
            Waitms 300
          Elseif Sw_ok = 0 Then
            Bitwait Sw_ok , Set
            Waitms 50
            Exit Do
          End If
        Loop

        If B1 = 0 Then
          My_team = "A"
        Elseif B1 = 1 Then
          My_team = "B"
        End If


        'Reply to unit broadcasting game to join
        Print #1 , My_team ; ":" ; Unit_name ; ":*" ;

        'Get your player number
        My_number = 0
        Do
          If New_remote_data = 1 Then
            Astr = ""
            B2 = 1
            Do
              B1 = Waitkey(#1)
              Astr_b(b2) = B1
              Incr B2
            Loop Until B1 = 42
            Astr_b(b2) = 0
            B4 = Split(astr , Strs(1) , ":")
            If Strs(1) = Unit_name Then My_number = Val(strs(2))
            If _rs_bufcountr0 > 5 Then New_remote_data = 1 Else New_remote_data = 0
          End If
        Loop Until My_number <> 0

        Cls
        Lcdat 60 , 2 , "  Waiting for" , Blue , White
        Lcdat 69 , 2 , " game to start!" , Blue , White

'Expect "START:[Loc_radius]:[View_friendly]:[View_enemy]:[Game_len]:[TO_len]:[AStrt_x]:[AStrt_y]:[BStrt_x]:[BStrt_y]:[Hill_x]:[Hill_y]:[TeamA_cnt]:[TeamB_cnt]:[Ref_lat]:*"
'    or "CANCEL:*"


'V0.1.2:KOTH:Proto2:*
        Wait_for_start:
        Do
          If New_remote_data = 1 Then                       'Ex: START:10:1:0:1200:120:1234567:1234567:1234567:1234567:1234567:1234567:3:3:*
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
              Teamb_start_loc_y = Val(strs(10))
              Hill_loc_x = Val(strs(11))
              Hill_loc_y = Val(strs(12))
              Teama_count = Val(strs(13))
              Teamb_count = Val(strs(14))
              'Ref_lat = Val(strs(15))
              Ref_lat = 45.3105333333333

              Countdown 3

              Do
                Get_gps
                My_x = Return_x
                My_y = Return_y
              Loop Until Return_valid = 1

              Print #1 , My_team ; ":" ; My_number ; ":" ; My_x ; ":" ; My_y ; ":*"
              Do
                If New_remote_data = 1 Then                 'Will either be "GO:*" or "RESTART:*"
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
Sub Edit_options()

End Sub
'*******************************************************************************

'*******************************************************************************
Sub Edit_settings()
  Local Lb1 As Byte , Lb2 As Byte , Lb3 As Byte

  'Print screen title
  Cls
  Lcdat 2 , 0 , "  Edit Settings  " , White , Green
  Line(0 , 9) -(128 , 9) , Black

  Lcdat 12 , 2 , "Unit Name:" , Black , White
  X = Len(unit_name) * 8
  X = 128 - X
  Lcdat 21 , X , Unit_name , Black , Gray

  Lcdat 120 , 2 , "Press ZO to exit." , Dark_gray , White

  Bitwait Sw_ok , Set                                       'Make sure we're debounced before we continue
  Waitms 50
  Do
    If Sw_out = 0 Then Exit Sub
    If Sw_ok = 0 Then Exit Do
  Loop

  Waitms 325

  'Have user enter a new name
  Box(2 , 12) -(128 , 60) , White
  Lcdat 12 , 2 , "Enter unit name:" , Black , White
  Loc_radius = 10

  While Len(unit_name) < 10
    Unit_name = Unit_name + " "
  Wend

  Lb1 = 1                                                   'Lb1 contains change flag (start with 1 so it displays once on entering loop)
  Lb2 = 1                                                   'Lb2 contains pointer to array element currently being modified
  Do                                                        'Loop constantly
    If Sw_up = 0 Then
      Incr Unit_name_b(lb2)
      Lb1 = 1
    Elseif Sw_down = 0 Then
      Decr Unit_name_b(lb2)
      Lb1 = 1
    Elseif Sw_right = 0 Then
      If Lb2 < 10 Then Incr Lb2
      Lb1 = 1
    Elseif Sw_left = 0 Then
      If Lb2 > 1 Then Decr Lb2
      Lb1 = 1
    End If

    If Lb1 = 1 Then
      'Redisplay
      Lb3 = Lb2 - 1
      S1 = Left(unit_name , Lb3)
'      Lb3 = Lb3 * 8
'      Lb3 = Lb3 + 48
      Lcdat 21 , 48 , S1 , Black , Gray                     'Print to the left of the cursor
      Lb3 = Lb2 * 8
      Lb3 = Lb3 + 40
      S1_b(1) = Unit_name_b(lb2)
      S1_b(2) = 0
      Lcdat 21 , Lb3 , S1 , White , Dark_gray               'Print the current character
      Lb3 = 10 - Lb2
      S1 = Right(unit_name , Lb3)
      Lb3 = Lb2 * 8
      Lb3 = Lb3 + 8
      Lb3 = Lb3 + 40
      Lcdat 21 , Lb3 , S1 , Black , Gray                    'Print to the right of the cursor
      Waitms 150
      Lb1 = 0
    End If
  Loop Until Sw_ok = 0

  Unit_name = Trim(unit_name)

  While Instr(unit_name , " ") > 0
    B3 = Len(unit_name) - 1
    Unit_name = Left(unit_name , B3)
  Wend
  Unit_name_e = Unit_name
  Goto Main
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

  My_team = "A"
  My_number = 1
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
  Waitms 15
  Wait_for_start_conf:
  Clear Serialin
  Do
    Print #1 , Unit_version ; ":KOTH:" ; Unit_name ; ":*" ;
    If New_remote_data = 1 Then                             'Will look like: "A:Proto2:*" or "B:thezephyr:*"
      Astr = ""
      B2 = 1
      Do
        B1 = Waitkey(#1)
        Astr_b(b2) = B1
        Incr B2
      Loop Until B1 = 42
      Astr_b(b2) = 0

      B5 = Split(astr , Strs(1) , ":")

      'Determine team and reply with teammate number
      If Strs(1) = "A" Then
        Incr Teama_count
        Teama_names(teama_count) = Strs(2)
        Print #1 , Strs(2) ; ":" ; Str(teama_count) ; ":*" ;
      Elseif Strs(1) = "B" Then
        Incr Teamb_count
        Teamb_names(teamb_count) = Strs(2)
        Print #1 , Strs(2) ; ":" ; Str(teamb_count) ; ":*" ;
      Else
        Print #1 , "Failed: <" ; Astr ; ">"
      End If

      'Clear the screen, redraw title
      Cls
      Lcdat 2 , 1 , "King of the Hill " , White , Green
      Line(0 , 9) -(128 , 9) , Black

      Y = 2
      For B5 = 1 To Teama_count
        Y = Y + 9
        Lcdat Y , 2 , Teama_names(b5) , Green , White
      Next

      For B5 = 1 To Teamb_count
        Y = Y + 9
        Lcdat Y , 2 , Teamb_names(b5) , Red , White
      Next

      Lcdat 110 , 1 , "Push OK to start" , Red , White      'Wait for confirmation to begin game
      Lcdat 119 , 1 , "or PWR to cancel." , Red , White

      If _rs_bufcountr0 > 5 Then New_remote_data = 1 Else New_remote_data = 0
    End If

    For B1 = 1 To 8
      Waitms 250
      If Sw_ok = 0 Then Exit Do
        'Clear the screen, redraw title
'        Cls
'        Lcdat 2 , 1 , "King of the Hill " , White , Green
'        Line(0 , 9) -(128 , 9) , Black

        If Sw_ok = 0 Then
          Exit Do
        Elseif Sw_onoff = 0 Then
          Goto Main
        End If
    Next B1
  Loop

  Astr = ""
  Astr = "START:" + Str(loc_radius) + ":" + Str(view_friendly) + ":" + Str(view_enemy) + ":" + Str(game_length) + ":" + Str(timeout_length) + ":"
  Astr = Astr + Str(teama_start_loc_x) + ":" + Str(teama_start_loc_y) + ":" + Str(teamb_start_loc_x) + ":" + Str(teamb_start_loc_y) + ":"
  Astr = Astr + Str(hill_loc_x) + ":" + Str(hill_loc_y) + ":" + Str(teama_count) + ":" + Str(teamb_count) + ":*"
  'Sample: "START:[Loc_radius]:[View_friendly]:[View_enemy]:[Game_len]:[TO_len]:[AStrt_x]:[AStrt_y]:[BStrt_x]:[BStrt_y]:[Hill_x]:[Hill_y]:[TeamA_cnt]:[TeamB_cnt]:*"

  Print #1 , Astr ;

  Countdown 3

'  B1 = 0
'  B2 = Teama_count + Teamb_count
'  B2 = B2 - 1
'  Do                                                        'Get coordinates from each player
'    If New_remote_data = 1 Then                             'Will look like: "B:1:1234567:1234567:*"
'      Astr = ""
'      B2 = 1
'      Do
'        B1 = Waitkey(#2)
'        Astr_b(b2) = B1
'        Incr B2
'      Loop Until B1 = 42
'      Astr_b(b2) = 0
  Led = 1

  B1 = Check_start_points()
  B1 = 1
  Led = 0
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
  Lb2 = Lb2 - 1
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
      If _rs_bufcountr0 > 5 Then New_remote_data = 1 Else New_remote_data = 0
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

  'Get enemy counts and friendly counts
  If My_team = "A" Then
    Enemy_count = Teamb_count
    Friendly_count = Teama_count
  Elseif My_team = "B" Then
    Enemy_count = Teama_count
    Friendly_count = Teamb_count
  End If

  'Setup game length
  Game_remaining = Game_length
  Zoom_factor = 1
  Do
    If New_gps_data = 1 Then
      New_gps_data = 0

      Get_gps                                               'Get the GPS data and update coordinate vars
      If Return_valid = 1 Then
        My_old_x = My_x
        My_old_y = My_y
        My_x = Return_x
        My_y = Return_y
        My_heading = Return_heading

        Lng1 = My_x - Hill_loc_x                            'Check to see if this unit is on the hill
        Lng1 = Abs(lng1)
        Lng2 = My_y - Hill_loc_y
        Lng2 = Abs(lng2)                                    'If it is, then set the Am_on_hill var
        If Lng1 < Loc_radius And Lng2 < Loc_radius Then
          If Am_hit = 0 Then Am_on_hill = 1
        Else
          Am_on_hill = 0
        End If
        Friendlies_on_hill.my_number = Am_on_hill

        If Am_hit = 1 Then
          If My_team = "A" Then
            Lng1 = My_x - Teama_start_loc_x                 'Check to see if the player is at base, if hit
            Lng1 = Abs(lng1)
            Lng2 = My_y - Teama_start_loc_y
            Lng2 = Abs(lng2)
          Else
            Lng1 = My_x - Teamb_start_loc_x                 'Check to see if the player is at base, if hit
            Lng1 = Abs(lng1)
            Lng2 = My_y - Teamb_start_loc_y
            Lng2 = Abs(lng2)
          End If

          If Lng1 < Loc_radius And Lng2 < Loc_radius Then
            Am_on_base = 1
            Decr Timeout_remaining
            If Timeout_remaining <= 1 Then
              Lcdat 20 , 20 , "GO!" , Green , White
              Wait 1
              Lcdat 20 , 20 , "GO!" , White , White
              Am_hit = 0
            End If
          Else
            Am_on_base = 0
          End If
        End If


        'Example String: "A:1:1234567:1234567:270:1:0:*"
        Astr = My_team + ":" + Str(my_number) + ":" + Str(my_x) + ":" + Str(my_y) + ":" + Str(my_heading) + ":" + Str(am_on_hill) + ":" + Str(am_hit) + ":*"

        Print #1 , Astr ;

        'Raise the redraw flag
        Needs_redraw = 1
      End If
    End If

    If New_remote_data = 1 Then                             'Get remote data
      Astr = ""
      B2 = 1
      Do
        B1 = Waitkey(#1)
        Astr_b(b2) = B1
        Incr B2
      Loop Until B1 = 42
      Astr_b(b2) = 0

      B4 = Split(astr , Strs(1) , ":")                      'Should look like "A:1:1234567:1234567:270:1:0:*"
                                                             'e.g., "Team:Num:Lat:Long:
      B3 = Val(strs(2))                                     'Contains player number

      If Strs(1) = My_team Then                             'Make sure we modify the right team
        Friendly_x(b3) = Val(strs(3))                       'Longitude
        Friendly_y(b3) = Val(strs(4))                       'Latitude
        Friendly_headings(b3) = Val(strs(5))                'Heading
        'Friendlies_firing = ...
        B4 = Val(strs(6))                                   'Store if this friendly is "on the hill"
        Friendlies_on_hill.b3 = B4
        B4 = Val(strs(7))                                   'Store if this friendly is currently hit
        W1 = Friendlies_hit
        Friendlies_hit.b3 = B4                              'Increment Friendly_hit_count if this is a new hit
        W1 = Friendlies_hit Xor W1
        If W1 > 0 And B4 = 1 Then Incr Friendly_hit_count
      Else
        Enemy_x(b3) = Val(strs(3))                          'Longitude
        Enemy_y(b3) = Val(strs(4))                          'Latitude
        Enemy_headings(b3) = Val(strs(5))                   'Heading
        'Enemies_firing = ...
        B4 = Val(strs(6))                                   'Store if this enemy is "on the hill"
        Enemies_on_hill.b3 = B4.0
        B4 = Val(strs(7))                                   'Store it if this enemy is currently hit
        W1 = Enemies_hit
        Enemies_hit.b3 = B4                                 'Increment Enemy_hit_count if this is a new hit
        W1 = Friendlies_hit Xor W1
        If W1 > 0 And B4 = 1 Then Incr Enemy_hit_count
      End If

      If _rs_bufcountr0 > 10 Then New_remote_data = 1 Else New_remote_data = 0
    End If

    If Can_scan > 3000 Then                                 ' Koth_sw_scan Else Incr Can_scan
      If Am_hit = 0 And Sw_up = 0 Then                      'Check if the player is reporting a hit
        Lcdat 20 , 20 , "HIT?" , Black , White
        Waitms 500
        For B1 = 1 To 20
          If Sw_up = 0 Then
            Am_hit = 1                                          'If yes, raise hit flags
            Friendlies_hit.my_number = 1
            Am_on_hill = 0                                      'Can't be on hill when you're hit
            Timeout_remaining = Timeout_length              'Set the timeout remaining for the player
          Elseif Sw_down = 0 Then
            Exit For
          End If
          Waitms 100
        Next B1
        Lcdat 20 , 20 , "HIT?" , White , White
        Can_scan = 0
      End If
      If Sw_in = 0 Then
        If Zoom_factor > 1 Then Decr Zoom_factor
        Can_scan = 0
      Elseif Sw_out = 0 Then
        If Zoom_factor < 10 Then Incr Zoom_factor
        Can_scan = 0
      End If
    Else
      Incr Can_scan
    End If

    If Needs_redraw = 1 Then
      Koth_update_score
      Koth_redraw
      Needs_redraw = 0                                      'Clear the redraw flag
    End If

    If Game_remaining <= 1 Then
      Cls
      Lcdat 20 , 20 , "GAME OVER" , Black , White

      If Friendly_time_on_hill > Enemy_time_on_hill Then
        Lcdat 40 , 20 , "YOU WON!" , Green , White
      Else
        Lcdat 40 , 20 , "YOU LOST!" , Red , White
      End If

      'Update friendly score
      B1 = Friendly_time_on_hill / 60
      B2 = Friendly_time_on_hill Mod 60
      If B2 > 9 Then
        Lcdat 112 , 96 , Str(b1) + ":" + Str(b2) , Green , White
      Else
        Lcdat 112 , 96 , Str(b1) + ":0" + Str(b2) , Green , White
      End If

      'Update enemy score
      B1 = Enemy_time_on_hill / 60
      B2 = Enemy_time_on_hill Mod 60
      If B2 > 9 Then
        Lcdat 120 , 96 , Str(b1) + ":" + Str(b2) , Red , White
      Else
        Lcdat 120 , 96 , Str(b1) + ":0" + Str(b2) , Red , White
      End If

      Wait 5
      Exit Sub                                              'GAME OVER
    End If

    If Sw_onoff = 0 Then                                    'Check to see if they're trying to turn off their unit
      Lcd_ven = 0
      Gps_en = 0
      Zig_slp = 0
      Waitms 200
      Goto &HFC00
    End If
    End_of_loop:
  Loop
End Sub
'*******************************************************************************

'*******************************************************************************
Sub Koth_redraw()
  'Clear your marker
  Draw_arrow 64 , 64 , White , My_old_heading

  'Clear friendlies from screen
  For B1 = 1 To Friendly_count
    If B1 <> My_number Then
      Draw_arrow Old_friendly_x(b1) , Old_friendly_y(b1) , White , Old_friendly_headings(b1)
    End If
  Next B1

  'Clear enemies from screen
  For B1 = 1 To Enemy_count
    Draw_arrow Old_enemy_x(b1) , Old_enemy_y(b1) , White , Old_enemy_headings(b1)       'Draw a white arrow over the last arrow
  Next B1

  'Update zoom level
'  B1 = Zoom_factor * 100
  Lcdat 2 , 1 , "x" + Str(zoom_factor) , Dark_gray , 2 , 1

  'Update game time remaining
  W1 = Game_remaining \ 60
  W2 = Game_remaining Mod 60
  If W2 > 9 Then
    Lcdat 120 , 1 , Str(w1) + ":" + Str(w2) , Black , White
  Else
    Lcdat 120 , 1 , Str(w1) + ":0" + Str(w2) , Black , White
  End If

  'Update friendly score
  W1 = Friendly_time_on_hill \ 60
  W2 = Friendly_time_on_hill Mod 60
  If W2 > 9 Then
    Lcdat 112 , 96 , Str(w1) + ":" + Str(w2) , Green , White
  Else
    Lcdat 112 , 96 , Str(w1) + ":0" + Str(w2) , Green , White
  End If

  'Update enemy score
  W1 = Enemy_time_on_hill \ 60
  W2 = Enemy_time_on_hill Mod 60
  If W2 > 9 Then
    Lcdat 120 , 96 , Str(w1) + ":" + Str(w2) , Red , White
  Else
    Lcdat 120 , 96 , Str(w1) + ":0" + Str(w2) , Red , White
  End If

  If Am_hit = 1 Then                                        'Update timeout remaining, if hit
    W1 = Timeout_remaining \ 60
    W2 = Timeout_remaining Mod 60
    If B2 > 9 Then
      Lcdat 120 , 48 , Str(w1) + ":" + Str(w2) , Orange , White
    Else
      Lcdat 120 , 48 , Str(w1) + ":0" + Str(w2) , Orange , White
    End If
  End If

  'Update friendly player counts
  B2 = 0
  For B1 = 1 To Friendly_count
    If Friendlies_hit.b1 = 0 Then Incr B2
  Next B1
  Astr = Str(b2) + "/" + Str(friendly_count) + " "
  Lcdat 1 , 104 , Astr , Green , White

  'Update enemy player counts, if allowed
  If View_enemy = 1 Then
    B2 = 0
    For B1 = 1 To Enemy_count
      If Enemies_hit.b1 = 0 Then Incr B2
    Next B1
    Astr = Str(b2) + "/" + Str(enemy_count) + " "
    Lcdat 9 , 104 , Astr , Red , White
  End If

  'Draw out friendly objects, if allowed
  If View_friendly = 1 Then
    'Draw new markers for friendly team
    For B1 = 1 To Friendly_count
      If B1 <> My_number Then
        Cur_x = Friendly_x(b1) - My_x                       'Find distance between you and him
        Cur_y = My_y - Friendly_y(b1)
        Cur_x = Cur_x / Zoom_factor                         'Factor zoom
        Cur_y = Cur_y / Zoom_factor
        Cur_x = Cur_x + 64                                  'Center the difference on the screen
        Cur_y = Cur_y + 64
        If Cur_x > 126 Then Cur_x = 126                     'Check bounds
        If Cur_x < 2 Then Cur_x = 2
        If Cur_y > 126 Then Cur_y = 126
        If Cur_y < 2 Then Cur_y = 2

        X = Cur_x                                           'Demote to byte variables so they can be passed to draw_arrow sub
        Y = Cur_y
        Old_friendly_x(b1) = X
        Old_friendly_y(b1) = Y
        Old_friendly_headings(b1) = Friendly_headings(b1)

        If Friendlies_hit.b1 = 1 Then Color = Brightblue Else Color = Green
        Draw_arrow X , Y , Color , Friendly_headings(b1)
      End If
    Next B1

    'Clear old start location
    Pset Old_friendly_start_x , Old_friendly_start_y , White
    Circle(old_friendly_start_x , Old_friendly_start_y) , 3 , White

    'Draw out the starting location
    If My_team = "A" Then
      Cur_x = Teama_start_loc_x - My_x
      Cur_y = My_y - Teama_start_loc_y
    Else
      Cur_x = Teamb_start_loc_x - My_x
      Cur_y = My_y - Teamb_start_loc_y
    End If
    Cur_x = Cur_x / Zoom_factor                             'Factor_zoom
    Cur_y = Cur_y / Zoom_factor
    Cur_x = Cur_x + 64
    Cur_y = Cur_y + 64
    If Cur_x > 126 Then Cur_x = 126
    If Cur_x < 2 Then Cur_x = 2
    If Cur_y > 126 Then Cur_y = 126
    If Cur_y < 2 Then Cur_y = 2
    X = Cur_x
    Y = Cur_y
    Old_friendly_start_x = X
    Old_friendly_start_y = Y

    Pset X , Y , Green                                      'Draw it out
    Circle(x , Y) , 3 , Green
  End If

  'Draw out new markers for the enemy, if allowed
  If View_enemy = 1 Then
    For B1 = 1 To Enemy_count
      Cur_x = Enemy_x(b1) - My_x
      Cur_y = My_y - Enemy_y(b1)
      Cur_x = Cur_x / Zoom_factor                           'Factor_zoom
      Cur_y = Cur_y / Zoom_factor
      Cur_x = Cur_x + 64
      Cur_y = Cur_y + 64
      If Cur_x > 126 Then Cur_x = 126
      If Cur_x < 2 Then Cur_x = 2
      If Cur_y > 126 Then Cur_y = 126
      If Cur_y < 2 Then Cur_y = 2

      X = Cur_x
      Y = Cur_y
      Old_enemy_x(b1) = X
      Old_enemy_y(b1) = Y
      Old_enemy_headings(b1) = Enemy_headings(b1)

      If Enemies_hit.b1 = 1 Then Color = Orange Else Color = Red
      Draw_arrow X , Y , Color , Enemy_headings(b1)
    Next B1

    'Clear old enemy starting location
    Pset Old_enemy_start_x , Old_enemy_start_y , White
    Circle(old_enemy_start_x , Old_enemy_start_y) , 3 , White

    'Draw out enemy starting location
    If My_team = "A" Then
      Cur_x = Teamb_start_loc_x - My_x
      Cur_y = My_y - Teamb_start_loc_y
    Else
      Cur_x = Teama_start_loc_x - My_x
      Cur_y = My_y - Teama_start_loc_y
    End If

    Cur_x = Cur_x / Zoom_factor                             'Factor_zoom
    Cur_y = Cur_y / Zoom_factor
    Cur_x = Cur_x + 64
    Cur_y = Cur_y + 64
    If Cur_x > 126 Then Cur_x = 126
    If Cur_x < 2 Then Cur_x = 2
    If Cur_y > 126 Then Cur_y = 126
    If Cur_y < 2 Then Cur_y = 2

    X = Cur_x
    Y = Cur_y
    Old_enemy_start_x = X
    Old_enemy_start_y = Y

    Pset X , Y , Red
    Circle(x , Y) , 3 , Red
  End If

  'Draw out hill location
  Draw_hill

  'Draw out a new marker for you
  If Am_hit = 1 Then Color = Brightblue Else Color = Green
  Draw_arrow 64 , 64 , Color , My_heading
  My_old_heading = My_heading

  'Retrace range lines
  Circle(64 , 64) , 16 , Dark_gray                          'Draw inner most line
  Circle(64 , 64) , 32 , Dark_gray                          'Draw mid-inner line
  Circle(64 , 64) , 48 , Dark_gray                          'Draw mid-outer line
  Circle(64 , 64) , 63 , Dark_gray                          'Draw outer most line
End Sub
'*******************************************************************************

'*******************************************************************************
Sub Koth_update_score()
  Decr Game_remaining                                       'Since this function is called once a second, remove a second from time remaining

  If Friendlies_on_hill > 0 And Enemies_on_hill = 0 Then Incr Friendly_time_on_hill       'Update scoring
  If Enemies_on_hill > 0 And Friendlies_on_hill = 0 Then Incr Enemy_time_on_hill

  If Am_hit = 1 Then                                        'Check if the player is hit
    If My_team = "A" Then                                   'If hit then decrement the amount of timeout remaining
      Lng1 = Teama_start_loc_x - My_x
      Lng2 = Teama_start_loc_y - My_y
    Else
      Lng1 = Teamb_start_loc_x - My_x
      Lng2 = Teamb_start_loc_y - My_y
    End If

    Lng1 = Abs(lng1)
    Lng2 = Abs(lng2)
    If Lng1 < Loc_radius And Lng2 < Loc_radius Then Decr Timeout_remaining       'If X and Y differences are less than the location radius\

    If Timeout_remaining = 0 Then
      Am_hit = 0
      Friendlies_hit.my_number = 0
    End If
  End If
End Sub
'*******************************************************************************

'*******************************************************************************
Sub Koth_sw_scan()

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
Sub Factor_zoom()
  'Scale the screen to 100 meters, then divide by the zoom factor
  Cur_x = Cur_x * 100                                       'Scoot cur_x over a couple of decimal places
  Cur_x = Cur_x * 156                                       'Essentially, we multiply by 1.56(25) to change a range of 64 (128/2) to a range of 100
  Cur_x = Cur_x / 100                                       'Remove the extra decimals
  Cur_y = Cur_y * 100                                       'Same for cur_y
  Cur_y = Cur_y * 156
  Cur_y = Cur_y / 100

  Cur_x = Cur_x / Zoom_factor                               'Now scale to the zoom factor
  Cur_y = Cur_y / Zoom_factor
End Sub
'*******************************************************************************

'*******************************************************************************
Sub Draw_hill()
  'Determine correct color
  If Friendlies_on_hill > 0 And Enemies_on_hill = 0 Then
    Color = Green
  Elseif Enemies_on_hill > 0 And Friendlies_on_hill = 0 Then
    Color = Red
  Else
    Color = Black
  End If

  'Remove old hill
  B1 = Old_hill_x - 6
  B2 = Old_hill_y - 4
  B3 = Old_hill_x + 6
  B4 = Old_hill_y + 4
  Box(b1 , B2) -(b3 , B4) , White

  Cur_x = Hill_loc_x - My_x                                 'Find distance between you and hill
  Cur_y = My_y - Hill_loc_y
  Cur_x = Cur_x / Zoom_factor                               'Factor_zoom
  Cur_y = Cur_y / Zoom_factor
  Cur_x = Cur_x + 64                                        'Center the difference on the screen
  Cur_y = Cur_y + 64
  If Cur_x > 126 Then Cur_x = 126                           'Check bounds
  If Cur_x < 2 Then Cur_x = 2
  If Cur_y > 126 Then Cur_y = 126
  If Cur_y < 2 Then Cur_y = 2

  X = Cur_x                                                 'Demote to byte variables to be able to pass to draw_arrow sub
  Y = Cur_y
  Old_hill_x = X                                            'Store these so you can clear it later
  Old_hill_y = Y

  B1 = X - 5
  B2 = Y + 3
  B3 = X - 3
  B4 = Y - 1
  Line(b1 , B2) -(b3 , B4) , Color

  B1 = Y + 2
  Line(b3 , B4) -(x , B1) , Color

  B1 = X - 1
  B3 = X + 2
  B4 = Y - 3
  Line(b1 , Y) -(b3 , B4) , Color

  B1 = X + 2
  B2 = Y - 1
  Line(b3 , B4) -(b1 , B2) , Color

  B3 = X + 5
  B4 = Y + 3
  Line(b1 , B2) -(b3 , B4) , Color
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

'      If Have_ref_lat = 0 Then
'        Ref_lat = Coord2dbl(strs(6) , 1)
'        Have_ref_lat = 1
'      End If

      'Get Longitude
      If Strs(6) <> "" Then
        Return_x = Lng2lng(strs(6))
'        If Strs(7) = "W" Then Return_x = Return_x * -1
      Else
        Return_x = 0
        Return_valid = 0
      End If

      'Get Latitude
      If Strs(4) <> "" Then
        Return_y = Lat2lng(strs(4))
'        If Strs(5) = "S" Then Return_y = Return_y * -1
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
'*******************************************************************************

'*******************************************************************************
Function Lat2lng(lat_str As String) As Long
  Local Loc_lat As Double , Loc_l1 As Long

  Loc_lat = Coord2dbl(lat_str , 1)                          'Convert latitude into double
  Loc_lat = Loc_lat * Yds_per_div                           'Multiply by yards per degree
  Loc_l1 = Loc_lat                                          'Convert to long data type
  Lat2lng = Loc_l1                                          'Return value
End Function
'*******************************************************************************

'*******************************************************************************
Function Lng2lng(lng_str As String) As Long
  Local Loc_lng As Double , Loc_d1 As Double , Loc_l1 As Long

  Loc_lng = Coord2dbl(lng_str , 0)
  Loc_d1 = Deg2rad(ref_lat)                                 'Determine an error coefficient to multiply against longitude
  Loc_d1 = Cos(loc_d1)
  Loc_d1 = Loc_d1 * Yds_per_div                             'Multiply number of yards per degree by error coefficient
  Loc_lng = Loc_lng * Loc_d1                                'Multiply longitude against error coefficient
  Loc_l1 = Loc_lng                                          'Convert to long data type
  Loc_l1 = Loc_l1 * -1                                      'Make negative
  Lng2lng = Loc_l1                                          'Return value
End Function
'*******************************************************************************

'*******************************************************************************
Function Coord2dbl(coord_str As String , Byval Is_lat As Byte) As Double
  Local Dbl1 As Double , Dbl2 As Double , Loc_b1 As Byte
  Local Loc_str1 As String * 12 , Loc_str2 As String * 12

  If Is_lat = 1 Then
    Loc_str1 = Left(coord_str , 2)
  Else
    Loc_str1 = Left(coord_str , 3)
  End If
  Loc_str2 = Right(coord_str , 7)
  Dbl1 = Val(loc_str1)
  Dbl2 = Val(loc_str2)
  Dbl2 = Dbl2 / 60
  If Dbl1 > 0 Then
    Coord2dbl = Dbl1 + Dbl2
  Else
    Coord2dbl = Dbl1 - Dbl2
  End If
End Function
'*******************************************************************************

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