var myFirstInt: int = 999;
var myFirstFloat: real = 99.9;
var mySecondInt: int;

var f: file = file(filename = "freadIntFloat.txt", mode = "r");

f.open();
f.read(myFirstInt, myFirstFloat, mySecondInt);

writeln(myFirstInt);
writeln(myFirstFloat);
writeln(mySecondInt);
