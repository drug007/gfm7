[![Testsuite](https://github.com/drug007/gfm7/actions/workflows/main.yml/badge.svg)](https://github.com/drug007/gfm7/actions/workflows/main.yml)

GFM7 is a fork of [gfm](https://github.com/d-gamedev-team/gfm) v.7 to keep functionality that has been removed in gfm v.8

# IMPORTANT: Bolt-on replacement for gfm v.7.0.8 is gfm7 v0.9.9
Unfortunately I added tag `v1.0.0` for another version of gfm7 that is non compatible to vanilla gfm v7. So I added tag `v0.9.9` for vanilla version of gfm v7.0.8

gfm7 v1.0.0 has breaking change - the only difference to original gfm is that OpenGL related classes ctors do not take OpenGL as its first parameters because it makes their using simpler. So instead of:
```D
	auto program = new GLProgram(gl, shaderSources);
```
you can write:
```D
	auto program = new GLProgram(shaderSources);
```

All error reporting is fully functionable, excluding some log messages (not errors). `GLRenderBuffer`, `GLShader`, `GLUniform`, `GLAttribute`, `GLProgram` have method `logger(Logger l)` that allows to set a logger to get functionality fully equal to original gfm v.7:
```D
	auto program = new GLProgram(shaderSources);
	program.logger = yourLogger;
```

## License

Public Domain (Unlicense).
