'GPS Functions


$regfile = "m128def.dat"
'$lib "fp_trig.lbx"
$lib "double.lbx"

$hwstack = 256
$swstack = 256
$framesize = 256

Declare Function Coord2dbl(coord_str As String , Byval Is_lat As Byte) As Double
Declare Function Lat2lng(lat_str As String) As Long
Declare Function Lng2lng(lng_str As String) As Long
Declare Sub Coords2lng(lat_str As String , Lng_str As String)

Const Yds_per_div = 121616                                  'Yards per longitude (or latitude)

Dim Lat1str As String * 15
Dim Lng1str As String * 15
Dim Lat2str As String * 15
Dim Lng2str As String * 15

Dim Return_x As Long
Dim Return_y As Long
Dim Return_valid As Bit

Dim My_x As Long , My_y As Long , His_x As Long , His_y As Long , Dif_y As Long , Dif_x As Long , Ref_lat As Double

Lat1str = "4518.6320"
Lng1str = "-11804.8750"
Lat2str = "4518.6371"
Lng2str = "-11804.8819"

Ref_lat = Coord2dbl(lat1str , 1)

My_x = Lat2lng(lat1str)
My_y = Lng2lng(lng1str)

His_x = Lat2lng(lat2str)
His_y = Lng2lng(lng2str)

Print "Ref_lat:  " ; Ref_lat
Print "My_x:  " ; My_x
Print "My_y:  " ; My_y
Print "His_x: " ; His_x
Print "His_y: " ; His_y

Dif_x = My_x - His_x
Dif_y = My_y - His_y

Print "Dif_x: " ; Dif_x
Print "Dif_y: " ; Dif_y


End

Function Lat2lng(lat_str As String) As Long
  Local Loc_lat As Double , Loc_l1 As Long

  Loc_lat = Coord2dbl(lat_str , 1)                          'Convert latitude into double
  Loc_lat = Loc_lat * Yds_per_div                           'Multiply by yards per degree
  Loc_l1 = Loc_lat                                          'Convert to long data type
  Lat2lng = Loc_l1                                          'Return value
End Function

Function Lng2lng(lng_str As String) As Long
  Local Loc_lng As Double , Loc_d1 As Double , Loc_l1 As Long

  Loc_lng = Coord2dbl(lng_str , 0)
  Loc_d1 = Deg2rad(ref_lat)                                 'Determine an error coefficient to multiply against longitude
  Loc_d1 = Cos(loc_d1)
  Loc_d1 = Loc_d1 * Yds_per_div                             'Multiply number of yards per degree by error coefficient
  Loc_lng = Loc_lng * Loc_d1                                'Multiply longitude against error coefficient
  Loc_l1 = Loc_lng                                          'Convert to long data type
  Lng2lng = Loc_l1                                         'Return value
End Function


Function Coord2dbl(coord_str As String , Byval Is_lat As Byte) As Double
  Local Dbl1 As Double , Dbl2 As Double , Loc_b1 As Byte
  Local Loc_str1 As String * 10 , Loc_str2 As String * 10

  If Is_lat = 1 Then
    Loc_str1 = Left(coord_str , 2)
  Else
    Loc_str1 = Left(coord_str , 4)
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