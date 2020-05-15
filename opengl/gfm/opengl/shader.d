module gfm.opengl.shader;

import std.string,
       std.conv,
       std.experimental.logger;

import bindbc.opengl;

import gfm.opengl.opengl;


/// OpenGL Shader wrapper.
final class GLShader
{
    public
    {
        /// Creates a shader devoid of source code.
        /// Throws: $(D OpenGLException) on error.
        this(GLenum shaderType)
        {
            _shader = glCreateShader(shaderType);
            if (_shader == 0)
                throw new OpenGLException("glCreateShader failed");
            _initialized = true;
        }

        /// Creates a shader with source code and compiles it.
        /// Throws: $(D OpenGLException) on error.
        this(GLenum shaderType, string[] lines)
        {
            this(shaderType);
            load(lines);
            compile();
        }

        /// Releases the OpenGL shader resource.
        ~this()
        {
            if (_initialized)
            {
                debug ensureNotInGC("GLShader");
                glDeleteShader(_shader);
                _initialized = false;
            }
        }

        /// Load source code for this shader.
        /// Throws: $(D OpenGLException) on error.
        void load(string[] lines)
        {
            size_t lineCount = lines.length;

            auto lengths = new GLint[lineCount];
            auto addresses = new immutable(GLchar)*[lineCount];
            auto localLines = new string[lineCount];

            for (size_t i = 0; i < lineCount; ++i)
            {
                localLines[i] = lines[i] ~ "\n";
                lengths[i] = cast(GLint)(localLines[i].length);
                addresses[i] = localLines[i].ptr;
            }

            glShaderSource(_shader,
                           cast(GLint)lineCount,
                           cast(const(char)**)addresses.ptr,
                           cast(const(int)*)(lengths.ptr));
            runtimeCheck();
        }

        /// Compile this OpenGL shader.
        /// Throws: $(D OpenGLException) on compilation error.
        void compile()
        {
            glCompileShader(_shader);
            runtimeCheck();

            // print info log
            const(char)[] infoLog = getInfoLog();
            if (infoLog != null && _logger)
                _logger.info(infoLog);

            GLint compiled;
            glGetShaderiv(_shader, GL_COMPILE_STATUS, &compiled);

            if (compiled != GL_TRUE)
                throw new OpenGLException("shader did not compile");
        }

        /// Gets the compiling report.
        /// Returns: Log output of the GLSL compiler. Can return null!
        /// Throws: $(D OpenGLException) on error.
        const(char)[] getInfoLog()
        {
            GLint logLength;
            glGetShaderiv(_shader, GL_INFO_LOG_LENGTH, &logLength);
            if (logLength <= 0) // "If shader has no information log, a value of 0 is returned."
                return null;

            char[] log = new char[logLength];
            GLint dummy;
            glGetShaderInfoLog(_shader, logLength, &dummy, log.ptr);
            runtimeCheck();
            return fromStringz(log.ptr);
        }

        /// Sets a logger for the program. That allows additional output
        /// besides error reporting.
        void logger(Logger l) pure nothrow { _logger = l; }
    }

    package
    {
        GLuint _shader;
    }

    private
    {
        Logger _logger;
        bool _initialized;
    }
}


