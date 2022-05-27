# Реализация приложения — принтер погоды

Итак, файл `weather_formatter.py`:

```python
from weather_api_service import Weather

def format_weather(weather: Weather) -> str:
    """Formats weather data in string"""
    return (f"{weather.city}, температура {weather.temperature}°C, "
            f"{weather.weather_type}\n"
            f"Восход: {weather.sunrise.strftime('%H:%M')}\n"
            f"Закат: {weather.sunset.strftime('%H:%M')}\n")

if __name__ == "__main__":
    from datetime import datetime
    from weather_api_service import WeatherType
    print(format_weather(Weather(
        temperature=25,
        weather_type=WeatherType.CLEAR,
        sunrise=datetime.fromisoformat("2022-05-03 04:00:00"),
        sunset=datetime.fromisoformat("2022-05-03 20:25:00"),
        city="Moscow"
    )))
```

Обратите внимание на печать типа погоды — `weather.weather_type`. Так можно, потому что мы отнаследовали `WeatherType` от `str` и `Enum`, а не только от `Enum`. Если бы мы отнаследовали `WeatherType` только от `Enum`, то для получения строкового значения нужно было бы напрямую обратиться к атрибуту `value`, вот так: `weather.weather_type.value` .

При необходимости выводить на печать значения как-то иначе, всегда можно это реализовать в одном месте приложения. Как всегда обратите внимание, здесь реализован блок `if __name__ == "__main__":`, который позволяет тестировать код при непосредственно прямом вызове этого файла `python3.10 weather_formatter.py`. При импорте функции `format_weather` код в этом блоке выполнен не будет. 
