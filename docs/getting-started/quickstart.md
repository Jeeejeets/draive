# Quick start

## Generate basic text response from model
Simplest thing to do in any LLM project is to prompt it to generate some text. In Draive you can do this with TextGeneration

```python
import asyncio

from draive import MultimodalContent, TextGeneration, ctx
from draive.gemini import Gemini, GeminiGenerationConfig


async def main():
    configuration = GeminiGenerationConfig(
        model="gemini-2.5-flash",
        temperature=0.4,
    )
    async with ctx.scope("app", configuration, disposables=[Gemini()]):
        response = await TextGeneration.generate(
            instruction="You are a greeting bot. You greet the user",
            input=MultimodalContent.of("Hello!")
        )
        print(response) # Hello there! It's lovely to see you.

asyncio.run(main())
```

### What happend here?
1. We imported deps
2. We defined main function
3. We defined configuration for gemini, more on that on the page describing configurations
4. we opened async context, on which we put:
    a. the previously created configuration
    b. the disposables list, on which we put the Gemini client
5. We requested the text response from the model using multimodalContent
6. We printed the response

### What about the API key?
The API key is defined in env under the key `GEMINI_API_KEY`. Draive offers a way to load the environment variable from .env file defined in the same diectory from which you run the script, thanks to Haiway framework it is based on:

```python
from haiway import load_env

load_env()
```

This will load all keys and values from your `.env` file, not only the ones the Draive library uses.


## Generate model response from model
Sometimes instead of just plain text you may need to generate a model. In Draive you can define a class that will hold your model's details and then prompt LLM to generate an instance of this class based on input data.

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

And the result is
```
people:
  - name: John Doe
    age: 20
  - name: Dennis Douche
    age: 30
```

### What happend here?
1. Up to response generation we did everything just like in the previous example
2. We requested a model generation from the LLM, providing the appropriate models we expect it to generate
3. We printed the result

Of course instead of printing it we could do whatever we like with the result. 

## Send an image to model
Sometimes you may need to send an image to the model in order to ask it to analyse its contents. With Draive you can do it like this:

```python
import asyncio

from draive import MediaData, MultimodalContent, TextGeneration, ctx
from draive.gemini import Gemini, GeminiGenerationConfig


async def main():
    path_to_image = "./image.png"
    with open(path_to_image, "rb") as image_file:
        image_bytes = image_file.read()

    configuration = GeminiGenerationConfig(
        model="gemini-2.5-flash",
        temperature=0.4,
    )
    async with ctx.scope("app", configuration, disposables=[Gemini()]):
        response = await TextGeneration.generate(
            instruction="Describe what you see on the picture user has provided",
            input=MultimodalContent.of(MediaData.of(image_bytes, media="image/png"))
        )
        print(response)

asyncio.run(main())
```

And the output

```
This image features a charming, light golden-colored puppy, likely a Golden Retriever, sitting against a solid dark green background. The puppy is positioned in the center of the frame, facing slightly towards the viewer with its head tilted.

Key features of the puppy include:
*   **Fur:** It has soft, fluffy golden fur with various shades, appearing lighter on its chest and face, and slightly darker, more reddish-gold on its ears and back. The fur looks well-groomed and shiny.
*   **Face:** The puppy has large, dark, expressive eyes that appear to be looking directly forward. Its nose is black and wet-looking. Its mouth is open in a happy, panting expression, revealing a pink tongue and a hint of its lower teeth.
*   **Ears:** Its ears are floppy and hang down the sides of its head, covered in the same golden fur.
*   **Body:** The puppy is in a seated position, with its front paws visible and its back legs tucked underneath. Its paws are dark, likely black or dark brown, contrasting with its light fur. The overall impression is one of cuteness and playfulness.

The background is a uniform, dark green color, which helps the golden fur of the puppy stand out. There are also faint, semi-transparent white lines and logos (like "pngtree" and a leaf icon) overlaid on the image, suggesting it might be a stock image or have watermarks.
```

### What happend here
1. We opened the image and read it as bytes
2. Then we have set up whole generation like in TextGeneraiton example
3. As an input we gave MultimodalContent made of MediaData made of the image bytes. Such a setup ich required for Draive to be able to sanitize and properly encapsulate the data sent to the model. 

## Using tools

If there's a need for LLM to perform any additional, defined operations before it returns its final answer you can use the tools to make it do it. In Draive you can use tools like this:

```python
import asyncio

from draive import Argument, MultimodalContent, TextGeneration, Toolbox, ctx, tool
from draive.gemini import Gemini, GeminiGenerationConfig


@tool(
    name="test_tool",
    description="the tool to use on user's query"
)
async def test_tool(
    query: str = Argument(description="The user's query to process")
) -> str:
    return query[::-1]

async def main():
    configuration = GeminiGenerationConfig(
        model="gemini-2.5-flash",
        temperature=0.4,
    )
    async with ctx.scope("app", configuration, disposables=[Gemini()]):
        response = await TextGeneration.generate(
            instruction="Process the user's query with test_tool and return the tool's result",
            input=MultimodalContent.of("A white rabbit jumped backwards"),
            tools=Toolbox.of(test_tool)
        )
        print(response)

asyncio.run(main())

```

And the response:
```
sdrawkcab depmuj tibbar etihw A
```

### What happend here
1. We defined a tool that reverses the input string
2. We instructed the model to use this tool and return only the result of this tool
3. We generated response

Note that in this example the tool is very simple and this effect could very well be achieved without any LLM, but it's an example to demonastrate how are the tools used in Draive. In real life scenarious you'll need to plan out where and how you'd need to support the model with tools. 