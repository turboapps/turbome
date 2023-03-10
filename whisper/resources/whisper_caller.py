import whisper

def transcribe(audioFile, outputFile):
    model = whisper.load_model("tiny")
    result = model.transcribe(audioFile)

    # print the recognized text
    print(result["text"])

    with open(outputFile, 'w') as f:
        f.write(result["text"])