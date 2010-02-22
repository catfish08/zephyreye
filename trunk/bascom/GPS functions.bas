'GPS Functions


$regfile = "m128def.dat"
'$lib "fp_trig.lbx"
$lib "double.lbx"

$hwstack = 128
$swstack = 128
$framesize = 128

Declare Function Coord2dbl(coord_str As String , Byval Is_lat As Byte) As Double

Const Tene7 = 10 ^ 7

Dim Lat1str As String * 15
Dim Lng1str As String * 15
Dim Lat2str As String * 15
Dim Lng2str As String * 15

Dim Dbl_lat1 As Double
Dim Dbl_lng1 As Double
Dim Dbl_lat2 As Double
Dim Dbl_lng2 As Double


Dim X As Long , Y As Long , D As Long , Lng1 As Long , Lng2 As Long , Lng3 As Long
Dim Sng1 As Single , Astr As String * 15 , Dbl3 As Double , Dbl4 As Double , Dbl5 As Double
Dim Split_strs(2) As String * 10

Lat1str = "4518.6401"
Lng1str = "-11804.8816"
Lat2str = "4518.6371"
Lng2str = "-11804.8819"

Dbl_lat1 = Coord2dbl(lat1str , 1)
Dbl_lng1 = Coord2dbl(lng1str , 0)
Dbl_lat2 = Coord2dbl(lat2str , 1)
Dbl_lng2 = Coord2dbl(lng2str , 0)

'Dbl_lat1 = 45.310618333333333
'Dbl_lng1 = -118.081358
'Dbl_lat2 = 45.310668333333333
'Dbl_lng2 = -118.081365


Print "1: " ; Str(dbl_lat1) ; " " ; Str(dbl_lng1)
Print "2: " ; Str(dbl_lat2) ; " " ; Str(dbl_lng2)

'd = sqrt( (lat1-lat2)^2 + (cos(lat1)*(lon1-lon2))^2)
Const R = 6975174.98                                        'Radius of earth in yards
Const Yds_per_div = 121616                                  'Yards per longitude (or latitude)

Dbl3 = Dbl_lat1 - Dbl_lat2
Dbl3 = Dbl3 * Yds_per_div
X = Dbl3

Dbl3 = Dbl_lng1 - Dbl_lng2
Dbl3 = Dbl3 * Yds_per_div
Dbl4 = Dbl_lat1 / 57.3
Dbl5 = Cos(dbl4)
Dbl3 = Dbl3 * Dbl5
Y = Dbl3

Print "D: " ; D
Print "X: " ; X
Print "Y: " ; Y



Function Coord2dbl(coord_str As String , Byval Is_lat As Byte) As Double
  Local Dbl1 As Double , Dbl2 As Double , Loc_b1 As Byte
  If Is_lat = 1 Then
    Split_strs(1) = Left(coord_str , 2)
  Else
    Split_strs(1) = Left(coord_str , 4)
  End If
  Split_strs(2) = Right(coord_str , 7)
  Dbl1 = Val(split_strs(1))
  Dbl2 = Val(split_strs(2))
  Dbl2 = Dbl2 / 60
  If Dbl1 > 0 Then
    Coord2dbl = Dbl1 + Dbl2
  Else
    Coord2dbl = Dbl1 - Dbl2
  End If
End Function