uses BlockFileOfT;

begin
  try
    var f := new BlockFileOf<byte>;
    
    f.Rewrite('temp.bin');
    f.Close;
    
    f.Append;
    f.Write(5);
    f.Close;
    
    f.Reset;
    Assert(f.Read = 5);
    
  except
    Assert(false);
  end;
end.