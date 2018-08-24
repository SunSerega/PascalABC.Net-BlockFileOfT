unit BlockFileOfT;

interface

uses System.Runtime.InteropServices;
uses System.IO;

type
  ///Тип, записывающий данные в файл по принципу схожему с "file of <T>"
  ///Но в отличии от "file of <T>" - данный тип сохраняет всю запись одним блоком,
  ///так, как она записа в памяти.
  ///Это даёт значительное преимущество по скорости, но ограничевает,
  ///типы, которые могут быть использованы в виде полей <T>
  ///
  ///Ожидается, что в видет шаблонного параметра <T> будет передана запись,
  ///не содержащая динамичных полей.
  ///Иначе целостность данных будет терятся
  ///Это значит, что поля записи T и всех вложенных записей - не могут быть:
  ///  -Указатели
  ///  -Ссылочные типы (то есть все классы)
  ///
  ///Исключение:
  ///С помощью атрибутов можно заставить ссылочные типы передаваться по значению, тогда сработает
  BlockFileOf<T>=class
  where T: record;
    
    private class sz: integer;
    
    private fi:FileInfo;
    private str:FileStream;
    private bw:BinaryWriter;
    private br:BinaryReader;
    
    
    private class constructor;
    begin
      sz := Marshal.SizeOf(typeof(T));
    end;
    
    private function GetName:string;
    private function GetFullName:string;
    
    private function GetExists:boolean;
    
    private function GetFileSize:int64 := GetByteFileSize div sz;
    private procedure SetFileSize(size:int64) := SetByteFileSize(size * sz);
    
    private function GetByteFileSize:int64;
    private procedure SetByteFileSize(size:int64);
    
    private function GetPos:int64 := GetPosByte div sz;
    private procedure SetPos(pos:int64) := SetPosByte(pos * sz);
    private function GetPosByte:int64;
    private procedure SetPosByte(pos:int64);
    
    private function InternalReadLazy(c:integer; start_pos:int64):sequence of T;
    
    ///Инициализирует переменную файла, не привязывая её к файлу на диске
    public constructor := exit;
    ///Инициализирует переменную файла, привязывая её к файлу fname
    public constructor(fname:string) := Assign(fname);
    
    
    ///Размер блока из одного элемента типа T, в байтах
    public property TSize:integer read integer(sz);
    
    ///Количество сохранённых в файл элементов типа T
    ///Чтоб установить длину файла - надо открыть файл. Но прочитать длину можно не открывая
    public property FileSize:int64 read GetFileSize write SetFileSize;
    ///Размер файла, в байтах
    ///Чтоб установить длину файла - надо открыть файл. Но прочитать длину можно не открывая
    public property FileByteSize:int64 read GetByteFileSize write SetByteFileSize;
    ///Имя файла (только имя самого файла, без имени папки)
    public property Name:string read GetName;
    ///Полное имя файла (вместе с именами всех под-папок, вплодь до корня диска)
    public property FullName:string read GetFullName;
    ///Существует ли файл
    public property Exists:boolean read GetExists;
    ///Возвращает номер текущего элемента в файле (нумеруя с 0)
    
    public property Pos:int64 read GetPos write SetPos;
    ///Возвращает номер текущего байта в файле (нумеруя с 0)
    public property PosByte:int64 read GetPosByte write SetPosByte;
    ///Основной поток открытого файла (или nil если файл не открыт)
    ///Внимание!!! Любое действие которое изменит этот поток - приведёт к неожиданным последствиям, используйте его только если знаете что делаете
    public property BaseStream:FileStream read str;
    ///Переменная, которая записывает данные в основной поток (или nil если файл не открыт)
    ///Внимание!!! Любое действие которое изменит основной поток файла - приведёт к неожиданным последствиям, используйте его только если знаете что делаете
    public property BinWriter:BinaryWriter read bw;
    ///Переменная, которая читает данные из основного потока (или nil если файл не открыт)
    ///Внимание!!! Любое действие которое изменит основной поток файла - приведёт к неожиданным последствиям, используйте его только если знаете что делаете
    public property BinReader:BinaryReader read br;
    ///Переменная, показывающая данные о файле (или nil, если переменная не привязана к файлу)
    public property FileInfo:System.IO.FileInfo read fi;
    
    
    
    ///Привязывает данную переменную к файлу {fname}
    ///Привязывать можно и к не существующим файлам, при откритии определёнными способами (как Rewrite) новый файл будет создан
    public procedure Assign(fname:string);
    ///Убирает свять переменной и файла, если связь есть
    public procedure UnAssign;
    ///Открывает файл, способом описанным в переменной mode
    ///Чтоб получить переменную этого типа - пишите System.IO.FileMode.<способ_открытия_файла>
    public procedure Open(mode:FileMode);
    ///Удаляет связаный файл, если он существует
    public procedure Erase := Delete;
    ///Удаляет связаный файл, если он существует
    public procedure Delete;
    ///Переименовывает файл
    ///Если указать другое расположение - файл будет перемещён
    public procedure Rename(NewName:string);
    
    ///Создает (или обнуляет) привязаный файл
    public procedure Rewrite;
    ///Привязывает данную переменную к файлу {fname} и создает (или обнуляет) этот файл
    public procedure Rewrite(fname:string);
    
    ///Открывает файл (ожидается, что он уже существует) и устанавливает позицию на начало файла
    public procedure Reset;
    ///Привязывает данную переменную к файлу {fname}, открывает этот файл на чтение (ожидается, что файл уже существует) и устанавливает позицию на начало файла
    public procedure Reset(fname:string);
    
    ///Открывает файл (ожидается, что он уже существует) и устанавливает позицию в конце файла
    public procedure Append;
    ///Привязывает данную переменную к файлу {fname}, открывает этот файл на чтение (ожидается, что файл уже существует) и устанавливает позицию в конце файла
    public procedure Append(fname:string);
    
    ///Переставляет позицию в файле на элемент #pos (нумеруя с 0)
    public procedure Seek(pos:int64) := self.Pos := pos;
    ///Переставляет позицию в файле на байт #pos (нумеруя с 0)
    public procedure SeekByte(pos:int64) := self.PosByte := pos;
    ///Достигнут ли конец файла
    public function EOF := FileByteSize-PosByte < sz;
    
    ///Записывает все изменения в файл
    public procedure Flush;
    ///Сохраняет и закрывает файл, если он открыт
    public procedure Close;
    
    
    ///Записывает один элемент одним блоком в файл
    public procedure Write(o: T);
    ///Записывает массив элементов одним блоком в файл
    public procedure Write(params o:array of T);
    ///Записывает последовательность элементов, у которой можно узнать длину, одним блоком в файл
    public procedure Write(o:ICollection<T>);
    ///Записывает последовательность элементов, у которой нельзя узнать длину, по 1 элементу типа T в файл
    public procedure Write(o:sequence of T);
    ///Записывает count элементов массива, начиная с элемента #from, одним блоком в файл
    public procedure Write(o:array of T; from,count:integer);
    ///Записывает count элементов последовательности, у которой можно узнать длину, начиная с элемента #from, одним блоком в файл
    public procedure Write(o:ICollection<T>; from,count:integer);
    ///Записывает count элементов последовательности, у которой нельзя узнать длину, начиная с элемента #from, одним блоком в файл
    public procedure Write(o:sequence of T; from,count:integer);
    
    ///Читает один элемент из файла одним блоком
    public function Read:T;
    ///Читает массив элементов из файла одним блоком
    public function Read(c:integer):array of T;
    ///Возвращает ленивую последовательность из c элементов
    ///При попытке доступа к элементам этой последовательности - начнёт читать элементы из файла, по блоку на элемент типа T
    public function ReadLazy(c:integer):sequence of T := InternalReadLazy(c,Pos);
    ///Возвращает ленивую последовательность из всех элементов начиная данной позиции и до конца файла
    ///При попытке доступа к элементам этой последовательности - начнёт читать элементы из файла, по блоку на элемент типа T
    public function ReadLazy:sequence of T := InternalReadLazy(FileSize-Pos, Pos);
    
  end;

implementation

{$region Exception's}

type
  FileNotAssignedException = class(Exception)
    constructor :=
    Create($'Данная переменная не была привязана к файлу{10}Используйте метод Assign');
  end;
  FileNotOpenedException = class(Exception)
    constructor(fname:string) :=
    Create($'Файл {fname} ещё не открыт, откройте его с помощью Open, Reset или Append');
  end;
  FileNotClosedException = class(Exception)
    constructor(fname:string) :=
    Create($'Файл {fname} ещё открыт, закройте его методом Close перед тем как продолжать');
  end;

{$endregion Exception's}

{$region property implementation}

function BlockFileOf<T>.GetName:string;
begin
  if fi = nil then raise new FileNotAssignedException;
  fi.Refresh;
  Result := fi.Name;
end;

function BlockFileOf<T>.GetFullName:string;
begin
  if fi = nil then raise new FileNotAssignedException;
  //fi.Refresh;//А тут не надо
  Result := fi.FullName;
end;



function BlockFileOf<T>.GetByteFileSize:int64;
begin
  if fi = nil then raise new FileNotAssignedException;
  if str <> nil then
  begin
    Result := str.Length;
    exit;
  end;
  fi.Refresh;
  Result := fi.Length;
end;

procedure BlockFileOf<T>.SetByteFileSize(size:int64);
begin
  if fi = nil then raise new FileNotAssignedException;
  if str = nil then raise new FileNotOpenedException(fi.FullName);
  str.SetLength(size);
end;



function BlockFileOf<T>.GetPosByte:int64;
begin
  if fi = nil then raise new FileNotAssignedException;
  if str = nil then raise new FileNotOpenedException(fi.FullName);
  Result := str.Position;
end;

procedure BlockFileOf<T>.SetPosByte(pos:int64);
begin
  if fi = nil then raise new FileNotAssignedException;
  if str = nil then raise new FileNotOpenedException(fi.FullName);
  str.Position := pos;
end;

{$endregion property implementation}

{$region Setup IO}

{$region Basic}

procedure BlockFileOf<T>.Assign(fname:string);
begin
  if str <> nil then raise new FileNotClosedException(fi.FullName);
  fi := new System.IO.FileInfo(fname);
end;

procedure BlockFileOf<T>.UnAssign;
begin
  if str <> nil then raise new FileNotClosedException(fi.FullName);
  fi := nil;
end;

procedure BlockFileOf<T>.Open(mode:FileMode);
begin
  if fi = nil then raise new FileNotAssignedException;
  if str <> nil then raise new FileNotClosedException(fi.FullName);
  str := fi.Open(mode);
  bw := new BinaryWriter(str);
  br := new BinaryReader(str);
end;

procedure BlockFileOf<T>.Delete;
begin
  if fi = nil then raise new FileNotAssignedException;
  fi.Delete;
end;

function BlockFileOf<T>.GetExists:boolean;
begin
  if fi = nil then raise new FileNotAssignedException;
  fi.Refresh;
  Result := fi.Exists;
end;

procedure BlockFileOf<T>.Rename(NewName:string);
begin
  if fi = nil then raise new FileNotAssignedException;
  if str <> nil then raise new FileNotClosedException(fi.FullName);
  fi.MoveTo(NewName);
end;

{$endregion Assign}

{$region Rewrite}

procedure BlockFileOf<T>.Rewrite :=
Open(FileMode.Create);

procedure BlockFileOf<T>.Rewrite(fname:string);
begin
  Assign(fname);
  Rewrite;
end;

{$endregion Rewrite}

{$region Reset}

procedure BlockFileOf<T>.Reset :=
Open(FileMode.Open);

procedure BlockFileOf<T>.Reset(fname:string);
begin
  Assign(fname);
  Reset;
end;

{$endregion Reset}

{$region Append}

procedure BlockFileOf<T>.Append :=
Open(FileMode.Append);

procedure BlockFileOf<T>.Append(fname:string);
begin
  Assign(fname);
  Append;
end;

{$endregion Append}

{$region Closing}

procedure BlockFileOf<T>.Flush;
begin
  if fi = nil then raise new FileNotAssignedException;
  if str = nil then raise new FileNotOpenedException(fi.FullName);
  str.Flush;
end;

procedure BlockFileOf<T>.Close;
begin
  if str <> nil then
  begin
    str.Close;
    str := nil;
    br := nil;
    bw := nil;
  end;
end;

{$endregion Closing}

{$endregion Setup IO}

{$region Write}

procedure BlockFileOf<T>.Write(o: T);
begin
  if fi = nil then raise new FileNotAssignedException;
  if str = nil then raise new FileNotOpenedException(fi.FullName);
  
  var a := new byte[sz];
  var ptr:^T := pointer(@a[0]);
  ptr^ := o;
  bw.Write(a);
end;

procedure BlockFileOf<T>.Write(params o:array of T);
begin
  if fi = nil then raise new FileNotAssignedException;
  if str = nil then raise new FileNotOpenedException(fi.FullName);
  
  var a := new byte[sz*o.Length];
  var ptr_id := integer(@a[0]);
  for var i := 0 to o.Length - 1 do
  begin
    var ptr:^T := pointer(ptr_id);
    ptr^ := o[i];
    ptr_id += sz;
  end;
  bw.Write(a);
end;

procedure BlockFileOf<T>.Write(o:ICollection<T>);
type TArr = array of T;
begin
  if o is TArr(var a) then
  begin
    Write(a);
    exit;
  end;
  
  if fi = nil then raise new FileNotAssignedException;
  if str = nil then raise new FileNotOpenedException(fi.FullName);
  
  var a := new byte[sz*o.Count];
  var ptr_id := integer(@a[0]);
  foreach var el in o do
  begin
    var ptr:^T := pointer(ptr_id);
    ptr^ := el;
    ptr_id += sz;
  end;
  bw.Write(a);
end;

procedure BlockFileOf<T>.Write(o:sequence of T) :=
if o is ICollection<T>(var c) then
  Write(c) else
foreach var el in o do
  Write(el);

procedure BlockFileOf<T>.Write(o:array of T; from,count:integer);
begin
  if fi = nil then raise new FileNotAssignedException;
  if str = nil then raise new FileNotOpenedException(fi.FullName);
  
  var a := new byte[sz*count];
  var ptr_id := integer(@a[0]);
  for var i := from to from+count - 1 do
  begin
    var ptr:^T := pointer(ptr_id);
    ptr^ := o[i];
    ptr_id += sz;
  end;
  bw.Write(a);
end;

procedure BlockFileOf<T>.Write(o:ICollection<T>; from,count:integer);
type TArr = array of T;
begin
  if o is TArr(var a) then
  begin
    Write(a, from, count);
    exit;
  end;
  
  if fi = nil then raise new FileNotAssignedException;
  if str = nil then raise new FileNotOpenedException(fi.FullName);
  
  var a := new byte[sz*o.Count];
  var ptr_id := integer(@a[0]);
  foreach var el in o do
    if from > 0 then
      from -= 1 else
    if count > 0 then
    begin
      var ptr:^T := pointer(ptr_id);
      ptr^ := el;
      ptr_id += sz;
      count -= 1;
    end
    else break;
  bw.Write(a);
end;

procedure BlockFileOf<T>.Write(o:sequence of T; from,count:integer) :=
if o is ICollection<T>(var c) then
  Write(c,from,count) else
  Write(o.Skip(from).Take(count));

{$endregion Write}

{$region Read}

function BlockFileOf<T>.Read:T;
begin
  if fi = nil then raise new FileNotAssignedException;
  if str = nil then raise new FileNotOpenedException(fi.FullName);
  
  var a := br.ReadBytes(sz);
  var ptr:^T := pointer(@a[0]);
  Result := ptr^;
end;

function BlockFileOf<T>.Read(c:integer):array of T;
begin
  if fi = nil then raise new FileNotAssignedException;
  if str = nil then raise new FileNotOpenedException(fi.FullName);
  
  var a := br.ReadBytes(sz*c);
  Result := new T[c];
  var ptr_id := integer(@a[0]);
  for var i := 0 to c - 1 do
  begin
    var ptr:^T := pointer(ptr_id);
    Result[i] := ptr^;
    ptr_id += sz;
  end;
end;

function BlockFileOf<T>.InternalReadLazy(c:integer; start_pos:int64):sequence of T;
begin
  //if fi = nil then raise new FileNotAssignedException;
  //if str = nil then raise new FileNotOpenedException(fi.FullName);
  //PosByte всё сам проверяет ;)
  
  PosByte := start_pos;
  loop c do
    yield Read;
end;

{$endregion Read}

end.