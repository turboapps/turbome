import whisper
import sys

def transcribe(audioFile, outputFile):
    model = whisper.load_model("tiny")

    # load audio and pad/trim it to fit 30 seconds
    audio = whisper.load_audio(audioFile)
    audio = whisper.pad_or_trim(audio)

    # make log-Mel spectrogram and move to the same device as the model
    mel = whisper.log_mel_spectrogram(audio).to(model.device)

    # detect the spoken language
    _, probs = model.detect_language(mel)
    print(f"Detected language: {max(probs, key=probs.get)}")

    # decode the audio
    options = whisper.DecodingOptions(fp16 = False)
    result = whisper.decode(model, mel, options)

    # print the recognized text
    print(result.text)

    with open(outputFile, 'w') as f:
        f.write(result.text)
