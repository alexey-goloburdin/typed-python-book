# Обработка исключений

В процессе работы приложения могут возникать 2 вида исключений, которые мы заложили в приложении — что-то может пойти не так с `whereami`, через который мы получаем текущие GPS координаты. Его может не быть в системе или по какой-то причине он может выдать результат не того формата, что мы ожидаем. В таком случае возбуждается исключение `CantGetCoordinates`.

Также что-то может пойти не так при запросе погоды по координатам. Тогда возбуждается исключение `ApiServiceError`. Обработаем и его. Файл `weather`:

```python
#!/usr/bin/env python3.10
from exceptions import ApiServiceError, CantGetCoordinates
from coordinates import get_gps_coordinates
from weather_api_service import get_weather
from weather_formatter import format_weather


def main():
    try:
        coordinates = get_gps_coordinates()
    except CantGetCoordinates:
        print("Не смог получить GPS координаты")
        exit(1)
    try:
        weather = get_weather(coordinates)
    except ApiServiceError:
        print("Не смог получить погоду в API сервиса погоды")
        exit(1)
    print(format_weather(weather))


if __name__ == "__main__":
    main()
```

