module gfm.sdl2.sdlimage;

import std.string;

import bindbc.sdl,
       sdl_image;

import std.experimental.logger;

import gfm.sdl2.sdl,
       gfm.sdl2.surface;

/// Load images using SDL_image, a SDL companion library able to load various image formats.
final class SDLImage
{
    public
    {
        /// Loads the SDL_image library.
        /// SDL must be already initialized.
        /// Throws: $(D SDL2Exception) on error.
        this(SDL2 sdl2, int flags = IMG_INIT_JPG | IMG_INIT_PNG | IMG_INIT_TIF | IMG_INIT_WEBP)
        {
            _sdl2 = sdl2; // force loading of SDL first
            _logger = sdl2._logger;
            _SDLImageInitialized = false;

            auto ret = loadSDLImage();
            if(ret < sdlImageSupport)
            {
                if(ret == SDLImageSupport.noLibrary)
                    throwSDL2ImageException("SDL Image shared library failed to load");
                else if(ret == SDLImageSupport.badLibrary)
                    // One or more symbols failed to load. The likely cause is that the
                    // shared library is for a lower version than bindbc-sdl was configured
                    // to load (via SDL_201, SDL_202, etc.)
                    throwSDL2ImageException("One or more symbols of SDL Image shared library failed to load");
                throwSDL2ImageException("The version of the SDL Image library on your system is too low. Please upgrade.");
            }

            int inited = IMG_Init(flags);
            _SDLImageInitialized = true;
        }

        /// Releases the SDL resource.
        ~this()
        {
            if (_SDLImageInitialized)
            {
                debug ensureNotInGC("SDLImage");
                _SDLImageInitialized = false;
                IMG_Quit();
            }
        }

        /// Load an image.
        /// Returns: A SDL surface with loaded content.
        /// Throws: $(D SDL2Exception) on error.
        SDL2Surface load(string path)
        {
            immutable(char)* pathz = toStringz(path);
            SDL_Surface* surface = IMG_Load(pathz);
            if (surface is null)
                throwSDL2ImageException("IMG_Load");

            return new SDL2Surface(_sdl2, surface, SDL2Surface.Owned.YES);
        }
    }

    private
    {
        Logger _logger;
        SDL2 _sdl2;
        bool _SDLImageInitialized;

        void throwSDL2ImageException(string callThatFailed)
        {
            string message = format("%s failed: %s", callThatFailed, getErrorString());
            throw new SDL2Exception(message);
        }

        const(char)[] getErrorString()
        {
            return fromStringz(IMG_GetError());
        }
    }
}
