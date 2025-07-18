# Data Model
Data models are easy to use structures to handle formatted communications with the model. You can easily generate them using the model or transform them into string representation and pass to the models as an input.

You can define the DataModels like this:
```python
class Person(DataModel):
    name: str
    age: int
```

And use them in the models as output, like this:
```python
import asyncio
from collections.abc import Sequence

from draive import DataModel, ModelGeneration, MultimodalContent, ctx
from draive.gemini import Gemini, GeminiGenerationConfig


class Person(DataModel):
    name: str
    age: int

class People(DataModel):
    people: Sequence[Person]

async def main():
    configuration = GeminiGenerationConfig(
        model="gemini-2.5-flash",
        temperature=0.4,
    )
    async with ctx.scope("app", configuration, disposables=[Gemini()]):
        response: People = await ModelGeneration.generate(
            People,
            instruction="The user will provide you with a story, you will extract details of every person that appears in it",
            input=MultimodalContent.of("A police officer John Doe age 20 arrested 30 yo Dennis Douche for speeding twice over the limit")
        )
        print(response)

asyncio.run(main())
```

Or format them as a text input like this:
```python
import asyncio
from collections.abc import Sequence

from draive import DataModel, ModelGeneration, MultimodalContent, TextGeneration, ctx
from draive.gemini import Gemini, GeminiGenerationConfig


class Person(DataModel):
    name: str
    age: int

class People(DataModel):
    people: Sequence[Person]

async def main():
    configuration = GeminiGenerationConfig(
        model="gemini-2.5-flash",
        temperature=0.4,
    )
    people = People(
        people=[
            Person(name="Alicia", age=20),
            Person(name="Adam", age=30),
            Person(name="William", age=60),
        ]
    )
    async with ctx.scope("app", configuration, disposables=[Gemini()]):
        response = await TextGeneration.generate(
            instruction="What people are on the provided list?",
            input=MultimodalContent.of(people.to_str())
        )
        print(response)

asyncio.run(main())
```

## Formatting the DataModel
You can get the different representations of a DataModel.


