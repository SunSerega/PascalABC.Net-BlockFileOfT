uses BlockFileOfT;

type
  r1=record
    b:byte := $EF;
    i:integer := $01234567;
    i64:int64 := $0123456789ABCDEF;
  end;

begin
  var f := new BlockFileOf<r1>('temp.bin');
  Assert(f.TSize = sizeof(r1));
  var a:r1;
  f.Delete;
  Assert(not f.Exists);
  
  f.Rewrite;
  Assert(f.Pos=0);
  Assert(f.PosByte=0);
  f.Write(a);
  Assert(f.Pos=1);
  Assert(f.PosByte=sizeof(r1));
  f.Close;
  
  Assert(f.Exists);
  Assert(f.FileSize=1);
  Assert(f.FileByteSize=sizeof(r1));
  
  f.Reset;
  Assert(f.Pos=0);
  Assert(f.PosByte=0);
  var b := f.Read;
  Assert(f.Pos=1);
  Assert(f.PosByte=sizeof(r1));
  f.Close;
  
  Assert(a=b);
  
end.