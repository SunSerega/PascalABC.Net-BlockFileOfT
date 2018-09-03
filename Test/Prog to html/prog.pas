uses BlockFileOfT;
uses System.Runtime.InteropServices;//Это пространство имён содержит несколько атрибутов, которые понадобятся
                                    //Можно писать и на прямую "System.Runtime.InteropServices.FieldOffset", но это не очень удобно

type
  //Чтоб сделать ещё 1 тип строки - надо:
  //  -Скопировать тип описаный ниже
  //  -Поменять значение константы MaxLength на нужную длину
  //  -Поменять число в названии (к примеру, Str15 на Str256)
  //  -Поменять тип в операторах explicit (хотя, компилятор и не даст его оставить Str15)
  
  [StructLayout(LayoutKind.&Explicit)]
  Str15=record
    private const MaxLength = 15;
    //Я провёл много тестов чтоб убедится:
    //-BinaryFormatter всегда делает для string заголовок в 25 байт
    //-В разных случаях тело строки может сохранять как MaxLength*1, MaxLength*2 и MaxLength*3 байт.
    //Последнее зависит от того, какие редкие символы были использованы. Для более редких символов надо больше памяти
    //Поэтому, на всякий случай, я сделал размер с расчётом на то, что все 15 символов могут быть редкими.
    private const Size=25+MaxLength*3;
    private [FieldOffset(Size-1)] last: byte;
    
    private class f := new System.Runtime.Serialization.Formatters.Binary.BinaryFormatter;
    
    public class function operator explicit(s:string):Str15;
    begin
      if s.Length > MaxLength then s := s.Substring(0,MaxLength);
      var str := new System.IO.MemoryStream(Size);
      str.SetLength(Size);
      f.Serialize(str, s);
      var a := str.ToArray;
      var ptr: ^Str15 := pointer(@a[0]);
      Result := ptr^;
    end;
    
    public class function operator explicit(s:Str15):string;
    begin
      var a := new byte[Size];
      var ptr: ^Str15 := pointer(@a[0]);
      ptr^ := s;
      var str := new System.IO.MemoryStream(a);
      Result := string(f.Deserialize(str));
    end;
    
  end;
  r1=record
    public s: Str15;
    public i: integer;
    
    public constructor(s:string; i: integer);
    begin
      self.s := Str15(s);
      self.i := i;
    end;
    
    public function ToString:string; override :=
    $'r1("{string(s).Replace(#0,#32)}", {i})';
  end;

begin
  var f := new BlockFileOf<r1>('temp.bin');
  var a1 := new r1('abcd',1234);
  var b1 := new r1('abcd'*4,5678);
  
  {
  f.Reset;
  {}
  f.Rewrite;
  f.Write(a1,b1);
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