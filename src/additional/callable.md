# Вызываемые объекты

Как известно функции в Python это обычные объекты, которые можно передавать в другие функции, возвращать из других функций и т. п., поэтому для них тоже есть свой тип `Callable`:

```python
from typing import Callable

def mysum(a: int, b: int) -> int:
    return a + b


def process_operation(operation: Callable[[int, int], int],
                      a: int, b: int) -> int:
    return operation(a, b)

print(process_operation(mysum, 1, 5))  # 6
```

Здесь для аргумента `operation` функции `process_operation` проставлен тип `Callable[[int, int], int]`. Здесь `[int, int]` — это типы аргументов функции `operation`, получается, что у этой функции должно быть два аргумента и они оба должны иметь тип `int`. Последний `int` в определении типа `Callable[[int, int], int]` обозначает тип возвращаемого функцией значения.

## Protocol

Теперь давайте немного изменим пример выше: сделаем один из аргументов функции `mysum` опциональным.

```python
from typing import Callable

def mysum(a: int, b: int = 1) -> int:
    return a + b


def call_sum(operation: Callable[[int, int], int],
             a: int) -> int:
    return operation(a)

print((call_sum, 2))  # 3
```

Как мы видим, код работает корректно. Мы просто вызываем переданную функцию с аргументом `a=2` и аргументом `b` по умолчанию. Однако, наша аннотация `Callable[[int, int], int]` не учитывает того, что второй аргумент опционален. В итоге мы получаем ошибку типизации при вызове `operation(a)`, т.к. переданная функция ожидает два аргумента (с точки зрения типов).

Для того, чтобы отразить в аннотации типов дополнительную информацию об аргументах функции, официальная документация советует использовать класс [Protocol](https://docs.python.org/3/library/typing.html#annotating-callable-objects) с методом `__call__`, который и будет использоваться для хранения информации об аргументах функции.

Перепишем наш пример:

```python
from typing import Protocol

def mysum(a: int, b: int = 1) -> int:
    return a + b

class OptionalBSumCall(Protocol):
    """Этот класс нужен только для аннотирования"""

    def __call__(self, a: int, b: int = 1) -> int:
        """Пустое тело функции"""

def call_sum(operation: OptionalBSumCall,
             a: int) -> int:
    return operation(a)

print((call_sum, 2))  # 3
```

Класс `OptionalBSumCall` в нашем случае содержит информацию о том, что аргумент `b` может иметь значение по умолчанию, ошибки типизации в данном случае нет.

Однако, следует учесть важный нюанс: `Protocol` позволяет хранить информацию о том, что дефолтное значение аргумента ЕСТЬ, но не о том, КАКОЕ ОНО.

Иными словами, функция вида:

```python
def mysum(a: int, b: int = 2) -> int:
    return a + b
```

Также подходит под аннотацию `OptionalBSumCall`, хотя и содержит иное дефолтное значение для аргумента `b` (**2** вместо **1**).

Кроме этого, `Protocol`, объявленный таким образом, требует точного совпадения имен аргументов. Поэтому следующая функция уже не попадает под нашу аннотацию, т.к. не содержит аргумента `b` (вместо него у нас `c`):

```python
def mysum(a: int, c: int = 1) -> int:
    return a + c
```

Однако, мы можем переписать нашу аннотацию таким образом, чтобы имена переменных перестали иметь значение. Для этого нужно просто добавить перед именем переменной `__`. В таком случае будет работать проверка типов и наличия дефолтного значения, но название аргументов не будет учитываться (только их порядок, как в случае с обычным `Callable`).

```python
from typing import Protocol

class OptionalBSumCall(Protocol):
    def __call__(self, __a: int, __b: int = 1) -> int:
        # Имена переменных не учитываются при проверке типов
        ...
```

## ParamSpec

Теперь давайте представим простейший декоратор, который не делает ничего, кроме как вызывает переданную функцию с задаными аргументами:

```python
from typing import Callable, Any

def simple_decor(
    func: Callable[..., Any]  # принимаем любую функцию
) -> Callable[..., Any]:  # возвращаем также функцию
    def simple_decor_wrapper(*args: Any, **kwargs: Any) -> Any:
        return func(*args, **kwargs)
    return simple_decor_wrapper


@simple_decor
def mysum(a: int, b: int = 1) -> int:
    return a + b


print(mysum(1, 1))  # 2
```

Декоратор работает корректно, **mypy** ошибок тоже не нашел, однако подсказки типов в **IDE** утеряны. Теперь `mysum` распознается как `Callable[..., Any]` и мы ничего не знаем ни про ее аргументы, ни про возвращаемое значение.

Давайте разбираться, как нам сохранить эту информацию.

Для начала разберемся с возвращаемым значением. Здесь все просто: для этого используем уже знакомый `TypeVar`

```python
from typing import Callable, Any, TypeVar

T = TypeVar("T")

def simple_decor(
    func: Callable[..., T]  # принимаем любую функцию с результатом `T`
) -> Callable[..., T]:  # возвращаем также функцию с результатом `T`
    def simple_decor_wrapper(*args: Any, **kwargs: Any) -> T:
        return func(*args, **kwargs)
    return simple_decor_wrapper
```

Отлично! Теперь наша функция хотя бы возвращает то же самое.

С аргументами все немного сложнее. Именно для поддержки этого функционала в **Pyrhon3.10** был добавлен тип [**ParamSpec**](https://docs.python.org/3/library/typing.html#typing.ParamSpec) (до версии 3.10 вы можете импортировать его из пакета `typing_extensions`).

Принцип работы схож с `TypeVar`, давайте посмотрим на примере:

```python
from typing import Callable, Any, TypeVar, ParamSpec

T = TypeVar("T")
P = ParamSpec("P")

def simple_decor(
    func: Callable[P, T]  # принимаем функцию с аргументами P
) -> Callable[P, T]:  # возвращаем функцию с такими же аргументами
    def simple_decor_wrapper(
        *args: P.args,  # позиционные аргумента оригинальной функции
        **kwargs: P.kwargs,  # именованные аргументы оригинальной функции
    ) -> T:
        return func(*args, **kwargs)
    return simple_decor_wrapper
```

Отлично! В таком виде, наш декоратор сохраняют всю информацию о типах декорируемой функции.

Осталось только одно небольшое замечание: `P.args` и `P.kwargs` всегда необходимо использовать совместно. Вы не можете написать, например `def f(*args: P.args): ...`, такой синтаксис попросту некорректен.

## Protocol + Generic

Последний пример имеет чисто ифнормативный характер, но вы должны знать о такой возможности. Так как класс `Protocol` является дженериком, мы можем совмещать его как с `TypeVar`, так и с `ParamSpec`.

```python
from typing import TypeVar, ParamSpec, Protocol

P = ParamSpec("P")
T = TypeVar("T")

class AnyFunc(Protocol[P, T]):
    """Данный класс эквивалентен Callable[P, T]"""
    def __call__(self, *args: P.args, **kwargs: P.kwargs) -> T:
        ...

def call_func(func: AnyFunc[P, T], *args: P.args, **kwargs: P.kwargs) -> T:
    return func(*args, **kwargs)

def mysum(a: int, b: int) -> int:
    return a + b

print(call_func(mysum, 1, 2))  # 3
```

## Concatenate

Тип [**Concatenate**](https://docs.python.org/3/library/typing.html#typing.Concatenate) был добавлен вместе с **ParamSpec** и работать может только в паре с ним. Этот тип нужен для того, чтобы убирать или добавлять аргументы аннотируемой функции.

Давайте разберемся на примерах.

Для начала добавим новый аргумент в нашу функцию:

```python
from typing import TypeVar, ParamSpec, Concatenate, Callable

P = ParamSpec("P")
T = TypeVar("T")

def add_number_decorator(func: Callable[P, T]) -> Callable[
    Concatenate[int, P],  # функция принимаем доп. аргумент тип int
    T
]:
    def wrapper(
        __a: int,  # принимаем доп аргумент
        *args: P.args, 
        **kwargs: P.kwargs
    ) -> T:
        # прячем доп аргумент под `__` чтобы избежать
        # конфликта с названиями аргументов оригинальной функции
        return func(*args, **kwargs) + __a
    return wrapper


@add_number_decorator
def mysum(a: int, b: int) -> int:
    return a + b

print(mysum(1, 2, 3))  # 6
```

А теперь уберем первый аргумент и заменим его значением по умолчанию:

```python
from typing import TypeVar, ParamSpec, Concatenate, Callable

P = ParamSpec("P")
T = TypeVar("T")

def default_a_decorator(
    # функция с первым аргументом типа `int`
    func: Callable[Concatenate[int, P], T]
) -> Callable[P, T]:
    def wrapper(
        *args: P.args, 
        **kwargs: P.kwargs
    ) -> T:
        return func(1, *args, **kwargs)
    return wrapper


@default_a_decorator
def mysum(a: int, b: int) -> int:
    return a + b

print(mysum(2))  # 3
```

Теперь пользователи функции `mysum` даже не узнают, что она принимала аргумент `a`, вместо него всегда будет подставлено дефолтное значение **1**.
