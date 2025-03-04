import os
import ffmpeg

script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

inputFile = "../movies/badapple_run.avi"
outputFile = "../movies/badapple_run.mp4"
scale = 8

ffmpeg.input(inputFile).output(
    outputFile,
    vcodec="libx264",
    crf=23,
    vf=f"scale={160 * scale}:{144 * scale}:flags=neighbor",
    profile="baseline",
    pix_fmt="yuv420p"
).run()