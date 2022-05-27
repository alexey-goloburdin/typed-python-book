# Alias для типа

После нашего отступления о структурах продолжим накидывать каркас приложения.

В `gps_coordinates.py` оставим структуру `dataclass` с параметрами `slots` и `frozen`, потому что не предусматривается изменение координат, которые вернёт нам GPS датчик на ноутбуке.

```python
from dataclasses import dataclass

@dataclass(slots=True, frozen=True)
class Coordinates:
    longitude: float
    latitude: float

def get_coordinates() -> Coordinates:
    return Coordinates(longitude=10, latitude=20)
```

Возвращаемое значение вставили пока, просто чтобы не ругались проверки в редакторе. Потом напишем реализацию, которая запросит координаты у команды `whereami`, распарсит её результаты и вернёт как результат функции `get_coordinates`.

Составим `weather_api_service.py`:

```python
from coordinates import Coordinate

def get_weather(coordinates: Coordinate):
    """Requests weather in OpenWeather API and returns it"""
    pass
```

Так, какой тип у погоды будет возвращаться? Тут главное не смотреть на формат данных в API сервисе, потому что сервис и формат данных в нём вторичны, первичны наши потребности. Какие данные нам нужны? Нам нужна температура за бортом, наше место, общая характеристика погоды — ясно/неясно/снег/дождь и тп, а также мне лично ещё интересно, во сколько сегодня восход солнца и закат солнца. Вот эти данные нам нужны, их пусть функция `get_weather` и возвращает. В каком формате?

Так, ну давайте думать. Просто `tuple`? Точно нет. Вообще есть мнение, что если мы хотим использовать `tuple`, то стоит использовать `NamedTuple`, потому что в нём явно данные будут названы. Поэтому возможно `NamedTuple`.

Просто `dict`? Точно нет. Не будет нормальных проверок в IDE и статическом анализаторе, не будет подсказок, и читателю кода непонятно, что там внутри словаря. `TypedDict`? Лучше, но мне нравится доставать данные как атрибуты класса, а не как ключи словаря. Поэтому `TypedDict` тоже не будем брать.

Может `dataclass`? Можно.

Итого `NamedTuple` или `dataclass`? Оба варианта ок, можно выбрать любой вариант, я, пожалуй, тут выберу `dataclass` с параметрами `frozen` и `slots` просто потому что распаковывать структуру как кортеж нам незачем, а по памяти `dataclass` с такими параметрами даже эффективнее кортежа.

```python
from dataclasses import dataclass
from datetime import datetime

from coordinates import Coordinate

Celsius = int

@dataclass(slots=True, frozen=True)
class Weather:
    temperature: Celsius
    weather_type: str  # Подумаем, как хранить описание погоды
    sunrise: datetime
    sunset: datetime
    city: str

def get_weather(coordinates: Coordinate):
    """Requests weather in OpenWeather API and returns it"""
    pass
```

Обратите внимание, как я обошёлся с температурой. Можно было прописать тип напрямую `int`, но я сделал *alias*, то есть псевдоним, для `int` с названием `Celsius` и теперь понятно, что у нас температура тут будет именно в градусах Цельсия, а не Фаренгейта или Кельвина.

Также, если какая-то функция будет принимать на вход или возвращать температуру, то мы тоже укажем для температуры там конкретный тип `Celsius`, а не общий непонятный `int`.
