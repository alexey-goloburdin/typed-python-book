# Реализация приложения — получение GPS координат

Реализуем в первую очередь получение GPS-координат, `coordinates.py`:

```python
from dataclasses import dataclass
from subprocess import Popen, PIPE

from exceptions import CantGetCoordinates

@dataclass(slots=True, frozen=True)
class Coordinates:
    longitude: float
    latitude: float

def get_gps_coordinates() -> Coordinates:
    """Returns current coordinates using MacBook GPS"""
    process = Popen(["whereami"], stdout=PIPE)
    (output, err) = process.communicate()
    exit_code = process.wait()
    if err is not None or exit_code != 0:
        raise CantGetCoordinates
    output_lines = output.decode().strip().lower().split("\n")
    latitude = longitude = None
    for line in output_lines:
        if line.startswith("latitude:"):
            latitude = float(line.split()[1])
        if line.startswith("longitude:"):
            longitude = float(line.split()[1])
    return Coordinates(longitude=longitude, latitude=latitude)

if __name__ == "__main__":
    print(get_gps_coordinates())
```

Хочу обратить внимание тут вот на что. Если что-то пошло не так с процессом получения координат — мы не возвращаем какую-то ерунду вроде `None`. Мы возбуждаем (*райзим*, от англ. *raise*) исключение. Причём исключение не какое-то системное вроде `ValueError`, а наш собственный тип исключения, который мы назвали `CantGetCoordinates` и положили в специальный модуль, куда мы будем класть исключения `exceptions.py`:

```python
class CantGetCoordinates(Exception):
    """Program can't get current GPS coordinates"""
```

Почему не `ValueError`, а свой тип исключений? Чтобы разделять обычные питоновские `ValueError` от конкретно нашей ситуации с невозможностью получить координаты. Явное лучше неявного.

Почему исключение, а не возврат `None`? Потому что если у функции есть нормальный сценарий работы и ненормальный, то есть исключительный, то исключительный сценарий должен использовать исключения, а не возвращать какую-то ерунду вроде `False`, `0`, `None`, `tuple()`. Исключительная ситуация должна возбуждать исключение, и уже на уровне выше нашей функции мы должны решить, что с этой исключительной ситуацией делать. Код, который будет вызывать нашу функцию `get_gps_coordinates`, решит, что делать с исключительной ситуацией, на каком уровне и как эта ситуация должна быть обработана. 

Отлично. Функция отдаёт сейчас точные координаты, которые я не хочу раскрывать, давайте введём в приложение конфиг `config.py` и в нём зададим, использовать точные координаты или примерные. Я буду использовать примерные координаты. Погода от этого не изменится, просто в другой район города попаду.

`config.py`:

```python
USE_ROUNDED_COORDS = True
```

`coordinates.py`:

```python
from dataclasses import dataclass
from subprocess import Popen, PIPE

import config
from exceptions import CantGetCoordinates

@dataclass(slots=True, frozen=True)
class Coordinates:
    longitude: float
    latitude: float

def get_gps_coordinates() -> Coordinates:
    """Returns current coordinates using MacBook GPS"""
    process = Popen(["whereami"], stdout=PIPE)
    output, err = process.communicate()
    exit_code = process.wait()
    if err is not None or exit_code != 0:
        raise CantGetCoordinates
    output_lines = output.decode().strip().lower().split("\n")
    latitude = longitude = None
    for line in output_lines:
        if line.startswith("latitude:"):
            latitude = float(line.split()[1])
        if line.startswith("longitude:"):
            longitude = float(line.split()[1])
    if config.USE_ROUNDED_COORDS:  # Добавили округление координат
        latitude, longitude = map(lambda c: round(c, 1), [latitude, longitude])
    return Coordinates(longitude=longitude, latitude=latitude)

if __name__ == "__main__":
    print(get_gps_coordinates())
```

Отлично. Обратите внимание — мы не полагаемся здесь на то, на какой строке будет значение широты и долготы в выдаче команды `whereami`. Мы ищем нужную строку во всех возвращаемых строках, не полагаясь на то, будут это первые строки или нет. Получается более надёжное решение на случай смены порядка строк в `whereami`.

Теперь проведём рефакторинг, поделив большую, делающую слишком много всего функцию `get_gps_coordinates` на несколько небольших простых функций:

```python
from dataclasses import dataclass
from subprocess import Popen, PIPE
from typing import Literal

import config
from exceptions import CantGetCoordinates

@dataclass(slots=True, frozen=True)
class Coordinates:
    latitude: float
    longitude: float

def get_gps_coordinates() -> Coordinates:
    """Returns current coordinates using MacBook GPS"""
    coordinates = _get_whereami_coordinates()
    return _round_coordinates(coordinates)

def _get_whereami_coordinates() -> Coordinates:
    whereami_output = _get_whereami_output()
    coordinates = _parse_coordinates(whereami_output)
    return coordinates

def _get_whereami_output() -> bytes:
    process = Popen(["whereami"], stdout=PIPE)
    output, err = process.communicate()
    exit_code = process.wait()
    if err is not None or exit_code != 0:
        raise CantGetCoordinates
    return output

def _parse_coordinates(whereami_output: bytes) -> Coordinates:
    try:
        output = whereami_output.decode().strip().lower().split("\n")
    except UnicodeDecodeError:
        raise CantGetCoordinates
    return Coordinates(
        latitude=_parse_coord(output, "latitude"),
        longitude=_parse_coord(output, "longitude")
    )

def _parse_coord(
        output: list[str],
        coord_type: Literal["latitude"] | Literal["longitude"]) -> float:
    for line in output:
        if line.startswith(f"{coord_type}:"):
            return _parse_float_coordinate(line.split()[1])
    else:
        raise CantGetCoordinates

def _parse_float_coordinate(value: str) -> float:
    try:
        return float(value)
    except ValueError:
        raise CantGetCoordinates

def _round_coordinates(coordinates: Coordinates) -> Coordinates:
    if not config.USE_ROUNDED_COORDS:
        return coordinates
    return Coordinates(*map(
        lambda c: round(c, 1),
        [coordinates.latitude, coordinates.longitude]
    ))


if __name__ == "__main__":
    print(get_gps_coordinates())
```

Кода стало больше, функций стало больше, но код стал проще читаться и будет проще сопровождаться. Если бы мы сейчас писали тесты, то убедились бы ещё и в том, что этот код легче обложить тестами, чем предыдущий вариант с одной большой функцией, делающей всё подряд.

Функции, имена которых начинаются с подчёркивания — не предназначены для вызова извне модуля, то есть они вызываются только соседними функциями модуля `coordinates.py`.

Почему много коротких функций это лучше, чем одна большая функция? Потому что для того, чтобы понять, что происходит внутри функции на 50 строк, надо прочитать 50 строк. А если эти 50 строк разбить на пару меньших функций и понятным образом эти пару функций назвать, то нам понадобится прочесть всего пару строк с вызовами этой пары функций и всё. Прочесть пару строк легче, чем 50. А если нам нужны детали реализации какой-то из этих меньших функций, мы всегда можем в неё провалиться и посмотреть, что внутри.

Функция `get_gps_coordinates` тут максимально проста — она получает координаты и затем округляет их и возвращает, всё. Два вызова понятно названных функций вместо длинного сложного кода, как было раньше.

Также обратите внимание — абсолютно все функции типизированы, все принимаемые аргументы функций типизированы и все возвращаемые значения тоже типизированы. Причём типизированы максимально конкретными типами.

Эта логика реализована без классов, на обычных функциях. Это нормально. Не нужно использовать ООП просто для того, чтобы у вас были классы. От того, что мы обернём несколько описанных здесь функций в класс — никакого нового полезного качества в нашем коде не появится, просто вместо функций будет класс. В таком случае вовсе не нужно использовать классы.

Обратите внимание также, как в функции `_parse_float_coordinate` обработана ошибка `ValueError`, которая может возникать, если вдруг координаты не получается привести из строки к типу `float` — мы возбуждаем (райзим) исключение своего типа  `CantGetCoordinates`. В любой ситуации, когда нам не удалось получить координаты из результатов команды `whereami` мы получаем такое исключение и можем обработать (или не обрабатывать) его в коде, который будет вызывать нашу верхнеуровневую функцию `get_gps_coordinates`. Про работу с исключениями более подробно мы поговорим в отдельном материале.

