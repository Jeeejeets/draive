# Configuration

Draive makes it easy to set up each provider's LLM configuration.

## Configuration state
In your application you may want to have multiple configurations for one provider. For example a different configuration for a model supposed to be generating models and different for it chatting with an user: different temperatures, token limits and so on.  

Draive allows you to predefine all the configurations and store them in a single state which you can use anytime to apply desired configuration for each model call:

```python
import asyncio

from draive import Configuration, MultimodalContent, TextGeneration, ctx
from draive.gemini import Gemini, GeminiGenerationConfig

CONFIGURATION: Configuration = Configuration.of(
        (
            "boring",
            GeminiGenerationConfig(
                model="gemini-2.5-flash",
                temperature=0.0,
            ),
        ),
        (
            "creative",
            GeminiGenerationConfig(
                model="gemini-2.5-flash",
                temperature=1.0,
            ),
        )
    )

async def main():
    async with ctx.scope("app", CONFIGURATION, disposables=[Gemini()]):
        with ctx.updated(
            await GeminiGenerationConfig.load(
                key="boring",
            ),
        ):
            response = await TextGeneration.generate(
                instruction="You are encyclopedia assistant, the clients asks you for things and you respond in one to two sentences",
                input=MultimodalContent.of("What is love?"),
            )
            print(response)

        with ctx.updated(
            await GeminiGenerationConfig.load(
                key="creative",
            ),
        ):
            response = await TextGeneration.generate(
                instruction="You are encyclopedia assistant, the clients asks you for things and you respond in one to two sentences",
                input=MultimodalContent.of("What is love?"),
            )
            print(response)


asyncio.run(main())
```

### What happend here?
1. We have defined a Configuration set out of two different Gemini configurations
2. We then added this configuration set as a state into the context of the application
3. Inside the context, before the generate call, we updated the context. Opened new one inside which we fetched a config with key name "boring" and inside this new context we generated the response. The response was generated using this "boring" content. 
4. For the second generation we did the same only this time we fetched the "creative" config. The

## Loading env
Draive handles much of the configuration wiring for you from the env variables, all you need to do is call `load_env()` at the start of your application.

```python
from haiway import load_env

load_env()
```

## The Gemini configuration
Full configuration and the arguments described:

```
TODO
```

## The OpenAI configuration
Full configuration and the arguments described:

```
TODO
```

## The Anthropic configuration
Full configuration and the arguments described:

```
TODO
```

## The Mistral configuration
Full configuration and the arguments described:

```
TODO
```

## The Cohere configuration
Full configuration and the arguments described:

```
TODO
```

## The VLLM configuration
Full configuration and the arguments described:

```
TODO
```

## The Ollama configuration
Full configuration and the arguments described:

```
TODO
```