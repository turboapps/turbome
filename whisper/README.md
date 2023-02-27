# Whisper

Site: [OpenAI Whisper](https://openai.com/blog/whisper/)
Source: [Github Repository](https://github.com/openai/whisper)

## Build and Run Instructions

To build the whisper runtime:
`turbo build whisper-runtime\turbo.me`

This will give you an image that is able to run whisper, but which does not have any models pre-installed. When you run a container using just a whisper-runtime image, it will download the model file it needs.

To run a container using a whisper-runtime image:
`turbo new whisper-runtime --mount=C:\path\to\audio -- TRANSCRIBE C:\path\to\audio\audio.wav C:\path\to\audio\transcription.txt`

To build a whisper image that has the tiny model pre-installed, make sure you have either built or pulled a whisper-runtime image, then run:
`turbo build whisper-tiny\turbo.me`

To run a container using a whisper-tiny image:
`turbo new whisper-tiny --mount=C:\path\to\audio -- TRANSCRIBE C:\path\to\audio\audio.wav C:\path\to\audio\transcription.txt`

It is possible to use other models instead of the tiny model, however, this will require the `whisper_caller.py` file in the `resources` folder to be edited to refer to the desired model, and a new whisper-runtime image will need to be built.

Pre-installing other whisper models onto an image built on top of whisper-runtime is also possible, refer to `whisper-tiny/turbo.me` to see how this can be achieved.