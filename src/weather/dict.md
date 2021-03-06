# Обычный словарь dict

Вторым вариантом структуры, которой тут можно воспользоваться — это словарь, просто обычный `dict`:

```python
# Совсем плохо! Что за dict, что внутри в нём?
def get_gps_coordinates() -> dict:
    return {"longitude": 10, "latitude": 20}

# Так лучше, хотя бы прописаны типы для ключей и значений
def get_gps_coordinates() -> dict[str, float]:
    return {"longitude": 10, "latitude": 20}

coords = get_gps_coordinates()
print(coords["longitude"])  # IDE не покажет опечатку в `longitude`
```

Как видно, при вводе ключа словаря `longitude` IDE нам не подсказывает и нет никакой проверки на опечатки. Если мы опечатаемся в ключе словаря, то эта ошибка может дойти до рантайма и уже в рантайме упадёт ошибка `KeyError`. Хочется, чтобы IDE и статический анализатор кода вроде `mypy`, о котором поговорим позднее, помогали нам, а чтобы они нам помогали, надо чётко прописывать типы данных и `dict` это не то, что нам нужно.
