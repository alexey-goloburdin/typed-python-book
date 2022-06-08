# Enum

Дальше, как быть с полем `weather_type`? Что за строка там будет? Хочется, чтобы там была не просто любая строка, а строго один из заранее заданных вариантов. Тут мы будем хранить описание погоды — ясно, туманно, дождливо и т. п. Для этих целей существует структура `Enum`. Её название происходит от слова *Enumeration*, *перечисление*. Когда нам нужно перечислить какие-то заранее заданные варианты значений, то `Enum` это та самая структура, которая нам нужна.

Давайте создадим структуру типов погоды, отнаследовав её от `Enum` и заполнив всеми возможными типами погоды, которые мы возьмём из справочника с [OpenWeather](https://openweathermap.org/weather-conditions#Weather-Condition-Codes-2):

```python
from datetime import datetime
from enum import Enum

class WeatherType(Enum):
    THUNDERSTORM = "Гроза"
    DRIZZLE = "Изморось"
    RAIN = "Дождь"
    SNOW = "Снег"
    CLEAR = "Ясно"
    FOG = "Туман"
    CLOUDS = "Облачно"

@dataclass(slots=True, frozen=True)
class Weather:
    temperature: Celsius
    weather_type: WeatherType
    sunrise: datetime
    sunset: datetime
    city: str
```

Каждый конкретный тип погоды описывается через атрибут `WeatherType`:

```python
print(WeatherType.CLEAR)  # WeatherType.CLEAR
print(WeatherType.CLEAR.value)  # Ясно
print(WeatherType.CLEAR.name)  # CLEAR
```

В чём фишка `Enum`? Зачем наследовать наш класс от `Enum`, почему бы просто не сделать класс с такими же атрибутами класса? Допустим, у нас есть функция `print_weather_type`, которая печатает погоду:

```python
from enum import Enum

class WeatherType(Enum):
    THUNDERSTORM = "Гроза"
    DRIZZLE = "Изморось"
    RAIN = "Дождь"
    SNOW = "Снег"
    CLEAR = "Ясно"
    FOG = "Туман"
    CLOUDS = "Облачно"

def print_weather_type(weather_type: WeatherType) -> None:
    print(weather_type.value)

print_weather_type(WeatherType.CLOUDS)  # Облачно
```

Как видите, тип для аргумента функции `weather_type` указан как `WeatherType`. А передаём туда мы не экземпляр `WeatherType`, а `WeatherType.CLOUDS`, при этом наш «проверятор» кода в IDE не ругается, ему всё нравится. Дело в том, что:

```python
print(
    isinstance(WeatherType.CLOUDS, WeatherType)
)  # True
```

То есть `WeatherType.CLOUDS` является экземпляром самого типа `WeatherType`, и это позволяет нам таким образом использовать этот класс в подсказке типов. В функцию `print_weather_type` можно передать только то, что явным образом перечислено в `Enum` структуре `WeatherType` и ничего больше.

Если мы уберём наследование от `Enum`, то IDE сразу скажет нам о несоответствии типов:

```python
from enum import Enum

class WeatherType:  # Убрали наследование от Enum 
    THUNDERSTORM = "Гроза"
    DRIZZLE = "Изморось"
    RAIN = "Дождь"
    SNOW = "Снег"
    CLEAR = "Ясно"
    FOG = "Туман"
    CLOUDS = "Облачно"

def print_weather_type(weather_type: WeatherType) -> None:
    print(weather_type)  # Вместо weather_type.value 

print_weather_type(WeatherType.CLOUDS)  # IDE подсветит ошибку типов
```

Здесь `WeatherType.CLOUDS` — это обычная строка со значением `"Облачно"`, тип `str`, а не `WeatherType`. Тип `str` и тип `WeatherType` — разные, поэтому IDE определит и подсветит эту ошибку несоответствия типов.

В этом особенность `Enum`. Цель этой структуры — задавать перечисление возможных вариантов значений.

Ещё по `Enum` можно итерироваться в цикле, что иногда может быть удобно:

```python
for weather_type in WeatherType:
    print(weather_type.name, weather_type.value)
```

И, конечно, `Enum` структуру можно разбирать с помощью новых возможностей Python — [Pattern Matching](https://www.youtube.com/watch?v=0kyy_zKO86U&t=255s):

```python
def what_should_i_do(weather_type: WeatherType) -> None:
    match weather_type:
        case WeatherType.THUNDERSTORM | WeatherType.RAIN:
            print("Уф, лучше сиди дома")
        case WeatherType.CLEAR:
            print("О, отличная погодка")
        case _:
            print("Ну так, выходить можно")

what_should_i_do(WeatherType.CLOUDS)  # Ну так, выходить можно
```

Но нам здесь это пока не нужно.

Также часто полезным бывает отнаследовать класс перечисления от `Enum` и от `str`. Тогда значение можно использовать как строку без обращения к `.value` атрибуту:

```python
# Наследование от str и Enum
class WeatherTypeStrEnum(str, Enum):
    FOG = "Туман"
    CLOUDS = "Облачно"

# Вариант без наследования от str
class WeatherTypeEnum(Enum):
    FOG = "Туман"
    CLOUDS = "Облачно"

print(WeatherTypeStrEnum.CLOUDS.upper())  # ОБЛАЧНО
print(WeatherTypeEnum.CLOUDS.upper())  # AttributeError
print(WeatherTypeEnum.CLOUDS.value.upper())  # ОБЛАЧНО

print(WeatherTypeStrEnum.CLOUDS == "Облачно")  # True
print(WeatherTypeEnum.CLOUDS == "Облачно")  # False
print(WeatherTypeEnum.CLOUDS.value == "Облачно")  # True

print(f"Погода: {WeatherTypeStrEnum.CLOUDS}")  # Погода: Облачно
print(f"Погода: {WeatherTypeEnum.CLOUDS}")  # Погода: WeatherTypeEnum.CLOUDS
print(f"Погода: {WeatherTypeEnum.CLOUDS.value}")  # Погода: Облачно
```

При этом тип `WeatherTypeStrEnum` и `str` — это всё же разные типы. Если аргумент функции ожидает `WeatherTypeStrEnum`, то передать туда `str` не получится. Типизация работает как надо:

```python
def make_something_great_with_weather(weather: WeatherTypeStrEnum): pass

smth("Туман")  # Не пройдёт проверку типов
smth(WeatherTypeStrEnum.FOG)  # Ок, всё в порядке
```

Какие еще варианты для использования Enum можно придумать? Например, перечисление полов, мужской/женский. Перечисление статусов запросов, ответов, каких-то операций. Перечисление статусов заказов, например, если эти статусы зашиты в приложении, а не берутся из справочника БД. Перечисление дней недели (понедельник, вторник и т. д.).

Итак, полный код `weather_api_service.py` на текущий момент:

```python
from datetime import datetime
from dataclasses import dataclass
from enum import Enum
from typing import TypeAlias

from coordinates import Coordinates

Celsius: TypeAlias = int

class WeatherType(str, Enum):
    THUNDERSTORM = "Гроза"
    DRIZZLE = "Изморось"
    RAIN = "Дождь"
    SNOW = "Снег"
    CLEAR = "Ясно"
    FOG = "Туман"
    CLOUDS = "Облачно"

@dataclass(slots=True, frozen=True)
class Weather:
    temperature: Celsius
    weather_type: WeatherType
    sunrise: datetime
    sunset: datetime
    city: str

def get_weather(coordinates: Coordinates) -> Weather:
    """Requests weather in OpenWeather API and returns it"""
    return Weather(
       temperature=20,
       weather_type=WeatherType.CLEAR,
       sunrise=datetime.fromisoformat("2022-05-04 04:00:00"),
       sunset=datetime.fromisoformat("2022-05-04 20:25:00"),
       city="Moscow"
   )
```

Обратите внимание, как всё чётенько! Мы читаем описание функции `get_weather` и у нас не может быть непониманий, что эта функция принимает на вход и в каком формате, а также что она возвращает на выход и опять же в каком формате. Если в будущем мы будем работать не с OpenWeather API, а с каким-то другим сервисом погоды, то мы просто заменим слой общения с этим внешним сервисом, но пока наша функция `get_weather` будет возвращать структуру `Weather`, весь остальной, внешний по отношению к этой функции, код будет работать без изменений. Мы прописали интерфейс коммуникации функции `get_weather` с внешним миром и пока этот интерфейс поддерживается — неважно как и откуда получаются данные внутри этой функции, главное, чтобы они просто на выходе преобразовались в нужный нам формат.

Отлично, осталось реализовать заглушку для принтера, который будет печатать нашу погоду, `weather_formatter.py`:

```python
from weather_api_service import Weather

def format_weather(weather: Weather) -> str:
    """Formats weather data in string"""
    return "Тут будет печать данных погоды из структуры weather"
```

Отлично, каркас приложения готов. Прописаны основные типы данных, что функции принимают на вход и возвращают. По этим функциям и типам уже сейчас понятно, как будет работать приложение, хотя мы ещё по сути ничего не реализовали.

Заполним полученный скелет приложения теперь реализацией.
