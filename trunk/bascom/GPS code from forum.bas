$regfile = "m32def.dat"                                     ' specify the used micro
$crystal = 8000000                                          ' used crystal frequency
$baud = 19200                                               ' use baud rate
$hwstack = 128                                              ' default use 32 for the hardware stack
$swstack = 128                                              ' default use 10 for the SW stack
$framesize = 128                                            ' default use 40 for the frame space

$lib "fp_trig.lbx"




Config Com1 = Dummy , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 0


Dim Le As Byte

Dim Lat1string As String * 12
Dim Lon1string As String * 12
Dim Lat2string As String * 12
Dim Lon2string As String * 12

Dim Lat1long As Long
Dim Lon1long As Long
Dim Lat2long As Long
Dim Lon2long As Long

Dim Lat1single As Single
Dim Lon1single As Single
Dim Lat2single As Single
Dim Lon2single As Single

Dim Tmp As Single
Dim W As Single

Const Pi = 3.1415926535


Declare Function 2long(daten As String) As Long
Declare Function Long2single(daten As Long) As Single
Declare Function Angle()as Single
Declare Function Distance(byval Angle As Single)as Single
Declare Function Direction(byval Angle As Single)as Single



Lat1string = "4518.6401"                                    ' Strings as delivered by GPS Device NMEA WGS84
Lon1string = "-11804.8819"

'Lat2string = "5044.2420"                                    'Target
'Lon2string = "00705.4690"



Lat2string = "4518.6372"                                    ' NEAREST WORKING TAGRET COORDINATE
Lon2string = "-11804.8819"                                  ' Distance 0,00144 KM





' drop last digit
Le = Len(lat1string)
Le = Le - 1
Lat1string = Left(lat1string , Le)

Le = Len(lon1string)
Le = Le - 1
Lon1string = Left(lon1string , Le)

Le = Len(lat2string)
Le = Le - 1
Lat2string = Left(lat2string , Le)

Le = Len(lon2string)
Le = Le - 1
Lon2string = Left(lon2string , Le)

Print Lat1string ; " " ; Lon1string
Print Lat2string ; " " ; Lon2string

Lat1long = 2long(lat1string)
Lon1long = 2long(lon1string)
Lat2long = 2long(lat2string)
Lon2long = 2long(lon2string)

Print Lat1long ; "  " ; Lon1long
Print Lat2long ; "  " ; Lon2long

Lat1single = Long2single(lat1long)
Lon1single = Long2single(lon1long)
Lat2single = Long2single(lat2long)
Lon2single = Long2single(lon2long)




W = Angle()
Print "Angle in DEG: " ; W

Tmp = Distance(w)

Print "Distance in KM: " ; Tmp

Tmp = Direction(w)

Print "Course clockwise from North: " ; Tmp





Do
Loop
End







Function 2long(daten As String)

   'Convert String to Numeric as LONG INT

   Local Tmp1 As String * 3
   Local Tmp2 As String * 6
   Local Tmp3 As Single
   Local Tmp4 As Single
   Local Tmp5 As Long

   Local L As Byte
   L = Len(daten)
   If L = 8 Then                                            'Lat Found ( 2 Digits Degrees)
      Tmp1 = Left(daten , 2) : Tmp2 = Right(daten , 6)
   Else                                                     'Lon Found ( 3 Digits Degrees)
      Tmp1 = Left(daten , 3) : Tmp2 = Right(daten , 6)
   End If
   Tmp4 = Val(tmp2)
   Tmp3 = Val(tmp1)
   Tmp4 = Tmp4 / 60                                         'Convert Minutes to Dec format
   Tmp4 = Tmp3 + Tmp4                                       ' Add Degrees to minutes
   Tmp5 = 10 ^ 7
   Tmp5 = Tmp4 * Tmp5                                       ' Multiply with 10E7

   2long = Tmp5                                             ' Save as LONG INT

End Function

Function Long2single(daten As Long)

   Local Tmp1 As Long
   Tmp1 = 10 ^ 7
   Long2single = Daten / Tmp1

End Function


Function Angle()


   Local Lat1 As Single
   Local Lon1 As Single
   Local Lat2 As Single
   Local Lon2 As Single
   Local Latsub As Long
   Local Lonsub As Long
   Local Longtmp As Long
   Local Faktor As Long
   Faktor = 10 ^ 7

   Local Tmp1 As Single                                     ' Temp Vars
   Local Tmp2 As Single
   Local Tmp3 As Single

   Lat1 = Deg2rad(lat1single)                               'Convert DEG Single Coordinates to RAD#
   Lon1 = Deg2rad(lon1single)
   Lat2 = Deg2rad(lat2single)
   Lon2 = Deg2rad(lon2single)

   Print Lat1 ; " " ; Lon1
   Print Lat2 ; " " ; Lon2

   'Formula used here:
   '
   '
   'd=2*asin(sqrt((sin((lat1-lat2)/2))^2 + cos(lat1)*cos(lat2)*(sin((lon1-lon2)/2))^2))



   If Lat1long > Lat2long Then
      Longtmp = Lat1long - Lat2long
   Else
      Longtmp = Lat2long - Lat1long
   End If

   Longtmp = Longtmp / 2
   Tmp1 = Longtmp / Faktor
   Tmp1 = Deg2rad(tmp1)

   Tmp1 = Sin(tmp1)
   Tmp1 = Tmp1 ^ 2

   If Lon1long > Lon2long Then
      Longtmp = Lon1long - Lon2long
   Else
      Longtmp = Lon2long - Lon1long
   End If

   Longtmp = Longtmp / 2
   Tmp2 = Longtmp / Faktor
   Tmp2 = Deg2rad(tmp2)
   Tmp2 = Sin(tmp2)
   Tmp2 = Tmp2 ^ 2

   Tmp2 = Tmp2 * Cos(lat2)
   Tmp2 = Tmp2 * Cos(lat1)


   Tmp1 = Tmp1 + Tmp2

   Tmp1 = Sqr(tmp1)

   Tmp1 = Asin(tmp1)

   Tmp1 = Tmp1 * 2

   Angle = Rad2deg(tmp1)

End Function


Function Distance(angle As Single)

   Local Tmp1 As Single

   Tmp = Angle / 360
   Distance = Tmp * 40000


End Function



Function Direction(byval Angle As Single)


'We Use the following Formula here to caluclate the course from point1 to point2
'
'IF sin(lon2-lon1)<0
'   tc1=acos((sin(lat2)-sin(lat1)*cos(d))/(sin(d)*cos(lat1)))
'ELSE
'   tc1=2*pi-acos((sin(lat2)-sin(lat1)*cos(d))/(sin(d)*cos(lat1)))
'End If
'
'

   Local Lat1 As Single
   Local Lon1 As Single
   Local Lat2 As Single
   Local Lon2 As Single
   Local Ang As Single
   Local Latsub As Long
   Local Lonsub As Long
   Local Longtmp As Long
   Local Faktor As Long
   Faktor = 10 ^ 7

   Local Tmp1 As Single                                     ' Temp Vars
   Local Tmp2 As Single
   Local Tmp3 As Single

   Lat1 = Deg2rad(lat1single)                               'Convert DEG Single Coordinates to RAD#
   Lon1 = Deg2rad(lon1single)
   Lat2 = Deg2rad(lat2single)
   Lon2 = Deg2rad(lon2single)
   Ang = Deg2rad(angle)

' Check for Pole Position ;)


   Tmp1 = Cos(lat1)

   If Tmp1 < 0.00000000234 Then                             ' Fake number as small as possible
      If Lat1 > 0 Then
         Direction = Pi
      Else
         Direction = 2 * Pi
      End If
   Else


      Longtmp = Lon2long - Lon1long

      Tmp1 = Sin(lat2)
      Tmp2 = Sin(lat1)
      Tmp2 = Tmp2 * Cos(ang)
      Tmp1 = Tmp1 - Tmp2

      Tmp2 = Sin(ang)
      Tmp2 = Tmp2 * Cos(lat1)
      Tmp1 = Tmp1 / Tmp2
      Tmp1 = Acos(tmp1)

      Longtmp = Lon2long - Lon1long
      Tmp3 = Longtmp / Faktor
      Tmp3 = Sin(tmp3)
      If Tmp3 < 0 Then
         Direction = Tmp1
      Else
         Tmp2 = 2 * Pi
         Direction = Tmp2 - Tmp1
      End If

   End If
   Direction = Rad2deg(direction)
   If Lat2long < Lat1long Then
      Direction = 360 - Direction
   End If

End Function