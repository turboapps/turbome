import sys
import whisper_caller

def main():
    if len(sys.argv) > 1:
        skill = sys.argv[1]
    else:
        print ("Invalid number of arguments. Expected usage: <skill> [<skill_args>...]")
        return -1

    if skill.upper() == "TRANSCRIBE":
        if len(sys.argv) > 3:
            inputFile = sys.argv[2]
            outputFile = sys.argv[3]
        else:
            print ("Invalid number of arguments. Expected usage: TRANSCRIBE <inputFile> <outputFile>")
            return -1

        whisper_caller.transcribe(inputFile, outputFile)
    else:
        print("Invalid skill name")
        return -1

if __name__ == "__main__":
    main()