import std.typecons;

import gfm.logger,
       gfm.sdl2,
       gfm.sdl2.audio;

enum MusicPath = "Roland-GR-1-Trumpet-C5.wav";

// prototype for our audio callback
// see the implementation for more information
extern(C)
void my_audio_callback(void *userdata, ubyte *stream, int len) nothrow
{
    auto audio_len = cast(int) audio.length;
    if (audio_len == 0)
        return;

    len = ( len > audio_len ? audio_len : len );
    stream[0..len] = audio[0..len];                     // simply copy from one buffer into the other
    // SDL_MixAudio(stream, audio.ptr, len, SDL_MIX_MAXVOLUME); // mix from one buffer into another
    
    audio = audio[len..$];
}

// audio buffer to be played
__gshared ubyte[] audio;

int main()
{
    auto log = new ConsoleLogger;

    auto sdl2 = scoped!SDL2(log);
    sdl2.subSystemInit(SDL_INIT_AUDIO);

    ubyte* wavptr;
    uint wavsize;
    SDL_AudioSpec spec, have;

    /* Load the WAV */
    // the specs, length and buffer of our wav are filled
    if( SDL_LoadWAV(MusicPath.ptr, &spec, &wavptr, &wavsize) is null)
    {
        log.critical("failed to open file `", MusicPath, "`");
        return 1;
    }

    spec.callback = &my_audio_callback;
    spec.userdata = null;
    audio = wavptr[0..wavsize];

    // Get all available audio devices
    auto devices = sdl2.getAudioDevices();

    // Open the first audio device
    auto device = new SDL2AudioDevice(sdl2, devices[0], 0, &spec, &have, SDL_AUDIO_ALLOW_ANY_CHANGE);

    /* Start playing */
    device.play;

    // wait until we're don't playing
    while ( audio.length > 0 )
    {
        import core.thread;
        Thread.sleep(100.msecs);
    }

    SDL_FreeWAV(wavptr);

    return 0;
}
