module gfm.opengl.renderbuffer;

import std.string;

import derelict.opengl;

import gfm.math.funcs,
       gfm.opengl.opengl;

/// OpenGL Renderbuffer wrapper.
final class GLRenderBuffer
{
    public
    {
        /// <p>Creates an OpenGL renderbuffer.</p>
        /// <p>If asking for a multisampled render buffer fails,
        /// a non multisampled buffer will be created instead.</p>
        /// Throws: $(D OpenGLException) if creation failed.
        this(GLenum internalFormat, int width, int height, int samples = 0)
        {
            glGenRenderbuffers(1, &_handle);
            runtimeCheck();

            use();
            scope(exit) unuse();
            if (samples > 1)
            {
                // fallback to non multisampled
                if (glRenderbufferStorageMultisample is null)
                {
                    if (_logger)
                        _logger.warningf("render-buffer multisampling is not supported, fallback to non-multisampled");
                    goto non_mutisampled;
                }

                int maxSamples;
                glGetIntegerv(GL_MAX_SAMPLES, &maxSamples);
                if (maxSamples < 1)
                    maxSamples = 1;

                // limit samples to what is supported on this machine
                if (samples >= maxSamples)
                {
                    int newSamples = clamp(samples, 0, maxSamples - 1);
                    if (_logger)
                        _logger.warningf(format("implementation does not support %s samples, fallback to %s samples", samples, newSamples));
                    samples = newSamples;
                }

                try
                {
                    glRenderbufferStorageMultisample(GL_RENDERBUFFER, samples, internalFormat, width, height);
                }
                catch(OpenGLException e)
                {
                    if (_logger)
                        _logger.warning(e.msg);
                    goto non_mutisampled; // fallback to non multisampled
                }
            }
            else
            {
            non_mutisampled:
                glRenderbufferStorage(GL_RENDERBUFFER, internalFormat, width, height);
                runtimeCheck();
            }

            _initialized = true;
        }

        /// Releases the OpenGL renderbuffer resource.
        ~this()
        {
            if (_initialized)
            {
                debug ensureNotInGC("GLRenderer");
                _initialized = false;
                glDeleteRenderbuffers(1, &_handle);
            }
        }

        /// Binds this renderbuffer.
        /// Throws: $(D OpenGLException) on error.
        void use()
        {
            glBindRenderbuffer(GL_RENDERBUFFER, _handle);
            runtimeCheck();
        }

        /// Unbinds this renderbuffer.
        /// Throws: $(D OpenGLException) on error.
        void unuse()
        {
            glBindRenderbuffer(GL_RENDERBUFFER, 0);
            runtimeCheck();
        }

        /// Returns: Wrapped OpenGL resource handle.
        GLuint handle() pure const nothrow
        {
            return _handle;
        }

        /// Sets a logger for the program. That allows additional output
        /// besides error reporting.
        void logger(Logger l) pure nothrow { _logger = l; }
    }

    package
    {
        GLuint _handle;
    }

    private
    {
        import std.experimental.logger : Logger;

        GLenum _format;
        GLenum _type;
        bool _initialized;
        Logger _logger;
    }
}
