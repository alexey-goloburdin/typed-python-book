# Dataclass

Ещё один вариант задания структуры — `dataclass`:

```python
from dataclasses import dataclass

@dataclass
class Coordinates:
    longitude: float
    latitude: float

def get_gps_coordinates() -> Coordinates:
    return Coordinates(10, 20)
```

Это обычный класс, это не именованный кортеж, распаковывать его как кортеж уже нельзя, и также он не ведет себя как кортеж с точки зрения изменения каждого элемента. Это обычный класс.

С ним работают проверки в IDE, автодополнения — это, пожалуй, самая часто используемая структура для таких задач:

```python
print(get_gps_coordinates().latitude)  # Автодополнение IDE для атрибута
print(get_gps_coordinates().latitudeRRR)  # IDE подсветит опечатку
```

Когда использовать `NamedTuple`, когда `dataclass`? Как мы поймём чуть позже, сценарий именованных кортежей — это сценарий распаковки. Когда нам нужно использовать структуру именно как кортеж, тогда стоит задать её как `NamedTuple`. В остальных сценариях имеет смысл предпочесть `dataclass`.

Давайте сравним количество памяти, которое занимает в оперативке именованный кортеж и датакласс. Для того, чтобы узнать, сколько памяти занимает переменная, воспользуемся библиотекой [Pympler](https://pympler.readthedocs.io/en/latest/).

```python
from dataclasses import dataclass
from typing import NamedTuple

from pympler import asizeof

@dataclass
class CoordinatesDT:
    longitude: float
    latitude: float

class CoordinatesNT(NamedTuple):
    longitude: float
    latitude: float


coordinates_dt = CoordinatesDT(longitude=10.0, latitude=20.0)
coordinates_nt = CoordinatesNT(longitude=10.0, latitude=20.0)

print("dataclass", asizeof.asized(coordinates_dt).size)  # 328 bytes
print("namedtuple:", asizeof.asized(coordinates_nt).size)  # 104 bytes
```

То есть, как видим, именованный кортеж занимает значительно меньше памяти в оперативке, чем `dataclass`, в данном примере в 3 раза. Это понятно, то как по своей сути это более простая структура данных, её нельзя менять и потому именованный кортеж можно эффективно хранить в памяти.

В то же время, если мы используем `dataclass` просто как фиксированную структуру для хранения неизменяемых данных, то можно сделать и его более эффективным:

```python
from dataclasses import dataclass
from pympler import asizeof


@dataclass(slots=True, frozen=True)
class CoordinatesDT2:
    longitude: float
    latitude: float

coordinates_dt2 = CoordinatesDT2(longitude=10.0, latitude=20.0)
print("dataclass with frozen and slots:", asizeof.asized(coordinates_dt2).size)
# dataclass with frozen and slots: 96 bytes
```

Обрати внимание — такая структура неизменна, как и кортеж (благодаря флагу `frozen=True`), то есть не получится после определения экземпляра класса изменить его атрибуты. Флаг `slots=True` автоматически добавляет `__slots__` нашему датаклассу (более быстрый доступ к атрибутам и более эффективное хранение в памяти).

Таким образом, как мы видим по нашему тесту, по памяти такой `dataclass` получается даже эффективнее кортежа. Кортеж можно использовать, если вам важно использовать его с распаковкой, например, таким образом:

```python
latitude, longitude = coordinates_nt
```

Экземпляр датакласса, очевидно, с распаковкой работать не будет, так как это не кортеж.

