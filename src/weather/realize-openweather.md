# Реализация приложения — получение погоды с API OpenWeather

Отлично, у нас реализована структура и скелет приложения, а также полностью реализована логика получения текущих GPS координат — в точном или округлённом варианте. Реализуем теперь получение по этим координатам значения погоды с использованием API сервиса OpenWeather. Добавим шаблон URL для получения погоды в `config.py`:

```python
USE_ROUNDED_COORDS = True
OPENWEATHER_API = "7549b3ff11a7b2f3cd25b56d21c83c6a"
OPENWEATHER_URL = (
    "https://api.openweathermap.org/data/2.5/weather?"
    "lat={latitude}&lon={longitude}&"
    "appid=" + OPENWEATHER_API + "&lang=ru&"
    "units=metric"
)
```

Значения широты и долготы будем потом подставлять в этот шаблон. Если нам понадобится изменить однажды этот шаблон URL для получения данных, мы сможем не искать его где-то глубоко в приложении, он лежит в конфиге. Все данные, которые предполагаются как конфигурационные, имеет смысл выносить в отдельное место, которое можно назвать конфигом или настройками приложения.

API ключ для сервиса OpenWeather лучше сохранить в переменной окружения и не хранить в исходном коде проекта (тогда значение константы будет получаться как-то так: `os.getenv("OPENWEATHER_API_KEY")`, но сейчас мы этого делать не будем для упрощения запуска приложения.

Итак, реализация работы с сервисом погоды OpenWeather, `weather_api_service.py`:

```python
from datetime import datetime
from dataclasses import dataclass
from enum import Enum
import json
from json.decoder import JSONDecodeError
import ssl
from typing import Literal
import urllib.request
from urllib.error import URLError

from coordinates import Coordinates
import config
from exceptions import ApiServiceError

Celsius = int

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
    openweather_response = _get_openweather_response(
        longitude=coordinates.longitude, latitude=coordinates.latitude)
    weather = _parse_openweather_response(openweather_response)
    return weather

def _get_openweather_response(latitude: float, longitude: float) -> str:
    ssl._create_default_https_context = ssl._create_unverified_context
    url = config.OPENWEATHER_URL.format(
        latitude=latitude, longitude=longitude)
    try:
        return urllib.request.urlopen(url).read()
    except URLError:
        raise ApiServiceError

def _parse_openweather_response(openweather_response: str) -> Weather:
    try:
        openweather_dict = json.loads(openweather_response)
    except JSONDecodeError:
        raise ApiServiceError
    return Weather(
        temperature=_parse_temperature(openweather_dict),
        weather_type=_parse_weather_type(openweather_dict),
        sunrise=_parse_sun_time(openweather_dict, "sunrise"),
        sunset=_parse_sun_time(openweather_dict, "sunset"),
        city=_parse_city(openweather_dict)
    )

def _parse_temperature(openweather_dict: dict) -> Celsius:
    return round(openweather_dict["main"]["temp"])

def _parse_weather_type(openweather_dict: dict) -> WeatherType:
    try:
        weather_type_id = str(openweather_dict["weather"][0]["id"])
    except (IndexError, KeyError):
        raise ApiServiceError
    weather_types = {
        "1": WeatherType.THUNDERSTORM,
        "3": WeatherType.DRIZZLE,
        "5": WeatherType.RAIN,
        "6": WeatherType.SNOW,
        "7": WeatherType.FOG,
        "800": WeatherType.CLEAR,
        "80": WeatherType.CLOUDS
    }
    for _id, _weather_type in weather_types.items():
        if weather_type_id.startswith(_id):
            return _weather_type
    raise ApiServiceError

def _parse_sun_time(
        openweather_dict: dict,
        time: Literal["sunrise"] | Literal["sunset"]) -> datetime:
    return datetime.fromtimestamp(openweather_dict["sys"][time])

def _parse_city(openweather_dict: dict) -> str:
    return openweather_dict["name"]

if __name__ == "__main__":
    print(get_weather(Coordinates(latitude=55.7, longitude=37.6)))
```

Как и ранее, следуем подходу небольших функций, каждая из которых делает одно небольшое действие, а общий результат достигается за счёт компоновки этих небольших функций. Логику парсинга каждой нужной нам единицы информации выносим в отдельные небольшие функции — отдельно парсинг температуры, отдельно парсинг типа погоды и времени восхода и заката. Каждая функция названа глагольным словом — получить, распарсить и тд. Напомню, что функция это ни что иное как именованный блок кода, этот блок кода что-то делает и потому его имеет смысл называть именно глаголом, который опишет это действие.

Тут стоит отметить, что для парсинга и одновременно валидации JSON данных удобно использовать библиотеку [Pydantic](https://pydantic-docs.helpmanual.io/). О ней было [видео](https://www.youtube.com/watch?v=dOO3GmX6ukU) на канале «Диджитализируй!». Здесь мы не стали её использовать из-за возможно некоторой её избыточности для нашей простой задачи, а также чтобы ограничиться только стандартной библиотекой Python.

Осталось реализовать «принтер», который выведет нужные нам значения погоды в консоль!

