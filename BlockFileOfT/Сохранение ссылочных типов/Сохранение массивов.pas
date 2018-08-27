uses BlockFileOfT;
uses System.Runtime.InteropServices;//Это пространство имён содержит несколько костылей, которые понадобятся
                                    //Можно писать и на прямую "System.Runtime.InteropServices.FieldOffset", но это не очень удобно

type
  //Чтоб сделать ещё 1 тип массива - надо:
  //  -Скопировать, для начала
  //  -Поменять в копии название (число означающее длину и название типа элементов массива)
  //  -Поменять в копии значение константы MaxLength на нужную длину
  //  -Поменять в копии значение константы TSize на объём памяти, необходимый под каждый элемент массива
  //  -Поменять тип Arr15Int в операторах explicit на новый (ну, компилятор и не даст его оставить Arr15Int)
  //  -Поменять тип array of integer в операторах explicit на array of <Ваш тип элементов>
  
  [StructLayout(LayoutKind.&Explicit)]
  ///Массив сохраняющий 15 элементов типа integer
  Arr15Int=record
    private const MaxLength = 15;
    private const TSize=4;//То что возвращает sizeof(T) где T - тип элементов массива (в нашем случаи - integer)
    private const Size=MaxLength*TSize;
    private [FieldOffset(Size-1)] last: byte;
    
    public class function operator explicit(a:array of integer):Arr15Int;
    begin
      if a.Length < MaxLength then 
        a := a + new integer[MaxLength-a.Length];//Если массив не достаточно длинный - дополняем его нулями
                                                 //А если будет слишком длинный - его само обрежет
      
      var ptr:^Arr15Int := pointer(@a[0]);//Это сохраняет только содержимое массива, а длина всегда 15 (в этом типе)
      Result := ptr^;                     //Можно сохранять и длину, но надо будет в 2 раза больше типов (тип массива будет содержать длину и переменную типа содержимого массива)
    end;
    
    public class function operator explicit(a:Arr15Int):array of integer;
    begin
      Result := new integer[MaxLength];
      var ptr:^Arr15Int := pointer(@Result[0]);
      ptr^ := a;
    end;
    
  end;
  r1=record
    public a: Arr15Int;
    public i: integer;
    
    public constructor(a:array of integer; i: integer);
    begin
      self.a := Arr15Int(a);
      self.i := i;
    end;
    
    public function ToString:string; override;
    type IntArr=array of integer;
    begin
      Result := $'r1({_ObjectToString(IntArr(a))}, {i})';
    end;
  end;

type IntArr=array of integer;
begin
  var f := new BlockFileOf<r1>('temp.bin');
  var a := new r1(new integer[](1,2,3,4,5),6);
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
  
  writeln(IntArr(a.a).Length);
  writeln(IntArr(b.a).Length);
end.