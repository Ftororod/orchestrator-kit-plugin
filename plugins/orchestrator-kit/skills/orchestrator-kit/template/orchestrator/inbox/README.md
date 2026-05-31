# inbox/

Respuestas de los ejecutores, una por archivo, por code:

    inbox/<code>/<YYYY-MM-DD>_<sprint-slug>_response.md

Los ejecutores escriben aqui. El orquestador revisa este directorio al arrancar
cada sesion (paso 4 del ritual de arranque), procesa las respuestas, actualiza
el state y luego archiva el par en `../prompts/completed/<code>/`.
