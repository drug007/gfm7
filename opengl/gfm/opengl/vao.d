module gfm.opengl.vao;

import std.string;

import derelict.opengl;

import gfm.opengl.opengl;

/// OpenGL Vertex Array Object wrapper.
final class GLVAO
{
    public
    {
        /// Creates a VAO.
        /// Throws: $(D OpenGLException) on error.
        this()
        {
            glGenVertexArrays(1, &_handle);
            runtimeCheck();
            _initialized = true;
        }

        /// Releases the OpenGL VAO resource.
        ~this()
        {
            if (_initialized)
            {
                debug ensureNotInGC("GLVAO");
                glDeleteVertexArrays(1, &_handle);
                _initialized = false;
            }
        }

        /// Uses this VAO.
        /// Throws: $(D OpenGLException) on error.
        void bind()
        {
            glBindVertexArray(_handle);
            runtimeCheck();
        }

        /// Unuses this VAO.
        /// Throws: $(D OpenGLException) on error.
        void unbind()
        {
            glBindVertexArray(0);
            runtimeCheck();
        }

        /// Returns: Wrapped OpenGL resource handle.
        GLuint handle() pure const nothrow
        {
            return _handle;
        }
    }

    private
    {
        GLuint _handle;
        bool _initialized;
    }
}
