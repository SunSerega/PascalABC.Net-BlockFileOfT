uses BlockFileOfT;	
uses System.Runtime.InteropServices;

type
  [StructLayout(LayoutKind.&Explicit)]	
  Str15 = record	
    private const MaxLength = 15;	
    //Я провёл много тестов чтоб убедится:	
    //-BinaryFormatter всегда делает для string заголовок в 25 байт	
    //-В разных случаях тело строки может сохранять как MaxLength*1, MaxLength*2 и MaxLength*3 байт.	
    //-Предыдущее зависит от того, на сколько редкие символы были использованы. Для более редких символов надо больше памяти	
    //Поэтому, на всякий случай, я сделал Size с расчётом на то, что все MaxLength символов могут быть редкими.	
    private const Size = 25 + MaxLength * 3;	
    private [FieldOffset(Size-1)] last: byte;	
    
    private class f := new System.Runtime.Serialization.Formatters.Binary.BinaryFormatter;	
    
    public class function operator explicit(s: string): Str15;
    begin
      if s.Length > MaxLength then s := s.Substring(0, MaxLength);	
      var str := new System.IO.MemoryStream(Size);	
      str.SetLength(Size);	
      f.Serialize(str, s);	
      var a := str.ToArray;
      var hnd := GCHandle.Alloc(a, GCHandleType.Pinned);
      try
        var ptr: ^Str15 := pointer(hnd.AddrOfPinnedObject);	
        Result := ptr^;	
      finally
        hnd.Free;
      end;
    end;
    
    public class function operator explicit(s: Str15): string;
    begin
      var a := new byte[Size];	
      var hnd := GCHandle.Alloc(a, GCHandleType.Pinned);
      try
        var ptr: ^Str15 := pointer(hnd.AddrOfPinnedObject);	
        ptr^ := s;	
      finally
        hnd.Free;
      end;
      var str := new System.IO.MemoryStream(a);	
      Result := string(f.Deserialize(str));	
    end;
  
  end;
  r1 = record	
    public s: Str15;	
    public i: integer;	
    
    public constructor(s: string; i: integer);
    begin
      self.s := Str15(s);	
      self.i := i;	
    end;
    
    public function ToString: string; override :=	
    $'r1("{string(s)}", {i})';	
  end;

begin
  var f := new BlockFileOf<r1>('temp.bin');	
  var a1 := new r1('abcd', 1234);	
  var b1 := new r1('abcd' * 4, 5678);	
  
  {
  f.Reset;	
  {}
  f.Rewrite;	
  f.Write(a1, b1);	
  {}	
  f.Pos := 0;	
  var a2 := f.Read;	
  var b2 := f.Read;	
  f.Close;	
  
  writeln(a1);	
  writeln(b1);	
  writeln(string(a1.s).Length);	
  writeln(string(b1.s).Length);	
  
  writeln(a2);	
  writeln(b2);	
  writeln(string(a2.s).Length);	
  writeln(string(b2.s).Length);	
  
end.