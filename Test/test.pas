uses BlockFileOfT;

type
  r1=record
    b1:byte;
    i:integer;
    b2:byte;
  end;

begin
  var f := new BlockFileOf<r1>;
  var a:r1;
  a.b1 := $FF;
  a.i := 123456789;
  a.b2 := $EE;
  f.Rewrite('temp.bin');
  f.Write(a);
  f.Close;
  
  f.Reset;
  var b := f.Read;
  f.Close;
  
  if a <> b then
    writeln($'Error in file {System.Environment.CommandLine}') else
    writeln($'{System.Environment.CommandLine} ok');
end.