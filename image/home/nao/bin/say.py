#!/usr/bin/python -u

"""
This script is run from runswift and things to say are piped
 in via stdin.  Sayings also appear on runswift's stderr

Why not done in runswift?
- because that requires linking runswift against
  aldebaran libraries and i don't want to do that

Why not in daemon.py?
- because that requires message passing
- because then we can't use stderr in simulation
- UNIX philosophy #1: Make each program do one thing well. To do a new job,
  build afresh rather than complicate old programs by adding new "features".

Why python and not c++?
- because this is easier
- because this is hopefully more maintainable

Why not the `say` that comes with the nao?
- because this uses less CPU by running persistently
- because this falls back to flite
"""

from __future__ import print_function
import os
import select
import sys
import traceback

sys.path.append('/opt/aldebaran/lib/python2.7/site-packages/')  # noqa

try:
    from naoqi import ALProxy
except ImportError as e:
    print(e, file=sys.stderr)
    ALProxy = None

IP = "localhost"
tts = None


def init():
    if ALProxy:
        try:
            global tts
            tts = ALProxy("ALTextToSpeech", IP, 9559)
        except RuntimeError:
            # just assume it is the below and don't do anything
            # we used to print it but it's just too noisy
            #         ALProxy::ALProxy
            #         Can't find service: ALTextToSpeech
            pass
        except BaseException:
            traceback.print_exc()


def say(text, *args, **kwargs):
    print("SAY:\t\t" + text, *args, file=sys.stderr, **kwargs)
    if not tts:
        init()
    if tts:
        tts.say(text, *args, **kwargs)
    else:
        os.system("echo '" + text + "' | /home/nao/2.8/bin/flite")


try:
    # we need a place to keep the previously read byte in
    # case we are spamming the input with things to say
    # it's set to the previously read byte in the while loop
    s = ''
    for line in iter(sys.stdin.readline, ''):
        line = line.strip()
        say(s + line)
        # tts.say blocks until it's complete
        # but we don't want sayings to buffer up
        # https://stackoverflow.com/a/2521030/192798
        s = ''
        while select.select([sys.stdin.fileno()], [], [], 0.0)[0]:
            # read exactly 1 byte because we have no way to know how many
            # bytes there are and we don't want to get stuck blocking
            s = sys.stdin.read(1)
            # select is truey if the buffer contains EOF or is closed
            # don't infinite loop if the buffer contains EOF or is closed
            if len(s) == 0:
                break
except KeyboardInterrupt:
    pass
