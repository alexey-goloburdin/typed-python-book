# Контейнеры — Iterable, Sequence, Mapping и другие

Как указать тип для контейнера с данными, например, для списка юзеров?

```python
from datetime import datetime
from dataclasses import dataclass

@dataclass
class User:
    birthday: datetime

users = [
    User(birthday=datetime.fromisoformat("1988-01-01")),
    User(birthday=datetime.fromisoformat("1985-07-29")),
    User(birthday=datetime.fromisoformat("2000-10-10"))
]

def get_younger_user(users: list[User]) -> User:
    if not users: raise ValueError("empty users!")
    sorted_users = sorted(users, key=lambda x: x.birthday)
    return sorted_users[0]

print(get_younger_user(users))
# User(birthday=datetime.datetime(1985, 7, 29, 0, 0))
```

До последних версий Python список для указания типа надо было импортировать из `typing`, но сейчас можно `list` не импортировать и просто сразу использовать, что удобно. То есть Python продолжает движение в сторону ещё более простого и удобного использования подсказок типов.

Обратите внимание — технически можно указать просто `users: list`, но тогда IDE и статический анализатор кода вроде `mypy` не будут знать, что находится внутри этого списка, и это нехорошо. Мы же изначально знаем, что там именно тип данных `User`, объекты класса `User`, и, значит, это надо в явном виде указать.

Так, отлично, а давайте подумаем, а обязательно ли функция поиска самого молодого юзера должна принимать на вход именно список юзеров? Ведь по сути главное, чтобы просто можно было проитерироваться по пользователям. Может, мы захотим потом передать сюда не список пользователей, а кортеж с пользователями, или еще что-то? Если мы передадим вместо списка кортеж — будет ошибка типов сейчас:

```python
from datetime import datetime
from dataclasses import dataclass

@dataclass
class User:
    birthday: datetime

users = (  # сменили на tuple
    User(birthday=datetime.fromisoformat("1988-01-01")),
    User(birthday=datetime.fromisoformat("1985-07-29")),
    User(birthday=datetime.fromisoformat("2000-10-10"))
)

def get_younger_user(users: list[User]) -> User:
    """Возвращает самого молодого пользователя из списка"""
    sorted_users = sorted(users, key=lambda x: x.birthday)
    return sorted_users[0]


print(get_younger_user(users))  # тут видна ошибка в pyright!
```

Код работает (повторимся, что интерпретатор не проверяет типы в type hinting), но проверка типов в редакторе (и `mypy`) ругается, это нехорошо.

Если мы посмотрим [документацию](https://docs.python.org/3/library/functions.html#sorted) по функции `sorted`, то увидим, что первый элемент там назван *iterable*, то есть итерируемый, то, по чему можно проитерироваться. То есть мы можем передать любую итерируемую структуру:

```python
from typing import Iterable

def get_younger_user(users: Iterable[User]) -> User | None:
    if not users: return None
    sorted_users = sorted(users, key=lambda x: x.birthday)
    return sorted_users[0]
```

И теперь всё в порядке. Мы можем передать любую итерируемую структуру, элементами которой являются экземпляры `User`.

А если нам надо обращаться внутри функции по индексу к элементам последовательности? Подойдёт ли `Iterable`? Нет, так как `Iterable` подразумевает возможность итерироваться по контейнеру, то есть обходить его в цикле, но это не предполагает обязательной возможности обращаться по индексу. Для этого есть `Sequence`:

```python
from typing import Sequence

def get_younger_user(users: Sequence[User]) -> User | None:
    """Возвращает самого молодого пользователя из списка"""
    if not users: return None
    print(users[0])
    sorted_users = sorted(users, key=lambda x: x.birthday)
    return sorted_users[0]
```

Теперь всё в порядке. В `Sequence` можно обращаться к элементам по индексу.

Ещё один важный вопрос тут. А зачем использовать `Iterable` или `Sequence`, если можно просто перечислить разные типы контейнеров? Ну их же ограниченное количество — там `list`, `tuple`, `set`, `dict.` Для чего нам тогда общие типы `Iterable` и `Sequence`?

На самом деле таких типов контейнеров, по которым можно итерироваться, вовсе не ограниченное число. Например, можно создать свой контейнер, по которому можно будет итерироваться, но при этом этот тип не будет наследовать ничего из вышеперечисленного типа `list`, `dict` и т. п.:

```python
from typing import Sequence

class Users:
    def __init__(self, users: Sequence[User]):
        self._users = users

    def __getitem__(self, key: int) -> User:
        return self._users[key]

users = Users((  # сменили на tuple
    User(birthday=datetime.fromisoformat("1988-01-01")),
    User(birthday=datetime.fromisoformat("1985-07-29")),
    User(birthday=datetime.fromisoformat("2000-10-10"))
))

for u in users:
    print(u)
```

Способов создать такую структуру, по которой можно итерироваться или обращаться по индексам, в Python много, это один из способов. Важно просто понимать, что если вам надо показать структуру, по которой, например, можно итерироваться, то не стоит ограничивать набор таких структур простым перечислением списка, кортежа и чего-то ещё. Используйте обобщённые типы, созданные специально для этого, например, `Iterable` или `Sequence`, потому что они покроют действительно всё, в том числе и свои кастомные (самописные) реализации контейнеров.

Ну и напоследок — как определить тип словаря, ключами которого являются строки, а значениями, например, объекты типа `User`:

```python
some_users_dict: dict[str, User] = {
    "alex": User(birthday=datetime.fromisoformat("1990-01-01")),
    "petr": User(birthday=datetime.fromisoformat("1988-10-23"))
}
```

И также, если нет смысла ограничиваться именно словарём и подойдёт любая структура, к которой можно обращаться по ключам — то есть обобщённый тип `Mapping`:

```python
from typing import Mapping

def smth(some_users: Mapping[str, User]) -> None:
    print(some_users["alex"])

smth({
    "alex": User(birthday=datetime.fromisoformat("1990-01-01")),
    "petr": User(birthday=datetime.fromisoformat("1988-10-23"))
})

```

> **Важно:** по возможности вместо указания в типах `list`, `dict` и т. п. указывай классы `Iterable`, `Sequence`, `Mapping`.
> 
> Во-первых, это позволит менять конкретные реализации, удовлетворяющие условию итерабельности, доступа по индексу или доступа по ключу соответственно, решение получится более гибким.
> 
> Во-вторых, анализатор кода `mypy` будет [лучше работать с такими типами данных](https://mypy.readthedocs.io/en/stable/common_issues.html#invariance-vs-covariance), что позволит избежать некоторых осложнений. 
> 
> Если от контейнера требуется итерабельность (чтобы по данным в контейнере можно было итерироваться, то есть проходить в цикле), то стоит указать `Iterable`, который гарантирует именно итерабельность, вместо того, чтобы указывать одни из возможных реализаций итерабельных контейнеров вроде `list` или `tuple`, несущих помимо собственно итерабельности и другие свойства.
> 
>  Если от контейнера требуется доступ по индексу, то стоит указать `Sequence`, а не одну из возможных реализаций вроде `list`.
>  
>  Наконец, если требуется доступ по ключу, то следует указать `Mapping`.

Пару слов стоит сказать про кортежи, если размер кортежа важен и мы хотим его прямо указать в типе, то это можно сделать так:

```python
three_ints = tuple[int, int, int]
```

Если количество элементов неизвестно — можно так:

```python
tuple_ints = tuple[int, ...]
```
