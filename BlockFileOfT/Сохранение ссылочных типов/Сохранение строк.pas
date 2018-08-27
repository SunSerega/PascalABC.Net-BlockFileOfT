uses BlockFileOfT;
uses System.Runtime.InteropServices;//Это пространство имён содержит несколько костылей, которые понадобятся
                                    //Можно писать и на прямую "System.Runtime.InteropServices.FieldOffset", но это не очень удобно

type
  //Чтоб сделать ещё 1 тип строки - надо:
  //  -Скопировать, для начала
  //  -Поменять в копии значение константы MaxLength на нужную длину
  //  -Поменять в копии число в названии (к примеру, Str15 на Str256)
  //  -Не забыть поменять тип в операторах explicit (ну, компилятор и не даст его оставить Str15)
  
  [StructLayout(LayoutKind.&Explicit)]
  Str15=record
    private const MaxLength = 15;
    private const Size=25+MaxLength*3;
    private [FieldOffset(Size-1)] last: byte;
    
    //private class f := new System.Runtime.Serialization.Formatters.Binary.BinaryFormatter;//ToDo разкомментировать когда исправят #1114
    
    public class function operator explicit(s:string):Str15;
    begin
      if s.Length > MaxLength then s := s.Substring(0,MaxLength);
      var f := new System.Runtime.Serialization.Formatters.Binary.BinaryFormatter;//ToDo убрать когда исправят #1114
      var str := new System.IO.MemoryStream;
      f.Serialize(str, s);//Сериализовываем строку в поток
      var a := str.ToArray;//Читаем в виде массива байт
      var ptr: ^Str15 := pointer(@a[0]);//И потом читерски превращаем массив байт в запись
      Result := ptr^;                   //Это на много медленнее чем хотелось бы, но хоть как то
    end;
    
    public class function operator explicit(s:Str15):string;
    begin
      var f := new System.Runtime.Serialization.Formatters.Binary.BinaryFormatter;//ToDo убрать когда исправят #1114
      var a := new byte[Size];
      var ptr: ^Str15 := pointer(@a[0]);//Чтоб назад превратить - так же читерски преобразовываем запись в массив байт
      ptr^ := s;
      var str := new System.IO.MemoryStream(a);//В этот раз лишний массив не создаётся (вроде)
      Result := string(f.Deserialize(str));//Назад получаем строку которую записывали
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
    $'r1("{string(s)}", {i})';
  end;

begin
  var f := new BlockFileOf<r1>('temp.bin');
  var a := new r1('abcd'*4,6);
  {
  f.Reset;
  {}
  f.Rewrite;
  f.Write(a);
  {}
  f.Pos := 0;
  var b := f.Read;
  f.Close;
  
  writeln(a);
  writeln(b);
  
  writeln(string(a.s).Length);
  writeln(string(b.s).Length);
end.