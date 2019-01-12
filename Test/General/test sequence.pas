uses BlockFileOfT;

type
  r1=record
    
    i64:int64;
    i:integer;
    b:byte;
    
    constructor;
    begin
      b := Random(256);
      loop 4 do
      begin
        i := i shl 8;
        i += Random(256);
      end;
      loop 8 do
      begin
        i64 := i64 shl 8;
        i64 += Random(256);
      end;
    end;
    
  end;

begin
  var f := new BlockFileOf<r1>('temp.bin');
  loop 100 do
  begin
    var test_arr := ArrGen(1024,i->new r1);
    
    f.Rewrite;
    Assert(f.Pos = 0);
    Assert(f.PosByte = 0);
    f.Write(test_arr);
    Assert(f.Pos = 1024);
    Assert(f.PosByte = 1024*sizeof(r1));
    f.Close;
    
    Assert(f.Exists);
    Assert(f.Size = 1024);
    Assert(f.ByteSize = 1024*sizeof(r1));
    
    var test_arr_copy:array of r1;
    var StartRead:procedure := ()->
    begin
      f.Reset;
      Assert(f.Pos = 0);
      Assert(f.PosByte = 0);
    end;
    var EndRead:procedure := ()->
    begin
      Assert(f.Pos = 1024);
      Assert(f.PosByte = 1024*sizeof(r1));
      f.Close;
      
      Assert(test_arr.SequenceEqual(test_arr_copy));
    end;
    
    StartRead;
    test_arr_copy := f.Read(1024);
    EndRead;
    
    StartRead;
    test_arr_copy := ArrGen(1024,i->
    begin
      Result := f.Read;
    end);
    EndRead;
    
    StartRead;
    test_arr_copy := ArrGen(1024,i->
    begin
      f.Seek(i);
      Result := f.Read;
    end);
    EndRead;
    
    StartRead;
    var inds := ArrGen(1024,i->i).Shuffle;
    test_arr_copy := ArrFill(1024,default(r1));
    inds.ForEach(i->
    begin
      
      f.Seek(i);
      test_arr_copy[i] := f.Read;
      
    end);
    f.Close;
    Assert(test_arr.SequenceEqual(test_arr_copy));
    
    StartRead;
    test_arr_copy := f.ReadLazy(1024).ToArray;
    EndRead;
    
    StartRead;
    test_arr_copy := f.ToSeq.ToArray;
    EndRead;
    
    StartRead;
    test_arr_copy := f.ToSeqBlocks.SelectMany(a->a).ToArray;
    EndRead;
    
  end;
  
end.